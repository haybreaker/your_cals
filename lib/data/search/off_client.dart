import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import '../../domain/food.dart';
import '../../domain/nutriments.dart';

/// Keyless Open Food Facts access with AU/NZ priority.
///
/// OFF rate-limits search to ~10 req/min/IP, so this client is strictly
/// single-flight (one in-flight request; newer queries replace older) and
/// every result is cached upstream by the caller into the local DB.
class OffClient {
  OffClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              headers: {
                'User-Agent': 'YourCals/0.1 (personal calorie tracker)',
              },
            ));

  final Dio _dio;

  CancelToken? _cancel;
  Timer? _throttle;
  DateTime _lastCall = DateTime.fromMillisecondsSinceEpoch(0);

  /// Minimum spacing between search calls — protects the shared quota.
  static const _minInterval = Duration(milliseconds: 1500);

  void dispose() {
    _cancel?.cancel();
    _throttle?.cancel();
  }

  Future<List<Food>> search(String query,
      {int limit = 25, bool worldwide = false}) async {
    final q = query.trim();
    if (q.length < 2) return const [];

    // Coalesce bursts: cancel the previous call, restart the timer.
    _cancel?.cancel();
    _cancel = CancelToken();
    final token = _cancel!;

    final sinceLast = DateTime.now().difference(_lastCall);
    if (sinceLast < _minInterval) {
      try {
        await Future<void>.delayed(_minInterval - sinceLast);
      } catch (_) {}
    }
    if (token.isCancelled) return const [];
    _lastCall = DateTime.now();

    // Real network/parse failures must propagate so the caller can show
    // "local only" UI. Cancellation and genuine empty results return [].
    try {
      List<Food> products;
      try {
        products = worldwide
            ? await _searchALiciousWorld(q, token, limit)
            : await _searchALicious(q, token, limit);
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel || token.isCancelled) {
          return const [];
        }
        // Primary backend failed — fall through to legacy below.
        products = const [];
      }
      if (!token.isCancelled && products.isEmpty) {
        products = await _searchLegacy(q, token, limit, worldwide: worldwide);
      }
      return products;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel || token.isCancelled) {
        return const [];
      }
      rethrow;
    }
  }

  /// Exact product by barcode (generous rate limit, no key).
  Future<Food?> fetchByBarcode(String barcode) async {
    final clean = barcode.trim().replaceAll(' ', '');
    if (clean.length < 6) return null;
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        'https://world.openfoodfacts.org/api/v2/product/$clean.json',
        queryParameters: {
          'fields': 'code,product_name,brands,nutriments,serving_quantity',
        },
      );
      final status = res.data?['status'];
      if (status != 1) return null;
      final product = res.data?['product'];
      if (product is! Map) return null;
      return _parseProduct(product.cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  /// Search-a-licious — OFF's dedicated typeahead service.
  Future<List<Food>> _searchALicious(
      String q, CancelToken token, int limit) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'https://search.openfoodfacts.org/search',
      queryParameters: {
        'q': q,
        'countries': 'en:australia,en:new-zealand',
        'page_size': '$limit',
        'fields': 'code,product_name,brands,nutriments,serving_quantity',
      },
      cancelToken: token,
    );
    final hits = res.data?['hits'] as List?;
    if (hits == null) return const [];
    return _parseHitList(hits);
  }

  /// Worldwide typeahead — catches products sold in AU but tagged to
  /// another country (or untagged), e.g. many Aldi AU own-brands.
  Future<List<Food>> _searchALiciousWorld(
      String q, CancelToken token, int limit) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'https://search.openfoodfacts.org/search',
      queryParameters: {
        'q': q,
        'page_size': '$limit',
        'fields': 'code,product_name,brands,nutriments,serving_quantity',
      },
      cancelToken: token,
    );
    final hits = res.data?['hits'] as List?;
    if (hits == null) return const [];
    return _parseHitList(hits);
  }

  /// Per-row defensive parse: one malformed hit must never kill the
  /// whole result set (this is what silently zeroed remote results when
  /// search-a-licious switched `brands` to a JSON array).
  static List<Food> _parseHitList(List hits) {
    final out = <Food>[];
    for (final h in hits) {
      try {
        if (h is! Map) continue;
        final food = _parseProduct(h.cast<String, dynamic>());
        if (food != null) out.add(food);
      } catch (_) {
        // Skip one bad row.
      }
    }
    return out;
  }

  /// Legacy CGI search fallback.
  Future<List<Food>> _searchLegacy(
      String q, CancelToken token, int limit,
      {bool worldwide = false}) async {
    final params = <String, String>{
      'search_terms': q,
      'json': '1',
      'page_size': '$limit',
      'fields': 'code,product_name,brands,nutriments,serving_quantity',
      if (!worldwide) 'countries_tags': 'en:australia',
    };
    final res = await _dio.get<dynamic>(
      'https://world.openfoodfacts.org/cgi/search.pl',
      queryParameters: params,
      cancelToken: token,
    );
    final products = res.data?['products'] as List?;
    if (products == null) return const [];
    final out = <Food>[];
    for (final p in products) {
      try {
        final food = _parseProduct((p as Map).cast<String, dynamic>());
        if (food != null) out.add(food);
      } catch (_) {
        // Skip one bad row — never kill the whole result set.
      }
    }
    return out;
  }

  /// Brands arrive as a comma-string from api/v2 + CGI but as a JSON
  /// array from search-a-licious. Accept both (plus null/missing).
  static String _parseBrand(dynamic raw) {
    if (raw is List) {
      for (final b in raw) {
        final s = b?.toString().trim() ?? '';
        if (s.isNotEmpty) return s;
      }
      return '';
    }
    if (raw is String) return raw.split(',').first.trim();
    if (raw != null) {
      final s = raw.toString().trim();
      if (s.isNotEmpty && s != 'null') return s;
    }
    return '';
  }

  static Food? _parseProduct(Map<String, dynamic> p) {
    try {
      final name = (p['product_name'] as String?)?.trim() ?? '';
      final resolvedName = name.isEmpty
          ? ((p['generic_name'] as String?)?.trim() ?? '')
          : name;
      final brand = _parseBrand(p['brands']);
      if (resolvedName.isEmpty) return null;

      final nutr =
          (p['nutriments'] as Map?)?.cast<String, dynamic>() ?? const {};
      double? n(String key) => (nutr[key] as num?)?.toDouble();

      var kcal = n('energy-kcal_100g');
      if (kcal == null) {
        final kJ = n('energy_100g');
        if (kJ != null) kcal = kJ / 4.184;
      }
      if (kcal == null || kcal <= 0) return null;

      double? servingQ;
      final rawServing = p['serving_quantity'];
      if (rawServing is num) {
        servingQ = rawServing.toDouble();
      } else if (rawServing is String) {
        // CGI sometimes returns "45g" style strings.
        final m = RegExp(r'[\d.]+').firstMatch(rawServing);
        if (m != null) servingQ = double.tryParse(m.group(0)!);
      }
      final grams = (servingQ != null && servingQ > 0 && servingQ <= 1000)
          ? servingQ
          : 100.0;

      final code = p['code']?.toString() ?? resolvedName.toLowerCase();
      return Food(
        id: 'off:$code',
        name: _titleCase(resolvedName),
        brand: brand,
        source: FoodSource.off,
        per100: Nutriments(
          kcal: kcal,
          proteinG: max(0, n('proteins_100g') ?? 0),
          carbsG: max(0, n('carbohydrates_100g') ?? 0),
          fatG: max(0, n('fat_100g') ?? 0),
          satFatG: max(0, n('saturated-fat_100g') ?? 0),
          sugarsG: max(0, n('sugars_100g') ?? 0),
          fiberG: max(0, n('fiber_100g') ?? 0),
          sodiumMg: max(0, (n('sodium_100g') ?? 0) * 1000),
        ),
        defaultGrams: grams,
      );
    } catch (_) {
      return null;
    }
  }

  static String _titleCase(String s) => s.length <= 3
      ? s
      : s
          .split(' ')
          .map((w) => w.isEmpty
              ? w
              : w[0].toUpperCase() + w.substring(1).toLowerCase())
          .join(' ');
}
