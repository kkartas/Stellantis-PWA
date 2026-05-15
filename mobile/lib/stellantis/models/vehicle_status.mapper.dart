// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'vehicle_status.dart';

class IgnitionTypeMapper extends EnumMapper<IgnitionType> {
  IgnitionTypeMapper._();

  static IgnitionTypeMapper? _instance;
  static IgnitionTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IgnitionTypeMapper._());
    }
    return _instance!;
  }

  static IgnitionType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  IgnitionType decode(dynamic value) {
    switch (value) {
      case 'StartUp':
        return IgnitionType.startUp;
      case 'Stop':
        return IgnitionType.stop;
      case 'Free':
        return IgnitionType.free;
      case 'unknown':
        return IgnitionType.unknown;
      default:
        return IgnitionType.values[3];
    }
  }

  @override
  dynamic encode(IgnitionType self) {
    switch (self) {
      case IgnitionType.startUp:
        return 'StartUp';
      case IgnitionType.stop:
        return 'Stop';
      case IgnitionType.free:
        return 'Free';
      case IgnitionType.unknown:
        return 'unknown';
    }
  }
}

extension IgnitionTypeMapperExtension on IgnitionType {
  dynamic toValue() {
    IgnitionTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<IgnitionType>(this);
  }
}

class DoorLockStatusMapper extends EnumMapper<DoorLockStatus> {
  DoorLockStatusMapper._();

  static DoorLockStatusMapper? _instance;
  static DoorLockStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DoorLockStatusMapper._());
    }
    return _instance!;
  }

  static DoorLockStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  DoorLockStatus decode(dynamic value) {
    switch (value) {
      case 'Locked':
        return DoorLockStatus.locked;
      case 'Unlocked':
        return DoorLockStatus.unlocked;
      case 'SuperLocked':
        return DoorLockStatus.superLocked;
      case 'unknown':
        return DoorLockStatus.unknown;
      default:
        return DoorLockStatus.values[3];
    }
  }

  @override
  dynamic encode(DoorLockStatus self) {
    switch (self) {
      case DoorLockStatus.locked:
        return 'Locked';
      case DoorLockStatus.unlocked:
        return 'Unlocked';
      case DoorLockStatus.superLocked:
        return 'SuperLocked';
      case DoorLockStatus.unknown:
        return 'unknown';
    }
  }
}

extension DoorLockStatusMapperExtension on DoorLockStatus {
  dynamic toValue() {
    DoorLockStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<DoorLockStatus>(this);
  }
}

class AirConditioningStatusMapper extends EnumMapper<AirConditioningStatus> {
  AirConditioningStatusMapper._();

  static AirConditioningStatusMapper? _instance;
  static AirConditioningStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AirConditioningStatusMapper._());
    }
    return _instance!;
  }

  static AirConditioningStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  AirConditioningStatus decode(dynamic value) {
    switch (value) {
      case 'Enabled':
        return AirConditioningStatus.enabled;
      case 'Disabled':
        return AirConditioningStatus.disabled;
      case 'Error':
        return AirConditioningStatus.error;
      case 'unknown':
        return AirConditioningStatus.unknown;
      default:
        return AirConditioningStatus.values[3];
    }
  }

  @override
  dynamic encode(AirConditioningStatus self) {
    switch (self) {
      case AirConditioningStatus.enabled:
        return 'Enabled';
      case AirConditioningStatus.disabled:
        return 'Disabled';
      case AirConditioningStatus.error:
        return 'Error';
      case AirConditioningStatus.unknown:
        return 'unknown';
    }
  }
}

extension AirConditioningStatusMapperExtension on AirConditioningStatus {
  dynamic toValue() {
    AirConditioningStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<AirConditioningStatus>(this);
  }
}

class IgnitionModelMapper extends ClassMapperBase<IgnitionModel> {
  IgnitionModelMapper._();

  static IgnitionModelMapper? _instance;
  static IgnitionModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IgnitionModelMapper._());
      IgnitionTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'IgnitionModel';

  static IgnitionType? _$type(IgnitionModel v) => v.type;
  static const Field<IgnitionModel, IgnitionType> _f$type =
      Field('type', _$type, opt: true);

  @override
  final MappableFields<IgnitionModel> fields = const {
    #type: _f$type,
  };

  static IgnitionModel _instantiate(DecodingData data) {
    return IgnitionModel(type: data.dec(_f$type));
  }

  @override
  final Function instantiate = _instantiate;

  static IgnitionModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<IgnitionModel>(map);
  }

  static IgnitionModel fromJson(String json) {
    return ensureInitialized().decodeJson<IgnitionModel>(json);
  }
}

mixin IgnitionModelMappable {
  String toJson() {
    return IgnitionModelMapper.ensureInitialized()
        .encodeJson<IgnitionModel>(this as IgnitionModel);
  }

  Map<String, dynamic> toMap() {
    return IgnitionModelMapper.ensureInitialized()
        .encodeMap<IgnitionModel>(this as IgnitionModel);
  }

  IgnitionModelCopyWith<IgnitionModel, IgnitionModel, IgnitionModel>
      get copyWith => _IgnitionModelCopyWithImpl(
          this as IgnitionModel, $identity, $identity);
  @override
  String toString() {
    return IgnitionModelMapper.ensureInitialized()
        .stringifyValue(this as IgnitionModel);
  }

  @override
  bool operator ==(Object other) {
    return IgnitionModelMapper.ensureInitialized()
        .equalsValue(this as IgnitionModel, other);
  }

  @override
  int get hashCode {
    return IgnitionModelMapper.ensureInitialized()
        .hashValue(this as IgnitionModel);
  }
}

extension IgnitionModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, IgnitionModel, $Out> {
  IgnitionModelCopyWith<$R, IgnitionModel, $Out> get $asIgnitionModel =>
      $base.as((v, t, t2) => _IgnitionModelCopyWithImpl(v, t, t2));
}

abstract class IgnitionModelCopyWith<$R, $In extends IgnitionModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({IgnitionType? type});
  IgnitionModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _IgnitionModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, IgnitionModel, $Out>
    implements IgnitionModelCopyWith<$R, IgnitionModel, $Out> {
  _IgnitionModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<IgnitionModel> $mapper =
      IgnitionModelMapper.ensureInitialized();
  @override
  $R call({Object? type = $none}) =>
      $apply(FieldCopyWithData({if (type != $none) #type: type}));
  @override
  IgnitionModel $make(CopyWithData data) =>
      IgnitionModel(type: data.get(#type, or: $value.type));

  @override
  IgnitionModelCopyWith<$R2, IgnitionModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _IgnitionModelCopyWithImpl($value, $cast, t);
}

class KineticModelMapper extends ClassMapperBase<KineticModel> {
  KineticModelMapper._();

  static KineticModelMapper? _instance;
  static KineticModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = KineticModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'KineticModel';

  static bool? _$moving(KineticModel v) => v.moving;
  static const Field<KineticModel, bool> _f$moving =
      Field('moving', _$moving, opt: true);
  static double? _$speed(KineticModel v) => v.speed;
  static const Field<KineticModel, double> _f$speed =
      Field('speed', _$speed, opt: true);

  @override
  final MappableFields<KineticModel> fields = const {
    #moving: _f$moving,
    #speed: _f$speed,
  };

  static KineticModel _instantiate(DecodingData data) {
    return KineticModel(moving: data.dec(_f$moving), speed: data.dec(_f$speed));
  }

  @override
  final Function instantiate = _instantiate;

  static KineticModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<KineticModel>(map);
  }

  static KineticModel fromJson(String json) {
    return ensureInitialized().decodeJson<KineticModel>(json);
  }
}

mixin KineticModelMappable {
  String toJson() {
    return KineticModelMapper.ensureInitialized()
        .encodeJson<KineticModel>(this as KineticModel);
  }

  Map<String, dynamic> toMap() {
    return KineticModelMapper.ensureInitialized()
        .encodeMap<KineticModel>(this as KineticModel);
  }

  KineticModelCopyWith<KineticModel, KineticModel, KineticModel> get copyWith =>
      _KineticModelCopyWithImpl(this as KineticModel, $identity, $identity);
  @override
  String toString() {
    return KineticModelMapper.ensureInitialized()
        .stringifyValue(this as KineticModel);
  }

  @override
  bool operator ==(Object other) {
    return KineticModelMapper.ensureInitialized()
        .equalsValue(this as KineticModel, other);
  }

  @override
  int get hashCode {
    return KineticModelMapper.ensureInitialized()
        .hashValue(this as KineticModel);
  }
}

extension KineticModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, KineticModel, $Out> {
  KineticModelCopyWith<$R, KineticModel, $Out> get $asKineticModel =>
      $base.as((v, t, t2) => _KineticModelCopyWithImpl(v, t, t2));
}

abstract class KineticModelCopyWith<$R, $In extends KineticModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({bool? moving, double? speed});
  KineticModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _KineticModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, KineticModel, $Out>
    implements KineticModelCopyWith<$R, KineticModel, $Out> {
  _KineticModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<KineticModel> $mapper =
      KineticModelMapper.ensureInitialized();
  @override
  $R call({Object? moving = $none, Object? speed = $none}) =>
      $apply(FieldCopyWithData({
        if (moving != $none) #moving: moving,
        if (speed != $none) #speed: speed
      }));
  @override
  KineticModel $make(CopyWithData data) => KineticModel(
      moving: data.get(#moving, or: $value.moving),
      speed: data.get(#speed, or: $value.speed));

  @override
  KineticModelCopyWith<$R2, KineticModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _KineticModelCopyWithImpl($value, $cast, t);
}

class DoorsStateOpeningMapper extends ClassMapperBase<DoorsStateOpening> {
  DoorsStateOpeningMapper._();

  static DoorsStateOpeningMapper? _instance;
  static DoorsStateOpeningMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DoorsStateOpeningMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DoorsStateOpening';

  static String? _$frontLeft(DoorsStateOpening v) => v.frontLeft;
  static const Field<DoorsStateOpening, String> _f$frontLeft =
      Field('frontLeft', _$frontLeft, opt: true);
  static String? _$frontRight(DoorsStateOpening v) => v.frontRight;
  static const Field<DoorsStateOpening, String> _f$frontRight =
      Field('frontRight', _$frontRight, opt: true);
  static String? _$rearLeft(DoorsStateOpening v) => v.rearLeft;
  static const Field<DoorsStateOpening, String> _f$rearLeft =
      Field('rearLeft', _$rearLeft, opt: true);
  static String? _$rearRight(DoorsStateOpening v) => v.rearRight;
  static const Field<DoorsStateOpening, String> _f$rearRight =
      Field('rearRight', _$rearRight, opt: true);
  static String? _$trunk(DoorsStateOpening v) => v.trunk;
  static const Field<DoorsStateOpening, String> _f$trunk =
      Field('trunk', _$trunk, opt: true);
  static String? _$roofWindow(DoorsStateOpening v) => v.roofWindow;
  static const Field<DoorsStateOpening, String> _f$roofWindow =
      Field('roofWindow', _$roofWindow, opt: true);
  static String? _$hood(DoorsStateOpening v) => v.hood;
  static const Field<DoorsStateOpening, String> _f$hood =
      Field('hood', _$hood, opt: true);

  @override
  final MappableFields<DoorsStateOpening> fields = const {
    #frontLeft: _f$frontLeft,
    #frontRight: _f$frontRight,
    #rearLeft: _f$rearLeft,
    #rearRight: _f$rearRight,
    #trunk: _f$trunk,
    #roofWindow: _f$roofWindow,
    #hood: _f$hood,
  };

  static DoorsStateOpening _instantiate(DecodingData data) {
    return DoorsStateOpening(
        frontLeft: data.dec(_f$frontLeft),
        frontRight: data.dec(_f$frontRight),
        rearLeft: data.dec(_f$rearLeft),
        rearRight: data.dec(_f$rearRight),
        trunk: data.dec(_f$trunk),
        roofWindow: data.dec(_f$roofWindow),
        hood: data.dec(_f$hood));
  }

  @override
  final Function instantiate = _instantiate;

  static DoorsStateOpening fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DoorsStateOpening>(map);
  }

  static DoorsStateOpening fromJson(String json) {
    return ensureInitialized().decodeJson<DoorsStateOpening>(json);
  }
}

mixin DoorsStateOpeningMappable {
  String toJson() {
    return DoorsStateOpeningMapper.ensureInitialized()
        .encodeJson<DoorsStateOpening>(this as DoorsStateOpening);
  }

  Map<String, dynamic> toMap() {
    return DoorsStateOpeningMapper.ensureInitialized()
        .encodeMap<DoorsStateOpening>(this as DoorsStateOpening);
  }

  DoorsStateOpeningCopyWith<DoorsStateOpening, DoorsStateOpening,
          DoorsStateOpening>
      get copyWith => _DoorsStateOpeningCopyWithImpl(
          this as DoorsStateOpening, $identity, $identity);
  @override
  String toString() {
    return DoorsStateOpeningMapper.ensureInitialized()
        .stringifyValue(this as DoorsStateOpening);
  }

  @override
  bool operator ==(Object other) {
    return DoorsStateOpeningMapper.ensureInitialized()
        .equalsValue(this as DoorsStateOpening, other);
  }

  @override
  int get hashCode {
    return DoorsStateOpeningMapper.ensureInitialized()
        .hashValue(this as DoorsStateOpening);
  }
}

extension DoorsStateOpeningValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DoorsStateOpening, $Out> {
  DoorsStateOpeningCopyWith<$R, DoorsStateOpening, $Out>
      get $asDoorsStateOpening =>
          $base.as((v, t, t2) => _DoorsStateOpeningCopyWithImpl(v, t, t2));
}

abstract class DoorsStateOpeningCopyWith<$R, $In extends DoorsStateOpening,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {String? frontLeft,
      String? frontRight,
      String? rearLeft,
      String? rearRight,
      String? trunk,
      String? roofWindow,
      String? hood});
  DoorsStateOpeningCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _DoorsStateOpeningCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DoorsStateOpening, $Out>
    implements DoorsStateOpeningCopyWith<$R, DoorsStateOpening, $Out> {
  _DoorsStateOpeningCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DoorsStateOpening> $mapper =
      DoorsStateOpeningMapper.ensureInitialized();
  @override
  $R call(
          {Object? frontLeft = $none,
          Object? frontRight = $none,
          Object? rearLeft = $none,
          Object? rearRight = $none,
          Object? trunk = $none,
          Object? roofWindow = $none,
          Object? hood = $none}) =>
      $apply(FieldCopyWithData({
        if (frontLeft != $none) #frontLeft: frontLeft,
        if (frontRight != $none) #frontRight: frontRight,
        if (rearLeft != $none) #rearLeft: rearLeft,
        if (rearRight != $none) #rearRight: rearRight,
        if (trunk != $none) #trunk: trunk,
        if (roofWindow != $none) #roofWindow: roofWindow,
        if (hood != $none) #hood: hood
      }));
  @override
  DoorsStateOpening $make(CopyWithData data) => DoorsStateOpening(
      frontLeft: data.get(#frontLeft, or: $value.frontLeft),
      frontRight: data.get(#frontRight, or: $value.frontRight),
      rearLeft: data.get(#rearLeft, or: $value.rearLeft),
      rearRight: data.get(#rearRight, or: $value.rearRight),
      trunk: data.get(#trunk, or: $value.trunk),
      roofWindow: data.get(#roofWindow, or: $value.roofWindow),
      hood: data.get(#hood, or: $value.hood));

  @override
  DoorsStateOpeningCopyWith<$R2, DoorsStateOpening, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _DoorsStateOpeningCopyWithImpl($value, $cast, t);
}

class DoorsStateModelMapper extends ClassMapperBase<DoorsStateModel> {
  DoorsStateModelMapper._();

  static DoorsStateModelMapper? _instance;
  static DoorsStateModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DoorsStateModelMapper._());
      DoorLockStatusMapper.ensureInitialized();
      DoorsStateOpeningMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DoorsStateModel';

  static DoorLockStatus? _$lockedStates(DoorsStateModel v) => v.lockedStates;
  static const Field<DoorsStateModel, DoorLockStatus> _f$lockedStates =
      Field('lockedStates', _$lockedStates, opt: true);
  static DoorsStateOpening? _$opening(DoorsStateModel v) => v.opening;
  static const Field<DoorsStateModel, DoorsStateOpening> _f$opening =
      Field('opening', _$opening, opt: true);

  @override
  final MappableFields<DoorsStateModel> fields = const {
    #lockedStates: _f$lockedStates,
    #opening: _f$opening,
  };

  static DoorsStateModel _instantiate(DecodingData data) {
    return DoorsStateModel(
        lockedStates: data.dec(_f$lockedStates), opening: data.dec(_f$opening));
  }

  @override
  final Function instantiate = _instantiate;

  static DoorsStateModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DoorsStateModel>(map);
  }

  static DoorsStateModel fromJson(String json) {
    return ensureInitialized().decodeJson<DoorsStateModel>(json);
  }
}

mixin DoorsStateModelMappable {
  String toJson() {
    return DoorsStateModelMapper.ensureInitialized()
        .encodeJson<DoorsStateModel>(this as DoorsStateModel);
  }

  Map<String, dynamic> toMap() {
    return DoorsStateModelMapper.ensureInitialized()
        .encodeMap<DoorsStateModel>(this as DoorsStateModel);
  }

  DoorsStateModelCopyWith<DoorsStateModel, DoorsStateModel, DoorsStateModel>
      get copyWith => _DoorsStateModelCopyWithImpl(
          this as DoorsStateModel, $identity, $identity);
  @override
  String toString() {
    return DoorsStateModelMapper.ensureInitialized()
        .stringifyValue(this as DoorsStateModel);
  }

  @override
  bool operator ==(Object other) {
    return DoorsStateModelMapper.ensureInitialized()
        .equalsValue(this as DoorsStateModel, other);
  }

  @override
  int get hashCode {
    return DoorsStateModelMapper.ensureInitialized()
        .hashValue(this as DoorsStateModel);
  }
}

extension DoorsStateModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DoorsStateModel, $Out> {
  DoorsStateModelCopyWith<$R, DoorsStateModel, $Out> get $asDoorsStateModel =>
      $base.as((v, t, t2) => _DoorsStateModelCopyWithImpl(v, t, t2));
}

abstract class DoorsStateModelCopyWith<$R, $In extends DoorsStateModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  DoorsStateOpeningCopyWith<$R, DoorsStateOpening, DoorsStateOpening>?
      get opening;
  $R call({DoorLockStatus? lockedStates, DoorsStateOpening? opening});
  DoorsStateModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _DoorsStateModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DoorsStateModel, $Out>
    implements DoorsStateModelCopyWith<$R, DoorsStateModel, $Out> {
  _DoorsStateModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DoorsStateModel> $mapper =
      DoorsStateModelMapper.ensureInitialized();
  @override
  DoorsStateOpeningCopyWith<$R, DoorsStateOpening, DoorsStateOpening>?
      get opening => $value.opening?.copyWith.$chain((v) => call(opening: v));
  @override
  $R call({Object? lockedStates = $none, Object? opening = $none}) =>
      $apply(FieldCopyWithData({
        if (lockedStates != $none) #lockedStates: lockedStates,
        if (opening != $none) #opening: opening
      }));
  @override
  DoorsStateModel $make(CopyWithData data) => DoorsStateModel(
      lockedStates: data.get(#lockedStates, or: $value.lockedStates),
      opening: data.get(#opening, or: $value.opening));

  @override
  DoorsStateModelCopyWith<$R2, DoorsStateModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _DoorsStateModelCopyWithImpl($value, $cast, t);
}

class PreconditioningProgramMapper
    extends ClassMapperBase<PreconditioningProgram> {
  PreconditioningProgramMapper._();

  static PreconditioningProgramMapper? _instance;
  static PreconditioningProgramMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PreconditioningProgramMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PreconditioningProgram';

  static bool? _$enabled(PreconditioningProgram v) => v.enabled;
  static const Field<PreconditioningProgram, bool> _f$enabled =
      Field('enabled', _$enabled, opt: true);
  static int? _$slot(PreconditioningProgram v) => v.slot;
  static const Field<PreconditioningProgram, int> _f$slot =
      Field('slot', _$slot, opt: true);
  static String? _$start(PreconditioningProgram v) => v.start;
  static const Field<PreconditioningProgram, String> _f$start =
      Field('start', _$start, opt: true);
  static List<String>? _$recurrence(PreconditioningProgram v) => v.recurrence;
  static const Field<PreconditioningProgram, List<String>> _f$recurrence =
      Field('recurrence', _$recurrence, opt: true);

  @override
  final MappableFields<PreconditioningProgram> fields = const {
    #enabled: _f$enabled,
    #slot: _f$slot,
    #start: _f$start,
    #recurrence: _f$recurrence,
  };

  static PreconditioningProgram _instantiate(DecodingData data) {
    return PreconditioningProgram(
        enabled: data.dec(_f$enabled),
        slot: data.dec(_f$slot),
        start: data.dec(_f$start),
        recurrence: data.dec(_f$recurrence));
  }

  @override
  final Function instantiate = _instantiate;

  static PreconditioningProgram fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PreconditioningProgram>(map);
  }

  static PreconditioningProgram fromJson(String json) {
    return ensureInitialized().decodeJson<PreconditioningProgram>(json);
  }
}

mixin PreconditioningProgramMappable {
  String toJson() {
    return PreconditioningProgramMapper.ensureInitialized()
        .encodeJson<PreconditioningProgram>(this as PreconditioningProgram);
  }

  Map<String, dynamic> toMap() {
    return PreconditioningProgramMapper.ensureInitialized()
        .encodeMap<PreconditioningProgram>(this as PreconditioningProgram);
  }

  PreconditioningProgramCopyWith<PreconditioningProgram, PreconditioningProgram,
          PreconditioningProgram>
      get copyWith => _PreconditioningProgramCopyWithImpl(
          this as PreconditioningProgram, $identity, $identity);
  @override
  String toString() {
    return PreconditioningProgramMapper.ensureInitialized()
        .stringifyValue(this as PreconditioningProgram);
  }

  @override
  bool operator ==(Object other) {
    return PreconditioningProgramMapper.ensureInitialized()
        .equalsValue(this as PreconditioningProgram, other);
  }

  @override
  int get hashCode {
    return PreconditioningProgramMapper.ensureInitialized()
        .hashValue(this as PreconditioningProgram);
  }
}

extension PreconditioningProgramValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PreconditioningProgram, $Out> {
  PreconditioningProgramCopyWith<$R, PreconditioningProgram, $Out>
      get $asPreconditioningProgram =>
          $base.as((v, t, t2) => _PreconditioningProgramCopyWithImpl(v, t, t2));
}

abstract class PreconditioningProgramCopyWith<
    $R,
    $In extends PreconditioningProgram,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get recurrence;
  $R call({bool? enabled, int? slot, String? start, List<String>? recurrence});
  PreconditioningProgramCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _PreconditioningProgramCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PreconditioningProgram, $Out>
    implements
        PreconditioningProgramCopyWith<$R, PreconditioningProgram, $Out> {
  _PreconditioningProgramCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PreconditioningProgram> $mapper =
      PreconditioningProgramMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
      get recurrence => $value.recurrence != null
          ? ListCopyWith(
              $value.recurrence!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(recurrence: v))
          : null;
  @override
  $R call(
          {Object? enabled = $none,
          Object? slot = $none,
          Object? start = $none,
          Object? recurrence = $none}) =>
      $apply(FieldCopyWithData({
        if (enabled != $none) #enabled: enabled,
        if (slot != $none) #slot: slot,
        if (start != $none) #start: start,
        if (recurrence != $none) #recurrence: recurrence
      }));
  @override
  PreconditioningProgram $make(CopyWithData data) => PreconditioningProgram(
      enabled: data.get(#enabled, or: $value.enabled),
      slot: data.get(#slot, or: $value.slot),
      start: data.get(#start, or: $value.start),
      recurrence: data.get(#recurrence, or: $value.recurrence));

  @override
  PreconditioningProgramCopyWith<$R2, PreconditioningProgram, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _PreconditioningProgramCopyWithImpl($value, $cast, t);
}

class AirConditioningModelMapper extends ClassMapperBase<AirConditioningModel> {
  AirConditioningModelMapper._();

  static AirConditioningModelMapper? _instance;
  static AirConditioningModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AirConditioningModelMapper._());
      AirConditioningStatusMapper.ensureInitialized();
      PreconditioningProgramMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AirConditioningModel';

  static AirConditioningStatus? _$status(AirConditioningModel v) => v.status;
  static const Field<AirConditioningModel, AirConditioningStatus> _f$status =
      Field('status', _$status, opt: true);
  static DateTime? _$updatedAt(AirConditioningModel v) => v.updatedAt;
  static const Field<AirConditioningModel, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, opt: true);
  static List<PreconditioningProgram>? _$programs(AirConditioningModel v) =>
      v.programs;
  static const Field<AirConditioningModel, List<PreconditioningProgram>>
      _f$programs = Field('programs', _$programs, opt: true);

  @override
  final MappableFields<AirConditioningModel> fields = const {
    #status: _f$status,
    #updatedAt: _f$updatedAt,
    #programs: _f$programs,
  };

  static AirConditioningModel _instantiate(DecodingData data) {
    return AirConditioningModel(
        status: data.dec(_f$status),
        updatedAt: data.dec(_f$updatedAt),
        programs: data.dec(_f$programs));
  }

  @override
  final Function instantiate = _instantiate;

  static AirConditioningModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AirConditioningModel>(map);
  }

  static AirConditioningModel fromJson(String json) {
    return ensureInitialized().decodeJson<AirConditioningModel>(json);
  }
}

mixin AirConditioningModelMappable {
  String toJson() {
    return AirConditioningModelMapper.ensureInitialized()
        .encodeJson<AirConditioningModel>(this as AirConditioningModel);
  }

  Map<String, dynamic> toMap() {
    return AirConditioningModelMapper.ensureInitialized()
        .encodeMap<AirConditioningModel>(this as AirConditioningModel);
  }

  AirConditioningModelCopyWith<AirConditioningModel, AirConditioningModel,
          AirConditioningModel>
      get copyWith => _AirConditioningModelCopyWithImpl(
          this as AirConditioningModel, $identity, $identity);
  @override
  String toString() {
    return AirConditioningModelMapper.ensureInitialized()
        .stringifyValue(this as AirConditioningModel);
  }

  @override
  bool operator ==(Object other) {
    return AirConditioningModelMapper.ensureInitialized()
        .equalsValue(this as AirConditioningModel, other);
  }

  @override
  int get hashCode {
    return AirConditioningModelMapper.ensureInitialized()
        .hashValue(this as AirConditioningModel);
  }
}

extension AirConditioningModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AirConditioningModel, $Out> {
  AirConditioningModelCopyWith<$R, AirConditioningModel, $Out>
      get $asAirConditioningModel =>
          $base.as((v, t, t2) => _AirConditioningModelCopyWithImpl(v, t, t2));
}

abstract class AirConditioningModelCopyWith<
    $R,
    $In extends AirConditioningModel,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
      $R,
      PreconditioningProgram,
      PreconditioningProgramCopyWith<$R, PreconditioningProgram,
          PreconditioningProgram>>? get programs;
  $R call(
      {AirConditioningStatus? status,
      DateTime? updatedAt,
      List<PreconditioningProgram>? programs});
  AirConditioningModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _AirConditioningModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AirConditioningModel, $Out>
    implements AirConditioningModelCopyWith<$R, AirConditioningModel, $Out> {
  _AirConditioningModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AirConditioningModel> $mapper =
      AirConditioningModelMapper.ensureInitialized();
  @override
  ListCopyWith<
      $R,
      PreconditioningProgram,
      PreconditioningProgramCopyWith<$R, PreconditioningProgram,
          PreconditioningProgram>>? get programs => $value.programs != null
      ? ListCopyWith($value.programs!, (v, t) => v.copyWith.$chain(t),
          (v) => call(programs: v))
      : null;
  @override
  $R call(
          {Object? status = $none,
          Object? updatedAt = $none,
          Object? programs = $none}) =>
      $apply(FieldCopyWithData({
        if (status != $none) #status: status,
        if (updatedAt != $none) #updatedAt: updatedAt,
        if (programs != $none) #programs: programs
      }));
  @override
  AirConditioningModel $make(CopyWithData data) => AirConditioningModel(
      status: data.get(#status, or: $value.status),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt),
      programs: data.get(#programs, or: $value.programs));

  @override
  AirConditioningModelCopyWith<$R2, AirConditioningModel, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _AirConditioningModelCopyWithImpl($value, $cast, t);
}

class PreconditioningModelMapper extends ClassMapperBase<PreconditioningModel> {
  PreconditioningModelMapper._();

  static PreconditioningModelMapper? _instance;
  static PreconditioningModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PreconditioningModelMapper._());
      AirConditioningModelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PreconditioningModel';

  static AirConditioningModel? _$airConditioning(PreconditioningModel v) =>
      v.airConditioning;
  static const Field<PreconditioningModel, AirConditioningModel>
      _f$airConditioning =
      Field('airConditioning', _$airConditioning, opt: true);

  @override
  final MappableFields<PreconditioningModel> fields = const {
    #airConditioning: _f$airConditioning,
  };

  static PreconditioningModel _instantiate(DecodingData data) {
    return PreconditioningModel(airConditioning: data.dec(_f$airConditioning));
  }

  @override
  final Function instantiate = _instantiate;

  static PreconditioningModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PreconditioningModel>(map);
  }

  static PreconditioningModel fromJson(String json) {
    return ensureInitialized().decodeJson<PreconditioningModel>(json);
  }
}

mixin PreconditioningModelMappable {
  String toJson() {
    return PreconditioningModelMapper.ensureInitialized()
        .encodeJson<PreconditioningModel>(this as PreconditioningModel);
  }

  Map<String, dynamic> toMap() {
    return PreconditioningModelMapper.ensureInitialized()
        .encodeMap<PreconditioningModel>(this as PreconditioningModel);
  }

  PreconditioningModelCopyWith<PreconditioningModel, PreconditioningModel,
          PreconditioningModel>
      get copyWith => _PreconditioningModelCopyWithImpl(
          this as PreconditioningModel, $identity, $identity);
  @override
  String toString() {
    return PreconditioningModelMapper.ensureInitialized()
        .stringifyValue(this as PreconditioningModel);
  }

  @override
  bool operator ==(Object other) {
    return PreconditioningModelMapper.ensureInitialized()
        .equalsValue(this as PreconditioningModel, other);
  }

  @override
  int get hashCode {
    return PreconditioningModelMapper.ensureInitialized()
        .hashValue(this as PreconditioningModel);
  }
}

extension PreconditioningModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PreconditioningModel, $Out> {
  PreconditioningModelCopyWith<$R, PreconditioningModel, $Out>
      get $asPreconditioningModel =>
          $base.as((v, t, t2) => _PreconditioningModelCopyWithImpl(v, t, t2));
}

abstract class PreconditioningModelCopyWith<
    $R,
    $In extends PreconditioningModel,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  AirConditioningModelCopyWith<$R, AirConditioningModel, AirConditioningModel>?
      get airConditioning;
  $R call({AirConditioningModel? airConditioning});
  PreconditioningModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _PreconditioningModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PreconditioningModel, $Out>
    implements PreconditioningModelCopyWith<$R, PreconditioningModel, $Out> {
  _PreconditioningModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PreconditioningModel> $mapper =
      PreconditioningModelMapper.ensureInitialized();
  @override
  AirConditioningModelCopyWith<$R, AirConditioningModel, AirConditioningModel>?
      get airConditioning => $value.airConditioning?.copyWith
          .$chain((v) => call(airConditioning: v));
  @override
  $R call({Object? airConditioning = $none}) => $apply(FieldCopyWithData(
      {if (airConditioning != $none) #airConditioning: airConditioning}));
  @override
  PreconditioningModel $make(CopyWithData data) => PreconditioningModel(
      airConditioning: data.get(#airConditioning, or: $value.airConditioning));

  @override
  PreconditioningModelCopyWith<$R2, PreconditioningModel, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _PreconditioningModelCopyWithImpl($value, $cast, t);
}

class VehicleOdometerMapper extends ClassMapperBase<VehicleOdometer> {
  VehicleOdometerMapper._();

  static VehicleOdometerMapper? _instance;
  static VehicleOdometerMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = VehicleOdometerMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'VehicleOdometer';

  static double? _$mileage(VehicleOdometer v) => v.mileage;
  static const Field<VehicleOdometer, double> _f$mileage =
      Field('mileage', _$mileage, opt: true);
  static DateTime? _$updatedAt(VehicleOdometer v) => v.updatedAt;
  static const Field<VehicleOdometer, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, opt: true);

  @override
  final MappableFields<VehicleOdometer> fields = const {
    #mileage: _f$mileage,
    #updatedAt: _f$updatedAt,
  };

  static VehicleOdometer _instantiate(DecodingData data) {
    return VehicleOdometer(
        mileage: data.dec(_f$mileage), updatedAt: data.dec(_f$updatedAt));
  }

  @override
  final Function instantiate = _instantiate;

  static VehicleOdometer fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<VehicleOdometer>(map);
  }

  static VehicleOdometer fromJson(String json) {
    return ensureInitialized().decodeJson<VehicleOdometer>(json);
  }
}

mixin VehicleOdometerMappable {
  String toJson() {
    return VehicleOdometerMapper.ensureInitialized()
        .encodeJson<VehicleOdometer>(this as VehicleOdometer);
  }

  Map<String, dynamic> toMap() {
    return VehicleOdometerMapper.ensureInitialized()
        .encodeMap<VehicleOdometer>(this as VehicleOdometer);
  }

  VehicleOdometerCopyWith<VehicleOdometer, VehicleOdometer, VehicleOdometer>
      get copyWith => _VehicleOdometerCopyWithImpl(
          this as VehicleOdometer, $identity, $identity);
  @override
  String toString() {
    return VehicleOdometerMapper.ensureInitialized()
        .stringifyValue(this as VehicleOdometer);
  }

  @override
  bool operator ==(Object other) {
    return VehicleOdometerMapper.ensureInitialized()
        .equalsValue(this as VehicleOdometer, other);
  }

  @override
  int get hashCode {
    return VehicleOdometerMapper.ensureInitialized()
        .hashValue(this as VehicleOdometer);
  }
}

extension VehicleOdometerValueCopy<$R, $Out>
    on ObjectCopyWith<$R, VehicleOdometer, $Out> {
  VehicleOdometerCopyWith<$R, VehicleOdometer, $Out> get $asVehicleOdometer =>
      $base.as((v, t, t2) => _VehicleOdometerCopyWithImpl(v, t, t2));
}

abstract class VehicleOdometerCopyWith<$R, $In extends VehicleOdometer, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({double? mileage, DateTime? updatedAt});
  VehicleOdometerCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _VehicleOdometerCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, VehicleOdometer, $Out>
    implements VehicleOdometerCopyWith<$R, VehicleOdometer, $Out> {
  _VehicleOdometerCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<VehicleOdometer> $mapper =
      VehicleOdometerMapper.ensureInitialized();
  @override
  $R call({Object? mileage = $none, Object? updatedAt = $none}) =>
      $apply(FieldCopyWithData({
        if (mileage != $none) #mileage: mileage,
        if (updatedAt != $none) #updatedAt: updatedAt
      }));
  @override
  VehicleOdometer $make(CopyWithData data) => VehicleOdometer(
      mileage: data.get(#mileage, or: $value.mileage),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt));

  @override
  VehicleOdometerCopyWith<$R2, VehicleOdometer, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _VehicleOdometerCopyWithImpl($value, $cast, t);
}

class VehicleStatusModelMapper extends ClassMapperBase<VehicleStatusModel> {
  VehicleStatusModelMapper._();

  static VehicleStatusModelMapper? _instance;
  static VehicleStatusModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = VehicleStatusModelMapper._());
      EnergyModelMapper.ensureInitialized();
      DoorsStateModelMapper.ensureInitialized();
      IgnitionModelMapper.ensureInitialized();
      KineticModelMapper.ensureInitialized();
      PositionModelMapper.ensureInitialized();
      PreconditioningModelMapper.ensureInitialized();
      VehicleOdometerMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'VehicleStatusModel';

  static List<EnergyModel>? _$energy(VehicleStatusModel v) => v.energy;
  static const Field<VehicleStatusModel, List<EnergyModel>> _f$energy =
      Field('energy', _$energy, opt: true);
  static DoorsStateModel? _$doorsState(VehicleStatusModel v) => v.doorsState;
  static const Field<VehicleStatusModel, DoorsStateModel> _f$doorsState =
      Field('doorsState', _$doorsState, opt: true);
  static IgnitionModel? _$ignition(VehicleStatusModel v) => v.ignition;
  static const Field<VehicleStatusModel, IgnitionModel> _f$ignition =
      Field('ignition', _$ignition, opt: true);
  static KineticModel? _$kinetic(VehicleStatusModel v) => v.kinetic;
  static const Field<VehicleStatusModel, KineticModel> _f$kinetic =
      Field('kinetic', _$kinetic, opt: true);
  static PositionModel? _$lastPosition(VehicleStatusModel v) => v.lastPosition;
  static const Field<VehicleStatusModel, PositionModel> _f$lastPosition =
      Field('lastPosition', _$lastPosition, opt: true);
  static PreconditioningModel? _$preconditioning(VehicleStatusModel v) =>
      v.preconditioning;
  static const Field<VehicleStatusModel, PreconditioningModel>
      _f$preconditioning =
      Field('preconditioning', _$preconditioning, opt: true);
  static VehicleOdometer? _$timedOdometer(VehicleStatusModel v) =>
      v.timedOdometer;
  static const Field<VehicleStatusModel, VehicleOdometer> _f$timedOdometer =
      Field('timedOdometer', _$timedOdometer, key: r'odometer', opt: true);

  @override
  final MappableFields<VehicleStatusModel> fields = const {
    #energy: _f$energy,
    #doorsState: _f$doorsState,
    #ignition: _f$ignition,
    #kinetic: _f$kinetic,
    #lastPosition: _f$lastPosition,
    #preconditioning: _f$preconditioning,
    #timedOdometer: _f$timedOdometer,
  };

  static VehicleStatusModel _instantiate(DecodingData data) {
    return VehicleStatusModel(
        energy: data.dec(_f$energy),
        doorsState: data.dec(_f$doorsState),
        ignition: data.dec(_f$ignition),
        kinetic: data.dec(_f$kinetic),
        lastPosition: data.dec(_f$lastPosition),
        preconditioning: data.dec(_f$preconditioning),
        timedOdometer: data.dec(_f$timedOdometer));
  }

  @override
  final Function instantiate = _instantiate;

  static VehicleStatusModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<VehicleStatusModel>(map);
  }

  static VehicleStatusModel fromJson(String json) {
    return ensureInitialized().decodeJson<VehicleStatusModel>(json);
  }
}

mixin VehicleStatusModelMappable {
  String toJson() {
    return VehicleStatusModelMapper.ensureInitialized()
        .encodeJson<VehicleStatusModel>(this as VehicleStatusModel);
  }

  Map<String, dynamic> toMap() {
    return VehicleStatusModelMapper.ensureInitialized()
        .encodeMap<VehicleStatusModel>(this as VehicleStatusModel);
  }

  VehicleStatusModelCopyWith<VehicleStatusModel, VehicleStatusModel,
          VehicleStatusModel>
      get copyWith => _VehicleStatusModelCopyWithImpl(
          this as VehicleStatusModel, $identity, $identity);
  @override
  String toString() {
    return VehicleStatusModelMapper.ensureInitialized()
        .stringifyValue(this as VehicleStatusModel);
  }

  @override
  bool operator ==(Object other) {
    return VehicleStatusModelMapper.ensureInitialized()
        .equalsValue(this as VehicleStatusModel, other);
  }

  @override
  int get hashCode {
    return VehicleStatusModelMapper.ensureInitialized()
        .hashValue(this as VehicleStatusModel);
  }
}

extension VehicleStatusModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, VehicleStatusModel, $Out> {
  VehicleStatusModelCopyWith<$R, VehicleStatusModel, $Out>
      get $asVehicleStatusModel =>
          $base.as((v, t, t2) => _VehicleStatusModelCopyWithImpl(v, t, t2));
}

abstract class VehicleStatusModelCopyWith<$R, $In extends VehicleStatusModel,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, EnergyModel,
      EnergyModelCopyWith<$R, EnergyModel, EnergyModel>>? get energy;
  DoorsStateModelCopyWith<$R, DoorsStateModel, DoorsStateModel>? get doorsState;
  IgnitionModelCopyWith<$R, IgnitionModel, IgnitionModel>? get ignition;
  KineticModelCopyWith<$R, KineticModel, KineticModel>? get kinetic;
  PositionModelCopyWith<$R, PositionModel, PositionModel>? get lastPosition;
  PreconditioningModelCopyWith<$R, PreconditioningModel, PreconditioningModel>?
      get preconditioning;
  VehicleOdometerCopyWith<$R, VehicleOdometer, VehicleOdometer>?
      get timedOdometer;
  $R call(
      {List<EnergyModel>? energy,
      DoorsStateModel? doorsState,
      IgnitionModel? ignition,
      KineticModel? kinetic,
      PositionModel? lastPosition,
      PreconditioningModel? preconditioning,
      VehicleOdometer? timedOdometer});
  VehicleStatusModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _VehicleStatusModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, VehicleStatusModel, $Out>
    implements VehicleStatusModelCopyWith<$R, VehicleStatusModel, $Out> {
  _VehicleStatusModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<VehicleStatusModel> $mapper =
      VehicleStatusModelMapper.ensureInitialized();
  @override
  ListCopyWith<$R, EnergyModel,
          EnergyModelCopyWith<$R, EnergyModel, EnergyModel>>?
      get energy => $value.energy != null
          ? ListCopyWith($value.energy!, (v, t) => v.copyWith.$chain(t),
              (v) => call(energy: v))
          : null;
  @override
  DoorsStateModelCopyWith<$R, DoorsStateModel, DoorsStateModel>?
      get doorsState =>
          $value.doorsState?.copyWith.$chain((v) => call(doorsState: v));
  @override
  IgnitionModelCopyWith<$R, IgnitionModel, IgnitionModel>? get ignition =>
      $value.ignition?.copyWith.$chain((v) => call(ignition: v));
  @override
  KineticModelCopyWith<$R, KineticModel, KineticModel>? get kinetic =>
      $value.kinetic?.copyWith.$chain((v) => call(kinetic: v));
  @override
  PositionModelCopyWith<$R, PositionModel, PositionModel>? get lastPosition =>
      $value.lastPosition?.copyWith.$chain((v) => call(lastPosition: v));
  @override
  PreconditioningModelCopyWith<$R, PreconditioningModel, PreconditioningModel>?
      get preconditioning => $value.preconditioning?.copyWith
          .$chain((v) => call(preconditioning: v));
  @override
  VehicleOdometerCopyWith<$R, VehicleOdometer, VehicleOdometer>?
      get timedOdometer =>
          $value.timedOdometer?.copyWith.$chain((v) => call(timedOdometer: v));
  @override
  $R call(
          {Object? energy = $none,
          Object? doorsState = $none,
          Object? ignition = $none,
          Object? kinetic = $none,
          Object? lastPosition = $none,
          Object? preconditioning = $none,
          Object? timedOdometer = $none}) =>
      $apply(FieldCopyWithData({
        if (energy != $none) #energy: energy,
        if (doorsState != $none) #doorsState: doorsState,
        if (ignition != $none) #ignition: ignition,
        if (kinetic != $none) #kinetic: kinetic,
        if (lastPosition != $none) #lastPosition: lastPosition,
        if (preconditioning != $none) #preconditioning: preconditioning,
        if (timedOdometer != $none) #timedOdometer: timedOdometer
      }));
  @override
  VehicleStatusModel $make(CopyWithData data) => VehicleStatusModel(
      energy: data.get(#energy, or: $value.energy),
      doorsState: data.get(#doorsState, or: $value.doorsState),
      ignition: data.get(#ignition, or: $value.ignition),
      kinetic: data.get(#kinetic, or: $value.kinetic),
      lastPosition: data.get(#lastPosition, or: $value.lastPosition),
      preconditioning: data.get(#preconditioning, or: $value.preconditioning),
      timedOdometer: data.get(#timedOdometer, or: $value.timedOdometer));

  @override
  VehicleStatusModelCopyWith<$R2, VehicleStatusModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _VehicleStatusModelCopyWithImpl($value, $cast, t);
}
