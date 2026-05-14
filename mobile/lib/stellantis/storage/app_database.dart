import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/alert_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/charge_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/maintenance_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/soh_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/status_snapshot.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/trip_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/vehicle_record.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
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
});
