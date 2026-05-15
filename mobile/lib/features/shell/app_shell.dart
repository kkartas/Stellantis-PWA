import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Top-level navigation shell. Renders a [NavigationBar] on Android and a
/// [CupertinoTabBar] on iOS so the destination switcher matches platform
/// conventions while the body content stays Material-themed.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = <_ShellDestination>[
    _ShellDestination(
      label: 'Dashboard',
      icon: Icons.home_filled,
      cupertinoIcon: CupertinoIcons.house_fill,
    ),
    _ShellDestination(
      label: 'Trips',
      icon: Icons.route_outlined,
      cupertinoIcon: CupertinoIcons.map,
    ),
    _ShellDestination(
      label: 'Charging',
      icon: Icons.bolt,
      cupertinoIcon: CupertinoIcons.bolt_fill,
    ),
    _ShellDestination(
      label: 'Stats',
      icon: Icons.bar_chart,
      cupertinoIcon: CupertinoIcons.chart_bar_fill,
    ),
    _ShellDestination(
      label: 'Settings',
      icon: Icons.settings_outlined,
      cupertinoIcon: CupertinoIcons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    final body = navigationShell;

    if (isIos) {
      return Scaffold(
        body: body,
        bottomNavigationBar: CupertinoTabBar(
          currentIndex: navigationShell.currentIndex,
          onTap: _go,
          items: [
            for (final d in _destinations)
              BottomNavigationBarItem(
                icon: Icon(d.cupertinoIcon),
                label: d.label,
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
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              label: d.label,
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

class _ShellDestination {
  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.cupertinoIcon,
  });

  final String label;
  final IconData icon;
  final IconData cupertinoIcon;
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
        ],
      ),
    );
  }
}
