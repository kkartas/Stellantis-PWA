import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/features/auth/brand_picker_page.dart';
import 'package:stellantis_mobile/features/auth/login_page.dart';
import 'package:stellantis_mobile/features/auth/otp_setup_page.dart';
import 'package:stellantis_mobile/features/auth/splash_page.dart';
import 'package:stellantis_mobile/features/dashboard/dashboard_page.dart';
import 'package:stellantis_mobile/features/shell/app_shell.dart';
import 'package:stellantis_mobile/features/vehicle_detail/vehicle_detail_page.dart';
import 'package:stellantis_mobile/features/vehicles/vehicle_picker_page.dart';

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
        builder: (context, state) => const OtpSetupPage(),
      ),
      GoRoute(
        path: '/vehicle-picker',
        builder: (context, state) => const VehiclePickerPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardPage(),
                routes: [
                  GoRoute(
                    path: 'vehicle',
                    builder: (context, state) => const VehicleDetailPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trips',
                builder: (context, state) => const TripsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/charging',
                builder: (context, state) => const ChargingPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                builder: (context, state) => const StatsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
