import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stellantis_mobile/stellantis/analytics/emissions_estimator.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _mockResp(Object? body, int status) =>
    Response<Map<String, dynamic>>(
      data: body as Map<String, dynamic>?,
      statusCode: status,
      requestOptions: RequestOptions(),
    );

void main() {
  late _MockDio mockDio;
  late EmissionsEstimator estimator;

  setUpAll(() {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(Options());
  });

  setUp(() {
    mockDio = _MockDio();
    estimator = EmissionsEstimator(
      dio: mockDio,
      co2SignalKey: 'test-key',
    );
  });

  group('EmissionsEstimator', () {
    test('getCo2FromSignalCache returns null on empty cache', () {
      final now = DateTime.now().toUtc();
      expect(
        estimator.getCo2FromSignalCache(
          now.subtract(const Duration(minutes: 30)),
          now,
          'FR',
        ),
        isNull,
      );
    });

    test('fetchCo2Signal returns false when key is null', () async {
      final noKey = EmissionsEstimator(dio: mockDio);
      expect(await noKey.fetchCo2Signal('FR'), isFalse);
    });

    test('fetchCo2Signal populates cache on success', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _mockResp({'carbonIntensity': 42.0}, 200),
      );

      expect(await estimator.fetchCo2Signal('FR'), isTrue);

      final now = DateTime.now().toUtc();
      final result = estimator.getCo2FromSignalCache(
        now.subtract(const Duration(minutes: 1)),
        now.add(const Duration(minutes: 1)),
        'FR',
      );
      expect(result, closeTo(42.0, 0.01));
    });

    test('fetchCo2Signal returns false on non-200 response', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _mockResp({'error': 'unauthorized'}, 401),
      );

      expect(await estimator.fetchCo2Signal('FR'), isFalse);
    });

    test('cleanCache does not evict fresh entries', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _mockResp({'carbonIntensity': 15.0}, 200),
      );

      await estimator.fetchCo2Signal('FR');
      estimator.cleanCache();

      final now = DateTime.now().toUtc();
      final result = estimator.getCo2FromSignalCache(
        now.subtract(const Duration(minutes: 1)),
        now.add(const Duration(minutes: 1)),
        'FR',
      );
      expect(result, closeTo(15.0, 0.01));
    });

    test('getCo2PerKw returns null with no key for non-FR country', () async {
      final noKey = EmissionsEstimator(dio: mockDio);
      final result = await noKey.getCo2PerKw(
        DateTime.utc(2021, 3, 1, 10),
        DateTime.utc(2021, 3, 1, 11),
        'DE',
      );
      expect(result, isNull);
    });
  });
}
