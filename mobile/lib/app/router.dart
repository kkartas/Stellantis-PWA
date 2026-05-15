import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/features/auth/brand_picker_page.dart';
import 'package:stellantis_mobile/features/auth/login_page.dart';
import 'package:stellantis_mobile/features/auth/splash_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/brand-picker',
        builder: (context, state) => const BrandPickerPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/otp-setup',
        builder: (context, state) => const _OtpSetupPlaceholderPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardPlaceholderPage(),
      ),
    ],
  );
});

class DashboardPlaceholderPage extends StatelessWidget {
  const DashboardPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Dashboard')),
    );
  }
}

class _OtpSetupPlaceholderPage extends StatelessWidget {
  const _OtpSetupPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('OTP setup (placeholder)')),
    );
  }
}
