import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/features/auth/data/brand_session.dart';
import 'package:stellantis_mobile/features/vehicles/data/selected_vehicle.dart';
import 'package:stellantis_mobile/main.dart' show appStartWallClock;
import 'package:stellantis_mobile/stellantis/auth/auth_storage.dart';
import 'package:stellantis_mobile/theme/brand_detector.dart';
import 'package:stellantis_mobile/theme/brand_theme.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  Future<void> _decide() async {
    // Minimum splash dwell so the brand logo feels intentional, but only
    // top up to the floor if we got here quickly. Warm starts where the
    // process was already alive paint the brand briefly and move on.
    const minDwell = Duration(milliseconds: 500);
    final elapsed = DateTime.now().difference(appStartWallClock);
    if (elapsed < minDwell) {
      await Future<void>.delayed(minDwell - elapsed);
    }

    final session = await ref.read(brandSessionStoreProvider).load();
    if (!mounted) return;

    if (session == null) {
      context.go('/brand-picker');
      return;
    }

    ref.read(selectedBrandSessionProvider.notifier).state = session;
    ref.read(brandOverrideProvider.notifier).state = session.brand;
    ref.read(brandThemeProvider.notifier).state =
        BrandTheme.perBrand[session.brand] ?? BrandTheme.neutral;

    final token = await ref.read(authStorageProvider).load();
    if (!mounted) return;

    if (token == null) {
      context.go('/login');
      return;
    }

    final vin = await ref.read(selectedVehicleStoreProvider).load();
    if (!mounted) return;

    if (vin == null) {
      context.go('/vehicle-picker');
      return;
    }

    ref.read(selectedVinProvider.notifier).state = vin;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset(
          'assets/brands/stellantis.svg',
          height: 120,
        ),
      ),
    );
  }
}
