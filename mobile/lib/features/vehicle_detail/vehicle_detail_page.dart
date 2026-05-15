import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/core/ui/state_lottie.dart';
import 'package:stellantis_mobile/core/ui/state_views.dart';
import 'package:stellantis_mobile/features/dashboard/data/latest_status.dart';
import 'package:stellantis_mobile/features/shell/wake_refresh_indicator.dart';
import 'package:stellantis_mobile/features/vehicle_detail/data/live_status.dart';
import 'package:stellantis_mobile/features/vehicles/data/selected_vehicle.dart';
import 'package:stellantis_mobile/stellantis/models/energy.dart';
import 'package:stellantis_mobile/stellantis/models/vehicle_status.dart';
import 'package:stellantis_mobile/stellantis/storage/repositories.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/alert_record.dart';

class VehicleDetailPage extends ConsumerWidget {
  const VehicleDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vin = ref.watch(selectedVinProvider);
    final liveByVin = ref.watch(liveVehicleStatusProvider);
    final live = vin == null ? null : liveByVin[vin];
    final cachedStatus = ref.watch(latestStatusProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Location',
            onPressed: () => context.go('/vehicle/location'),
          ),
        ],
      ),
      body: WakeRefreshIndicator(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (live == null && cachedStatus == null)
              const EmptyStateView(
                icon: Icons.cloud_download_outlined,
                message:
                    'No live state yet. Pull to refresh to fetch the latest '
                    'status from your car.',
              )
            else ...[
              _DoorsCard(live: live),
              const SizedBox(height: 12),
              _ClimateCard(live: live),
              const SizedBox(height: 12),
              _EnergyDetailCard(live: live),
              const SizedBox(height: 12),
              _AlertsCard(vin: vin, ref: ref),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.children});

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DoorsCard extends StatelessWidget {
  const _DoorsCard({required this.live});

  final VehicleStatusModel? live;

  @override
  Widget build(BuildContext context) {
    final doors = live?.doorsState;
    final lockState = doors?.lockedStates;
    final opening = doors?.opening;

    return _SectionCard(
      title: 'Doors & windows',
      icon: Icons.directions_car_outlined,
      children: [
        _KeyValue(
          label: 'Lock state',
          value: lockState == null ? '—' : _humanizeLock(lockState),
          icon: _lockIcon(lockState),
        ),
        if (opening != null) ...[
          const Divider(height: 24),
          _DoorRow(label: 'Front left', value: opening.frontLeft),
          _DoorRow(label: 'Front right', value: opening.frontRight),
          _DoorRow(label: 'Rear left', value: opening.rearLeft),
          _DoorRow(label: 'Rear right', value: opening.rearRight),
          _DoorRow(label: 'Trunk', value: opening.trunk),
          if (opening.hood != null) _DoorRow(label: 'Hood', value: opening.hood),
          if (opening.roofWindow != null)
            _DoorRow(label: 'Sunroof', value: opening.roofWindow),
        ],
      ],
    );
  }

  IconData _lockIcon(DoorLockStatus? s) {
    switch (s) {
      case DoorLockStatus.locked:
      case DoorLockStatus.superLocked:
        return Icons.lock;
      case DoorLockStatus.unlocked:
        return Icons.lock_open;
      case null:
      case DoorLockStatus.unknown:
        return Icons.help_outline;
    }
  }

  String _humanizeLock(DoorLockStatus s) {
    switch (s) {
      case DoorLockStatus.locked:
        return 'Locked';
      case DoorLockStatus.superLocked:
        return 'Super-locked';
      case DoorLockStatus.unlocked:
        return 'Unlocked';
      case DoorLockStatus.unknown:
        return 'Unknown';
    }
  }
}

class _DoorRow extends StatelessWidget {
  const _DoorRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final closed = value == null || value!.toLowerCase() == 'closed';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            closed ? Icons.check_circle : Icons.warning_amber,
            color: closed
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(value ?? '—',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ClimateCard extends StatelessWidget {
  const _ClimateCard({required this.live});

  final VehicleStatusModel? live;

  @override
  Widget build(BuildContext context) {
    final ac = live?.preconditioning?.airConditioning;
    final acOn = ac?.status == AirConditioningStatus.enabled;
    return _SectionCard(
      title: 'Climate',
      icon: Icons.ac_unit,
      children: [
        if (acOn)
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: StateLottieView(kind: StateLottie.climateOn, size: 80),
          ),
        _KeyValue(
          label: 'Air conditioning',
          value: ac == null
              ? '—'
              : (ac.status?.name ?? 'unknown'),
          icon: ac?.status == AirConditioningStatus.enabled
              ? Icons.toggle_on
              : Icons.toggle_off,
        ),
        if (ac?.updatedAt != null)
          _KeyValue(
            label: 'Updated',
            value: ac!.updatedAt!.toLocal().toString().substring(0, 16),
            icon: Icons.access_time,
          ),
      ],
    );
  }
}

class _EnergyDetailCard extends StatelessWidget {
  const _EnergyDetailCard({required this.live});

  final VehicleStatusModel? live;

  @override
  Widget build(BuildContext context) {
    final electric = live?.electricEnergy;
    final fuel = live?.fuelEnergy;

    return _SectionCard(
      title: 'Energy',
      icon: Icons.bolt,
      children: [
        if (electric != null) ...[
          _KeyValue(
            label: 'Battery',
            value: '${electric.level?.toStringAsFixed(0) ?? '—'}%',
            icon: Icons.battery_full,
          ),
          if (electric.autonomy != null)
            _KeyValue(
              label: 'Range',
              value: '${electric.autonomy!.toStringAsFixed(0)} km',
              icon: Icons.speed,
            ),
          if (electric.charging?.plugged != null)
            _KeyValue(
              label: 'Plug',
              value: electric.charging!.plugged! ? 'Connected' : 'Disconnected',
              icon: Icons.electrical_services,
            ),
        ],
        if (fuel != null && fuel.level != null && fuel.level! > 0)
          _KeyValue(
            label: 'Fuel',
            value: '${fuel.level!.toStringAsFixed(0)}%',
            icon: Icons.local_gas_station,
          ),
        if (electric == null && fuel == null)
          const _KeyValue(
            label: 'Energy',
            value: 'No data',
            icon: Icons.help_outline,
          ),
      ],
    );
  }
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard({required this.vin, required this.ref});

  final String? vin;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    if (vin == null) return const SizedBox.shrink();

    final repoAsync = ref.watch(alertRepoProvider);
    return repoAsync.when(
      loading: () => const _SectionCard(
        title: 'Alerts',
        icon: Icons.warning_amber,
        children: [Text('Loading…')],
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (repo) {
        return StreamBuilder<List<AlertRecord>>(
          stream: repo.watchUnacknowledgedForVin(vin!),
          builder: (context, snap) {
            final alerts = snap.data ?? const <AlertRecord>[];
            return _SectionCard(
              title: 'Alerts',
              icon: Icons.warning_amber,
              children: alerts.isEmpty
                  ? const [
                      _KeyValue(
                        label: 'Status',
                        value: 'No active alerts',
                        icon: Icons.check_circle_outline,
                      ),
                    ]
                  : [
                      for (final alert in alerts)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.warning_amber,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          title: Text(alert.type),
                          subtitle: alert.message == null
                              ? null
                              : Text(alert.message!),
                          trailing: IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () => repo.acknowledge(alert.id),
                          ),
                        ),
                    ],
            );
          },
        );
      },
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
