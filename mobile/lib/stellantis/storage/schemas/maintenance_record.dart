import 'package:isar/isar.dart';

part 'maintenance_record.g.dart';

@collection
class MaintenanceRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late String vin;

  late String serviceType;
  DateTime? dueDate;
  double? dueMileage;
  bool completed = false;
  DateTime? completedAt;
}
