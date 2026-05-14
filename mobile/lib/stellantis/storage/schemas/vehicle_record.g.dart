// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVehicleRecordCollection on Isar {
  IsarCollection<VehicleRecord> get vehicleRecords => this.collection();
}

const VehicleRecordSchema = CollectionSchema(
  name: r'VehicleRecord',
  id: -3548028493443854613,
  properties: {
    r'batteryPower': PropertySchema(
      id: 0,
      name: r'batteryPower',
      type: IsarType.double,
    ),
    r'brand': PropertySchema(
      id: 1,
      name: r'brand',
      type: IsarType.string,
    ),
    r'fuelCapacity': PropertySchema(
      id: 2,
      name: r'fuelCapacity',
      type: IsarType.double,
    ),
    r'label': PropertySchema(
      id: 3,
      name: r'label',
      type: IsarType.string,
    ),
    r'lastSeenAt': PropertySchema(
      id: 4,
      name: r'lastSeenAt',
      type: IsarType.dateTime,
    ),
    r'modelName': PropertySchema(
      id: 5,
      name: r'modelName',
      type: IsarType.string,
    ),
    r'vin': PropertySchema(
      id: 6,
      name: r'vin',
      type: IsarType.string,
    )
  },
  estimateSize: _vehicleRecordEstimateSize,
  serialize: _vehicleRecordSerialize,
  deserialize: _vehicleRecordDeserialize,
  deserializeProp: _vehicleRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'vin': IndexSchema(
      id: 4347584320853526484,
      name: r'vin',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'vin',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _vehicleRecordGetId,
  getLinks: _vehicleRecordGetLinks,
  attach: _vehicleRecordAttach,
  version: '3.1.0+1',
);

int _vehicleRecordEstimateSize(
  VehicleRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.brand.length * 3;
  bytesCount += 3 + object.label.length * 3;
  {
    final value = object.modelName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.vin.length * 3;
  return bytesCount;
}

void _vehicleRecordSerialize(
  VehicleRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.batteryPower);
  writer.writeString(offsets[1], object.brand);
  writer.writeDouble(offsets[2], object.fuelCapacity);
  writer.writeString(offsets[3], object.label);
  writer.writeDateTime(offsets[4], object.lastSeenAt);
  writer.writeString(offsets[5], object.modelName);
  writer.writeString(offsets[6], object.vin);
}

VehicleRecord _vehicleRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VehicleRecord();
  object.batteryPower = reader.readDouble(offsets[0]);
  object.brand = reader.readString(offsets[1]);
  object.fuelCapacity = reader.readDouble(offsets[2]);
  object.id = id;
  object.label = reader.readString(offsets[3]);
  object.lastSeenAt = reader.readDateTimeOrNull(offsets[4]);
  object.modelName = reader.readStringOrNull(offsets[5]);
  object.vin = reader.readString(offsets[6]);
  return object;
}

P _vehicleRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _vehicleRecordGetId(VehicleRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _vehicleRecordGetLinks(VehicleRecord object) {
  return [];
}

void _vehicleRecordAttach(
    IsarCollection<dynamic> col, Id id, VehicleRecord object) {
  object.id = id;
}

extension VehicleRecordByIndex on IsarCollection<VehicleRecord> {
  Future<VehicleRecord?> getByVin(String vin) {
    return getByIndex(r'vin', [vin]);
  }

  VehicleRecord? getByVinSync(String vin) {
    return getByIndexSync(r'vin', [vin]);
  }

  Future<bool> deleteByVin(String vin) {
    return deleteByIndex(r'vin', [vin]);
  }

  bool deleteByVinSync(String vin) {
    return deleteByIndexSync(r'vin', [vin]);
  }

  Future<List<VehicleRecord?>> getAllByVin(List<String> vinValues) {
    final values = vinValues.map((e) => [e]).toList();
    return getAllByIndex(r'vin', values);
  }

  List<VehicleRecord?> getAllByVinSync(List<String> vinValues) {
    final values = vinValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'vin', values);
  }

  Future<int> deleteAllByVin(List<String> vinValues) {
    final values = vinValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'vin', values);
  }

  int deleteAllByVinSync(List<String> vinValues) {
    final values = vinValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'vin', values);
  }

  Future<Id> putByVin(VehicleRecord object) {
    return putByIndex(r'vin', object);
  }

  Id putByVinSync(VehicleRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'vin', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByVin(List<VehicleRecord> objects) {
    return putAllByIndex(r'vin', objects);
  }

  List<Id> putAllByVinSync(List<VehicleRecord> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'vin', objects, saveLinks: saveLinks);
  }
}

extension VehicleRecordQueryWhereSort
    on QueryBuilder<VehicleRecord, VehicleRecord, QWhere> {
  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VehicleRecordQueryWhere
    on QueryBuilder<VehicleRecord, VehicleRecord, QWhereClause> {
  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> vinEqualTo(
      String vin) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'vin',
        value: [vin],
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterWhereClause> vinNotEqualTo(
      String vin) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'vin',
              lower: [],
              upper: [vin],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'vin',
              lower: [vin],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'vin',
              lower: [vin],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'vin',
              lower: [],
              upper: [vin],
              includeUpper: false,
            ));
      }
    });
  }
}

extension VehicleRecordQueryFilter
    on QueryBuilder<VehicleRecord, VehicleRecord, QFilterCondition> {
  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      batteryPowerEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batteryPower',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      batteryPowerGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'batteryPower',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      batteryPowerLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'batteryPower',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      batteryPowerBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'batteryPower',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      brandEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      brandGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      brandLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      brandBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'brand',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      brandStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      brandEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      brandContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      brandMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'brand',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      brandIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'brand',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      brandIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'brand',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      fuelCapacityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fuelCapacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      fuelCapacityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fuelCapacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      fuelCapacityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fuelCapacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      fuelCapacityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fuelCapacity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      labelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'label',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'label',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      lastSeenAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSeenAt',
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      lastSeenAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSeenAt',
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      lastSeenAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSeenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      lastSeenAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSeenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      lastSeenAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSeenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      lastSeenAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSeenAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      modelNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'modelName',
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      modelNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'modelName',
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      modelNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      modelNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'modelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      modelNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'modelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      modelNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'modelName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      modelNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'modelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      modelNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'modelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      modelNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'modelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      modelNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'modelName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      modelNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modelName',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      modelNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'modelName',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> vinEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      vinGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> vinLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> vinBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      vinStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'vin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> vinEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'vin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> vinContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition> vinMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vin',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      vinIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vin',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterFilterCondition>
      vinIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vin',
        value: '',
      ));
    });
  }
}

extension VehicleRecordQueryObject
    on QueryBuilder<VehicleRecord, VehicleRecord, QFilterCondition> {}

extension VehicleRecordQueryLinks
    on QueryBuilder<VehicleRecord, VehicleRecord, QFilterCondition> {}

extension VehicleRecordQuerySortBy
    on QueryBuilder<VehicleRecord, VehicleRecord, QSortBy> {
  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
      sortByBatteryPower() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryPower', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
      sortByBatteryPowerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryPower', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByBrand() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByBrandDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
      sortByFuelCapacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelCapacity', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
      sortByFuelCapacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelCapacity', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
      sortByLastSeenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByModelName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelName', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
      sortByModelNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelName', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByVin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vin', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> sortByVinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vin', Sort.desc);
    });
  }
}

extension VehicleRecordQuerySortThenBy
    on QueryBuilder<VehicleRecord, VehicleRecord, QSortThenBy> {
  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
      thenByBatteryPower() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryPower', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
      thenByBatteryPowerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryPower', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByBrand() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByBrandDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
      thenByFuelCapacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelCapacity', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
      thenByFuelCapacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelCapacity', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
      thenByLastSeenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByModelName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelName', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy>
      thenByModelNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelName', Sort.desc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByVin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vin', Sort.asc);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QAfterSortBy> thenByVinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vin', Sort.desc);
    });
  }
}

extension VehicleRecordQueryWhereDistinct
    on QueryBuilder<VehicleRecord, VehicleRecord, QDistinct> {
  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct>
      distinctByBatteryPower() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batteryPower');
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct> distinctByBrand(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'brand', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct>
      distinctByFuelCapacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fuelCapacity');
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct> distinctByLabel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct> distinctByLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSeenAt');
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct> distinctByModelName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'modelName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleRecord, VehicleRecord, QDistinct> distinctByVin(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vin', caseSensitive: caseSensitive);
    });
  }
}

extension VehicleRecordQueryProperty
    on QueryBuilder<VehicleRecord, VehicleRecord, QQueryProperty> {
  QueryBuilder<VehicleRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VehicleRecord, double, QQueryOperations> batteryPowerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batteryPower');
    });
  }

  QueryBuilder<VehicleRecord, String, QQueryOperations> brandProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'brand');
    });
  }

  QueryBuilder<VehicleRecord, double, QQueryOperations> fuelCapacityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fuelCapacity');
    });
  }

  QueryBuilder<VehicleRecord, String, QQueryOperations> labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<VehicleRecord, DateTime?, QQueryOperations>
      lastSeenAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSeenAt');
    });
  }

  QueryBuilder<VehicleRecord, String?, QQueryOperations> modelNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'modelName');
    });
  }

  QueryBuilder<VehicleRecord, String, QQueryOperations> vinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vin');
    });
  }
}
