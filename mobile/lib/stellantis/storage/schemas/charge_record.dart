import 'package:isar/isar.dart';

part 'charge_record.g.dart';

/// Persisted charge session; mirrors the legacy `battery` SQLite table.
@collection
class ChargeRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late String vin;

  @Index()
  late DateTime startAt;

  DateTime? stopAt;
  double? startLevel;
  double? endLevel;
  double? kw;
  double? price;
  double? co2;
  String? chargingMode;
  double? mileage;
}
