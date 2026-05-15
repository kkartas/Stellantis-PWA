import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/features/auth/data/session_service.dart';

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


class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.straighten),
            title: Text('Units'),
            subtitle: Text('km/mi, °C/°F, currency (Phase 6)'),
            enabled: false,
          ),
          const ListTile(
            leading: Icon(Icons.bolt),
            title: Text('Charging'),
            subtitle: Text('Target SOC, schedule, kWh price (Phase 6)'),
            enabled: false,
          ),
          ListTile(
            leading: const Icon(Icons.build_outlined),
            title: const Text('Maintenance'),
            subtitle: const Text('Oil, brakes, service reminders'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/maintenance'),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Sign out',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle:
                const Text('Clears tokens, OTP credentials and local cache.'),
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You\'ll need to sign in again and set up OTP. Trip history and '
          'charging sessions stored on this device will be erased.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(sessionServiceProvider).logout();
    if (!context.mounted) return;
    context.go('/brand-picker');
  }
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
