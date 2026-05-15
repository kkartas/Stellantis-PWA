import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/features/auth/brand_picker_page.dart';
import 'package:stellantis_mobile/features/auth/login_page.dart';
import 'package:stellantis_mobile/features/auth/otp_setup_page.dart';
import 'package:stellantis_mobile/features/auth/splash_page.dart';
import 'package:stellantis_mobile/features/dashboard/dashboard_page.dart';
import 'package:stellantis_mobile/features/shell/app_shell.dart';
import 'package:stellantis_mobile/features/maintenance/maintenance_page.dart';
import 'package:stellantis_mobile/features/settings/abrp_settings_page.dart';
import 'package:stellantis_mobile/features/settings/charging_settings_page.dart';
import 'package:stellantis_mobile/features/settings/openweather_settings_page.dart';
import 'package:stellantis_mobile/features/settings/theme_settings_page.dart';
import 'package:stellantis_mobile/features/settings/units_settings_page.dart';
import 'package:stellantis_mobile/features/stats/stats_page.dart';
import 'package:stellantis_mobile/features/charging/charging_detail_page.dart';
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
                      return ChargingDetailPage(chargeId: id);
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
                routes: [
                  GoRoute(
                    path: 'maintenance',
                    builder: (context, state) => const MaintenancePage(),
                  ),
                  GoRoute(
                    path: 'units',
                    builder: (context, state) => const UnitsSettingsPage(),
                  ),
                  GoRoute(
                    path: 'charging',
                    builder: (context, state) =>
                        const ChargingSettingsPage(),
                  ),
                  GoRoute(
                    path: 'abrp',
                    builder: (context, state) => const AbrpSettingsPage(),
                  ),
                  GoRoute(
                    path: 'openweather',
                    builder: (context, state) =>
                        const OpenWeatherSettingsPage(),
                  ),
                  GoRoute(
                    path: 'theme',
                    builder: (context, state) => const ThemeSettingsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});


