// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'alert.dart';

class AlertSeverityMapper extends EnumMapper<AlertSeverity> {
  AlertSeverityMapper._();

  static AlertSeverityMapper? _instance;
  static AlertSeverityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AlertSeverityMapper._());
    }
    return _instance!;
  }

  static AlertSeverity fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  AlertSeverity decode(dynamic value) {
    switch (value) {
      case 'Information':
        return AlertSeverity.information;
      case 'Warning':
        return AlertSeverity.warning;
      case 'Critical':
        return AlertSeverity.critical;
      case 'unknown':
        return AlertSeverity.unknown;
      default:
        return AlertSeverity.values[3];
    }
  }

  @override
  dynamic encode(AlertSeverity self) {
    switch (self) {
      case AlertSeverity.information:
        return 'Information';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.critical:
        return 'Critical';
      case AlertSeverity.unknown:
        return 'unknown';
    }
  }
}

extension AlertSeverityMapperExtension on AlertSeverity {
  dynamic toValue() {
    AlertSeverityMapper.ensureInitialized();
    return MapperContainer.globals.toValue<AlertSeverity>(this);
  }
}

class AlertModelMapper extends ClassMapperBase<AlertModel> {
  AlertModelMapper._();

  static AlertModelMapper? _instance;
  static AlertModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AlertModelMapper._());
      AlertSeverityMapper.ensureInitialized();
      PositionModelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AlertModel';

  static String _$id(AlertModel v) => v.id;
  static const Field<AlertModel, String> _f$id = Field('id', _$id);
  static String _$type(AlertModel v) => v.type;
  static const Field<AlertModel, String> _f$type = Field('type', _$type);
  static bool? _$active(AlertModel v) => v.active;
  static const Field<AlertModel, bool> _f$active =
      Field('active', _$active, opt: true);
  static AlertSeverity? _$severity(AlertModel v) => v.severity;
  static const Field<AlertModel, AlertSeverity> _f$severity =
      Field('severity', _$severity, opt: true);
  static DateTime? _$startedAt(AlertModel v) => v.startedAt;
  static const Field<AlertModel, DateTime> _f$startedAt =
      Field('startedAt', _$startedAt, opt: true);
  static DateTime? _$endAt(AlertModel v) => v.endAt;
  static const Field<AlertModel, DateTime> _f$endAt =
      Field('endAt', _$endAt, opt: true);
  static PositionModel? _$startPosition(AlertModel v) => v.startPosition;
  static const Field<AlertModel, PositionModel> _f$startPosition =
      Field('startPosition', _$startPosition, opt: true);
  static PositionModel? _$endPosition(AlertModel v) => v.endPosition;
  static const Field<AlertModel, PositionModel> _f$endPosition =
      Field('endPosition', _$endPosition, opt: true);
  static DateTime? _$createdAt(AlertModel v) => v.createdAt;
  static const Field<AlertModel, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, opt: true);
  static DateTime? _$updatedAt(AlertModel v) => v.updatedAt;
  static const Field<AlertModel, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, opt: true);

  @override
  final MappableFields<AlertModel> fields = const {
    #id: _f$id,
    #type: _f$type,
    #active: _f$active,
    #severity: _f$severity,
    #startedAt: _f$startedAt,
    #endAt: _f$endAt,
    #startPosition: _f$startPosition,
    #endPosition: _f$endPosition,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  static AlertModel _instantiate(DecodingData data) {
    return AlertModel(
        id: data.dec(_f$id),
        type: data.dec(_f$type),
        active: data.dec(_f$active),
        severity: data.dec(_f$severity),
        startedAt: data.dec(_f$startedAt),
        endAt: data.dec(_f$endAt),
        startPosition: data.dec(_f$startPosition),
        endPosition: data.dec(_f$endPosition),
        createdAt: data.dec(_f$createdAt),
        updatedAt: data.dec(_f$updatedAt));
  }

  @override
  final Function instantiate = _instantiate;

  static AlertModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AlertModel>(map);
  }

  static AlertModel fromJson(String json) {
    return ensureInitialized().decodeJson<AlertModel>(json);
  }
}

mixin AlertModelMappable {
  String toJson() {
    return AlertModelMapper.ensureInitialized()
        .encodeJson<AlertModel>(this as AlertModel);
  }

  Map<String, dynamic> toMap() {
    return AlertModelMapper.ensureInitialized()
        .encodeMap<AlertModel>(this as AlertModel);
  }

  AlertModelCopyWith<AlertModel, AlertModel, AlertModel> get copyWith =>
      _AlertModelCopyWithImpl(this as AlertModel, $identity, $identity);
  @override
  String toString() {
    return AlertModelMapper.ensureInitialized()
        .stringifyValue(this as AlertModel);
  }

  @override
  bool operator ==(Object other) {
    return AlertModelMapper.ensureInitialized()
        .equalsValue(this as AlertModel, other);
  }

  @override
  int get hashCode {
    return AlertModelMapper.ensureInitialized().hashValue(this as AlertModel);
  }
}

extension AlertModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AlertModel, $Out> {
  AlertModelCopyWith<$R, AlertModel, $Out> get $asAlertModel =>
      $base.as((v, t, t2) => _AlertModelCopyWithImpl(v, t, t2));
}

abstract class AlertModelCopyWith<$R, $In extends AlertModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  PositionModelCopyWith<$R, PositionModel, PositionModel>? get startPosition;
  PositionModelCopyWith<$R, PositionModel, PositionModel>? get endPosition;
  $R call(
      {String? id,
      String? type,
      bool? active,
      AlertSeverity? severity,
      DateTime? startedAt,
      DateTime? endAt,
      PositionModel? startPosition,
      PositionModel? endPosition,
      DateTime? createdAt,
      DateTime? updatedAt});
  AlertModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AlertModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AlertModel, $Out>
    implements AlertModelCopyWith<$R, AlertModel, $Out> {
  _AlertModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AlertModel> $mapper =
      AlertModelMapper.ensureInitialized();
  @override
  PositionModelCopyWith<$R, PositionModel, PositionModel>? get startPosition =>
      $value.startPosition?.copyWith.$chain((v) => call(startPosition: v));
  @override
  PositionModelCopyWith<$R, PositionModel, PositionModel>? get endPosition =>
      $value.endPosition?.copyWith.$chain((v) => call(endPosition: v));
  @override
  $R call(
          {String? id,
          String? type,
          Object? active = $none,
          Object? severity = $none,
          Object? startedAt = $none,
          Object? endAt = $none,
          Object? startPosition = $none,
          Object? endPosition = $none,
          Object? createdAt = $none,
          Object? updatedAt = $none}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (type != null) #type: type,
        if (active != $none) #active: active,
        if (severity != $none) #severity: severity,
        if (startedAt != $none) #startedAt: startedAt,
        if (endAt != $none) #endAt: endAt,
        if (startPosition != $none) #startPosition: startPosition,
        if (endPosition != $none) #endPosition: endPosition,
        if (createdAt != $none) #createdAt: createdAt,
        if (updatedAt != $none) #updatedAt: updatedAt
      }));
  @override
  AlertModel $make(CopyWithData data) => AlertModel(
      id: data.get(#id, or: $value.id),
      type: data.get(#type, or: $value.type),
      active: data.get(#active, or: $value.active),
      severity: data.get(#severity, or: $value.severity),
      startedAt: data.get(#startedAt, or: $value.startedAt),
      endAt: data.get(#endAt, or: $value.endAt),
      startPosition: data.get(#startPosition, or: $value.startPosition),
      endPosition: data.get(#endPosition, or: $value.endPosition),
      createdAt: data.get(#createdAt, or: $value.createdAt),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt));

  @override
  AlertModelCopyWith<$R2, AlertModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _AlertModelCopyWithImpl($value, $cast, t);
}

class AlertsResponseMapper extends ClassMapperBase<AlertsResponse> {
  AlertsResponseMapper._();

  static AlertsResponseMapper? _instance;
  static AlertsResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AlertsResponseMapper._());
      AlertsEmbeddedMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AlertsResponse';

  static AlertsEmbedded? _$alerts(AlertsResponse v) => v.alerts;
  static const Field<AlertsResponse, AlertsEmbedded> _f$alerts =
      Field('alerts', _$alerts, key: r'_embedded', opt: true);

  @override
  final MappableFields<AlertsResponse> fields = const {
    #alerts: _f$alerts,
  };

  static AlertsResponse _instantiate(DecodingData data) {
    return AlertsResponse(alerts: data.dec(_f$alerts));
  }

  @override
  final Function instantiate = _instantiate;

  static AlertsResponse fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AlertsResponse>(map);
  }

  static AlertsResponse fromJson(String json) {
    return ensureInitialized().decodeJson<AlertsResponse>(json);
  }
}

mixin AlertsResponseMappable {
  String toJson() {
    return AlertsResponseMapper.ensureInitialized()
        .encodeJson<AlertsResponse>(this as AlertsResponse);
  }

  Map<String, dynamic> toMap() {
    return AlertsResponseMapper.ensureInitialized()
        .encodeMap<AlertsResponse>(this as AlertsResponse);
  }

  AlertsResponseCopyWith<AlertsResponse, AlertsResponse, AlertsResponse>
      get copyWith => _AlertsResponseCopyWithImpl(
          this as AlertsResponse, $identity, $identity);
  @override
  String toString() {
    return AlertsResponseMapper.ensureInitialized()
        .stringifyValue(this as AlertsResponse);
  }

  @override
  bool operator ==(Object other) {
    return AlertsResponseMapper.ensureInitialized()
        .equalsValue(this as AlertsResponse, other);
  }

  @override
  int get hashCode {
    return AlertsResponseMapper.ensureInitialized()
        .hashValue(this as AlertsResponse);
  }
}

extension AlertsResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AlertsResponse, $Out> {
  AlertsResponseCopyWith<$R, AlertsResponse, $Out> get $asAlertsResponse =>
      $base.as((v, t, t2) => _AlertsResponseCopyWithImpl(v, t, t2));
}

abstract class AlertsResponseCopyWith<$R, $In extends AlertsResponse, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  AlertsEmbeddedCopyWith<$R, AlertsEmbedded, AlertsEmbedded>? get alerts;
  $R call({AlertsEmbedded? alerts});
  AlertsResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _AlertsResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AlertsResponse, $Out>
    implements AlertsResponseCopyWith<$R, AlertsResponse, $Out> {
  _AlertsResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AlertsResponse> $mapper =
      AlertsResponseMapper.ensureInitialized();
  @override
  AlertsEmbeddedCopyWith<$R, AlertsEmbedded, AlertsEmbedded>? get alerts =>
      $value.alerts?.copyWith.$chain((v) => call(alerts: v));
  @override
  $R call({Object? alerts = $none}) =>
      $apply(FieldCopyWithData({if (alerts != $none) #alerts: alerts}));
  @override
  AlertsResponse $make(CopyWithData data) =>
      AlertsResponse(alerts: data.get(#alerts, or: $value.alerts));

  @override
  AlertsResponseCopyWith<$R2, AlertsResponse, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _AlertsResponseCopyWithImpl($value, $cast, t);
}

class AlertsEmbeddedMapper extends ClassMapperBase<AlertsEmbedded> {
  AlertsEmbeddedMapper._();

  static AlertsEmbeddedMapper? _instance;
  static AlertsEmbeddedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AlertsEmbeddedMapper._());
      AlertModelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AlertsEmbedded';

  static List<AlertModel>? _$alerts(AlertsEmbedded v) => v.alerts;
  static const Field<AlertsEmbedded, List<AlertModel>> _f$alerts =
      Field('alerts', _$alerts, opt: true);

  @override
  final MappableFields<AlertsEmbedded> fields = const {
    #alerts: _f$alerts,
  };

  static AlertsEmbedded _instantiate(DecodingData data) {
    return AlertsEmbedded(alerts: data.dec(_f$alerts));
  }

  @override
  final Function instantiate = _instantiate;

  static AlertsEmbedded fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AlertsEmbedded>(map);
  }

  static AlertsEmbedded fromJson(String json) {
    return ensureInitialized().decodeJson<AlertsEmbedded>(json);
  }
}

mixin AlertsEmbeddedMappable {
  String toJson() {
    return AlertsEmbeddedMapper.ensureInitialized()
        .encodeJson<AlertsEmbedded>(this as AlertsEmbedded);
  }

  Map<String, dynamic> toMap() {
    return AlertsEmbeddedMapper.ensureInitialized()
        .encodeMap<AlertsEmbedded>(this as AlertsEmbedded);
  }

  AlertsEmbeddedCopyWith<AlertsEmbedded, AlertsEmbedded, AlertsEmbedded>
      get copyWith => _AlertsEmbeddedCopyWithImpl(
          this as AlertsEmbedded, $identity, $identity);
  @override
  String toString() {
    return AlertsEmbeddedMapper.ensureInitialized()
        .stringifyValue(this as AlertsEmbedded);
  }

  @override
  bool operator ==(Object other) {
    return AlertsEmbeddedMapper.ensureInitialized()
        .equalsValue(this as AlertsEmbedded, other);
  }

  @override
  int get hashCode {
    return AlertsEmbeddedMapper.ensureInitialized()
        .hashValue(this as AlertsEmbedded);
  }
}

extension AlertsEmbeddedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AlertsEmbedded, $Out> {
  AlertsEmbeddedCopyWith<$R, AlertsEmbedded, $Out> get $asAlertsEmbedded =>
      $base.as((v, t, t2) => _AlertsEmbeddedCopyWithImpl(v, t, t2));
}

abstract class AlertsEmbeddedCopyWith<$R, $In extends AlertsEmbedded, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, AlertModel, AlertModelCopyWith<$R, AlertModel, AlertModel>>?
      get alerts;
  $R call({List<AlertModel>? alerts});
  AlertsEmbeddedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _AlertsEmbeddedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AlertsEmbedded, $Out>
    implements AlertsEmbeddedCopyWith<$R, AlertsEmbedded, $Out> {
  _AlertsEmbeddedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AlertsEmbedded> $mapper =
      AlertsEmbeddedMapper.ensureInitialized();
  @override
  ListCopyWith<$R, AlertModel, AlertModelCopyWith<$R, AlertModel, AlertModel>>?
      get alerts => $value.alerts != null
          ? ListCopyWith($value.alerts!, (v, t) => v.copyWith.$chain(t),
              (v) => call(alerts: v))
          : null;
  @override
  $R call({Object? alerts = $none}) =>
      $apply(FieldCopyWithData({if (alerts != $none) #alerts: alerts}));
  @override
  AlertsEmbedded $make(CopyWithData data) =>
      AlertsEmbedded(alerts: data.get(#alerts, or: $value.alerts));

  @override
  AlertsEmbeddedCopyWith<$R2, AlertsEmbedded, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _AlertsEmbeddedCopyWithImpl($value, $cast, t);
}
