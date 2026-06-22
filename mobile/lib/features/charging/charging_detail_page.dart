import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/core/ui/state_lottie.dart';
import 'package:stellantis_mobile/core/ui/state_views.dart';
import 'package:stellantis_mobile/features/vehicles/data/selected_vehicle.dart';
import 'package:stellantis_mobile/stellantis/storage/app_database.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/charge_record.dart';

final _chargeByIdProvider =
    FutureProvider.autoDispose.family<ChargeRecord?, int>((ref, id) async {
  final isar = await ref.watch(isarProvider.future);
  final record = await isar.chargeRecords.get(id);
  final vin = ref.watch(selectedVinProvider);
  if (record == null || (vin != null && record.vin != vin)) return null;
  return record;
});

class ChargingDetailPage extends ConsumerWidget {
  const ChargingDetailPage({required this.chargeId, super.key});
  final int chargeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_chargeByIdProvider(chargeId));
    return Scaffold(
      appBar: AppBar(title: const Text('Charge')),
      body: async.when(
        loading: () => const LoadingStateView(),
        error: (e, _) => mapErrorToStateView(e),
        data: (charge) {
          if (charge == null) {
            return const EmptyStateView(
              icon: Icons.bolt,
              message: 'Charge session not found in local cache.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(charge: charge),
              const SizedBox(height: 12),
              _CurveCard(charge: charge),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.charge});
  final ChargeRecord charge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration =
        (charge.stopAt ?? charge.startAt).difference(charge.startAt);
    final energy = (charge.startLevel != null &&
            charge.endLevel != null &&
            charge.kw != null)
        ? ((charge.endLevel! - charge.startLevel!) / 100) * charge.kw!
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(charge.startAt),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _Stat(
                  icon: Icons.timer_outlined,
                  label: 'Duration',
                  value: _formatDuration(duration),
                ),
                _Stat(
                  icon: Icons.bolt,
                  label: 'Energy',
                  value: energy == null
                      ? '—'
                      : '${energy.toStringAsFixed(1)} kWh',
                ),
                _Stat(
                  icon: Icons.euro,
                  label: 'Cost',
                  value: charge.price == null
                      ? '—'
                      : charge.price!.toStringAsFixed(2),
                ),
                _Stat(
                  icon: Icons.eco,
                  label: 'CO₂',
                  value: charge.co2 == null
                      ? '—'
                      : '${charge.co2!.toStringAsFixed(1)} kg',
                ),
                _Stat(
                  icon: Icons.electrical_services,
                  label: 'Mode',
                  value: charge.chargingMode ?? '—',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CurveCard extends StatelessWidget {
  const _CurveCard({required this.charge});
  final ChargeRecord charge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = charge.startLevel ?? 0;
    final end = charge.endLevel ?? start;
    final hasRange = end > start;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const StateLottieView(kind: StateLottie.charging, size: 48),
                const SizedBox(width: 8),
                Text('Charge curve', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hasRange
                  ? '${start.toStringAsFixed(0)}% → ${end.toStringAsFixed(0)}%'
                  : 'Per-sample curve will appear here once telemetry is '
                      'persisted.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  borderData: FlBorderData(show: false),
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, start),
                        FlSpot(1, end),
                      ],
                      isCurved: true,
                      barWidth: 3,
                      color: theme.colorScheme.tertiary,
                      belowBarData: BarAreaData(
                        color: theme.colorScheme.tertiary.withAlpha(40),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 120,
      child: Row(
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
      ),
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
