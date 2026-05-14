import 'package:dart_mappable/dart_mappable.dart';

part 'energy.mapper.dart';

/// "Fuel" or "Electric" from the API `type` field.
@MappableEnum(defaultValue: EnergyType.unknown)
enum EnergyType {
  @MappableValue('Fuel')
  fuel,
  @MappableValue('Electric')
  electric,
  unknown,
}

/// Charging status values from the PSA API `status` field.
@MappableEnum(defaultValue: ChargingStatus.disconnected)
enum ChargingStatus {
  @MappableValue('Disconnected')
  disconnected,
  @MappableValue('InProgress')
  inProgress,
  @MappableValue('Failure')
  failure,
  @MappableValue('Stopped')
  stopped,
  @MappableValue('Finished')
  finished,
}

@MappableClass()
class EnergyBatteryHealth with EnergyBatteryHealthMappable {
  const EnergyBatteryHealth({this.capacity, this.resistance, this.state});

  /// Usable capacity in Wh.
  final double? capacity;

  /// Internal resistance in mΩ.
  final double? resistance;

  final String? state;
}

@MappableClass()
class EnergyBattery with EnergyBatteryMappable {
  const EnergyBattery({this.capacity, this.health});

  /// Total battery capacity in Wh.
  final double? capacity;

  final EnergyBatteryHealth? health;
}

@MappableClass()
class EnergyCharging with EnergyChargingMappable {
  const EnergyCharging({
    this.status,
    this.plugged,
    this.chargingMode,
    this.chargingRate,
    this.remainingTime,
    this.nextDelayedTime,
  });

  final ChargingStatus? status;

  final bool? plugged;

  @MappableField(key: 'chargingMode')
  final String? chargingMode;

  /// Charging speed in km/h equivalent.
  @MappableField(key: 'chargingRate')
  final int? chargingRate;

  /// ISO 8601 duration string, e.g. "PT1H30M".
  @MappableField(key: 'remainingTime')
  final String? remainingTime;

  @MappableField(key: 'nextDelayedTime')
  final String? nextDelayedTime;
}

@MappableClass()
class EnergyModel with EnergyModelMappable {
  const EnergyModel({
    this.type,
    this.level,
    this.autonomy,
    this.residual,
    this.consumption,
    this.battery,
    this.charging,
    this.updatedAt,
  });

  final EnergyType? type;

  /// State of charge 0–100.
  final double? level;

  /// Remaining range in km.
  final double? autonomy;

  /// Residual electric energy in kWh.
  final double? residual;

  /// Instant consumption (fuel only), in L/100 km.
  final double? consumption;

  final EnergyBattery? battery;
  final EnergyCharging? charging;

  @MappableField(key: 'updatedAt')
  final DateTime? updatedAt;
}
