import 'package:isar/isar.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/status_snapshot.dart';

class StatusRepository {
  StatusRepository(this._isar);

  final Isar _isar;

  Stream<StatusSnapshot?> watchLatestForVin(String vin) =>
      _isar.statusSnapshots
          .where()
          .vinEqualTo(vin)
          .sortByTimestampDesc()
          .limit(1)
          .watch(fireImmediately: true)
          .map((list) => list.isEmpty ? null : list.first);

  Future<void> save(StatusSnapshot snapshot) =>
      _isar.writeTxn(() => _isar.statusSnapshots.put(snapshot));

  Future<void> pruneOlderThan(String vin, DateTime cutoff) =>
      _isar.writeTxn(
        () => _isar.statusSnapshots
            .filter()
            .vinEqualTo(vin)
            .and()
            .timestampLessThan(cutoff)
            .deleteAll(),
      );
}
