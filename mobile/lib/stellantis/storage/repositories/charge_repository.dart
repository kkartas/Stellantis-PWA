import 'package:isar/isar.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/charge_record.dart';

class ChargeRepository {
  ChargeRepository(this._isar);

  final Isar _isar;

  Stream<List<ChargeRecord>> watchForVin(String vin) =>
      _isar.chargeRecords
          .where()
          .vinEqualTo(vin)
          .sortByStartAtDesc()
          .watch(fireImmediately: true);

  Future<List<ChargeRecord>> getForVin(String vin) =>
      _isar.chargeRecords
          .where()
          .vinEqualTo(vin)
          .sortByStartAtDesc()
          .findAll();

  Future<void> saveAll(List<ChargeRecord> records) =>
      _isar.writeTxn(() => _isar.chargeRecords.putAll(records));
}
