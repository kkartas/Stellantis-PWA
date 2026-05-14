import 'package:isar/isar.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/soh_record.dart';

class SohRepository {
  SohRepository(this._isar);

  final Isar _isar;

  Stream<List<SohRecord>> watchForVin(String vin) =>
      _isar.sohRecords
          .where()
          .vinEqualTo(vin)
          .sortByDate()
          .watch(fireImmediately: true);

  Future<List<SohRecord>> getForVin(String vin) =>
      _isar.sohRecords.where().vinEqualTo(vin).sortByDate().findAll();

  Future<void> save(SohRecord record) =>
      _isar.writeTxn(() => _isar.sohRecords.put(record));
}
