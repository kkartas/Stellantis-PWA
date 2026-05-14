import 'package:isar/isar.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/alert_record.dart';

class AlertRepository {
  AlertRepository(this._isar);

  final Isar _isar;

  Stream<List<AlertRecord>> watchUnacknowledgedForVin(String vin) =>
      _isar.alertRecords
          .filter()
          .vinEqualTo(vin)
          .and()
          .acknowledgedEqualTo(false)
          .watch(fireImmediately: true);

  Future<void> save(AlertRecord record) =>
      _isar.writeTxn(() => _isar.alertRecords.put(record));

  Future<void> acknowledge(Id id) async {
    await _isar.writeTxn(() async {
      final record = await _isar.alertRecords.get(id);
      if (record == null) return;
      record.acknowledged = true;
      await _isar.alertRecords.put(record);
    });
  }
}
