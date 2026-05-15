import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/features/shell/wake_refresh_indicator.dart';

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

/// Placeholder pages — replaced one-by-one in Phase 6.

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: WakeRefreshIndicator(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Pull down to wake the car and refresh telemetry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) => const _PlaceholderTab(title: 'Trips');
}

class ChargingPage extends StatelessWidget {
  const ChargingPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const _PlaceholderTab(title: 'Charging');
}

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) => const _PlaceholderTab(title: 'Stats');
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const _PlaceholderTab(title: 'Settings');
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
