import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/core/ui/skeleton.dart';
import 'package:stellantis_mobile/core/ui/state_views.dart';
import 'package:stellantis_mobile/features/trips/data/trip_filter.dart';
import 'package:stellantis_mobile/features/vehicles/data/selected_vehicle.dart';
import 'package:stellantis_mobile/stellantis/storage/repositories.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/trip_record.dart';

final _tripsStreamProvider =
    StreamProvider.autoDispose<List<TripRecord>>((ref) async* {
  final vin = ref.watch(selectedVinProvider);
  if (vin == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(tripRepoProvider.future);
  yield* repo.watchForVin(vin);
});

class TripsPage extends ConsumerWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(tripFilterProvider);
    final tripsAsync = ref.watch(_tripsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: filter.isActive,
              child: const Icon(Icons.filter_alt_outlined),
            ),
            tooltip: 'Filter',
            onPressed: () => _openFilterSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by date or distance',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (q) => ref
                  .read(tripFilterProvider.notifier)
                  .update((f) => f.copyWith(query: q)),
            ),
          ),
          Expanded(
            child: tripsAsync.when(
              loading: () => const SkeletonList(),
              error: (e, _) => mapErrorToStateView(e),
              data: (trips) {
                final visible = filter.apply(trips);
                if (visible.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.route_outlined,
                    message: trips.isEmpty
                        ? 'No trips recorded yet. The first trip after '
                            'login will show up here once telemetry syncs.'
                        : 'No trips match the current filter.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _TripTile(trip: visible[i]),
                  // Keep widgets disposed off-screen — TripTile is cheap
                  // to rebuild and the records list can grow into hundreds.
                  addAutomaticKeepAlives: false,
                  // One repaint boundary per row keeps scroll bursts from
                  // forcing the whole list to repaint.
                  addRepaintBoundaries: true,
                  // Pre-build a screen of items ahead so fast flings stay
                  // smooth without paying for the whole list at once.
                  cacheExtent: 600,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _FilterSheet(),
    );
  }
}

class _TripTile extends StatelessWidget {
  const _TripTile({required this.trip});
  final TripRecord trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = (trip.endAt ?? trip.startAt).difference(trip.startAt);
    return Card(
      child: InkWell(
        onTap: () => context.go('/trips/${trip.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(Icons.route,
                    color: theme.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(trip.startAt),
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${trip.distance.toStringAsFixed(1)} km · '
                      '${_formatDuration(duration)}'
                      '${trip.consumption == null ? '' : ' · ${trip.consumption!.toStringAsFixed(1)} kWh/100km'}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late TripFilter _draft;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(tripFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filter trips', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('After'),
            subtitle: Text(_draft.startAfter?.toString().substring(0, 10) ??
                'No lower bound'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _draft.startAfter ?? DateTime.now(),
                firstDate: DateTime(2018),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _draft = _draft.copyWith(startAfter: picked));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Minimum distance (km)'),
            subtitle: Slider(
              value: _draft.minDistanceKm,
              min: 0,
              max: 500,
              divisions: 50,
              label: '${_draft.minDistanceKm.toStringAsFixed(0)} km',
              onChanged: (v) =>
                  setState(() => _draft = _draft.copyWith(minDistanceKm: v)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(tripFilterProvider.notifier).state =
                        const TripFilter();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    ref.read(tripFilterProvider.notifier).state = _draft;
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime t) {
  final l = t.toLocal();
  return '${l.year}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')} '
      '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
}

String _formatDuration(Duration d) {
  if (d.inHours > 0) {
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
  }
  return '${d.inMinutes}m';
}
