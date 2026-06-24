import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/stellantis/auth/oauth_service.dart';

void main() {
  group('OAuthService.extractAuthorizationCode', () {
    test('returns the code when the callback carries one', () {
      final code = OAuthService.extractAuthorizationCode(
        'mymap://oauth2redirect/gr?code=abc123&state=xyz',
      );
      expect(code, 'abc123');
    });

    test('throws a catchable OAuthException when the provider returns an error',
        () {
      expect(
        () => OAuthService.extractAuthorizationCode(
          'mymap://oauth2redirect/gr?error=invalid_scope'
          '&error_description=Unknown%2Finvalid%20scope%28s%29%3A%20'
          '%5Bdata%3Atrip%5D&state=xyz',
        ),
        throwsA(
          isA<OAuthException>()
              .having((e) => e.error, 'error', 'invalid_scope')
              .having(
                (e) => e.description,
                'description',
                contains('invalid scope'),
              ),
        ),
      );
    });

    test('throws a catchable Exception when neither code nor error is present',
        () {
      expect(
        () => OAuthService.extractAuthorizationCode(
          'mymap://oauth2redirect/gr?state=xyz',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
