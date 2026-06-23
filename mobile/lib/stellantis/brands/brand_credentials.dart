import 'package:stellantis_mobile/stellantis/brands/secrets.dart';

/// Resolves OAuth client credentials for a brand.
///
/// The PSA `client_id` / `client_secret` are embedded once per brand in that
/// brand's single global APK, so they are the same for a given brand
/// regardless of the user's country (confirmed against the legacy
/// psa_car_controller decoder — see docs/LEGACY_AUDIT.md §1.2/1.3).
///
/// [BrandSecrets] keys every entry by `<brand>:<COUNTRY>` because the
/// country-specific inWebo fields (site_code/culture/host_brandid_prod) live
/// in the same maps. For client credentials we therefore match by **brand**,
/// falling back to whichever country entry was extracted for that brand when
/// an exact `brand:country` key is absent. This is what lets a single
/// extracted brand APK authenticate users in every market the brand serves.
class BrandCredentials {
  BrandCredentials._();

  /// OAuth2 client_id for [cacheKey] (`<brand>:<COUNTRY>`), resolved at the
  /// brand level. Returns null if no entry exists for the brand.
  static String? clientId(String cacheKey) =>
      _resolve(BrandSecrets.clientId, cacheKey);

  /// OAuth2 client_secret for [cacheKey], resolved at the brand level.
  static String? clientSecret(String cacheKey) =>
      _resolve(BrandSecrets.clientSecret, cacheKey);

  static String? _resolve(Map<String, String> map, String cacheKey) {
    final exact = map[cacheKey];
    if (exact != null && exact.isNotEmpty) return exact;

    final brandPrefix = '${cacheKey.split(':').first}:';
    for (final entry in map.entries) {
      if (entry.key.startsWith(brandPrefix) && entry.value.isNotEmpty) {
        return entry.value;
      }
    }
    return null;
  }
}
