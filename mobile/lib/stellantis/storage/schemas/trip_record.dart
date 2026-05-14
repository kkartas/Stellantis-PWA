import 'package:isar/isar.dart';

part 'trip_record.g.dart';

@collection
class TripRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late String vin;

  @Index()
  late DateTime startAt;

  DateTime? endAt;
  double distance = 0;
  double? consumption;
  double? consumptionFuel;
  double? speedAverage;
  double? mileage;
}
