import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/app/app.dart';
import 'package:stellantis_mobile/core/logging/logger.dart';

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

  runApp(const ProviderScope(child: StellantisApp()));
}
