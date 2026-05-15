import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/features/vehicles/data/selected_vehicle.dart';
import 'package:stellantis_mobile/stellantis/storage/repositories.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/status_snapshot.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/vehicle_record.dart';

/// Latest cached [StatusSnapshot] for the active vehicle. SWR — emits the
/// cached value immediately, then updates whenever the Isar collection
/// changes. Returns null while there is no selected VIN or no snapshot yet.
final latestStatusProvider = StreamProvider<StatusSnapshot?>((ref) async* {
  final vin = ref.watch(selectedVinProvider);
  if (vin == null) {
    yield null;
    return;
  }
  final repo = await ref.watch(statusRepoProvider.future);
  yield* repo.watchLatestForVin(vin);
});

/// The active [VehicleRecord] from Isar. Used to show label/brand on the
/// dashboard hero independently of the live status stream.
final activeVehicleProvider = StreamProvider<VehicleRecord?>((ref) async* {
  final vin = ref.watch(selectedVinProvider);
  if (vin == null) {
    yield null;
    return;
  }
  final repo = await ref.watch(vehicleRepoProvider.future);
  yield* repo.watchAll().map(
        (vehicles) => vehicles.where((v) => v.vin == vin).firstOrNull,
      );
});
