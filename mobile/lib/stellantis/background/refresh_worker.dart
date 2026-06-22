import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/alert_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/charge_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/maintenance_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/soh_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/status_snapshot.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/trip_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/vehicle_record.dart';
import 'package:workmanager/workmanager.dart';

const _taskName = 'vehicleStatusRefresh';
const _uniqueName = 'stellantis.vehicle.refresh';
const _refreshInterval = Duration(minutes: 30);

/// Prune snapshots older than this to keep on-device storage bounded.
const _snapshotRetention = Duration(hours: 48);

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == _taskName) await _runRefresh();
    return true;
  });
}

class RefreshWorker {
  const RefreshWorker._();

  static Future<void> initialize() => Workmanager().initialize(
        callbackDispatcher,
      );

  static Future<void> schedule() => Workmanager().registerPeriodicTask(
        _uniqueName,
        _taskName,
        frequency: _refreshInterval,
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );

  static Future<void> cancel() =>
      Workmanager().cancelByUniqueName(_uniqueName);
}

Future<void> _runRefresh() async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      VehicleRecordSchema,
      StatusSnapshotSchema,
      TripRecordSchema,
      ChargeRecordSchema,
      SohRecordSchema,
      AlertRecordSchema,
      MaintenanceRecordSchema,
    ],
    directory: dir.path,
    name: 'stellantis',
  );

  final cutoff = DateTime.now().subtract(_snapshotRetention);
  final vehicles = await isar.vehicleRecords.where().findAll();
  for (final vehicle in vehicles) {
    await isar.writeTxn(
      () => isar.statusSnapshots
          .filter()
          .vinEqualTo(vehicle.vin)
          .and()
          .timestampLessThan(cutoff)
          .deleteAll(),
    );
  }

  await isar.close();
}
