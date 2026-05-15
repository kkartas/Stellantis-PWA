import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/features/auth/brand_picker_page.dart';
import 'package:stellantis_mobile/features/auth/login_page.dart';
import 'package:stellantis_mobile/features/auth/otp_setup_page.dart';
import 'package:stellantis_mobile/features/auth/splash_page.dart';
import 'package:stellantis_mobile/features/dashboard/dashboard_page.dart';
import 'package:stellantis_mobile/features/shell/app_shell.dart';
import 'package:stellantis_mobile/features/charging/charging_page.dart';
import 'package:stellantis_mobile/features/trips/trip_detail_page.dart';
import 'package:stellantis_mobile/features/trips/trips_page.dart';
import 'package:stellantis_mobile/features/vehicle_detail/location_page.dart';
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
                    routes: [
                      GoRoute(
                        path: 'location',
                        builder: (context, state) =>
                            const VehicleLocationPage(),
                      ),
                    ],
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
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id =
                          int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                      return TripDetailPage(tripId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/charging',
                builder: (context, state) => const ChargingPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id =
                          int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                      return _ChargingDetailPlaceholder(id: id);
                    },
                  ),
                ],
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

class _ChargingDetailPlaceholder extends StatelessWidget {
  const _ChargingDetailPlaceholder({required this.id});
  final int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Charge $id')),
      body: const Center(child: Text('Charging detail (6.8)')),
    );
  }
}

