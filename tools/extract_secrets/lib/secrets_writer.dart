import 'dart:io';

import 'apk_cache.dart';

const _header = '''// GENERATED — do not edit by hand.
// Run: dart run tools/extract_secrets/bin/extract_secrets.dart --cache <path>
// This file is .gitignored; commit secrets_template.dart instead.

// ignore_for_file: lines_longer_than_80_chars

''';

String _brandMapLiteral(List<BrandEntry> entries, String Function(BrandEntry) selector) {
  final buf = StringBuffer('{\n');
  for (final e in entries) {
    buf.writeln("    '${e.brand}:${e.countryCode}': '${selector(e)}',");
  }
  buf.write('  }');
  return buf.toString();
}

/// Writes a `secrets.dart` file to [outputPath] populated from [entries].
void writeSecrets(List<BrandEntry> entries, String outputPath) {
  if (entries.isEmpty) {
    throw ArgumentError('No valid entries found in cache — nothing to write');
  }

  final clientIds = _brandMapLiteral(entries, (e) => e.clientId);
  final clientSecrets = _brandMapLiteral(entries, (e) => e.clientSecret);
  final siteCodes = _brandMapLiteral(entries, (e) => e.siteCode);
  final cultures = _brandMapLiteral(entries, (e) => e.culture);
  final hostUrls = _brandMapLiteral(entries, (e) => e.hostBrandidProd);

  final content = '''${_header}class BrandSecrets {
  BrandSecrets._();

  /// Map of '<brand>:<COUNTRY>' → OAuth2 client_id extracted from the APK.
  static const Map<String, String> clientId = $clientIds;

  /// Map of '<brand>:<COUNTRY>' → OAuth2 client_secret extracted from the APK.
  static const Map<String, String> clientSecret = $clientSecrets;

  /// Map of '<brand>:<COUNTRY>' → inWebo site_code extracted from the APK.
  static const Map<String, String> siteCode = $siteCodes;

  /// Map of '<brand>:<COUNTRY>' → inWebo culture (e.g. "fr-FR").
  static const Map<String, String> culture = $cultures;

  /// Map of '<brand>:<COUNTRY>' → host_brandid_prod URL for inWebo auth.
  static const Map<String, String> hostBrandidProd = $hostUrls;
}
''';

  File(outputPath)
    ..createSync(recursive: true)
    ..writeAsStringSync(content);

  stdout.writeln('Wrote ${entries.length} brand(s) to $outputPath');
}
