import 'package:dart_mappable/dart_mappable.dart';
import 'package:stellantis_mobile/stellantis/models/energy.dart';
import 'package:stellantis_mobile/stellantis/models/position.dart';

part 'vehicle_status.mapper.dart';

@MappableEnum(defaultValue: IgnitionType.unknown)
enum IgnitionType {
  @MappableValue('StartUp')
  startUp,
  @MappableValue('Stop')
  stop,
  @MappableValue('Free')
  free,
  unknown,
}

@MappableClass()
class IgnitionModel with IgnitionModelMappable {
  const IgnitionModel({this.type});

  final IgnitionType? type;
}

@MappableClass()
class KineticModel with KineticModelMappable {
  const KineticModel({this.moving, this.speed});

  final bool? moving;

  /// Speed in km/h.
  final double? speed;
}

@MappableEnum(defaultValue: DoorLockStatus.unknown)
enum DoorLockStatus {
  @MappableValue('Locked')
  locked,
  @MappableValue('Unlocked')
  unlocked,
  @MappableValue('SuperLocked')
  superLocked,
  unknown,
}

@MappableClass()
class DoorsStateOpening with DoorsStateOpeningMappable {
  const DoorsStateOpening({
    this.frontLeft,
    this.frontRight,
    this.rearLeft,
    this.rearRight,
    this.trunk,
    this.roofWindow,
    this.hood,
  });

  @MappableField(key: 'frontLeft')
  final String? frontLeft;
  @MappableField(key: 'frontRight')
  final String? frontRight;
  @MappableField(key: 'rearLeft')
  final String? rearLeft;
  @MappableField(key: 'rearRight')
  final String? rearRight;

  final String? trunk;

  @MappableField(key: 'roofWindow')
  final String? roofWindow;

  final String? hood;
}

@MappableClass()
class DoorsStateModel with DoorsStateModelMappable {
  const DoorsStateModel({this.lockedStates, this.opening});

  @MappableField(key: 'lockedStates')
  final DoorLockStatus? lockedStates;

  final DoorsStateOpening? opening;
}

@MappableEnum(defaultValue: AirConditioningStatus.unknown)
enum AirConditioningStatus {
  @MappableValue('Enabled')
  enabled,
  @MappableValue('Disabled')
  disabled,
  @MappableValue('Error')
  error,
  unknown,
}

@MappableClass()
class PreconditioningProgram with PreconditioningProgramMappable {
  const PreconditioningProgram({
    this.enabled,
    this.slot,
    this.start,
    this.recurrence,
  });

  final bool? enabled;
  final int? slot;
  final String? start;
  final List<String>? recurrence;
}

@MappableClass()
class AirConditioningModel with AirConditioningModelMappable {
  const AirConditioningModel({this.status, this.updatedAt, this.programs});

  final AirConditioningStatus? status;

  @MappableField(key: 'updatedAt')
  final DateTime? updatedAt;

  final List<PreconditioningProgram>? programs;
}

@MappableClass()
class PreconditioningModel with PreconditioningModelMappable {
  const PreconditioningModel({this.airConditioning});

  @MappableField(key: 'airConditioning')
  final AirConditioningModel? airConditioning;
}

@MappableClass()
class VehicleOdometer with VehicleOdometerMappable {
  const VehicleOdometer({this.mileage, this.updatedAt});

  final double? mileage;

  @MappableField(key: 'updatedAt')
  final DateTime? updatedAt;
}

/// Full status payload returned by `GET /user/vehicles/{id}/status`.
@MappableClass()
class VehicleStatusModel with VehicleStatusModelMappable {
  const VehicleStatusModel({
    this.energy,
    this.doorsState,
    this.ignition,
    this.kinetic,
    this.lastPosition,
    this.preconditioning,
    this.timedOdometer,
  });

  final List<EnergyModel>? energy;

  @MappableField(key: 'doorsState')
  final DoorsStateModel? doorsState;

  final IgnitionModel? ignition;
  final KineticModel? kinetic;

  @MappableField(key: 'lastPosition')
  final PositionModel? lastPosition;

  /// Note: the API spells this "preconditioning" (one n).
  @MappableField(key: 'preconditioning')
  final PreconditioningModel? preconditioning;

  @MappableField(key: 'odometer')
  final VehicleOdometer? timedOdometer;

  EnergyModel? get electricEnergy =>
      energy?.where((e) => e.type == EnergyType.electric).firstOrNull;

  EnergyModel? get fuelEnergy =>
      energy?.where((e) => e.type == EnergyType.fuel).firstOrNull;
}
