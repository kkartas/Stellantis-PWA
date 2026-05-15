import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/app/app.dart';
import 'package:stellantis_mobile/core/logging/logger.dart';
import 'package:stellantis_mobile/core/perf/asset_precache.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const log = AppLogger('main');

  FlutterError.onError = (details) {
    log.e(
      details.exceptionAsString(),
      details.exception,
      details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log.e('PlatformDispatcher', error, stack);
    return false;
  };

  // Kick off asset precache in parallel with the first frame so the
  // splash logo renders immediately and brand SVGs are in the cache by
  // the time the splash routes onward.
  unawaited(precacheBrandAssets());
  unawaited(precacheDataAssets());

  runApp(const ProviderScope(child: StellantisApp()));
}
