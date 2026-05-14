// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'energy.dart';

class EnergyTypeMapper extends EnumMapper<EnergyType> {
  EnergyTypeMapper._();

  static EnergyTypeMapper? _instance;
  static EnergyTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EnergyTypeMapper._());
    }
    return _instance!;
  }

  static EnergyType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  EnergyType decode(dynamic value) {
    switch (value) {
      case 'Fuel':
        return EnergyType.fuel;
      case 'Electric':
        return EnergyType.electric;
      case r'unknown':
        return EnergyType.unknown;
      default:
        return EnergyType.values[2];
    }
  }

  @override
  dynamic encode(EnergyType self) {
    switch (self) {
      case EnergyType.fuel:
        return 'Fuel';
      case EnergyType.electric:
        return 'Electric';
      case EnergyType.unknown:
        return r'unknown';
    }
  }
}

extension EnergyTypeMapperExtension on EnergyType {
  dynamic toValue() {
    EnergyTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<EnergyType>(this);
  }
}

class ChargingStatusMapper extends EnumMapper<ChargingStatus> {
  ChargingStatusMapper._();

  static ChargingStatusMapper? _instance;
  static ChargingStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChargingStatusMapper._());
    }
    return _instance!;
  }

  static ChargingStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ChargingStatus decode(dynamic value) {
    switch (value) {
      case 'Disconnected':
        return ChargingStatus.disconnected;
      case 'InProgress':
        return ChargingStatus.inProgress;
      case 'Failure':
        return ChargingStatus.failure;
      case 'Stopped':
        return ChargingStatus.stopped;
      case 'Finished':
        return ChargingStatus.finished;
      default:
        return ChargingStatus.values[0];
    }
  }

  @override
  dynamic encode(ChargingStatus self) {
    switch (self) {
      case ChargingStatus.disconnected:
        return 'Disconnected';
      case ChargingStatus.inProgress:
        return 'InProgress';
      case ChargingStatus.failure:
        return 'Failure';
      case ChargingStatus.stopped:
        return 'Stopped';
      case ChargingStatus.finished:
        return 'Finished';
    }
  }
}

extension ChargingStatusMapperExtension on ChargingStatus {
  dynamic toValue() {
    ChargingStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ChargingStatus>(this);
  }
}

class EnergyBatteryHealthMapper extends ClassMapperBase<EnergyBatteryHealth> {
  EnergyBatteryHealthMapper._();

  static EnergyBatteryHealthMapper? _instance;
  static EnergyBatteryHealthMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EnergyBatteryHealthMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'EnergyBatteryHealth';

  static double? _$capacity(EnergyBatteryHealth v) => v.capacity;
  static const Field<EnergyBatteryHealth, double> _f$capacity =
      Field('capacity', _$capacity, opt: true);
  static double? _$resistance(EnergyBatteryHealth v) => v.resistance;
  static const Field<EnergyBatteryHealth, double> _f$resistance =
      Field('resistance', _$resistance, opt: true);
  static String? _$state(EnergyBatteryHealth v) => v.state;
  static const Field<EnergyBatteryHealth, String> _f$state =
      Field('state', _$state, opt: true);

  @override
  final MappableFields<EnergyBatteryHealth> fields = const {
    #capacity: _f$capacity,
    #resistance: _f$resistance,
    #state: _f$state,
  };

  static EnergyBatteryHealth _instantiate(DecodingData data) {
    return EnergyBatteryHealth(
        capacity: data.dec(_f$capacity),
        resistance: data.dec(_f$resistance),
        state: data.dec(_f$state));
  }

  @override
  final Function instantiate = _instantiate;

  static EnergyBatteryHealth fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EnergyBatteryHealth>(map);
  }

  static EnergyBatteryHealth fromJson(String json) {
    return ensureInitialized().decodeJson<EnergyBatteryHealth>(json);
  }
}

mixin EnergyBatteryHealthMappable {
  String toJson() {
    return EnergyBatteryHealthMapper.ensureInitialized()
        .encodeJson<EnergyBatteryHealth>(this as EnergyBatteryHealth);
  }

  Map<String, dynamic> toMap() {
    return EnergyBatteryHealthMapper.ensureInitialized()
        .encodeMap<EnergyBatteryHealth>(this as EnergyBatteryHealth);
  }

  EnergyBatteryHealthCopyWith<EnergyBatteryHealth, EnergyBatteryHealth,
      EnergyBatteryHealth> get copyWith => _EnergyBatteryHealthCopyWithImpl<
          EnergyBatteryHealth, EnergyBatteryHealth>(
      this as EnergyBatteryHealth, $identity, $identity);
  @override
  String toString() {
    return EnergyBatteryHealthMapper.ensureInitialized()
        .stringifyValue(this as EnergyBatteryHealth);
  }

  @override
  bool operator ==(Object other) {
    return EnergyBatteryHealthMapper.ensureInitialized()
        .equalsValue(this as EnergyBatteryHealth, other);
  }

  @override
  int get hashCode {
    return EnergyBatteryHealthMapper.ensureInitialized()
        .hashValue(this as EnergyBatteryHealth);
  }
}

extension EnergyBatteryHealthValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EnergyBatteryHealth, $Out> {
  EnergyBatteryHealthCopyWith<$R, EnergyBatteryHealth, $Out>
      get $asEnergyBatteryHealth => $base.as(
          (v, t, t2) => _EnergyBatteryHealthCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EnergyBatteryHealthCopyWith<$R, $In extends EnergyBatteryHealth,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({double? capacity, double? resistance, String? state});
  EnergyBatteryHealthCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _EnergyBatteryHealthCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EnergyBatteryHealth, $Out>
    implements EnergyBatteryHealthCopyWith<$R, EnergyBatteryHealth, $Out> {
  _EnergyBatteryHealthCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EnergyBatteryHealth> $mapper =
      EnergyBatteryHealthMapper.ensureInitialized();
  @override
  $R call(
          {Object? capacity = $none,
          Object? resistance = $none,
          Object? state = $none}) =>
      $apply(FieldCopyWithData({
        if (capacity != $none) #capacity: capacity,
        if (resistance != $none) #resistance: resistance,
        if (state != $none) #state: state
      }));
  @override
  EnergyBatteryHealth $make(CopyWithData data) => EnergyBatteryHealth(
      capacity: data.get(#capacity, or: $value.capacity),
      resistance: data.get(#resistance, or: $value.resistance),
      state: data.get(#state, or: $value.state));

  @override
  EnergyBatteryHealthCopyWith<$R2, EnergyBatteryHealth, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _EnergyBatteryHealthCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class EnergyBatteryMapper extends ClassMapperBase<EnergyBattery> {
  EnergyBatteryMapper._();

  static EnergyBatteryMapper? _instance;
  static EnergyBatteryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EnergyBatteryMapper._());
      EnergyBatteryHealthMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'EnergyBattery';

  static double? _$capacity(EnergyBattery v) => v.capacity;
  static const Field<EnergyBattery, double> _f$capacity =
      Field('capacity', _$capacity, opt: true);
  static EnergyBatteryHealth? _$health(EnergyBattery v) => v.health;
  static const Field<EnergyBattery, EnergyBatteryHealth> _f$health =
      Field('health', _$health, opt: true);

  @override
  final MappableFields<EnergyBattery> fields = const {
    #capacity: _f$capacity,
    #health: _f$health,
  };

  static EnergyBattery _instantiate(DecodingData data) {
    return EnergyBattery(
        capacity: data.dec(_f$capacity), health: data.dec(_f$health));
  }

  @override
  final Function instantiate = _instantiate;

  static EnergyBattery fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EnergyBattery>(map);
  }

  static EnergyBattery fromJson(String json) {
    return ensureInitialized().decodeJson<EnergyBattery>(json);
  }
}

mixin EnergyBatteryMappable {
  String toJson() {
    return EnergyBatteryMapper.ensureInitialized()
        .encodeJson<EnergyBattery>(this as EnergyBattery);
  }

  Map<String, dynamic> toMap() {
    return EnergyBatteryMapper.ensureInitialized()
        .encodeMap<EnergyBattery>(this as EnergyBattery);
  }

  EnergyBatteryCopyWith<EnergyBattery, EnergyBattery, EnergyBattery>
      get copyWith => _EnergyBatteryCopyWithImpl<EnergyBattery, EnergyBattery>(
          this as EnergyBattery, $identity, $identity);
  @override
  String toString() {
    return EnergyBatteryMapper.ensureInitialized()
        .stringifyValue(this as EnergyBattery);
  }

  @override
  bool operator ==(Object other) {
    return EnergyBatteryMapper.ensureInitialized()
        .equalsValue(this as EnergyBattery, other);
  }

  @override
  int get hashCode {
    return EnergyBatteryMapper.ensureInitialized()
        .hashValue(this as EnergyBattery);
  }
}

extension EnergyBatteryValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EnergyBattery, $Out> {
  EnergyBatteryCopyWith<$R, EnergyBattery, $Out> get $asEnergyBattery =>
      $base.as((v, t, t2) => _EnergyBatteryCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EnergyBatteryCopyWith<$R, $In extends EnergyBattery, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  EnergyBatteryHealthCopyWith<$R, EnergyBatteryHealth, EnergyBatteryHealth>?
      get health;
  $R call({double? capacity, EnergyBatteryHealth? health});
  EnergyBatteryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EnergyBatteryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EnergyBattery, $Out>
    implements EnergyBatteryCopyWith<$R, EnergyBattery, $Out> {
  _EnergyBatteryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EnergyBattery> $mapper =
      EnergyBatteryMapper.ensureInitialized();
  @override
  EnergyBatteryHealthCopyWith<$R, EnergyBatteryHealth, EnergyBatteryHealth>?
      get health => $value.health?.copyWith.$chain((v) => call(health: v));
  @override
  $R call({Object? capacity = $none, Object? health = $none}) =>
      $apply(FieldCopyWithData({
        if (capacity != $none) #capacity: capacity,
        if (health != $none) #health: health
      }));
  @override
  EnergyBattery $make(CopyWithData data) => EnergyBattery(
      capacity: data.get(#capacity, or: $value.capacity),
      health: data.get(#health, or: $value.health));

  @override
  EnergyBatteryCopyWith<$R2, EnergyBattery, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _EnergyBatteryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class EnergyChargingMapper extends ClassMapperBase<EnergyCharging> {
  EnergyChargingMapper._();

  static EnergyChargingMapper? _instance;
  static EnergyChargingMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EnergyChargingMapper._());
      ChargingStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'EnergyCharging';

  static ChargingStatus? _$status(EnergyCharging v) => v.status;
  static const Field<EnergyCharging, ChargingStatus> _f$status =
      Field('status', _$status, opt: true);
  static bool? _$plugged(EnergyCharging v) => v.plugged;
  static const Field<EnergyCharging, bool> _f$plugged =
      Field('plugged', _$plugged, opt: true);
  static String? _$chargingMode(EnergyCharging v) => v.chargingMode;
  static const Field<EnergyCharging, String> _f$chargingMode =
      Field('chargingMode', _$chargingMode, opt: true);
  static int? _$chargingRate(EnergyCharging v) => v.chargingRate;
  static const Field<EnergyCharging, int> _f$chargingRate =
      Field('chargingRate', _$chargingRate, opt: true);
  static String? _$remainingTime(EnergyCharging v) => v.remainingTime;
  static const Field<EnergyCharging, String> _f$remainingTime =
      Field('remainingTime', _$remainingTime, opt: true);
  static String? _$nextDelayedTime(EnergyCharging v) => v.nextDelayedTime;
  static const Field<EnergyCharging, String> _f$nextDelayedTime =
      Field('nextDelayedTime', _$nextDelayedTime, opt: true);

  @override
  final MappableFields<EnergyCharging> fields = const {
    #status: _f$status,
    #plugged: _f$plugged,
    #chargingMode: _f$chargingMode,
    #chargingRate: _f$chargingRate,
    #remainingTime: _f$remainingTime,
    #nextDelayedTime: _f$nextDelayedTime,
  };

  static EnergyCharging _instantiate(DecodingData data) {
    return EnergyCharging(
        status: data.dec(_f$status),
        plugged: data.dec(_f$plugged),
        chargingMode: data.dec(_f$chargingMode),
        chargingRate: data.dec(_f$chargingRate),
        remainingTime: data.dec(_f$remainingTime),
        nextDelayedTime: data.dec(_f$nextDelayedTime));
  }

  @override
  final Function instantiate = _instantiate;

  static EnergyCharging fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EnergyCharging>(map);
  }

  static EnergyCharging fromJson(String json) {
    return ensureInitialized().decodeJson<EnergyCharging>(json);
  }
}

mixin EnergyChargingMappable {
  String toJson() {
    return EnergyChargingMapper.ensureInitialized()
        .encodeJson<EnergyCharging>(this as EnergyCharging);
  }

  Map<String, dynamic> toMap() {
    return EnergyChargingMapper.ensureInitialized()
        .encodeMap<EnergyCharging>(this as EnergyCharging);
  }

  EnergyChargingCopyWith<EnergyCharging, EnergyCharging, EnergyCharging>
      get copyWith =>
          _EnergyChargingCopyWithImpl<EnergyCharging, EnergyCharging>(
              this as EnergyCharging, $identity, $identity);
  @override
  String toString() {
    return EnergyChargingMapper.ensureInitialized()
        .stringifyValue(this as EnergyCharging);
  }

  @override
  bool operator ==(Object other) {
    return EnergyChargingMapper.ensureInitialized()
        .equalsValue(this as EnergyCharging, other);
  }

  @override
  int get hashCode {
    return EnergyChargingMapper.ensureInitialized()
        .hashValue(this as EnergyCharging);
  }
}

extension EnergyChargingValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EnergyCharging, $Out> {
  EnergyChargingCopyWith<$R, EnergyCharging, $Out> get $asEnergyCharging =>
      $base.as((v, t, t2) => _EnergyChargingCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EnergyChargingCopyWith<$R, $In extends EnergyCharging, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {ChargingStatus? status,
      bool? plugged,
      String? chargingMode,
      int? chargingRate,
      String? remainingTime,
      String? nextDelayedTime});
  EnergyChargingCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _EnergyChargingCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EnergyCharging, $Out>
    implements EnergyChargingCopyWith<$R, EnergyCharging, $Out> {
  _EnergyChargingCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EnergyCharging> $mapper =
      EnergyChargingMapper.ensureInitialized();
  @override
  $R call(
          {Object? status = $none,
          Object? plugged = $none,
          Object? chargingMode = $none,
          Object? chargingRate = $none,
          Object? remainingTime = $none,
          Object? nextDelayedTime = $none}) =>
      $apply(FieldCopyWithData({
        if (status != $none) #status: status,
        if (plugged != $none) #plugged: plugged,
        if (chargingMode != $none) #chargingMode: chargingMode,
        if (chargingRate != $none) #chargingRate: chargingRate,
        if (remainingTime != $none) #remainingTime: remainingTime,
        if (nextDelayedTime != $none) #nextDelayedTime: nextDelayedTime
      }));
  @override
  EnergyCharging $make(CopyWithData data) => EnergyCharging(
      status: data.get(#status, or: $value.status),
      plugged: data.get(#plugged, or: $value.plugged),
      chargingMode: data.get(#chargingMode, or: $value.chargingMode),
      chargingRate: data.get(#chargingRate, or: $value.chargingRate),
      remainingTime: data.get(#remainingTime, or: $value.remainingTime),
      nextDelayedTime: data.get(#nextDelayedTime, or: $value.nextDelayedTime));

  @override
  EnergyChargingCopyWith<$R2, EnergyCharging, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _EnergyChargingCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class EnergyModelMapper extends ClassMapperBase<EnergyModel> {
  EnergyModelMapper._();

  static EnergyModelMapper? _instance;
  static EnergyModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EnergyModelMapper._());
      EnergyTypeMapper.ensureInitialized();
      EnergyBatteryMapper.ensureInitialized();
      EnergyChargingMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'EnergyModel';

  static EnergyType? _$type(EnergyModel v) => v.type;
  static const Field<EnergyModel, EnergyType> _f$type =
      Field('type', _$type, opt: true);
  static double? _$level(EnergyModel v) => v.level;
  static const Field<EnergyModel, double> _f$level =
      Field('level', _$level, opt: true);
  static double? _$autonomy(EnergyModel v) => v.autonomy;
  static const Field<EnergyModel, double> _f$autonomy =
      Field('autonomy', _$autonomy, opt: true);
  static double? _$residual(EnergyModel v) => v.residual;
  static const Field<EnergyModel, double> _f$residual =
      Field('residual', _$residual, opt: true);
  static double? _$consumption(EnergyModel v) => v.consumption;
  static const Field<EnergyModel, double> _f$consumption =
      Field('consumption', _$consumption, opt: true);
  static EnergyBattery? _$battery(EnergyModel v) => v.battery;
  static const Field<EnergyModel, EnergyBattery> _f$battery =
      Field('battery', _$battery, opt: true);
  static EnergyCharging? _$charging(EnergyModel v) => v.charging;
  static const Field<EnergyModel, EnergyCharging> _f$charging =
      Field('charging', _$charging, opt: true);
  static DateTime? _$updatedAt(EnergyModel v) => v.updatedAt;
  static const Field<EnergyModel, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, opt: true);

  @override
  final MappableFields<EnergyModel> fields = const {
    #type: _f$type,
    #level: _f$level,
    #autonomy: _f$autonomy,
    #residual: _f$residual,
    #consumption: _f$consumption,
    #battery: _f$battery,
    #charging: _f$charging,
    #updatedAt: _f$updatedAt,
  };

  static EnergyModel _instantiate(DecodingData data) {
    return EnergyModel(
        type: data.dec(_f$type),
        level: data.dec(_f$level),
        autonomy: data.dec(_f$autonomy),
        residual: data.dec(_f$residual),
        consumption: data.dec(_f$consumption),
        battery: data.dec(_f$battery),
        charging: data.dec(_f$charging),
        updatedAt: data.dec(_f$updatedAt));
  }

  @override
  final Function instantiate = _instantiate;

  static EnergyModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EnergyModel>(map);
  }

  static EnergyModel fromJson(String json) {
    return ensureInitialized().decodeJson<EnergyModel>(json);
  }
}

mixin EnergyModelMappable {
  String toJson() {
    return EnergyModelMapper.ensureInitialized()
        .encodeJson<EnergyModel>(this as EnergyModel);
  }

  Map<String, dynamic> toMap() {
    return EnergyModelMapper.ensureInitialized()
        .encodeMap<EnergyModel>(this as EnergyModel);
  }

  EnergyModelCopyWith<EnergyModel, EnergyModel, EnergyModel> get copyWith =>
      _EnergyModelCopyWithImpl<EnergyModel, EnergyModel>(
          this as EnergyModel, $identity, $identity);
  @override
  String toString() {
    return EnergyModelMapper.ensureInitialized()
        .stringifyValue(this as EnergyModel);
  }

  @override
  bool operator ==(Object other) {
    return EnergyModelMapper.ensureInitialized()
        .equalsValue(this as EnergyModel, other);
  }

  @override
  int get hashCode {
    return EnergyModelMapper.ensureInitialized().hashValue(this as EnergyModel);
  }
}

extension EnergyModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EnergyModel, $Out> {
  EnergyModelCopyWith<$R, EnergyModel, $Out> get $asEnergyModel =>
      $base.as((v, t, t2) => _EnergyModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EnergyModelCopyWith<$R, $In extends EnergyModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  EnergyBatteryCopyWith<$R, EnergyBattery, EnergyBattery>? get battery;
  EnergyChargingCopyWith<$R, EnergyCharging, EnergyCharging>? get charging;
  $R call(
      {EnergyType? type,
      double? level,
      double? autonomy,
      double? residual,
      double? consumption,
      EnergyBattery? battery,
      EnergyCharging? charging,
      DateTime? updatedAt});
  EnergyModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EnergyModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EnergyModel, $Out>
    implements EnergyModelCopyWith<$R, EnergyModel, $Out> {
  _EnergyModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EnergyModel> $mapper =
      EnergyModelMapper.ensureInitialized();
  @override
  EnergyBatteryCopyWith<$R, EnergyBattery, EnergyBattery>? get battery =>
      $value.battery?.copyWith.$chain((v) => call(battery: v));
  @override
  EnergyChargingCopyWith<$R, EnergyCharging, EnergyCharging>? get charging =>
      $value.charging?.copyWith.$chain((v) => call(charging: v));
  @override
  $R call(
          {Object? type = $none,
          Object? level = $none,
          Object? autonomy = $none,
          Object? residual = $none,
          Object? consumption = $none,
          Object? battery = $none,
          Object? charging = $none,
          Object? updatedAt = $none}) =>
      $apply(FieldCopyWithData({
        if (type != $none) #type: type,
        if (level != $none) #level: level,
        if (autonomy != $none) #autonomy: autonomy,
        if (residual != $none) #residual: residual,
        if (consumption != $none) #consumption: consumption,
        if (battery != $none) #battery: battery,
        if (charging != $none) #charging: charging,
        if (updatedAt != $none) #updatedAt: updatedAt
      }));
  @override
  EnergyModel $make(CopyWithData data) => EnergyModel(
      type: data.get(#type, or: $value.type),
      level: data.get(#level, or: $value.level),
      autonomy: data.get(#autonomy, or: $value.autonomy),
      residual: data.get(#residual, or: $value.residual),
      consumption: data.get(#consumption, or: $value.consumption),
      battery: data.get(#battery, or: $value.battery),
      charging: data.get(#charging, or: $value.charging),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt));

  @override
  EnergyModelCopyWith<$R2, EnergyModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _EnergyModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
