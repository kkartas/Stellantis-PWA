import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/app/router.dart';
import 'package:stellantis_mobile/theme/brand_theme.dart';

/// Root application widget.
class StellantisApp extends ConsumerWidget {
  const StellantisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final brand = ref.watch(brandThemeProvider);

    return MaterialApp.router(
      title: 'Stellantis',
      theme: brand.lightTheme,
      darkTheme: brand.darkTheme,

      routerConfig: router,
    );
  }
}
