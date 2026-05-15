import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/core/ui/state_views.dart';
import 'package:stellantis_mobile/features/vehicles/data/selected_vehicle.dart';
import 'package:stellantis_mobile/stellantis/storage/repositories.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/charge_record.dart';

final _chargesStreamProvider =
    StreamProvider.autoDispose<List<ChargeRecord>>((ref) async* {
  final vin = ref.watch(selectedVinProvider);
  if (vin == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(chargeRepoProvider.future);
  yield* repo.watchForVin(vin);
});

class ChargingPage extends ConsumerWidget {
  const ChargingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chargesAsync = ref.watch(_chargesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Charging')),
      body: chargesAsync.when(
        loading: () => const LoadingStateView(),
        error: (e, _) => mapErrorToStateView(e),
        data: (charges) {
          if (charges.isEmpty) {
            return const EmptyStateView(
              icon: Icons.bolt,
              message: 'No charging sessions recorded yet.',
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _TotalsCard(charges: charges)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList.separated(
                  itemCount: charges.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) =>
                      _ChargeTile(charge: charges[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.charges});
  final List<ChargeRecord> charges;

  @override
  Widget build(BuildContext context) {
    final totalKwh = charges.fold<double>(
      0,
      (sum, c) {
        if (c.startLevel == null || c.endLevel == null || c.kw == null) {
          return sum;
        }
        return sum + ((c.endLevel! - c.startLevel!) / 100) * c.kw!;
      },
    );
    final totalCost = charges.fold<double>(
      0,
      (sum, c) => sum + (c.price ?? 0),
    );
    final totalCo2 = charges.fold<double>(
      0,
      (sum, c) => sum + (c.co2 ?? 0),
    );
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lifetime totals', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Total(
                      icon: Icons.bolt,
                      label: 'Energy',
                      value: '${totalKwh.toStringAsFixed(1)} kWh',
                    ),
                  ),
                  Expanded(
                    child: _Total(
                      icon: Icons.euro,
                      label: 'Cost',
                      value: totalCost.toStringAsFixed(2),
                    ),
                  ),
                  Expanded(
                    child: _Total(
                      icon: Icons.eco,
                      label: 'CO₂',
                      value: '${totalCo2.toStringAsFixed(1)} kg',
                    ),
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

class _Total extends StatelessWidget {
  const _Total({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

class _ChargeTile extends StatelessWidget {
  const _ChargeTile({required this.charge});
  final ChargeRecord charge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delta = (charge.startLevel != null && charge.endLevel != null)
        ? charge.endLevel! - charge.startLevel!
        : null;
    return Card(
      child: InkWell(
        onTap: () => context.go('/charging/${charge.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.tertiaryContainer,
                child: Icon(
                  Icons.bolt,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(charge.startAt),
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (charge.startLevel != null && charge.endLevel != null)
                          '${charge.startLevel!.toStringAsFixed(0)}% → ${charge.endLevel!.toStringAsFixed(0)}%',
                        if (delta != null) '(+${delta.toStringAsFixed(0)}%)',
                        if (charge.chargingMode != null) charge.chargingMode!,
                      ].join(' · '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (charge.price != null)
                Text(
                  charge.price!.toStringAsFixed(2),
                  style: theme.textTheme.titleSmall,
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime t) {
  final l = t.toLocal();
  return '${l.year}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')} '
      '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
}
