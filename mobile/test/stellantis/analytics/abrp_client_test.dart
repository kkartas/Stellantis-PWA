import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stellantis_mobile/stellantis/analytics/abrp_client.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio mockDio;
  late AbrpClient client;

  setUpAll(() {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(Options());
  });

  setUp(() {
    mockDio = _MockDio();
    client = AbrpClient(dio: mockDio, token: 'test-token');
  });

  group('AbrpClient', () {
    test('isEnabled returns false before any call to enableAbrp', () {
      expect(client.isEnabled('VR3UHZKX'), isFalse);
    });

    test('enableAbrp(enable: true) enables the VIN', () {
      client.enableAbrp('VR3UHZKX', enable: true);
      expect(client.isEnabled('VR3UHZKX'), isTrue);
    });

    test('enableAbrp(enable: false) removes a previously enabled VIN', () {
      client.enableAbrp('VR3UHZKX', enable: true);
      client.enableAbrp('VR3UHZKX', enable: false);
      expect(client.isEnabled('VR3UHZKX'), isFalse);
    });

    test('send returns false when token is empty (no HTTP call)', () async {
      final emptyToken = AbrpClient(dio: mockDio, token: '');
      emptyToken.enableAbrp('VR3UHZKX', enable: true);
      final result = await emptyToken.send(
        'VR3UHZKX',
        const AbrpTelemetry(utc: 1_614_595_200, soc: 75),
      );
      expect(result, isFalse);
      verifyNever(() => mockDio.post<Map<String, dynamic>>(any()));
    });

    test('send returns false when VIN is not enabled (no HTTP call)', () async {
      final result = await client.send(
        'VR3UHZKX',
        const AbrpTelemetry(utc: 1_614_595_200, soc: 75),
      );
      expect(result, isFalse);
      verifyNever(() => mockDio.post<Map<String, dynamic>>(any()));
    });

    test('send returns true when API responds ok', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {'status': 'ok'},
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      client.enableAbrp('VR3UHZKX', enable: true);
      final result = await client.send(
        'VR3UHZKX',
        const AbrpTelemetry(utc: 1_614_595_200, soc: 75),
      );
      expect(result, isTrue);
    });

    test('send returns false when API responds with non-ok status', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {'status': 'error'},
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      client.enableAbrp('VR3UHZKX', enable: true);
      final result = await client.send(
        'VR3UHZKX',
        const AbrpTelemetry(utc: 1_614_595_200, soc: 75),
      );
      expect(result, isFalse);
    });
  });
}
