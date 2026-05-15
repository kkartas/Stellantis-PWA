import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/core/perf/prefetcher.dart';
import 'package:stellantis_mobile/features/dashboard/data/latest_status.dart';
import 'package:stellantis_mobile/features/dashboard/data/quick_action_controller.dart';
import 'package:stellantis_mobile/features/dashboard/widgets/battery_ring.dart';
import 'package:stellantis_mobile/features/dashboard/widgets/hero_card.dart';
import 'package:stellantis_mobile/features/dashboard/widgets/quick_actions_row.dart';
import 'package:stellantis_mobile/features/shell/wake_refresh_indicator.dart';
import 'package:stellantis_mobile/stellantis/storage/repositories.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(latestStatusProvider);
    final vehicleAsync = ref.watch(activeVehicleProvider);

    ref.listen<QuickActionState>(quickActionControllerProvider,
        (prev, next) {
      final result = next.lastResult;
      final action = next.lastAction;
      if (result == null || action == null) return;
      if (prev?.lastResult == result && prev?.lastAction == action) return;

      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result == QuickActionStatus.success
                ? '${action.label} sent to your car'
                : '${action.label} failed. Tap to retry.',
          ),
          backgroundColor: result == QuickActionStatus.failure
              ? Theme.of(context).colorScheme.error
              : null,
          action: result == QuickActionStatus.failure
              ? SnackBarAction(
                  label: 'Retry',
                  textColor: Theme.of(context).colorScheme.onError,
                  onPressed: () => ref
                      .read(quickActionControllerProvider.notifier)
                      .dispatch(action),
                )
              : null,
        ),
      );
      ref
          .read(quickActionControllerProvider.notifier)
          .acknowledgeLastResult();
    });

    final status = statusAsync.valueOrNull;
    final vehicle = vehicleAsync.valueOrNull;

    final electricLevel = status?.batteryLevel?.toDouble();
    final fuelLevel = status?.fuelLevel?.toDouble();
    final charging = status?.chargingStatus == 'inProgress';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Prefetcher(
        providers: [
          tripRepoProvider,
          chargeRepoProvider,
          sohRepoProvider,
          alertRepoProvider,
        ],
        child: WakeRefreshIndicator(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            GestureDetector(
              onTap: () => context.go('/vehicle'),
              child: HeroCard(vehicle: vehicle, status: status),
            ),
            const SizedBox(height: 20),
            _EnergyRings(
              electricLevel: electricLevel,
              fuelLevel: fuelLevel,
              isCharging: charging,
            ),
            const SizedBox(height: 20),
            Text(
              'Quick actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const QuickActionsRow(),
            const SizedBox(height: 20),
            _StatsStrip(status: status),
          ],
        ),
        ),
      ),
    );
  }
}

class _EnergyRings extends StatelessWidget {
  const _EnergyRings({
    required this.electricLevel,
    required this.fuelLevel,
    required this.isCharging,
  });

  final double? electricLevel;
  final double? fuelLevel;
  final bool isCharging;

  @override
  Widget build(BuildContext context) {
    final hasFuel = fuelLevel != null && fuelLevel! > 0;
    final hasElectric = electricLevel != null;

    if (!hasFuel && !hasElectric) {
      return BatteryRing(
        percentage: null,
        label: 'No data yet',
        subtitle: 'Pull to refresh',
      );
    }

    if (hasFuel && hasElectric) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BatteryRing(
            percentage: electricLevel,
            label: 'Battery',
            isCharging: isCharging,
          ),
          BatteryRing(
            percentage: fuelLevel,
            label: 'Fuel',
          ),
        ],
      );
    }

    return Center(
      child: BatteryRing(
        percentage: hasElectric ? electricLevel : fuelLevel,
        label: hasElectric ? 'Battery' : 'Fuel',
        isCharging: hasElectric && isCharging,
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.status});

  final dynamic status;

  @override
  Widget build(BuildContext context) {
    final mileage = status?.mileage as double?;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.speed,
            label: 'Mileage',
            value: mileage == null ? '—' : '${mileage.toStringAsFixed(0)} km',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.access_time,
            label: 'Last sync',
            value: _formatTimestamp(status?.timestamp as DateTime?),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

String _formatTimestamp(DateTime? t) {
  if (t == null) return 'Never';
  final now = DateTime.now().toUtc();
  final diff = now.difference(t);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inDays < 1) return '${diff.inHours} h ago';
  return '${diff.inDays} d ago';
}
