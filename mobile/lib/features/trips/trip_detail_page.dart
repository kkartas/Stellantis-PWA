import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/core/ui/state_views.dart';
import 'package:stellantis_mobile/features/vehicles/data/selected_vehicle.dart';
import 'package:stellantis_mobile/stellantis/storage/app_database.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/trip_record.dart';

final _tripByIdProvider =
    FutureProvider.autoDispose.family<TripRecord?, int>((ref, id) async {
  // Read directly from Isar — the repository's vin-scoped queries are not
  // a good fit for a lookup by primary key.
  final isar = await ref.watch(isarProvider.future);
  final trip = await isar.tripRecords.get(id);
  final activeVin = ref.watch(selectedVinProvider);
  if (trip == null || (activeVin != null && trip.vin != activeVin)) return null;
  return trip;
});

class TripDetailPage extends ConsumerWidget {
  const TripDetailPage({required this.tripId, super.key});
  final int tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(_tripByIdProvider(tripId));
    return Scaffold(
      appBar: AppBar(title: const Text('Trip')),
      body: tripAsync.when(
        loading: () => const LoadingStateView(),
        error: (e, _) => mapErrorToStateView(e),
        data: (trip) {
          if (trip == null) {
            return const EmptyStateView(
              icon: Icons.route_outlined,
              message: 'Trip not found in local cache.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatsCard(trip: trip),
              const SizedBox(height: 12),
              _ConsumptionCard(trip: trip),
              const SizedBox(height: 12),
              const _RoutePlaceholder(),
            ],
          );
        },
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.trip});
  final TripRecord trip;

  @override
  Widget build(BuildContext context) {
    final duration = (trip.endAt ?? trip.startAt).difference(trip.startAt);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(trip.startAt),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    icon: Icons.route,
                    label: 'Distance',
                    value: '${trip.distance.toStringAsFixed(1)} km',
                  ),
                ),
                Expanded(
                  child: _Stat(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: _formatDuration(duration),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    icon: Icons.speed,
                    label: 'Avg speed',
                    value: trip.speedAverage == null
                        ? '—'
                        : '${trip.speedAverage!.toStringAsFixed(0)} km/h',
                  ),
                ),
                Expanded(
                  child: _Stat(
                    icon: Icons.adjust,
                    label: 'Odometer',
                    value: trip.mileage == null
                        ? '—'
                        : '${trip.mileage!.toStringAsFixed(0)} km',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsumptionCard extends StatelessWidget {
  const _ConsumptionCard({required this.trip});
  final TripRecord trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Consumption', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (trip.consumption != null)
              _Stat(
                icon: Icons.bolt,
                label: 'Electric',
                value: '${trip.consumption!.toStringAsFixed(1)} kWh/100km',
              )
            else
              const _Stat(
                icon: Icons.bolt,
                label: 'Electric',
                value: '—',
              ),
            const SizedBox(height: 8),
            if (trip.consumptionFuel != null)
              _Stat(
                icon: Icons.local_gas_station,
                label: 'Fuel',
                value: '${trip.consumptionFuel!.toStringAsFixed(2)} L/100km',
              )
            else
              const _Stat(
                icon: Icons.local_gas_station,
                label: 'Fuel',
                value: '—',
              ),
          ],
        ),
      ),
    );
  }
}

class _RoutePlaceholder extends StatelessWidget {
  const _RoutePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.map_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            const Text(
              'Trip polyline storage lands with the trip-parser '
              'integration. Once positions are persisted, the route will '
              'render here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
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
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text(value, style: theme.textTheme.titleSmall),
          ],
        ),
      ],
    );
  }
}

String _formatDate(DateTime t) {
  final l = t.toLocal();
  final date =
      '${l.year}-${l.month.toString().padLeft(2, '0')}'
      '-${l.day.toString().padLeft(2, '0')}';
  final time =
      '${l.hour.toString().padLeft(2, '0')}'
      ':${l.minute.toString().padLeft(2, '0')}';
  return '$date $time';
}

String _formatDuration(Duration d) {
  if (d.inHours > 0) {
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
  }
  return '${d.inMinutes}m';
}
