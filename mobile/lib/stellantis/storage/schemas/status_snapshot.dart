import 'package:isar/isar.dart';

part 'status_snapshot.g.dart';

/// One API poll snapshot for a vehicle; keyed by VIN + timestamp.
@collection
class StatusSnapshot {
  Id id = Isar.autoIncrement;

  @Index()
  late String vin;

  @Index()
  late DateTime timestamp;

  double? latitude;
  double? longitude;
  double? mileage;
  int? batteryLevel;
  String? chargingStatus;
  String? chargingMode;
  double? batteryResistance;
  int? fuelLevel;
  double? speed;
}
