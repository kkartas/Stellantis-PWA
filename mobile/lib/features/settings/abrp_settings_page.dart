import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/features/settings/data/integration_preferences.dart';

class AbrpSettingsPage extends ConsumerStatefulWidget {
  const AbrpSettingsPage({super.key});

  @override
  ConsumerState<AbrpSettingsPage> createState() => _AbrpSettingsPageState();
}

class _AbrpSettingsPageState extends ConsumerState<AbrpSettingsPage> {
  final _tokenController = TextEditingController();
  bool _enabled = false;
  bool _hydrated = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(integrationPrefsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('A Better Route Planner')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (prefs) {
          if (!_hydrated) {
            _enabled = prefs.abrpEnabled;
            _tokenController.text = prefs.abrpToken;
            _hydrated = true;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _InfoCard(
                text:
                    'When enabled, the app forwards live telemetry (battery, '
                    'speed, position) to ABRP so its routing engine can use '
                    'your real consumption data. Disable to stop sending.',
              ),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  value: _enabled,
                  title: const Text('Enable ABRP forwarding'),
                  subtitle: const Text(
                    'Requires a user token from abetterrouteplanner.com',
                  ),
                  onChanged: (v) => setState(() => _enabled = v),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User token',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _tokenController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Paste your ABRP token',
                        ),
                        enabled: _enabled,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await ref
                      .read(integrationPrefsControllerProvider.notifier)
                      .setAbrp(
                        enabled: _enabled,
                        token: _tokenController.text.trim(),
                      );
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('ABRP settings saved')),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
