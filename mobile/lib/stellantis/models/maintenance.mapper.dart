// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'maintenance.dart';

class MaintenanceModelMapper extends ClassMapperBase<MaintenanceModel> {
  MaintenanceModelMapper._();

  static MaintenanceModelMapper? _instance;
  static MaintenanceModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MaintenanceModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MaintenanceModel';

  static int? _$daysBeforeMaintenance(MaintenanceModel v) =>
      v.daysBeforeMaintenance;
  static const Field<MaintenanceModel, int> _f$daysBeforeMaintenance =
      Field('daysBeforeMaintenance', _$daysBeforeMaintenance, opt: true);
  static double? _$mileageBeforeMaintenance(MaintenanceModel v) =>
      v.mileageBeforeMaintenance;
  static const Field<MaintenanceModel, double> _f$mileageBeforeMaintenance =
      Field('mileageBeforeMaintenance', _$mileageBeforeMaintenance, opt: true);
  static DateTime? _$createdAt(MaintenanceModel v) => v.createdAt;
  static const Field<MaintenanceModel, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, opt: true);
  static DateTime? _$updatedAt(MaintenanceModel v) => v.updatedAt;
  static const Field<MaintenanceModel, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, opt: true);

  @override
  final MappableFields<MaintenanceModel> fields = const {
    #daysBeforeMaintenance: _f$daysBeforeMaintenance,
    #mileageBeforeMaintenance: _f$mileageBeforeMaintenance,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  static MaintenanceModel _instantiate(DecodingData data) {
    return MaintenanceModel(
        daysBeforeMaintenance: data.dec(_f$daysBeforeMaintenance),
        mileageBeforeMaintenance: data.dec(_f$mileageBeforeMaintenance),
        createdAt: data.dec(_f$createdAt),
        updatedAt: data.dec(_f$updatedAt));
  }

  @override
  final Function instantiate = _instantiate;

  static MaintenanceModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MaintenanceModel>(map);
  }

  static MaintenanceModel fromJson(String json) {
    return ensureInitialized().decodeJson<MaintenanceModel>(json);
  }
}

mixin MaintenanceModelMappable {
  String toJson() {
    return MaintenanceModelMapper.ensureInitialized()
        .encodeJson<MaintenanceModel>(this as MaintenanceModel);
  }

  Map<String, dynamic> toMap() {
    return MaintenanceModelMapper.ensureInitialized()
        .encodeMap<MaintenanceModel>(this as MaintenanceModel);
  }

  MaintenanceModelCopyWith<MaintenanceModel, MaintenanceModel, MaintenanceModel>
      get copyWith => _MaintenanceModelCopyWithImpl(
          this as MaintenanceModel, $identity, $identity);
  @override
  String toString() {
    return MaintenanceModelMapper.ensureInitialized()
        .stringifyValue(this as MaintenanceModel);
  }

  @override
  bool operator ==(Object other) {
    return MaintenanceModelMapper.ensureInitialized()
        .equalsValue(this as MaintenanceModel, other);
  }

  @override
  int get hashCode {
    return MaintenanceModelMapper.ensureInitialized()
        .hashValue(this as MaintenanceModel);
  }
}

extension MaintenanceModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MaintenanceModel, $Out> {
  MaintenanceModelCopyWith<$R, MaintenanceModel, $Out>
      get $asMaintenanceModel =>
          $base.as((v, t, t2) => _MaintenanceModelCopyWithImpl(v, t, t2));
}

abstract class MaintenanceModelCopyWith<$R, $In extends MaintenanceModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {int? daysBeforeMaintenance,
      double? mileageBeforeMaintenance,
      DateTime? createdAt,
      DateTime? updatedAt});
  MaintenanceModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _MaintenanceModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MaintenanceModel, $Out>
    implements MaintenanceModelCopyWith<$R, MaintenanceModel, $Out> {
  _MaintenanceModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MaintenanceModel> $mapper =
      MaintenanceModelMapper.ensureInitialized();
  @override
  $R call(
          {Object? daysBeforeMaintenance = $none,
          Object? mileageBeforeMaintenance = $none,
          Object? createdAt = $none,
          Object? updatedAt = $none}) =>
      $apply(FieldCopyWithData({
        if (daysBeforeMaintenance != $none)
          #daysBeforeMaintenance: daysBeforeMaintenance,
        if (mileageBeforeMaintenance != $none)
          #mileageBeforeMaintenance: mileageBeforeMaintenance,
        if (createdAt != $none) #createdAt: createdAt,
        if (updatedAt != $none) #updatedAt: updatedAt
      }));
  @override
  MaintenanceModel $make(CopyWithData data) => MaintenanceModel(
      daysBeforeMaintenance:
          data.get(#daysBeforeMaintenance, or: $value.daysBeforeMaintenance),
      mileageBeforeMaintenance: data.get(#mileageBeforeMaintenance,
          or: $value.mileageBeforeMaintenance),
      createdAt: data.get(#createdAt, or: $value.createdAt),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt));

  @override
  MaintenanceModelCopyWith<$R2, MaintenanceModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _MaintenanceModelCopyWithImpl($value, $cast, t);
}
