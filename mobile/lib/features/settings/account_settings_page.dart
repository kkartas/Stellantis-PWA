import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/features/auth/data/brand_session.dart';
import 'package:stellantis_mobile/features/auth/data/session_service.dart';
import 'package:stellantis_mobile/features/vehicles/data/selected_vehicle.dart';
import 'package:stellantis_mobile/stellantis/storage/repositories.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/vehicle_record.dart';

final _vehiclesProvider =
    StreamProvider.autoDispose<List<VehicleRecord>>((ref) async* {
  final repo = await ref.watch(vehicleRepoProvider.future);
  yield* repo.watchAll();
});

class AccountSettingsPage extends ConsumerWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(selectedBrandSessionProvider);
    final activeVin = ref.watch(selectedVinProvider);
    final vehiclesAsync = ref.watch(_vehiclesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Signed in to',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session == null
                        ? 'Not signed in'
                        : '${_brandName(session)} · ${session.countryCode}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Vehicles', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          vehiclesAsync.when(
            loading: () =>
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: LinearProgressIndicator(),
                ),
            error: (e, _) => Text('Error: $e'),
            data: (vehicles) {
              if (vehicles.isEmpty) {
                return const Card(
                  child: ListTile(
                    leading: Icon(Icons.directions_car_outlined),
                    title: Text('No vehicles paired'),
                  ),
                );
              }
              return Column(
                children: [
                  for (final v in vehicles)
                    Card(
                      child: ListTile(
                        leading: Icon(
                          v.vin == activeVin
                              ? Icons.directions_car_filled
                              : Icons.directions_car_outlined,
                          color: v.vin == activeVin
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        title: Text(v.label),
                        subtitle: Text('VIN ${v.vin}'),
                        trailing: v.vin == activeVin
                            ? const Text('Active')
                            : TextButton(
                                onPressed: () async {
                                  await ref
                                      .read(selectedVehicleStoreProvider)
                                      .save(v.vin);
                                  ref
                                      .read(selectedVinProvider.notifier)
                                      .state = v.vin;
                                },
                                child: const Text('Switch'),
                              ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: () => _confirmLogout(context, ref),
            style: FilledButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.errorContainer,
              foregroundColor:
                  Theme.of(context).colorScheme.onErrorContainer,
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Sign out'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You\'ll need to sign in again and set up OTP. Trip history and '
          'charging sessions stored on this device will be erased.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(sessionServiceProvider).logout();
    if (!context.mounted) return;
    context.go('/brand-picker');
  }
}

String _brandName(BrandSession session) {
  final n = session.brand.name;
  if (n == 'alfaRomeo') return 'Alfa Romeo';
  return n[0].toUpperCase() + n.substring(1);
}
