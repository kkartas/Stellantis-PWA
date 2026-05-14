import 'package:isar/isar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/charge_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/soh_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/status_snapshot.dart';

class LegacyImportResult {
  const LegacyImportResult({
    required this.snapshots,
    required this.charges,
    required this.sohReadings,
  });

  final int snapshots;
  final int charges;
  final int sohReadings;

  @override
  String toString() =>
      'Imported $snapshots snapshots, $charges charges, '
      '$sohReadings SOH readings.';
}

/// Reads legacy `info.db` SQLite tables and writes them into Isar.
///
/// The legacy schema stores battery resistance in a column named `level`
/// inside `battery_soh` — mapped here to [SohRecord.resistance].
class LegacyDbImporter {
  const LegacyDbImporter({required this.isar});

  final Isar isar;

  Future<LegacyImportResult> importFrom(String dbPath) async {
    final db = await openDatabase(dbPath, readOnly: true);
    try {
      final snapshotRows = await db.rawQuery('SELECT * FROM position');
      final chargeRows = await db.rawQuery('SELECT * FROM battery');
      final sohRows = await db.rawQuery('SELECT * FROM battery_soh');

      final snapshots = snapshotRows.map(_snapshotFromRow).toList();
      final charges = chargeRows.map(_chargeFromRow).toList();
      final sohs = sohRows.map(_sohFromRow).toList();

      await isar.writeTxn(() async {
        await isar.statusSnapshots.putAll(snapshots);
        await isar.chargeRecords.putAll(charges);
        await isar.sohRecords.putAll(sohs);
      });

      return LegacyImportResult(
        snapshots: snapshots.length,
        charges: charges.length,
        sohReadings: sohs.length,
      );
    } finally {
      await db.close();
    }
  }

  static StatusSnapshot _snapshotFromRow(Map<String, Object?> row) =>
      StatusSnapshot()
        ..vin = row['VIN'] as String? ?? ''
        ..timestamp = _parseDate(row['Timestamp'] as String? ?? '')
        ..latitude = (row['latitude'] as num?)?.toDouble()
        ..longitude = (row['longitude'] as num?)?.toDouble()
        ..mileage = (row['mileage'] as num?)?.toDouble()
        ..batteryLevel = row['level'] as int?
        ..fuelLevel = row['level_fuel'] as int?;

  static ChargeRecord _chargeFromRow(Map<String, Object?> row) {
    final stopAtStr = row['stop_at'] as String?;
    return ChargeRecord()
      ..vin = row['VIN'] as String? ?? ''
      ..startAt = _parseDate(row['start_at'] as String? ?? '')
      ..stopAt = stopAtStr == null ? null : _parseDate(stopAtStr)
      ..startLevel = (row['start_level'] as num?)?.toDouble()
      ..endLevel = (row['end_level'] as num?)?.toDouble()
      ..co2 = (row['co2'] as num?)?.toDouble()
      ..kw = (row['kw'] as num?)?.toDouble()
      ..price = (row['price'] as num?)?.toDouble()
      ..chargingMode = row['charging_mode'] as String?
      ..mileage = (row['mileage'] as num?)?.toDouble();
  }

  static SohRecord _sohFromRow(Map<String, Object?> row) =>
      SohRecord()
        ..vin = row['VIN'] as String? ?? ''
        ..date = _parseDate(row['date'] as String? ?? '')
        ..resistance = (row['level'] as num?)?.toDouble() ?? 0;

  static DateTime _parseDate(String s) =>
      DateTime.parse(s.replaceFirst(' ', 'T'));
}
