import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/features/settings/data/units_preferences.dart';

class UnitsSettingsPage extends ConsumerWidget {
  const UnitsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(unitsControllerProvider);
    final controller = ref.read(unitsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Units')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (prefs) => ListView(
          children: [
            const _SectionHeader(label: 'Distance'),
            RadioGroup<DistanceUnit>(
              groupValue: prefs.distance,
              onChanged: (v) => v == null ? null : controller.setDistance(v),
              child: const Column(
                children: [
                  RadioListTile<DistanceUnit>(
                    value: DistanceUnit.kilometers,
                    title: Text('Kilometres (km)'),
                  ),
                  RadioListTile<DistanceUnit>(
                    value: DistanceUnit.miles,
                    title: Text('Miles (mi)'),
                  ),
                ],
              ),
            ),
            const _SectionHeader(label: 'Temperature'),
            RadioGroup<TemperatureUnit>(
              groupValue: prefs.temperature,
              onChanged: (v) =>
                  v == null ? null : controller.setTemperature(v),
              child: const Column(
                children: [
                  RadioListTile<TemperatureUnit>(
                    value: TemperatureUnit.celsius,
                    title: Text('Celsius (°C)'),
                  ),
                  RadioListTile<TemperatureUnit>(
                    value: TemperatureUnit.fahrenheit,
                    title: Text('Fahrenheit (°F)'),
                  ),
                ],
              ),
            ),
            const _SectionHeader(label: 'Currency'),
            RadioGroup<String>(
              groupValue: prefs.currency,
              onChanged: (v) =>
                  v == null ? null : controller.setCurrency(v),
              child: const Column(
                children: [
                  RadioListTile<String>(
                    value: 'EUR',
                    title: Text('EUR'),
                  ),
                  RadioListTile<String>(
                    value: 'GBP',
                    title: Text('GBP'),
                  ),
                  RadioListTile<String>(
                    value: 'USD',
                    title: Text('USD'),
                  ),
                  RadioListTile<String>(
                    value: 'CHF',
                    title: Text('CHF'),
                  ),
                  RadioListTile<String>(
                    value: 'SEK',
                    title: Text('SEK'),
                  ),
                  RadioListTile<String>(
                    value: 'NOK',
                    title: Text('NOK'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
