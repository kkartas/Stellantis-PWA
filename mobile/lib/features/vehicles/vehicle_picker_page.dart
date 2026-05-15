import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/core/logging/logger.dart';
import 'package:stellantis_mobile/features/auth/data/brand_session.dart';
import 'package:stellantis_mobile/features/vehicles/data/selected_vehicle.dart';
import 'package:stellantis_mobile/stellantis/api/vehicles_api.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';
import 'package:stellantis_mobile/stellantis/brands/secrets_template.dart';
import 'package:stellantis_mobile/stellantis/models/vehicle.dart';
import 'package:stellantis_mobile/stellantis/storage/repositories.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/vehicle_record.dart';

const _log = AppLogger('VehiclePicker');

/// Fetches vehicles from the API and writes them into Isar. The list is the
/// authoritative source after this runs.
final _fetchedVehiclesProvider = FutureProvider<List<VehicleModel>>((ref) async {
  final session = ref.watch(selectedBrandSessionProvider);
  if (session == null) return const [];
  final clientId = BrandSecrets.clientId[session.cacheKey] ?? '';
  final realm = BrandConstants.realm[session.brand] ?? '';
  final api = ref.watch(vehiclesApiProvider);
  final vehicles = await api.getVehicles(clientId: clientId, realm: realm);

  // Persist into Isar so downstream features (theme detector, dashboard)
  // can read the brand label without depending on the network.
  final repo = await ref.read(vehicleRepoProvider.future);
  for (final v in vehicles) {
    await repo.save(
      VehicleRecord()
        ..vin = v.vin
        ..brand = v.brand ?? session.brand.name
        ..label = v.label ?? v.vin,
    );
  }
  return vehicles;
});

class VehiclePickerPage extends ConsumerWidget {
  const VehiclePickerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(_fetchedVehiclesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Choose your vehicle')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _ErrorView(
          message: 'Could not load vehicles. Pull to retry.',
          onRetry: () => ref.invalidate(_fetchedVehiclesProvider),
        ),
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return _ErrorView(
              message:
                  'No vehicles were returned for this account. Make sure '
                  'your car is paired in the official app.',
              onRetry: () => ref.invalidate(_fetchedVehiclesProvider),
            );
          }

          if (vehicles.length == 1) {
            // Auto-pick the only car — no point making the user tap.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              _selectAndGo(context, ref, vehicles.first);
            });
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final v = vehicles[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const Icon(Icons.directions_car_filled, size: 36),
                  title: Text(
                    v.label ?? 'Vehicle ${v.vin.substring(v.vin.length - 6)}',
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text('VIN ${v.vin}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectAndGo(context, ref, v),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _selectAndGo(
    BuildContext context,
    WidgetRef ref,
    VehicleModel vehicle,
  ) async {
    _log.i('Selected vehicle ${vehicle.vin}');
    await ref.read(selectedVehicleStoreProvider).save(vehicle.vin);
    ref.read(selectedVinProvider.notifier).state = vehicle.vin;
    if (!context.mounted) return;
    context.go('/');
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.car_crash_outlined, size: 56),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
