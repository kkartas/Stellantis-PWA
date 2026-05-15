import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/app/app.dart';
import 'package:stellantis_mobile/core/logging/logger.dart';
import 'package:stellantis_mobile/core/perf/asset_precache.dart';

/// Wall-clock at process start. Splash uses this to decide whether the
/// 'minimum-dwell' has already elapsed (the user may have stared at the
/// system launcher splash for a beat first), so we don't dawdle when the
/// process actually warmed up quickly.
final DateTime appStartWallClock = DateTime.now();

void main() {
  final stopwatch = Stopwatch()..start();
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

  // Log the first-frame budget once it lands. Target is 800 ms; warn over.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    stopwatch.stop();
    final ms = stopwatch.elapsedMilliseconds;
    if (ms > 800) {
      log.w('Cold start ${ms}ms (target 800ms)');
    } else {
      log.i('Cold start ${ms}ms');
    }
  });
}
