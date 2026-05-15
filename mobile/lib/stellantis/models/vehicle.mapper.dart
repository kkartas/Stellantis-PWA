// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'vehicle.dart';

class VehicleModelMapper extends ClassMapperBase<VehicleModel> {
  VehicleModelMapper._();

  static VehicleModelMapper? _instance;
  static VehicleModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = VehicleModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'VehicleModel';

  static String _$vin(VehicleModel v) => v.vin;
  static const Field<VehicleModel, String> _f$vin = Field('vin', _$vin);
  static String _$vehicleId(VehicleModel v) => v.vehicleId;
  static const Field<VehicleModel, String> _f$vehicleId =
      Field('vehicleId', _$vehicleId, key: r'id');
  static String? _$label(VehicleModel v) => v.label;
  static const Field<VehicleModel, String> _f$label =
      Field('label', _$label, opt: true);
  static String? _$brand(VehicleModel v) => v.brand;
  static const Field<VehicleModel, String> _f$brand =
      Field('brand', _$brand, opt: true);
  static List<String>? _$pictureUrl(VehicleModel v) => v.pictureUrl;
  static const Field<VehicleModel, List<String>> _f$pictureUrl =
      Field('pictureUrl', _$pictureUrl, key: r'pictures', opt: true);

  @override
  final MappableFields<VehicleModel> fields = const {
    #vin: _f$vin,
    #vehicleId: _f$vehicleId,
    #label: _f$label,
    #brand: _f$brand,
    #pictureUrl: _f$pictureUrl,
  };

  static VehicleModel _instantiate(DecodingData data) {
    return VehicleModel(
        vin: data.dec(_f$vin),
        vehicleId: data.dec(_f$vehicleId),
        label: data.dec(_f$label),
        brand: data.dec(_f$brand),
        pictureUrl: data.dec(_f$pictureUrl));
  }

  @override
  final Function instantiate = _instantiate;

  static VehicleModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<VehicleModel>(map);
  }

  static VehicleModel fromJson(String json) {
    return ensureInitialized().decodeJson<VehicleModel>(json);
  }
}

mixin VehicleModelMappable {
  String toJson() {
    return VehicleModelMapper.ensureInitialized()
        .encodeJson<VehicleModel>(this as VehicleModel);
  }

  Map<String, dynamic> toMap() {
    return VehicleModelMapper.ensureInitialized()
        .encodeMap<VehicleModel>(this as VehicleModel);
  }

  VehicleModelCopyWith<VehicleModel, VehicleModel, VehicleModel> get copyWith =>
      _VehicleModelCopyWithImpl(this as VehicleModel, $identity, $identity);
  @override
  String toString() {
    return VehicleModelMapper.ensureInitialized()
        .stringifyValue(this as VehicleModel);
  }

  @override
  bool operator ==(Object other) {
    return VehicleModelMapper.ensureInitialized()
        .equalsValue(this as VehicleModel, other);
  }

  @override
  int get hashCode {
    return VehicleModelMapper.ensureInitialized()
        .hashValue(this as VehicleModel);
  }
}

extension VehicleModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, VehicleModel, $Out> {
  VehicleModelCopyWith<$R, VehicleModel, $Out> get $asVehicleModel =>
      $base.as((v, t, t2) => _VehicleModelCopyWithImpl(v, t, t2));
}

abstract class VehicleModelCopyWith<$R, $In extends VehicleModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get pictureUrl;
  $R call(
      {String? vin,
      String? vehicleId,
      String? label,
      String? brand,
      List<String>? pictureUrl});
  VehicleModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _VehicleModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, VehicleModel, $Out>
    implements VehicleModelCopyWith<$R, VehicleModel, $Out> {
  _VehicleModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<VehicleModel> $mapper =
      VehicleModelMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
      get pictureUrl => $value.pictureUrl != null
          ? ListCopyWith(
              $value.pictureUrl!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(pictureUrl: v))
          : null;
  @override
  $R call(
          {String? vin,
          String? vehicleId,
          Object? label = $none,
          Object? brand = $none,
          Object? pictureUrl = $none}) =>
      $apply(FieldCopyWithData({
        if (vin != null) #vin: vin,
        if (vehicleId != null) #vehicleId: vehicleId,
        if (label != $none) #label: label,
        if (brand != $none) #brand: brand,
        if (pictureUrl != $none) #pictureUrl: pictureUrl
      }));
  @override
  VehicleModel $make(CopyWithData data) => VehicleModel(
      vin: data.get(#vin, or: $value.vin),
      vehicleId: data.get(#vehicleId, or: $value.vehicleId),
      label: data.get(#label, or: $value.label),
      brand: data.get(#brand, or: $value.brand),
      pictureUrl: data.get(#pictureUrl, or: $value.pictureUrl));

  @override
  VehicleModelCopyWith<$R2, VehicleModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _VehicleModelCopyWithImpl($value, $cast, t);
}

class VehiclesResponseMapper extends ClassMapperBase<VehiclesResponse> {
  VehiclesResponseMapper._();

  static VehiclesResponseMapper? _instance;
  static VehiclesResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = VehiclesResponseMapper._());
      VehiclesEmbeddedMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'VehiclesResponse';

  static VehiclesEmbedded? _$vehicles(VehiclesResponse v) => v.vehicles;
  static const Field<VehiclesResponse, VehiclesEmbedded> _f$vehicles =
      Field('vehicles', _$vehicles, key: r'_embedded', opt: true);

  @override
  final MappableFields<VehiclesResponse> fields = const {
    #vehicles: _f$vehicles,
  };

  static VehiclesResponse _instantiate(DecodingData data) {
    return VehiclesResponse(vehicles: data.dec(_f$vehicles));
  }

  @override
  final Function instantiate = _instantiate;

  static VehiclesResponse fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<VehiclesResponse>(map);
  }

  static VehiclesResponse fromJson(String json) {
    return ensureInitialized().decodeJson<VehiclesResponse>(json);
  }
}

mixin VehiclesResponseMappable {
  String toJson() {
    return VehiclesResponseMapper.ensureInitialized()
        .encodeJson<VehiclesResponse>(this as VehiclesResponse);
  }

  Map<String, dynamic> toMap() {
    return VehiclesResponseMapper.ensureInitialized()
        .encodeMap<VehiclesResponse>(this as VehiclesResponse);
  }

  VehiclesResponseCopyWith<VehiclesResponse, VehiclesResponse, VehiclesResponse>
      get copyWith => _VehiclesResponseCopyWithImpl(
          this as VehiclesResponse, $identity, $identity);
  @override
  String toString() {
    return VehiclesResponseMapper.ensureInitialized()
        .stringifyValue(this as VehiclesResponse);
  }

  @override
  bool operator ==(Object other) {
    return VehiclesResponseMapper.ensureInitialized()
        .equalsValue(this as VehiclesResponse, other);
  }

  @override
  int get hashCode {
    return VehiclesResponseMapper.ensureInitialized()
        .hashValue(this as VehiclesResponse);
  }
}

extension VehiclesResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, VehiclesResponse, $Out> {
  VehiclesResponseCopyWith<$R, VehiclesResponse, $Out>
      get $asVehiclesResponse =>
          $base.as((v, t, t2) => _VehiclesResponseCopyWithImpl(v, t, t2));
}

abstract class VehiclesResponseCopyWith<$R, $In extends VehiclesResponse, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  VehiclesEmbeddedCopyWith<$R, VehiclesEmbedded, VehiclesEmbedded>?
      get vehicles;
  $R call({VehiclesEmbedded? vehicles});
  VehiclesResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _VehiclesResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, VehiclesResponse, $Out>
    implements VehiclesResponseCopyWith<$R, VehiclesResponse, $Out> {
  _VehiclesResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<VehiclesResponse> $mapper =
      VehiclesResponseMapper.ensureInitialized();
  @override
  VehiclesEmbeddedCopyWith<$R, VehiclesEmbedded, VehiclesEmbedded>?
      get vehicles =>
          $value.vehicles?.copyWith.$chain((v) => call(vehicles: v));
  @override
  $R call({Object? vehicles = $none}) =>
      $apply(FieldCopyWithData({if (vehicles != $none) #vehicles: vehicles}));
  @override
  VehiclesResponse $make(CopyWithData data) =>
      VehiclesResponse(vehicles: data.get(#vehicles, or: $value.vehicles));

  @override
  VehiclesResponseCopyWith<$R2, VehiclesResponse, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _VehiclesResponseCopyWithImpl($value, $cast, t);
}

class VehiclesEmbeddedMapper extends ClassMapperBase<VehiclesEmbedded> {
  VehiclesEmbeddedMapper._();

  static VehiclesEmbeddedMapper? _instance;
  static VehiclesEmbeddedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = VehiclesEmbeddedMapper._());
      VehicleModelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'VehiclesEmbedded';

  static List<VehicleModel>? _$vehicles(VehiclesEmbedded v) => v.vehicles;
  static const Field<VehiclesEmbedded, List<VehicleModel>> _f$vehicles =
      Field('vehicles', _$vehicles, opt: true);

  @override
  final MappableFields<VehiclesEmbedded> fields = const {
    #vehicles: _f$vehicles,
  };

  static VehiclesEmbedded _instantiate(DecodingData data) {
    return VehiclesEmbedded(vehicles: data.dec(_f$vehicles));
  }

  @override
  final Function instantiate = _instantiate;

  static VehiclesEmbedded fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<VehiclesEmbedded>(map);
  }

  static VehiclesEmbedded fromJson(String json) {
    return ensureInitialized().decodeJson<VehiclesEmbedded>(json);
  }
}

mixin VehiclesEmbeddedMappable {
  String toJson() {
    return VehiclesEmbeddedMapper.ensureInitialized()
        .encodeJson<VehiclesEmbedded>(this as VehiclesEmbedded);
  }

  Map<String, dynamic> toMap() {
    return VehiclesEmbeddedMapper.ensureInitialized()
        .encodeMap<VehiclesEmbedded>(this as VehiclesEmbedded);
  }

  VehiclesEmbeddedCopyWith<VehiclesEmbedded, VehiclesEmbedded, VehiclesEmbedded>
      get copyWith => _VehiclesEmbeddedCopyWithImpl(
          this as VehiclesEmbedded, $identity, $identity);
  @override
  String toString() {
    return VehiclesEmbeddedMapper.ensureInitialized()
        .stringifyValue(this as VehiclesEmbedded);
  }

  @override
  bool operator ==(Object other) {
    return VehiclesEmbeddedMapper.ensureInitialized()
        .equalsValue(this as VehiclesEmbedded, other);
  }

  @override
  int get hashCode {
    return VehiclesEmbeddedMapper.ensureInitialized()
        .hashValue(this as VehiclesEmbedded);
  }
}

extension VehiclesEmbeddedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, VehiclesEmbedded, $Out> {
  VehiclesEmbeddedCopyWith<$R, VehiclesEmbedded, $Out>
      get $asVehiclesEmbedded =>
          $base.as((v, t, t2) => _VehiclesEmbeddedCopyWithImpl(v, t, t2));
}

abstract class VehiclesEmbeddedCopyWith<$R, $In extends VehiclesEmbedded, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, VehicleModel,
      VehicleModelCopyWith<$R, VehicleModel, VehicleModel>>? get vehicles;
  $R call({List<VehicleModel>? vehicles});
  VehiclesEmbeddedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _VehiclesEmbeddedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, VehiclesEmbedded, $Out>
    implements VehiclesEmbeddedCopyWith<$R, VehiclesEmbedded, $Out> {
  _VehiclesEmbeddedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<VehiclesEmbedded> $mapper =
      VehiclesEmbeddedMapper.ensureInitialized();
  @override
  ListCopyWith<$R, VehicleModel,
          VehicleModelCopyWith<$R, VehicleModel, VehicleModel>>?
      get vehicles => $value.vehicles != null
          ? ListCopyWith($value.vehicles!, (v, t) => v.copyWith.$chain(t),
              (v) => call(vehicles: v))
          : null;
  @override
  $R call({Object? vehicles = $none}) =>
      $apply(FieldCopyWithData({if (vehicles != $none) #vehicles: vehicles}));
  @override
  VehiclesEmbedded $make(CopyWithData data) =>
      VehiclesEmbedded(vehicles: data.get(#vehicles, or: $value.vehicles));

  @override
  VehiclesEmbeddedCopyWith<$R2, VehiclesEmbedded, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _VehiclesEmbeddedCopyWithImpl($value, $cast, t);
}
