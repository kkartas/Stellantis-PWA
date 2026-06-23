import 'dart:convert';
import 'dart:io';

const _requiredKeys = [
  'host_brandid_prod',
  'site_code',
  'culture',
  'client_id',
  'client_secret',
];

/// Represents the extracted credentials for one brand+country combination.
class BrandEntry {
  const BrandEntry({
    required this.brand,
    required this.countryCode,
    required this.hostBrandidProd,
    required this.siteCode,
    required this.culture,
    required this.clientId,
    required this.clientSecret,
  });

  final String brand;
  final String countryCode;
  final String hostBrandidProd;
  final String siteCode;
  final String culture;
  final String clientId;
  final String clientSecret;
}

/// Normalizes the brand portion of a cache key. The Python app_decoder keys
/// entries by APK filename (e.g. "mypeugeot.apk"), but the Flutter app looks
/// up credentials by [Brand] enum name (e.g. "peugeot"). Strip the leading
/// "my" and trailing ".apk" so the two agree. Keys already in plain
/// "<brand>" form pass through unchanged.
String _normalizeBrand(String raw) {
  var brand = raw.toLowerCase().trim();
  if (brand.endsWith('.apk')) {
    brand = brand.substring(0, brand.length - '.apk'.length);
  }
  if (brand.startsWith('my')) {
    brand = brand.substring('my'.length);
  }
  return brand;
}

/// Reads the APK setup cache JSON produced by the Python app_decoder and
/// returns one [BrandEntry] per valid entry.
///
/// Expected JSON shape (key = "<brand>:<COUNTRY>"):
/// ```json
/// {
///   "peugeot:FR": {
///     "saved_at": 1234567890,
///     "host_brandid_prod": "...",
///     "site_code": "...",
///     "culture": "fr-FR",
///     "client_id": "...",
///     "client_secret": "..."
///   }
/// }
/// ```
List<BrandEntry> loadCache(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    throw ArgumentError('Cache file not found: $path');
  }

  final raw = jsonDecode(file.readAsStringSync());
  if (raw is! Map<String, dynamic>) {
    throw const FormatException('Cache file must be a JSON object at the root');
  }

  final entries = <BrandEntry>[];

  for (final mapEntry in raw.entries) {
    final key = mapEntry.key; // e.g. "peugeot:FR"
    final value = mapEntry.value;

    if (value is! Map<String, dynamic>) continue;

    final missing = _requiredKeys.where((k) => (value[k] as String?) == null || (value[k] as String).isEmpty).toList();
    if (missing.isNotEmpty) {
      stderr.writeln('Skipping $key — missing fields: ${missing.join(', ')}');
      continue;
    }

    final parts = key.split(':');
    final brand = _normalizeBrand(parts[0]);
    final country = parts.length > 1 ? parts[1].toUpperCase() : 'XX';

    entries.add(
      BrandEntry(
        brand: brand,
        countryCode: country,
        hostBrandidProd: value['host_brandid_prod'] as String,
        siteCode: value['site_code'] as String,
        culture: value['culture'] as String,
        clientId: value['client_id'] as String,
        clientSecret: value['client_secret'] as String,
      ),
    );
  }

  return entries;
}
