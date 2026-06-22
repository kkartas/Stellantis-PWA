import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/features/vehicles/data/selected_vehicle.dart';
import 'package:stellantis_mobile/stellantis/storage/repositories.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/charge_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/soh_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/trip_record.dart';

final _sohStreamProvider =
    StreamProvider.autoDispose<List<SohRecord>>((ref) async* {
  final vin = ref.watch(selectedVinProvider);
  if (vin == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(sohRepoProvider.future);
  yield* repo.watchForVin(vin);
});

final _tripsForStatsProvider =
    StreamProvider.autoDispose<List<TripRecord>>((ref) async* {
  final vin = ref.watch(selectedVinProvider);
  if (vin == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(tripRepoProvider.future);
  yield* repo.watchForVin(vin);
});

final _chargesForStatsProvider =
    StreamProvider.autoDispose<List<ChargeRecord>>((ref) async* {
  final vin = ref.watch(selectedVinProvider);
  if (vin == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(chargeRepoProvider.future);
  yield* repo.watchForVin(vin);
});

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soh = ref.watch(_sohStreamProvider).valueOrNull ?? const [];
    final trips = ref.watch(_tripsForStatsProvider).valueOrNull ?? const [];
    final charges = ref.watch(_chargesForStatsProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SohCard(samples: soh),
          const SizedBox(height: 12),
          _ConsumptionCard(trips: trips),
          const SizedBox(height: 12),
          _MileageProjectionCard(trips: trips),
          const SizedBox(height: 12),
          _CostCard(charges: charges),
          const SizedBox(height: 12),
          _EmissionsCard(charges: charges),
        ],
      ),
    );
  }
}

class _SohCard extends StatelessWidget {
  const _SohCard({required this.samples});
  final List<SohRecord> samples;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Section(
      title: 'Battery health (SOH)',
      icon: Icons.battery_charging_full,
      child: samples.length < 2
          ? _emptyHint(context, 'Need at least two samples for a trend.')
          : SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                      ),
                    ),
                    bottomTitles: AxisTitles(),
                    topTitles: AxisTitles(),
                    rightTitles: AxisTitles(),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 3,
                      color: theme.colorScheme.primary,
                      dotData: const FlDotData(show: false),
                      spots: [
                        for (var i = 0; i < samples.length; i++)
                          FlSpot(i.toDouble(), samples[i].resistance),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ConsumptionCard extends StatelessWidget {
  const _ConsumptionCard({required this.trips});
  final List<TripRecord> trips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final withConsumption =
        trips.where((t) => t.consumption != null).toList()..sort(
            (a, b) => a.startAt.compareTo(b.startAt));
    final avg = withConsumption.isEmpty
        ? null
        : withConsumption
                .map((t) => t.consumption!)
                .reduce((a, b) => a + b) /
            withConsumption.length;

    return _Section(
      title: 'Consumption (kWh/100km)',
      icon: Icons.flash_on,
      trailing: avg == null
          ? null
          : Text(
              'Avg ${avg.toStringAsFixed(1)}',
              style: theme.textTheme.titleSmall,
            ),
      child: withConsumption.length < 2
          ? _emptyHint(context, 'Need at least two trips with consumption.')
          : SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                      ),
                    ),
                    bottomTitles: AxisTitles(),
                    topTitles: AxisTitles(),
                    rightTitles: AxisTitles(),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 3,
                      color: theme.colorScheme.tertiary,
                      dotData: const FlDotData(show: false),
                      spots: [
                        for (var i = 0; i < withConsumption.length; i++)
                          FlSpot(
                            i.toDouble(),
                            withConsumption[i].consumption!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _MileageProjectionCard extends StatelessWidget {
  const _MileageProjectionCard({required this.trips});
  final List<TripRecord> trips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (trips.isEmpty) {
      return _Section(
        title: 'Mileage projection',
        icon: Icons.speed,
        child: _emptyHint(context, 'No trips recorded yet.'),
      );
    }

    // Distance covered in the last 30 days, projected to a year.
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final recent = trips.where((t) => t.startAt.isAfter(cutoff));
    final recentKm = recent.fold<double>(0, (sum, t) => sum + t.distance);
    final yearly = recentKm * (365 / 30);
    final maxMileage = trips
        .where((t) => t.mileage != null)
        .map((t) => t.mileage!)
        .fold<double>(0, (max, v) => v > max ? v : max);

    return _Section(
      title: 'Mileage projection',
      icon: Icons.speed,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Expanded(
              child: _Stat(
                label: 'Last 30 days',
                value: '${recentKm.toStringAsFixed(0)} km',
                color: theme.colorScheme.primary,
              ),
            ),
            Expanded(
              child: _Stat(
                label: 'Annualised',
                value: '${yearly.toStringAsFixed(0)} km',
                color: theme.colorScheme.tertiary,
              ),
            ),
            Expanded(
              child: _Stat(
                label: 'Current odo',
                value: '${maxMileage.toStringAsFixed(0)} km',
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  const _CostCard({required this.charges});
  final List<ChargeRecord> charges;

  @override
  Widget build(BuildContext context) {
    final total = charges.fold<double>(0, (sum, c) => sum + (c.price ?? 0));
    final last30 = charges
        .where((c) => c.startAt
            .isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .fold<double>(0, (sum, c) => sum + (c.price ?? 0));
    return _Section(
      title: 'Energy cost',
      icon: Icons.euro,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Expanded(
              child: _Stat(
                label: 'Last 30 days',
                value: last30.toStringAsFixed(2),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child: _Stat(
                label: 'Lifetime',
                value: total.toStringAsFixed(2),
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmissionsCard extends StatelessWidget {
  const _EmissionsCard({required this.charges});
  final List<ChargeRecord> charges;

  @override
  Widget build(BuildContext context) {
    final total = charges.fold<double>(0, (sum, c) => sum + (c.co2 ?? 0));
    return _Section(
      title: 'CO₂ emissions',
      icon: Icons.eco,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: _Stat(
          label: 'From charging',
          value: '${total.toStringAsFixed(1)} kg',
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

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
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

Widget _emptyHint(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    ),
  );
}
