import 'package:isar/isar.dart';

part 'soh_record.g.dart';

/// Battery state-of-health sample; mirrors the legacy `battery_soh` table.
@collection
class SohRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late String vin;

  @Index()
  late DateTime date;

  late double resistance;
}
