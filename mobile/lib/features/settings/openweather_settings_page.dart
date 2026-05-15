import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/features/settings/data/integration_preferences.dart';

class OpenWeatherSettingsPage extends ConsumerStatefulWidget {
  const OpenWeatherSettingsPage({super.key});

  @override
  ConsumerState<OpenWeatherSettingsPage> createState() =>
      _OpenWeatherSettingsPageState();
}

class _OpenWeatherSettingsPageState
    extends ConsumerState<OpenWeatherSettingsPage> {
  final _controller = TextEditingController();
  bool _hydrated = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(integrationPrefsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('OpenWeather')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (prefs) {
          if (!_hydrated) {
            _controller.text = prefs.openWeatherApiKey;
            _hydrated = true;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.wb_sunny_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Stellantis does not always report ambient temperature. '
                        'Add an OpenWeather API key and the app will fall back '
                        'to your last known position\'s outdoor temp when the '
                        'car has not reported one recently.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'API key',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '32-character key from openweathermap.org',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(integrationPrefsControllerProvider.notifier)
                      .setOpenWeatherKey(_controller.text.trim());
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OpenWeather key saved')),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Save'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
