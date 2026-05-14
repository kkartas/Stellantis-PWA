import 'package:isar/isar.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/trip_record.dart';

class TripRepository {
  TripRepository(this._isar);

  final Isar _isar;

  Stream<List<TripRecord>> watchForVin(String vin) =>
      _isar.tripRecords
          .where()
          .vinEqualTo(vin)
          .sortByStartAtDesc()
          .watch(fireImmediately: true);

  Future<List<TripRecord>> getForVin(String vin) =>
      _isar.tripRecords.where().vinEqualTo(vin).sortByStartAtDesc().findAll();

  Future<void> saveAll(List<TripRecord> records) =>
      _isar.writeTxn(() => _isar.tripRecords.putAll(records));
}
