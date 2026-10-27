import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_cals/data/search/off_client.dart';

/// Stub Dio that answers OFF endpoints with canned JSON and optionally
/// captures the legacy CGI query parameters.
Dio _stubDio({
  Map<String, dynamic>? searchJson,
  Map<String, dynamic>? legacyJson,
  void Function(Map<String, dynamic> params)? onLegacy,
}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, h) {
        if (o.path.contains('search.openfoodfacts.org')) {
          h.resolve(
            Response(
              requestOptions: o,
              statusCode: 200,
              data: searchJson ?? const {'hits': []},
            ),
          );
        } else {
          onLegacy?.call(Map<String, dynamic>.from(o.queryParameters));
          h.resolve(
            Response(
              requestOptions: o,
              statusCode: 200,
              data: legacyJson ?? const {'products': []},
            ),
          );
        }
      },
    ),
  );
  return dio;
}

Map<String, dynamic> _hit({
  required String code,
  required dynamic brands,
  required String name,
  Map<String, dynamic>? nutriments,
}) => {
  'code': code,
  'brands': brands,
  'product_name': name,
  'nutriments':
      nutriments ??
      {
        'energy-kcal_100g': 401,
        'proteins_100g': 66.6,
        'carbohydrates_100g': 15.3,
        'fat_100g': 7.3,
      },
};

void main() {
  test('parses search-a-licious array brands (not just CGI strings)', () async {
    final dio = _stubDio(
      searchJson: {
        'hits': [
          _hit(
            code: '9400581047608',
            brands: ['Musashi'],
            name: 'Musashi high protein',
          ),
        ],
      },
    );
    final foods = await OffClient(dio: dio).search('musashi protein');
    expect(foods, hasLength(1));
    expect(foods.first.brand, 'Musashi');
    expect(foods.first.name, 'Musashi High Protein');
    expect(foods.first.id, 'off:9400581047608');
  });

  test('one malformed hit never kills the whole result set', () async {
    final dio = _stubDio(
      searchJson: {
        'hits': [
          // No nutriments/kcal → skipped, must not throw the batch away.
          _hit(code: '1', brands: ['X'], name: 'Mystery', nutriments: {}),
          _hit(
            code: '9400581047608',
            brands: 'Musashi, Other',
            name: 'Musashi high protein',
          ),
        ],
      },
    );
    final foods = await OffClient(dio: dio).search('musashi protein');
    expect(foods, hasLength(1));
    expect(foods.first.brand, 'Musashi');
  });

  test('empty primary falls back to legacy', () async {
    final dio = _stubDio(
      searchJson: const {'hits': []},
      legacyJson: {
        'products': [
          _hit(
            code: '9314549902208',
            brands: 'MUSASHI',
            name: 'HIGH PROTEIN',
          ),
        ],
      },
    );
    final foods = await OffClient(dio: dio).search('high protein musashi');
    expect(foods, hasLength(1));
    expect(foods.first.brand, 'MUSASHI');
  });

  test('legacy fallback respects the worldwide flag', () async {
    Map<String, dynamic>? auParams;
    await OffClient(
      dio: _stubDio(
        searchJson: const {'hits': []},
        onLegacy: (p) => auParams = p,
      ),
    ).search('musashi');
    expect(auParams, isNotNull);
    expect(auParams!['countries_tags'], 'en:australia');

    Map<String, dynamic>? worldParams;
    await OffClient(
      dio: _stubDio(
        searchJson: const {'hits': []},
        onLegacy: (p) => worldParams = p,
      ),
    ).search('musashi', worldwide: true);
    expect(worldParams, isNotNull);
    expect(worldParams!.containsKey('countries_tags'), isFalse);
  });

  test('network failure propagates so callers can show offline UI', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) => h.reject(
          DioException(
            requestOptions: o,
            type: DioExceptionType.connectionTimeout,
          ),
        ),
      ),
    );
    await expectLater(
      OffClient(dio: dio).search('musashi'),
      throwsA(isA<DioException>()),
    );
  });
}
