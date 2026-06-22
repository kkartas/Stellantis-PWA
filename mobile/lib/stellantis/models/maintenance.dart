import 'package:dart_mappable/dart_mappable.dart';

part 'maintenance.mapper.dart';

/// Next-maintenance details returned by `GET /user/vehicles/{id}/maintenance`.
///
/// Expresses the number of days and the mileage until the next scheduled
/// maintenance. Values are negative when the next maintenance (day or mileage)
/// has already passed. At least one of the two figures is always provided.
@MappableClass()
class MaintenanceModel with MaintenanceModelMappable {
  const MaintenanceModel({
    this.daysBeforeMaintenance,
    this.mileageBeforeMaintenance,
    this.createdAt,
    this.updatedAt,
  });

  @MappableField(key: 'daysBeforeMaintenance')
  final int? daysBeforeMaintenance;

  @MappableField(key: 'mileageBeforeMaintenance')
  final double? mileageBeforeMaintenance;

  @MappableField(key: 'createdAt')
  final DateTime? createdAt;

  @MappableField(key: 'updatedAt')
  final DateTime? updatedAt;

  /// Whether the next maintenance (by days or mileage) is already overdue.
  bool get isOverdue =>
      (daysBeforeMaintenance != null && daysBeforeMaintenance! < 0) ||
      (mileageBeforeMaintenance != null && mileageBeforeMaintenance! < 0);
}
