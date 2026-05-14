import 'package:isar/isar.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/vehicle_record.dart';

class VehicleRepository {
  VehicleRepository(this._isar);

  final Isar _isar;

  Stream<List<VehicleRecord>> watchAll() =>
      _isar.vehicleRecords.where().watch(fireImmediately: true);

  Future<VehicleRecord?> findByVin(String vin) =>
      _isar.vehicleRecords.where().vinEqualTo(vin).findFirst();

  Future<void> save(VehicleRecord record) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.vehicleRecords
          .where()
          .vinEqualTo(record.vin)
          .findFirst();
      if (existing != null) record.id = existing.id;
      await _isar.vehicleRecords.put(record);
    });
  }
}
