import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stellantis_mobile/core/logging/logger.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';
import 'package:stellantis_mobile/theme/brand_theme.dart';

const _log = AppLogger('AssetPrecache');

/// Loads every brand SVG into the SVG cache during app startup so the
/// first time a brand-themed widget mounts it can render without a
/// disk read. The SVGs are small (~5 KB each) and there are 13 of
/// them — total cost is well under one frame.
Future<void> precacheBrandAssets() async {
  final stopwatch = Stopwatch()..start();
  final assets = <String>{
    BrandTheme.neutral.logoAsset,
    for (final brand in Brand.values)
      BrandTheme.perBrand[brand]?.logoAsset ?? '',
  }.where((path) => path.isNotEmpty);

  for (final path in assets) {
    try {
      final loader = SvgAssetLoader(path);
      await svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
    } catch (e) {
      _log.w('Failed to precache $path: $e');
    }
  }
  stopwatch.stop();
  _log.i(
    'Precached ${assets.length} brand SVG(s) in '
    '${stopwatch.elapsedMilliseconds}ms',
  );
}

/// Drains the asset bundle for the car-models YAML and any other startup
/// data assets so subsequent reads hit the bundle cache.
Future<void> precacheDataAssets() async {
  try {
    await rootBundle.loadString('assets/data/car_models.yml');
  } catch (e) {
    _log.w('Failed to precache car_models.yml: $e');
  }
}
