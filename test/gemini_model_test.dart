import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_cals/data/ai/gemini_client.dart';

void main() {
  group('pickBestModel (auto-discovery after model retirement)', () {
    test('prefers newest GA flash over retired models', () {
      final models = [
        {
          'name': 'models/gemini-2.0-flash',
          'supportedGenerationMethods': ['generateContent'],
        },
        {
          'name': 'models/gemini-3.8-flash',
          'supportedGenerationMethods': ['generateContent'],
        },
        {
          'name': 'models/gemini-3.6-flash',
          'supportedGenerationMethods': ['generateContent'],
        },
      ];
      expect(GeminiClient.pickBestModel(models), 'gemini-3.8-flash');
    });

    test('skips preview, lite, image and non-generateContent entries', () {
      final models = [
        {
          'name': 'models/gemini-4.0-flash-preview',
          'supportedGenerationMethods': ['generateContent'],
        },
        {
          'name': 'models/gemini-3.9-flash-lite',
          'supportedGenerationMethods': ['generateContent'],
        },
        {
          'name': 'models/gemini-3.8-flash-image',
          'supportedGenerationMethods': ['generateContent'],
        },
        {
          'name': 'models/text-embedding-004',
          'supportedGenerationMethods': ['embedContent'],
        },
        {
          'name': 'models/gemini-3.5-flash',
          'supportedGenerationMethods': ['generateContent'],
        },
      ];
      expect(GeminiClient.pickBestModel(models), 'gemini-3.5-flash');
    });

    test('falls back to preview when nothing GA exists', () {
      final models = [
        {
          'name': 'models/gemini-9.9-flash-preview',
          'supportedGenerationMethods': ['generateContent'],
        },
      ];
      expect(GeminiClient.pickBestModel(models), 'gemini-9.9-flash-preview');
    });

    test('returns null on empty list', () {
      expect(GeminiClient.pickBestModel([]), isNull);
      expect(GeminiClient.pickBestModel(null), isNull);
    });
  });

  group('parseResponse', () {
    final client = GeminiClient();

    Response<Map<String, dynamic>> fakeResponse(String rawJson) =>
        Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/x'),
          data: {
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': rawJson}
                  ]
                }
              }
            ]
          },
        );
    test('parses candidates into detected items', () {
      const raw = '''
{"is_food": true, "items": [{
  "name": "grilled chicken", "estimated_grams": 180, "confidence": 0.9,
  "kcal_per_100g": 165, "protein_g_per_100g": 31,
  "carbs_g_per_100g": 0, "fat_g_per_100g": 3.6}]}
''';
      final analysis = client.parseResponse(fakeResponse(raw));
      expect(analysis.isFood, isTrue);
      expect(analysis.items.single.name, 'grilled chicken');
      expect(analysis.items.single.totals.kcal, closeTo(297, 0.1));
      expect(analysis.items.single.totals.proteinG, closeTo(55.8, 0.1));
    });

    test('strips code fences defensively', () {
      const raw = '''
```json
{"is_food": true, "items": []}
```
''';
      final analysis = client.parseResponse(fakeResponse(raw));
      expect(analysis.items, isEmpty);
      expect(analysis.isFood, isTrue);
    });

    test('safety refusal (no parts text) yields not-food, not crash', () {
      final res = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/x'),
        data: {
          'candidates': [
            {
              'content': {'parts': []},
              'finishReason': 'SAFETY',
            }
          ],
        },
      );
      final analysis = client.parseResponse(res);
      expect(analysis.isFood, isFalse);
      expect(analysis.items, isEmpty);
    });
  });

  group('error honesty (slow model ≠ no internet)', () {
    GeminiClient withFault(DioExceptionType type) {
      final dio = Dio(BaseOptions(receiveTimeout: const Duration(seconds: 1)));
      dio.httpClientAdapter = _FaultAdapter(type);
      return GeminiClient(dio: dio);
    }

    test('receiveTimeout becomes "took too long" after one retry', () async {
      await expectLater(
        withFault(DioExceptionType.receiveTimeout).analyzeText(
          description: 'x',
          apiKey: 'k',
        ),
        throwsA(isA<GeminiException>().having(
          (e) => e.message,
          'message',
          contains('took too long'),
        )),
      );
    });

    test('connectionError says no internet and carries the cause', () async {
      await expectLater(
        withFault(DioExceptionType.connectionError).analyzeText(
          description: 'x',
          apiKey: 'k',
        ),
        throwsA(isA<GeminiException>().having(
          (e) => e.message,
          'message',
          allOf(contains('No internet'), contains('boom')),
        )),
      );
    });
  });
}

/// Adapter that always fails with the given [type] — no real HTTP.
class _FaultAdapter implements HttpClientAdapter {
  _FaultAdapter(this.type);
  final DioExceptionType type;

  @override
  Future<ResponseBody> fetch(
    RequestOptions requestOptions,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw DioException(
      requestOptions: requestOptions,
      type: type,
      error: Exception('boom'),
    );
  }

  @override
  void close({bool force = false}) {}
}
