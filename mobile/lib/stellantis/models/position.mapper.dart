// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'position.dart';

class GeoPointMapper extends ClassMapperBase<GeoPoint> {
  GeoPointMapper._();

  static GeoPointMapper? _instance;
  static GeoPointMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GeoPointMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'GeoPoint';

  static String? _$type(GeoPoint v) => v.type;
  static const Field<GeoPoint, String> _f$type =
      Field('type', _$type, opt: true);
  static List<double>? _$coordinates(GeoPoint v) => v.coordinates;
  static const Field<GeoPoint, List<double>> _f$coordinates =
      Field('coordinates', _$coordinates, opt: true);

  @override
  final MappableFields<GeoPoint> fields = const {
    #type: _f$type,
    #coordinates: _f$coordinates,
  };

  static GeoPoint _instantiate(DecodingData data) {
    return GeoPoint(
        type: data.dec(_f$type), coordinates: data.dec(_f$coordinates));
  }

  @override
  final Function instantiate = _instantiate;

  static GeoPoint fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GeoPoint>(map);
  }

  static GeoPoint fromJson(String json) {
    return ensureInitialized().decodeJson<GeoPoint>(json);
  }
}

mixin GeoPointMappable {
  String toJson() {
    return GeoPointMapper.ensureInitialized()
        .encodeJson<GeoPoint>(this as GeoPoint);
  }

  Map<String, dynamic> toMap() {
    return GeoPointMapper.ensureInitialized()
        .encodeMap<GeoPoint>(this as GeoPoint);
  }

  GeoPointCopyWith<GeoPoint, GeoPoint, GeoPoint> get copyWith =>
      _GeoPointCopyWithImpl<GeoPoint, GeoPoint>(
          this as GeoPoint, $identity, $identity);
  @override
  String toString() {
    return GeoPointMapper.ensureInitialized().stringifyValue(this as GeoPoint);
  }

  @override
  bool operator ==(Object other) {
    return GeoPointMapper.ensureInitialized()
        .equalsValue(this as GeoPoint, other);
  }

  @override
  int get hashCode {
    return GeoPointMapper.ensureInitialized().hashValue(this as GeoPoint);
  }
}

extension GeoPointValueCopy<$R, $Out> on ObjectCopyWith<$R, GeoPoint, $Out> {
  GeoPointCopyWith<$R, GeoPoint, $Out> get $asGeoPoint =>
      $base.as((v, t, t2) => _GeoPointCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class GeoPointCopyWith<$R, $In extends GeoPoint, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, double, ObjectCopyWith<$R, double, double>>? get coordinates;
  $R call({String? type, List<double>? coordinates});
  GeoPointCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _GeoPointCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GeoPoint, $Out>
    implements GeoPointCopyWith<$R, GeoPoint, $Out> {
  _GeoPointCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GeoPoint> $mapper =
      GeoPointMapper.ensureInitialized();
  @override
  ListCopyWith<$R, double, ObjectCopyWith<$R, double, double>>?
      get coordinates => $value.coordinates != null
          ? ListCopyWith(
              $value.coordinates!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(coordinates: v))
          : null;
  @override
  $R call({Object? type = $none, Object? coordinates = $none}) =>
      $apply(FieldCopyWithData({
        if (type != $none) #type: type,
        if (coordinates != $none) #coordinates: coordinates
      }));
  @override
  GeoPoint $make(CopyWithData data) => GeoPoint(
      type: data.get(#type, or: $value.type),
      coordinates: data.get(#coordinates, or: $value.coordinates));

  @override
  GeoPointCopyWith<$R2, GeoPoint, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _GeoPointCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PositionPropertiesMapper extends ClassMapperBase<PositionProperties> {
  PositionPropertiesMapper._();

  static PositionPropertiesMapper? _instance;
  static PositionPropertiesMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PositionPropertiesMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PositionProperties';

  static double? _$heading(PositionProperties v) => v.heading;
  static const Field<PositionProperties, double> _f$heading =
      Field('heading', _$heading, opt: true);
  static bool? _$moving(PositionProperties v) => v.moving;
  static const Field<PositionProperties, bool> _f$moving =
      Field('moving', _$moving, opt: true);
  static int? _$signalQuality(PositionProperties v) => v.signalQuality;
  static const Field<PositionProperties, int> _f$signalQuality =
      Field('signalQuality', _$signalQuality, opt: true);
  static DateTime? _$updatedAt(PositionProperties v) => v.updatedAt;
  static const Field<PositionProperties, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, opt: true);

  @override
  final MappableFields<PositionProperties> fields = const {
    #heading: _f$heading,
    #moving: _f$moving,
    #signalQuality: _f$signalQuality,
    #updatedAt: _f$updatedAt,
  };

  static PositionProperties _instantiate(DecodingData data) {
    return PositionProperties(
        heading: data.dec(_f$heading),
        moving: data.dec(_f$moving),
        signalQuality: data.dec(_f$signalQuality),
        updatedAt: data.dec(_f$updatedAt));
  }

  @override
  final Function instantiate = _instantiate;

  static PositionProperties fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PositionProperties>(map);
  }

  static PositionProperties fromJson(String json) {
    return ensureInitialized().decodeJson<PositionProperties>(json);
  }
}

mixin PositionPropertiesMappable {
  String toJson() {
    return PositionPropertiesMapper.ensureInitialized()
        .encodeJson<PositionProperties>(this as PositionProperties);
  }

  Map<String, dynamic> toMap() {
    return PositionPropertiesMapper.ensureInitialized()
        .encodeMap<PositionProperties>(this as PositionProperties);
  }

  PositionPropertiesCopyWith<PositionProperties, PositionProperties,
          PositionProperties>
      get copyWith => _PositionPropertiesCopyWithImpl<PositionProperties,
          PositionProperties>(this as PositionProperties, $identity, $identity);
  @override
  String toString() {
    return PositionPropertiesMapper.ensureInitialized()
        .stringifyValue(this as PositionProperties);
  }

  @override
  bool operator ==(Object other) {
    return PositionPropertiesMapper.ensureInitialized()
        .equalsValue(this as PositionProperties, other);
  }

  @override
  int get hashCode {
    return PositionPropertiesMapper.ensureInitialized()
        .hashValue(this as PositionProperties);
  }
}

extension PositionPropertiesValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PositionProperties, $Out> {
  PositionPropertiesCopyWith<$R, PositionProperties, $Out>
      get $asPositionProperties => $base.as(
          (v, t, t2) => _PositionPropertiesCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PositionPropertiesCopyWith<$R, $In extends PositionProperties,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {double? heading, bool? moving, int? signalQuality, DateTime? updatedAt});
  PositionPropertiesCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _PositionPropertiesCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PositionProperties, $Out>
    implements PositionPropertiesCopyWith<$R, PositionProperties, $Out> {
  _PositionPropertiesCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PositionProperties> $mapper =
      PositionPropertiesMapper.ensureInitialized();
  @override
  $R call(
          {Object? heading = $none,
          Object? moving = $none,
          Object? signalQuality = $none,
          Object? updatedAt = $none}) =>
      $apply(FieldCopyWithData({
        if (heading != $none) #heading: heading,
        if (moving != $none) #moving: moving,
        if (signalQuality != $none) #signalQuality: signalQuality,
        if (updatedAt != $none) #updatedAt: updatedAt
      }));
  @override
  PositionProperties $make(CopyWithData data) => PositionProperties(
      heading: data.get(#heading, or: $value.heading),
      moving: data.get(#moving, or: $value.moving),
      signalQuality: data.get(#signalQuality, or: $value.signalQuality),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt));

  @override
  PositionPropertiesCopyWith<$R2, PositionProperties, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _PositionPropertiesCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PositionModelMapper extends ClassMapperBase<PositionModel> {
  PositionModelMapper._();

  static PositionModelMapper? _instance;
  static PositionModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PositionModelMapper._());
      GeoPointMapper.ensureInitialized();
      PositionPropertiesMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PositionModel';

  static String? _$type(PositionModel v) => v.type;
  static const Field<PositionModel, String> _f$type =
      Field('type', _$type, opt: true);
  static GeoPoint? _$geometry(PositionModel v) => v.geometry;
  static const Field<PositionModel, GeoPoint> _f$geometry =
      Field('geometry', _$geometry, opt: true);
  static PositionProperties? _$properties(PositionModel v) => v.properties;
  static const Field<PositionModel, PositionProperties> _f$properties =
      Field('properties', _$properties, opt: true);

  @override
  final MappableFields<PositionModel> fields = const {
    #type: _f$type,
    #geometry: _f$geometry,
    #properties: _f$properties,
  };

  static PositionModel _instantiate(DecodingData data) {
    return PositionModel(
        type: data.dec(_f$type),
        geometry: data.dec(_f$geometry),
        properties: data.dec(_f$properties));
  }

  @override
  final Function instantiate = _instantiate;

  static PositionModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PositionModel>(map);
  }

  static PositionModel fromJson(String json) {
    return ensureInitialized().decodeJson<PositionModel>(json);
  }
}

mixin PositionModelMappable {
  String toJson() {
    return PositionModelMapper.ensureInitialized()
        .encodeJson<PositionModel>(this as PositionModel);
  }

  Map<String, dynamic> toMap() {
    return PositionModelMapper.ensureInitialized()
        .encodeMap<PositionModel>(this as PositionModel);
  }

  PositionModelCopyWith<PositionModel, PositionModel, PositionModel>
      get copyWith => _PositionModelCopyWithImpl<PositionModel, PositionModel>(
          this as PositionModel, $identity, $identity);
  @override
  String toString() {
    return PositionModelMapper.ensureInitialized()
        .stringifyValue(this as PositionModel);
  }

  @override
  bool operator ==(Object other) {
    return PositionModelMapper.ensureInitialized()
        .equalsValue(this as PositionModel, other);
  }

  @override
  int get hashCode {
    return PositionModelMapper.ensureInitialized()
        .hashValue(this as PositionModel);
  }
}

extension PositionModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PositionModel, $Out> {
  PositionModelCopyWith<$R, PositionModel, $Out> get $asPositionModel =>
      $base.as((v, t, t2) => _PositionModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PositionModelCopyWith<$R, $In extends PositionModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  GeoPointCopyWith<$R, GeoPoint, GeoPoint>? get geometry;
  PositionPropertiesCopyWith<$R, PositionProperties, PositionProperties>?
      get properties;
  $R call({String? type, GeoPoint? geometry, PositionProperties? properties});
  PositionModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PositionModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PositionModel, $Out>
    implements PositionModelCopyWith<$R, PositionModel, $Out> {
  _PositionModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PositionModel> $mapper =
      PositionModelMapper.ensureInitialized();
  @override
  GeoPointCopyWith<$R, GeoPoint, GeoPoint>? get geometry =>
      $value.geometry?.copyWith.$chain((v) => call(geometry: v));
  @override
  PositionPropertiesCopyWith<$R, PositionProperties, PositionProperties>?
      get properties =>
          $value.properties?.copyWith.$chain((v) => call(properties: v));
  @override
  $R call(
          {Object? type = $none,
          Object? geometry = $none,
          Object? properties = $none}) =>
      $apply(FieldCopyWithData({
        if (type != $none) #type: type,
        if (geometry != $none) #geometry: geometry,
        if (properties != $none) #properties: properties
      }));
  @override
  PositionModel $make(CopyWithData data) => PositionModel(
      type: data.get(#type, or: $value.type),
      geometry: data.get(#geometry, or: $value.geometry),
      properties: data.get(#properties, or: $value.properties));

  @override
  PositionModelCopyWith<$R2, PositionModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _PositionModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
