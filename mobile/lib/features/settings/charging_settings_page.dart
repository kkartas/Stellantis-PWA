import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/features/settings/data/charging_preferences.dart';

class ChargingSettingsPage extends ConsumerStatefulWidget {
  const ChargingSettingsPage({super.key});

  @override
  ConsumerState<ChargingSettingsPage> createState() =>
      _ChargingSettingsPageState();
}

class _ChargingSettingsPageState extends ConsumerState<ChargingSettingsPage> {
  ChargingPreferences? _draft;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(chargingPrefsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Charging'),
        actions: [
          if (_draft != null)
            TextButton(
              onPressed: () async {
                await ref
                    .read(chargingPrefsControllerProvider.notifier)
                    .save(_draft!);
                if (!mounted) return;
                setState(() => _draft = null);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved')),
                );
              },
              child: const Text('Save'),
            ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (saved) {
          final prefs = _draft ?? saved;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section(
                title: 'Target state of charge',
                child: Column(
                  children: [
                    Text(
                      '${prefs.targetSoc}%',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    Slider(
                      min: 50,
                      max: 100,
                      divisions: 10,
                      value: prefs.targetSoc.toDouble(),
                      label: '${prefs.targetSoc}%',
                      onChanged: (v) => setState(
                        () => _draft = prefs.copyWith(targetSoc: v.toInt()),
                      ),
                    ),
                  ],
                ),
              ),
              _Section(
                title: 'Scheduled charging window',
                child: Column(
                  children: [
                    _HourSelector(
                      label: 'Start',
                      value: prefs.scheduledStartHour,
                      onChanged: (v) => setState(
                        () => _draft =
                            prefs.copyWith(scheduledStartHour: v),
                      ),
                    ),
                    _HourSelector(
                      label: 'Stop',
                      value: prefs.scheduledStopHour,
                      onChanged: (v) => setState(
                        () => _draft = prefs.copyWith(scheduledStopHour: v),
                      ),
                    ),
                  ],
                ),
              ),
              _Section(
                title: 'Price per kWh',
                child: TextFormField(
                  initialValue: prefs.pricePerKwh.toStringAsFixed(3),
                  decoration: const InputDecoration(
                    suffixText: '/ kWh',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) {
                    final parsed = double.tryParse(v);
                    if (parsed == null) return;
                    setState(
                      () => _draft = prefs.copyWith(pricePerKwh: parsed),
                    );
                  },
                ),
              ),
              _Section(
                title: 'Peak window (more expensive)',
                child: Column(
                  children: [
                    _HourSelector(
                      label: 'Peak start',
                      value: prefs.peakStartHour,
                      onChanged: (v) => setState(
                        () => _draft = prefs.copyWith(peakStartHour: v),
                      ),
                    ),
                    _HourSelector(
                      label: 'Peak stop',
                      value: prefs.peakStopHour,
                      onChanged: (v) => setState(
                        () => _draft = prefs.copyWith(peakStopHour: v),
                      ),
                    ),
                    TextFormField(
                      initialValue: prefs.peakPricePerKwh.toStringAsFixed(3),
                      decoration: const InputDecoration(
                        labelText: 'Peak price',
                        suffixText: '/ kWh',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (v) {
                        final parsed = double.tryParse(v);
                        if (parsed == null) return;
                        setState(
                          () => _draft =
                              prefs.copyWith(peakPricePerKwh: parsed),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _HourSelector extends StatelessWidget {
  const _HourSelector({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: DropdownButton<int>(
        value: value,
        items: [
          for (var i = 0; i < 24; i++)
            DropdownMenuItem(
              value: i,
              child: Text('${i.toString().padLeft(2, '0')}:00'),
            ),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
