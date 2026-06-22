import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/l10n/app_localizations.dart';

/// Top-level navigation shell. Renders a [NavigationBar] on Android and a
/// [CupertinoTabBar] on iOS so the destination switcher matches platform
/// conventions while the body content stays Material-themed.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _icons = <_ShellIcon>[
    _ShellIcon(Icons.home_filled, CupertinoIcons.house_fill),
    _ShellIcon(Icons.route_outlined, CupertinoIcons.map),
    _ShellIcon(Icons.bolt, CupertinoIcons.bolt_fill),
    _ShellIcon(Icons.bar_chart, CupertinoIcons.chart_bar_fill),
    _ShellIcon(Icons.settings_outlined, CupertinoIcons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    final body = navigationShell;
    final l10n = AppLocalizations.of(context);
    final labels = <String>[
      l10n.navDashboard,
      l10n.navTrips,
      l10n.navCharging,
      l10n.navStats,
      l10n.navSettings,
    ];

    if (isIos) {
      return Scaffold(
        body: body,
        bottomNavigationBar: CupertinoTabBar(
          currentIndex: navigationShell.currentIndex,
          onTap: _go,
          items: [
            for (var i = 0; i < _icons.length; i++)
              BottomNavigationBarItem(
                icon: Icon(_icons[i].cupertino),
                label: labels[i],
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _go,
        destinations: [
          for (var i = 0; i < _icons.length; i++)
            NavigationDestination(
              icon: Icon(_icons[i].material),
              label: labels[i],
            ),
        ],
      ),
    );
  }

  void _go(int index) {
    navigationShell.goBranch(
      index,
      // Tapping the active tab pops to its root rather than no-op.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _ShellIcon {
  const _ShellIcon(this.material, this.cupertino);

  final IconData material;
  final IconData cupertino;
}

/// Settings root — every entry below is its own sub-route under /settings.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Units'),
            subtitle: const Text('km/mi, °C/°F, currency'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/units'),
          ),
          ListTile(
            leading: const Icon(Icons.bolt),
            title: const Text('Charging'),
            subtitle: const Text('Target SOC, schedule, kWh price'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/charging'),
          ),
          ListTile(
            leading: const Icon(Icons.build_outlined),
            title: const Text('Maintenance'),
            subtitle: const Text('Oil, brakes, service reminders'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/maintenance'),
          ),
          ListTile(
            leading: const Icon(Icons.alt_route),
            title: const Text('ABRP'),
            subtitle:
                const Text('Forward telemetry to A Better Route Planner'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/abrp'),
          ),
          ListTile(
            leading: const Icon(Icons.wb_sunny_outlined),
            title: const Text('OpenWeather'),
            subtitle: const Text('Ambient temperature fallback'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/openweather'),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: const Text('Auto-brand vs forced brand'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/theme'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Account'),
            subtitle: const Text('Signed-in brand, vehicles, sign out'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/account'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About & diagnostics'),
            subtitle:
                const Text('Version, last refresh, cache size, copy logs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/about'),
          ),
        ],
      ),
    );
  }
}
