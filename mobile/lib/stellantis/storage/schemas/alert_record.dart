import 'package:isar/isar.dart';

part 'alert_record.g.dart';

@collection
class AlertRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late String vin;

  late String type;
  late DateTime createdAt;
  bool acknowledged = false;
  String? message;
}
