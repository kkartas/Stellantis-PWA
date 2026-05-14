// Template — copy to secrets.dart and fill in values, OR run:
//   dart run tools/extract_secrets/bin/extract_secrets.dart --cache <path>
//
// secrets.dart is .gitignored and must never be committed.

// ignore_for_file: lines_longer_than_80_chars

class BrandSecrets {
  BrandSecrets._();

  /// Map of '<brand>:<COUNTRY>' → OAuth2 client_id extracted from the APK.
  static const Map<String, String> clientId = {
    'peugeot:FR': '',
    'citroen:FR': '',
    'ds:FR': '',
    'opel:DE': '',
    'vauxhall:GB': '',
  };

  /// Map of '<brand>:<COUNTRY>' → OAuth2 client_secret extracted from the APK.
  static const Map<String, String> clientSecret = {
    'peugeot:FR': '',
    'citroen:FR': '',
    'ds:FR': '',
    'opel:DE': '',
    'vauxhall:GB': '',
  };

  /// Map of '<brand>:<COUNTRY>' → inWebo site_code extracted from the APK.
  static const Map<String, String> siteCode = {
    'peugeot:FR': '',
    'citroen:FR': '',
    'ds:FR': '',
    'opel:DE': '',
    'vauxhall:GB': '',
  };

  /// Map of '<brand>:<COUNTRY>' → inWebo culture (e.g. "fr-FR").
  static const Map<String, String> culture = {
    'peugeot:FR': 'fr-FR',
    'citroen:FR': 'fr-FR',
    'ds:FR': 'fr-FR',
    'opel:DE': 'de-DE',
    'vauxhall:GB': 'en-GB',
  };

  /// Map of '<brand>:<COUNTRY>' → host_brandid_prod URL for inWebo auth.
  static const Map<String, String> hostBrandidProd = {
    'peugeot:FR': '',
    'citroen:FR': '',
    'ds:FR': '',
    'opel:DE': '',
    'vauxhall:GB': '',
  };
}
