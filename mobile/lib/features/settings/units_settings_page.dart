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
            RadioListTile<DistanceUnit>(
              value: DistanceUnit.kilometers,
              groupValue: prefs.distance,
              title: const Text('Kilometres (km)'),
              onChanged: (v) => v == null ? null : controller.setDistance(v),
            ),
            RadioListTile<DistanceUnit>(
              value: DistanceUnit.miles,
              groupValue: prefs.distance,
              title: const Text('Miles (mi)'),
              onChanged: (v) => v == null ? null : controller.setDistance(v),
            ),
            const _SectionHeader(label: 'Temperature'),
            RadioListTile<TemperatureUnit>(
              value: TemperatureUnit.celsius,
              groupValue: prefs.temperature,
              title: const Text('Celsius (°C)'),
              onChanged: (v) =>
                  v == null ? null : controller.setTemperature(v),
            ),
            RadioListTile<TemperatureUnit>(
              value: TemperatureUnit.fahrenheit,
              groupValue: prefs.temperature,
              title: const Text('Fahrenheit (°F)'),
              onChanged: (v) =>
                  v == null ? null : controller.setTemperature(v),
            ),
            const _SectionHeader(label: 'Currency'),
            for (final code in const ['EUR', 'GBP', 'USD', 'CHF', 'SEK', 'NOK'])
              RadioListTile<String>(
                value: code,
                groupValue: prefs.currency,
                title: Text(code),
                onChanged: (v) =>
                    v == null ? null : controller.setCurrency(v),
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
