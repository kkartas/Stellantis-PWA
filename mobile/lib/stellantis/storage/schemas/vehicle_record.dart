import 'package:isar/isar.dart';

part 'vehicle_record.g.dart';

@collection
class VehicleRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String vin;

  late String brand;
  late String label;
  String? modelName;
  double batteryPower = 0;
  double fuelCapacity = 0;
  DateTime? lastSeenAt;
}
