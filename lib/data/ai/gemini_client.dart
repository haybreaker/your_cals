import 'dart:convert';

import 'package:dio/dio.dart';

import '../../domain/food.dart';
import '../../domain/nutriments.dart';

class GeminiException implements Exception {
  GeminiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// One food item recognized in a meal.
class DetectedItem {
  DetectedItem({
    required this.name,
    required this.grams,
    required this.confidence,
    required this.per100,
    this.alternatives = const [],
  });

  final String name;
  final double grams;
  final double confidence; // 0..1
  final Nutriments per100;

  /// Other plausible identifications the model considered.
  final List<String> alternatives;

  Nutriments get totals => per100.forGrams(grams);

  Food toAiFood() => Food(
    id: 'ai:${name.toLowerCase().trim()}:${DateTime.now().microsecondsSinceEpoch}',
    name: _titleCase(name),
    source: FoodSource.ai,
    per100: per100,
    defaultGrams: grams,
  );

  static String _titleCase(String s) => s.isEmpty
      ? s
      : s
            .split(' ')
            .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
            .join(' ');
}

class MealAnalysis {
  MealAnalysis({required this.isFood, required this.items});
  final bool isFood;
  final List<DetectedItem> items;
}

/// One dated weigh-in extracted from a weight-graph screenshot.
class WeightPoint {
  const WeightPoint({required this.date, required this.weightKg});

  /// Calendar day (time stripped).
  final DateTime date;
  final double weightKg;
}

/// Nutrition facts read off a label photo (NIP panel).
/// All macros are normalized per 100 g/ml, matching [Nutriments].
class LabelNutrition {
  const LabelNutrition({
    this.productName,
    this.brand,
    this.servingSize,
    this.servingUnit,
    this.isLiquid,
    this.barcode,
    required this.per100,
  });

  final String? productName;
  final String? brand;
  final double? servingSize;
  final String? servingUnit; // 'g' | 'ml'
  final bool? isLiquid;
  final String? barcode;
  final Nutriments per100;

  bool get isEmpty => per100.kcal <= 0;
}

class _RankedModel {
  const _RankedModel(this.name, this.rank);
  final String name;
  final int rank;
}

/// Gemini over REST with strict JSON response schema.
///
/// Model IDs get retired frequently (the 2.5 family died mid-2026), so this
/// client self-heals: preferred aliases are tried in order; on 404/503 it
/// lists the key's models, picks the newest GA flash model supporting
/// generateContent, caches it, and retries. Network vs API errors are
/// reported distinctly.
class GeminiClient {
  GeminiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              // Photo analysis on reasoning-capable flash models can run
              // well past 60 s before the first byte arrives.
              receiveTimeout: const Duration(seconds: 120),
            ),
          );

  final Dio _dio;

  static const endpoint = 'https://generativelanguage.googleapis.com/v1beta';

  /// Tried in order before discovery kicks in. `gemini-flash-latest` is the
  /// alias hot-swapped to the newest flash release (breaking changes get a
  /// 2-week notice); 3.8 is the newest stable flash, 3.6 the previous
  /// generation (ai.google.dev/gemini-api/docs/models, checked 2026-10-23).
  static const preferredModels = [
    'gemini-flash-latest',
    'gemini-3.8-flash',
    'gemini-3.6-flash',
  ];

  int _prefIndex = 0;
  String? _discovered;

  /// Dedupes concurrent model-discovery network calls: Dart is
  /// single-threaded so `_prefIndex++` itself is atomic, but two parallel
  /// `_generate` loops could each fire a `models.list` request and last-win
  /// on `_discovered`. Sharing one in-flight future keeps them converged
  /// on the same result without extra quota burn.
  Future<String?>? _discoveryInFlight;
  String? _discoveryInFlightKey;

  /// Why the last discovery attempt failed (bad key, quota, …) — surfaced
  /// in the caller's error instead of being swallowed.
  String? _discoveryFailureReason;

  Future<String?> _discoverOnce(String apiKey) {
    final inFlight = _discoveryInFlight;
    if (inFlight != null && _discoveryInFlightKey == apiKey) return inFlight;
    late final Future<String?> fut;
    fut = discoverModel(apiKey).whenComplete(() {
      if (identical(_discoveryInFlight, fut)) {
        _discoveryInFlight = null;
        _discoveryInFlightKey = null;
      }
    });
    _discoveryInFlight = fut;
    _discoveryInFlightKey = apiKey;
    return fut;
  }

  /// User-selected model (Settings). When set, it is used directly and
  /// discovery/fallback only happens if it 404s (retired model).
  String? _override;

  /// Sentinel meaning "auto-discover the newest flash model".
  static const autoModel = 'auto';

  /// Persisted model preference: a concrete model id or [autoModel].
  String get modelPreference => _override ?? autoModel;

  set modelPreference(String? value) {
    _override = (value == null || value.isEmpty || value == autoModel)
        ? null
        : value;
    // Forget in-memory discovery so the new preference takes effect
    // immediately on the next call.
    _discovered = _override;
    _prefIndex = 0;
  }

  String get currentModel =>
      _override ??
      _discovered ??
      preferredModels[_prefIndex.clamp(0, preferredModels.length - 1)];

  bool get hasOverride => _override != null;

  void resetModelCache() {
    if (_override != null) {
      _discovered = _override;
    } else {
      _discovered = null;
      _prefIndex = 0;
    }
  }

  // ─── Public API ──────────────────────────────────────────────────────────

  Future<MealAnalysis> analyzePhoto({
    required List<int> jpegBytes,
    required String apiKey,
  }) {
    return _generate(
      apiKey: apiKey,
      body: {
        'contents': [
          {
            'parts': [
              {'text': _photoPrompt},
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Encode(jpegBytes),
                },
              },
            ],
          },
        ],
        'generationConfig': _generationConfig(),
      },
    );
  }

  Future<MealAnalysis> analyzeText({
    required String description,
    required String apiKey,
  }) {
    return _generate(
      apiKey: apiKey,
      body: {
        'contents': [
          {
            'parts': [
              {'text': _textPrompt(description)},
            ],
          },
        ],
        'generationConfig': _generationConfig(),
      },
    );
  }

  /// Reads a weight-tracker graph screenshot (Lose It, Apple Health…)
  /// and returns the dated weigh-ins visible in it.
  Future<List<WeightPoint>> analyzeWeightGraph({
    required List<int> bytes,
    required String mimeType,
    required String apiKey,
  }) async {
    final data = await _postJson(
      apiKey: apiKey,
      body: {
        'contents': [
          {
            'parts': [
              {'text': _weightPrompt(DateTime.now())},
              {
                'inline_data': {
                  'mime_type': mimeType,
                  'data': base64Encode(bytes),
                },
              },
            ],
          },
        ],
        'generationConfig': _weightConfig(),
      },
    );
    return parseWeightPoints(data);
  }

  /// Reads an AU/NZ Nutrition Information Panel photo and returns
  /// per-100g facts. Used as the AI fallback when on-device OCR finds
  /// nothing (bad light, angle, glare). Throws [GeminiException] with a
  /// user-facing message when no usable panel is visible.
  Future<LabelNutrition> analyzeNutritionLabel({
    required List<int> bytes,
    required String mimeType,
    required String apiKey,
  }) async {
    final data = await _postJson(
      apiKey: apiKey,
      body: {
        'contents': [
          {
            'parts': [
              {'text': _labelPrompt},
              {
                'inline_data': {
                  'mime_type': mimeType,
                  'data': base64Encode(bytes),
                },
              },
            ],
          },
        ],
        'generationConfig': _labelConfig(),
      },
    );
    return parseLabelNutrition(data);
  }

  /// Google's own error text for the failed call — the REST body is
  /// `{error: {message: ...}}`. REST quirk: `:generateContent` answers a
  /// bad key with a 404 and an EMPTY body (models.list answers 400), so
  /// the fallback keeps the status code/type. Everything that used to be
  /// swallowed (timeout, 400, discovery) now carries its real cause.
  static String _apiError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final err = data['error'];
      if (err is Map && err['message'] is String) {
        final msg = (err['message'] as String).trim();
        if (msg.isNotEmpty) return msg;
      }
    }
    return '${e.response?.statusCode ?? e.type.name}';
  }

  /// One-line root cause for connection-level failures (SocketException,
  /// HandshakeException, closed mid-transfer…) — no more blind "network".
  static String _networkCause(DioException e) {
    final text = '${e.error ?? e}'.trim();
    return text.length > 90 ? '${text.substring(0, 90)}…' : text;
  }

  // ─── Core request loop ──────────────────────────────────────────────────

  Future<MealAnalysis> _generate({
    required String apiKey,
    required Map<String, dynamic> body,
  }) async {
    final maxAttempts = preferredModels.length + 3;
    Object? lastError;
    var bodyByAttempt = body;
    var slowRetries = 0;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final res = await _dio.post<Map<String, dynamic>>(
          '$endpoint/models/$currentModel:generateContent',
          queryParameters: {'key': apiKey},
          data: bodyByAttempt,
        );
        return parseResponse(res);
      } on DioException catch (e) {
        lastError = e;
        final code = e.response?.statusCode;
        final isNetwork =
            code == null &&
            (e.type == DioExceptionType.connectionError ||
                e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.unknown);
        // Timeouts are NOT "no internet": heavy reasoning models can
        // legitimately exceed the window. Retry once, then say it plainly
        // instead of telling the user to check their wifi.
        final isTimeout =
            code == null &&
            (e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.sendTimeout);

        if (isNetwork && e.error is! FormatException) {
          throw GeminiException(
            'No internet connection (${_networkCause(e)}) — '
            'check your network and try again.',
          );
        }
        if (isTimeout) {
          if (slowRetries++ >= 1) {
            throw GeminiException(
              'Gemini took too long to respond — try again.',
            );
          }
          continue;
        }
        if (code == 400) {
          // Could be the model rejecting thinkingConfig — retry once
          // without it; otherwise surface Google's own error text (a 400
          // is NOT necessarily a bad key).
          if (bodyByAttempt['generationConfig'] case final cfg
              when cfg is Map && cfg.containsKey('thinkingConfig')) {
            cfg.remove('thinkingConfig');
            continue;
          }
          throw GeminiException('Gemini rejected the request: ${_apiError(e)}');
        }
        if (code == 403) {
          throw GeminiException('Invalid Gemini API key — check Settings.');
        }
        if (code == 429) {
          throw GeminiException(
            'Gemini rate limit reached — wait a minute and retry.',
          );
        }

        if (code == 404 || code == 503) {
          // Model retired/unavailable: advance alias, then auto-discover.
          if (_override != null) {
            // User-chosen model is gone — fall back to discovery, but keep
            // the preference in case it returns.
            final found = await _discoverOnce(apiKey);
            if (found != null) {
              _discovered = found;
              continue;
            }
            throw GeminiException(
              'Model "$_override" is unavailable for your key — pick another in Settings.',
            );
          }
          if (_discovered == null && _prefIndex < preferredModels.length - 1) {
            _prefIndex++;
            continue;
          }
          final found = await _discoverOnce(apiKey);
          if (found != null && found != currentModel) {
            _discovered = found;
            continue;
          }
          throw GeminiException(
            'Your Gemini key has no compatible vision model available.'
            '${_discoveryFailureReason == null ? '' : ' ($_discoveryFailureReason)'}',
          );
        }

        if (code != null && code >= 500) continue; // transient
        throw GeminiException('Gemini error (${_apiError(e)}).');
      } on GeminiException {
        rethrow;
      } catch (e) {
        lastError = e;
        break;
      }
    }
    throw GeminiException('Could not reach Gemini (${_describe(lastError)}).');
  }

  static String _describe(Object? e) =>
      e is DioException ? _apiError(e) : 'unexpected response';

  /// Raw JSON POST with the same model fallback/discovery loop as
  /// [_generate]. Non-meal callers (weight import) parse the payload
  /// themselves via [parseWeightPoints].
  Future<Map<String, dynamic>> _postJson({
    required String apiKey,
    required Map<String, dynamic> body,
  }) async {
    final maxAttempts = preferredModels.length + 3;
    Object? lastError;
    var bodyByAttempt = body;
    var slowRetries = 0;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final res = await _dio.post<Map<String, dynamic>>(
          '$endpoint/models/$currentModel:generateContent',
          queryParameters: {'key': apiKey},
          data: bodyByAttempt,
        );
        return res.data ?? const {};
      } on DioException catch (e) {
        lastError = e;
        final code = e.response?.statusCode;
        final isNetwork =
            code == null &&
            (e.type == DioExceptionType.connectionError ||
                e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.unknown);
        final isTimeout =
            code == null &&
            (e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.sendTimeout);

        if (isNetwork && e.error is! FormatException) {
          throw GeminiException(
            'No internet connection (${_networkCause(e)}) — '
            'check your network and try again.',
          );
        }
        if (isTimeout) {
          if (slowRetries++ >= 1) {
            throw GeminiException(
              'Gemini took too long to respond — try again.',
            );
          }
          continue;
        }
        if (code == 400) {
          if (bodyByAttempt['generationConfig'] case final cfg
              when cfg is Map && cfg.containsKey('thinkingConfig')) {
            cfg.remove('thinkingConfig');
            continue;
          }
          throw GeminiException('Gemini rejected the request: ${_apiError(e)}');
        }
        if (code == 403) {
          throw GeminiException('Invalid Gemini API key — check Settings.');
        }
        if (code == 429) {
          throw GeminiException(
            'Gemini rate limit reached — wait a minute and retry.',
          );
        }

        if (code == 404 || code == 503) {
          if (_override != null) {
            final found = await _discoverOnce(apiKey);
            if (found != null) {
              _discovered = found;
              continue;
            }
            throw GeminiException(
              'Model "$_override" is unavailable for your key — pick another in Settings.',
            );
          }
          if (_discovered == null && _prefIndex < preferredModels.length - 1) {
            _prefIndex++;
            continue;
          }
          final found = await _discoverOnce(apiKey);
          if (found != null && found != currentModel) {
            _discovered = found;
            continue;
          }
          throw GeminiException(
            'Your Gemini key has no compatible vision model available.'
            '${_discoveryFailureReason == null ? '' : ' ($_discoveryFailureReason)'}',
          );
        }

        if (code != null && code >= 500) continue; // transient
        throw GeminiException('Gemini error (${_apiError(e)}).');
      } catch (e) {
        lastError = e;
        break;
      }
    }
    throw GeminiException('Could not reach Gemini (${_describe(lastError)}).');
  }

  /// Lists models available to this key; picks newest GA flash model that
  /// supports generateContent (skips -preview, -lite, image/tts/embeddings).
  Future<String?> discoverModel(String apiKey) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$endpoint/models',
        queryParameters: {'key': apiKey, 'pageSize': '1000'},
      );
      return pickBestModel(res.data?['models'] as List?);
    } catch (e) {
      // No longer silent: the reason (bad key, quota, blocked region)
      // surfaces in the caller's "no compatible model" message.
      _discoveryFailureReason = e is DioException ? _apiError(e) : '$e';
      return null;
    }
  }

  /// All eligible vision-capable flash models for this key, best first.
  /// Feeds the Settings model picker — new releases (e.g. a fresh
  /// "gemini-3.8-flash") appear here without an app update.
  Future<List<String>> listModels(String apiKey) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '$endpoint/models',
      queryParameters: {'key': apiKey, 'pageSize': '1000'},
    );
    final models = res.data?['models'] as List? ?? const [];
    final eligible = <_RankedModel>[];
    for (final raw in models) {
      final m = (raw as Map).cast<String, dynamic>();
      final name = ((m['name'] as String?) ?? '').split('/').last;
      if (!_isEligibleFlash(name)) continue;
      final methods = ((m['supportedGenerationMethods'] as List?) ?? const [])
          .map((e) => '$e')
          .toList();
      if (!methods.contains('generateContent')) continue;
      eligible.add(_RankedModel(name, modelRank(name)));
    }
    eligible.sort((a, b) => b.rank.compareTo(a.rank));
    return eligible.map((e) => e.name).toList();
  }

  /// Pure ranking logic (unit tested).
  static String? pickBestModel(List<dynamic>? models) {
    if (models == null) return null;
    String? best;
    const bestRankSentinel = -0x7fffffffffffffff;
    var bestRank = bestRankSentinel;
    for (final raw in models) {
      final m = (raw as Map).cast<String, dynamic>();
      final name = ((m['name'] as String?) ?? '').split('/').last;
      if (!_isEligibleFlash(name)) continue;
      final methods = ((m['supportedGenerationMethods'] as List?) ?? const [])
          .map((e) => '$e')
          .toList();
      if (!methods.contains('generateContent')) continue;
      final rank = modelRank(name);
      if (rank > bestRank || best == null) {
        bestRank = rank;
        best = name;
      }
    }
    return best;
  }

  static bool _isEligibleFlash(String name) {
    if (!name.contains('flash')) return false;
    if (name.contains('-lite') || name.contains('-image')) return false;
    if (name.contains('embedding') ||
        name.contains('tts') ||
        name.contains('robotics') ||
        name.contains('live') ||
        name.contains('native-audio')) {
      return false;
    }
    return true;
  }

  /// Higher rank = better candidate. Any GA release beats any preview
  /// (previews get shut down — that's what retired the 2.x family), then
  /// higher version wins.
  static int modelRank(String name) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(name);
    final version = match == null ? 0.0 : double.tryParse(match.group(1)!) ?? 0;
    return (version * 10).round() - (name.contains('-preview') ? 1000 : 0);
  }

  /// Re-identifies ONE item after a user correction ("it was actually X").
  /// Returns a fresh [DetectedItem]; portion re-estimated against the photo.
  Future<DetectedItem> correctItem({
    required List<int> jpegBytes,
    required String originalName,
    required String userCorrection,
    required String apiKey,
  }) {
    final body = {
      'contents': [
        {
          'parts': [
            {
              'text':
                  '''
You are an expert sports dietitian. A photo of a meal was analysed and one
item was identified as "$originalName". The user says it was actually:
"$userCorrection".

Re-analyse the photo for THIS item only:
- confirm the user's identification (or the closest sensible match)
- re-estimate the portion grams from visual cues (plate ~26 cm, cutlery)
- give nutrition PER 100 GRAMS of the item
- include 2-3 alternative identifications

Respond ONLY with JSON matching the schema, with exactly ONE item.''',
            },
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Encode(jpegBytes),
              },
            },
          ],
        },
      ],
      'generationConfig': _generationConfig(),
    };
    return _generateSingle(apiKey: apiKey, body: body);
  }

  Future<DetectedItem> _generateSingle({
    required String apiKey,
    required Map<String, dynamic> body,
  }) async {
    final maxAttempts = preferredModels.length + 3;
    var bodyByAttempt = body;
    var slowRetries = 0;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final res = await _dio.post<Map<String, dynamic>>(
          '$endpoint/models/$currentModel:generateContent',
          queryParameters: {'key': apiKey},
          data: bodyByAttempt,
        );
        final analysis = parseResponse(res);
        if (analysis.items.isEmpty) {
          throw GeminiException('Could not re-analyse that item.');
        }
        return analysis.items.first;
      } on GeminiException {
        rethrow;
      } on DioException catch (e) {
        final code = e.response?.statusCode;
        final isTimeout =
            e.response == null &&
            (e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.sendTimeout);
        if (isTimeout) {
          if (slowRetries++ >= 1) {
            throw GeminiException(
              'Gemini took too long to respond — try again.',
            );
          }
          continue;
        }
        if (code == 400) {
          if (bodyByAttempt['generationConfig'] case final cfg
              when cfg is Map && cfg.containsKey('thinkingConfig')) {
            cfg.remove('thinkingConfig');
            continue;
          }
          throw GeminiException('Gemini rejected the request: ${_apiError(e)}');
        }
        if (code == 403) {
          throw GeminiException('Invalid Gemini API key — check Settings.');
        }
        if (code == 404 || code == 503) {
          if (_override != null) {
            final found = await _discoverOnce(apiKey);
            if (found != null) {
              _discovered = found;
              continue;
            }
          } else if (_discovered == null &&
              _prefIndex < preferredModels.length - 1) {
            _prefIndex++;
            continue;
          } else {
            final found = await _discoverOnce(apiKey);
            if (found != null && found != currentModel) {
              _discovered = found;
              continue;
            }
          }
        }
        if (code != null && code >= 500) continue;
        throw GeminiException('Gemini error (${_apiError(e)}).');
      }
    }
    throw GeminiException('Could not reach Gemini.');
  }

  // ─── Prompt / schema / parsing ──────────────────────────────────────────

  Map<String, dynamic> _generationConfig({bool fast = true}) => {
    'temperature': 0.2,
    'response_mime_type': 'application/json',
    // Skip long "thinking" phases — 3.x flash models accept a zero
    // budget for big latency wins. Older models just ignore this.
    if (fast) 'thinkingConfig': {'thinkingBudget': 0},
    'response_schema': {
      'type': 'object',
      'properties': {
        'is_food': {'type': 'boolean'},
        'items': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'name': {'type': 'string'},
              'estimated_grams': {'type': 'number'},
              'confidence': {'type': 'number'},
              'kcal_per_100g': {'type': 'number'},
              'protein_g_per_100g': {'type': 'number'},
              'carbs_g_per_100g': {'type': 'number'},
              'fat_g_per_100g': {'type': 'number'},
              'alternatives': {
                'type': 'array',
                'items': {'type': 'string'},
              },
            },
            'required': [
              'name',
              'estimated_grams',
              'confidence',
              'kcal_per_100g',
              'protein_g_per_100g',
              'carbs_g_per_100g',
              'fat_g_per_100g',
            ],
          },
        },
      },
      'required': ['is_food', 'items'],
    },
  };

  static const _photoPrompt = '''
You are an expert sports dietitian analysing a photo of a meal for a calorie tracker.

Rules:
- Identify EVERY distinct edible item, including drinks, sauces, oils and garnishes.
- Estimate portion grams using visual cues (plate ~26 cm diameter, cutlery, packaging).
- Account for hidden calories: cooking oil, butter, dressings, sugar in drinks.
- For each item give nutrition PER 100 GRAMS of that item (not the whole portion).
- Break mixed dishes into components when visible.
- For each item include 2-3 alternative identifications you considered (things it could easily be mistaken for).
- If the image contains no food, set is_food=false and return an empty items list.

Respond ONLY with JSON matching the provided schema.''';

  static String _textPrompt(String description) =>
      '''
You are an expert dietitian estimating nutrition for a calorie tracker.
Meal description from user: "$description"

For each distinct food item estimate typical consumed grams and nutrition
PER 100 GRAMS. Include cooking oils and sauces implied by the description.
Respond ONLY with JSON matching the schema (is_food=true).''';

  Map<String, dynamic> _weightConfig() => {
    'temperature': 0.2,
    'response_mime_type': 'application/json',
    'thinkingConfig': {'thinkingBudget': 0},
    'response_schema': {
      'type': 'object',
      'properties': {
        'points': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'date': {
                'type': 'string',
                'description': 'Weigh-in date as yyyy-MM-dd',
              },
              'weight_kg': {'type': 'number'},
            },
            'required': ['date', 'weight_kg'],
          },
        },
      },
      'required': ['points'],
    },
  };

  Map<String, dynamic> _labelConfig() => {
    'temperature': 0.1,
    'response_mime_type': 'application/json',
    'thinkingConfig': {'thinkingBudget': 0},
    'response_schema': {
      'type': 'object',
      'properties': {
        'has_panel': {'type': 'boolean'},
        'product_name': {'type': 'string'},
        'brand': {'type': 'string'},
        'serving_size': {'type': 'number'},
        'serving_unit': {'type': 'string'},
        'is_liquid': {'type': 'boolean'},
        'barcode': {'type': 'string'},
        'energy_kcal_per_100g': {'type': 'number'},
        'protein_g_per_100g': {'type': 'number'},
        'fat_g_per_100g': {'type': 'number'},
        'sat_fat_g_per_100g': {'type': 'number'},
        'carbs_g_per_100g': {'type': 'number'},
        'sugars_g_per_100g': {'type': 'number'},
        'fiber_g_per_100g': {'type': 'number'},
        'sodium_mg_per_100g': {'type': 'number'},
      },
      'required': ['has_panel', 'energy_kcal_per_100g'],
    },
  };

  static const _labelPrompt = '''
You are reading an Australian Nutrition Information Panel (NIP) label photo for a calorie tracker.

Rules:
- Find the NIP table ("Per 100g" / "Per 100mL" and "Per serve" columns). Prefer the Per-100 column; when only Per-serve is visible, scale to per-100 using the serving size.
- Energy: report KCAL per 100g. When the label shows kJ only, convert (kcal = kJ / 4.184).
- Report macros PER 100g/ml: protein, fat, saturated fat, carbs, sugars, fibre, sodium (mg per 100g).
- Also extract product name, brand, serving size + unit (g|ml), whether liquid, and any visible barcode digits.
- If no nutrition panel is visible, set has_panel=false and energy to 0.

Respond ONLY with JSON matching the provided schema.''';

  static String _weightPrompt(DateTime today) {
    final stamp =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return '''
You are reading a weight-tracker graph screenshot (e.g. Lose It, Apple Health, Renpho, Withings).
Extract EVERY dated weigh-in visible: axis labels, data-point labels, table rows, min/max annotations.

Rules:
- Today is $stamp. Resolve relative labels ("3 months ago", "last Monday") against it.
- Cover the ENTIRE visible range (years if shown) — every dated point matters, smoothing happens later.
- If a date is ambiguous, use the most recent matching date on or before today.
- Round weights to 0.1 kg. Ignore goal/target lines — only real weigh-ins.
- If no weigh-ins are visible, return {"points": []}.

Respond ONLY with JSON matching the provided schema.''';
  }

  MealAnalysis parseResponse(Response<Map<String, dynamic>?> res) {
    final candidates = res.data?['candidates'] as List?;
    final parts = ((candidates?[0] as Map?)?['content'] as Map?)?['parts'];
    if (parts is! List || parts.isEmpty) {
      // Safety-refusal or empty candidate — treat as "not food".
      return MealAnalysis(isFood: false, items: []);
    }
    final raw = ((parts.first as Map)['text'] as String?) ?? '';
    try {
      return _parseAnalysis(raw);
    } catch (_) {
      throw GeminiException('Unexpected AI response format.');
    }
  }

  static MealAnalysis _parseAnalysis(String raw) {
    final json = jsonDecode(_stripFences(raw)) as Map<String, dynamic>;
    final itemsJson = (json['items'] as List?) ?? const [];
    final items = itemsJson.map(_parseItem).whereType<DetectedItem>().toList();
    return MealAnalysis(
      isFood: json['is_food'] as bool? ?? items.isNotEmpty,
      items: items,
    );
  }

  /// Shared fence-stripper (```json blocks) for AI JSON payloads.
  static String _stripFences(String raw) {
    var text = raw.trim();
    if (text.startsWith('```')) {
      text = text.replaceFirst(RegExp(r'^```(json)?'), '').trim();
      if (text.endsWith('```')) {
        text = text.substring(0, text.length - 3).trim();
      }
    }
    return text;
  }

  /// Parses an `analyzeWeightGraph` payload into dated weigh-ins.
  /// Defensive: drops unparseable rows, clamps absurd weights, sorts by
  /// date and dedupes to one point per day (latest wins).
  static List<WeightPoint> parseWeightPoints(Map<String, dynamic> data) {
    final candidates = data['candidates'] as List?;
    final parts = ((candidates?[0] as Map?)?['content'] as Map?)?['parts'];
    if (parts is! List || parts.isEmpty) {
      throw GeminiException('The AI returned nothing usable.');
    }
    final raw = ((parts.first as Map)['text'] as String?) ?? '';
    late final Map<String, dynamic> json;
    try {
      json = jsonDecode(_stripFences(raw)) as Map<String, dynamic>;
    } catch (_) {
      throw GeminiException('Unexpected AI response format.');
    }
    final byDay = <String, WeightPoint>{};
    for (final e in (json['points'] as List?) ?? const []) {
      final m = (e as Map?)?.cast<String, dynamic>();
      if (m == null) continue;
      final date = DateTime.tryParse('${m['date']}');
      final kg = (m['weight_kg'] as num?)?.toDouble();
      if (date == null || kg == null || kg < 20 || kg > 400) continue;
      final day = DateTime(date.year, date.month, date.day);
      byDay[_dayKey(day)] = WeightPoint(date: day, weightKg: kg);
    }
    final points = byDay.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Parses an `analyzeNutritionLabel` payload. Defensive: clamps
  /// negatives, converts absurd kJ-as-kcal slips, normalizes serving
  /// units. Throws [GeminiException] when no panel was found or energy
  /// is missing (caller shows "try again" UI).
  static LabelNutrition parseLabelNutrition(Map<String, dynamic> data) {
    final candidates = data['candidates'] as List?;
    final parts = ((candidates?[0] as Map?)?['content'] as Map?)?['parts'];
    if (parts is! List || parts.isEmpty) {
      throw GeminiException('The AI returned nothing usable.');
    }
    final raw = ((parts.first as Map)['text'] as String?) ?? '';
    late final Map<String, dynamic> json;
    try {
      json = jsonDecode(_stripFences(raw)) as Map<String, dynamic>;
    } catch (_) {
      throw GeminiException('Unexpected AI response format.');
    }
    if (json['has_panel'] == false) {
      throw GeminiException('No nutrition panel found — try a closer photo.');
    }
    double f(String key) =>
        ((json[key] as num?)?.toDouble() ?? 0).clamp(0.0, double.infinity);
    var kcal = f('energy_kcal_per_100g');
    // Model occasionally echoes kJ despite the prompt — same guard as OCR.
    if (kcal > 2000) kcal /= 4.184;
    if (kcal <= 0) {
      throw GeminiException('No nutrition panel found — try a closer photo.');
    }
    String? t(String key) {
      final v = (json[key] as String?)?.trim();
      return (v == null || v.isEmpty) ? null : v;
    }

    var servingSize = (json['serving_size'] as num?)?.toDouble();
    if (servingSize != null && (servingSize <= 0 || servingSize > 5000)) {
      servingSize = null;
    }
    var unit = t('serving_unit')?.toLowerCase();
    if (unit != null && unit != 'g' && unit != 'ml') {
      unit = (unit.contains('ml') || unit.contains('l')) ? 'ml' : 'g';
    }
    var barcode = t('barcode');
    if (barcode != null) {
      barcode = barcode.replaceAll(RegExp(r'\D'), '');
      if (barcode.length < 6) barcode = null;
    }
    final isLiquid = json['is_liquid'] as bool?;
    return LabelNutrition(
      productName: t('product_name'),
      brand: t('brand'),
      servingSize: servingSize,
      servingUnit: unit,
      isLiquid: isLiquid,
      barcode: barcode,
      per100: Nutriments(
        kcal: kcal,
        proteinG: f('protein_g_per_100g'),
        carbsG: f('carbs_g_per_100g'),
        fatG: f('fat_g_per_100g'),
        satFatG: f('sat_fat_g_per_100g'),
        sugarsG: f('sugars_g_per_100g'),
        fiberG: f('fiber_g_per_100g'),
        sodiumMg: f('sodium_mg_per_100g'),
      ),
    );
  }

  /// Condenses raw weigh-ins to the overall movement: short ranges (a
  /// dozen points or fewer) pass through untouched; longer ones collapse
  /// to one median point per calendar week (Monday). Weekly medians kill
  /// ±250g day-noise while preserving the true trend — and keep a
  /// multi-year import to a few hundred rows instead of thousands.
  static List<WeightPoint> weeklyTrend(List<WeightPoint> points) {
    if (points.length <= 12) return points;
    final buckets = <DateTime, List<double>>{};
    for (final p in points) {
      final monday = p.date.subtract(Duration(days: p.date.weekday - 1));
      final key = DateTime(monday.year, monday.month, monday.day);
      buckets.putIfAbsent(key, () => []).add(p.weightKg);
    }
    final out = buckets.entries.map((e) {
      final ws = [...e.value]..sort();
      final median = ws.length.isOdd
          ? ws[ws.length ~/ 2]
          : (ws[ws.length ~/ 2 - 1] + ws[ws.length ~/ 2]) / 2;
      return WeightPoint(date: e.key, weightKg: (median * 10).round() / 10);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
    return out;
  }

  static DetectedItem? _parseItem(dynamic e) {
    final m = (e as Map).cast<String, dynamic>();
    final name = (m['name'] as String?)?.trim();
    final kcal = (m['kcal_per_100g'] as num?)?.toDouble() ?? 0;
    if (name == null || name.isEmpty || kcal <= 0) return null;
    double f(String key) =>
        ((m[key] as num?)?.toDouble() ?? 0).clamp(0.0, double.infinity);
    final alts = ((m['alternatives'] as List?) ?? const [])
        .map((a) => '$a'.trim())
        .where((a) => a.isNotEmpty)
        .take(3)
        .toList();
    return DetectedItem(
      name: name,
      grams: ((m['estimated_grams'] as num?)?.toDouble() ?? 100).clamp(1, 3000),
      confidence: ((m['confidence'] as num?)?.toDouble() ?? 0.7).clamp(0, 1),
      alternatives: alts,
      per100: Nutriments(
        kcal: kcal,
        proteinG: f('protein_g_per_100g'),
        carbsG: f('carbs_g_per_100g'),
        fatG: f('fat_g_per_100g'),
      ),
    );
  }
}
