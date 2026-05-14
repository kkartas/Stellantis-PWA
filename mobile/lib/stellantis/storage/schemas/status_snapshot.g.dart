// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_snapshot.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStatusSnapshotCollection on Isar {
  IsarCollection<StatusSnapshot> get statusSnapshots => this.collection();
}

const StatusSnapshotSchema = CollectionSchema(
  name: r'StatusSnapshot',
  id: 7133740480961583678,
  properties: {
    r'batteryLevel': PropertySchema(
      id: 0,
      name: r'batteryLevel',
      type: IsarType.long,
    ),
    r'batteryResistance': PropertySchema(
      id: 1,
      name: r'batteryResistance',
      type: IsarType.double,
    ),
    r'chargingMode': PropertySchema(
      id: 2,
      name: r'chargingMode',
      type: IsarType.string,
    ),
    r'chargingStatus': PropertySchema(
      id: 3,
      name: r'chargingStatus',
      type: IsarType.string,
    ),
    r'fuelLevel': PropertySchema(
      id: 4,
      name: r'fuelLevel',
      type: IsarType.long,
    ),
    r'latitude': PropertySchema(
      id: 5,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 6,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'mileage': PropertySchema(
      id: 7,
      name: r'mileage',
      type: IsarType.double,
    ),
    r'speed': PropertySchema(
      id: 8,
      name: r'speed',
      type: IsarType.double,
    ),
    r'timestamp': PropertySchema(
      id: 9,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'vin': PropertySchema(
      id: 10,
      name: r'vin',
      type: IsarType.string,
    )
  },
  estimateSize: _statusSnapshotEstimateSize,
  serialize: _statusSnapshotSerialize,
  deserialize: _statusSnapshotDeserialize,
  deserializeProp: _statusSnapshotDeserializeProp,
  idName: r'id',
  indexes: {
    r'vin': IndexSchema(
      id: 4347584320853526484,
      name: r'vin',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'vin',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _statusSnapshotGetId,
  getLinks: _statusSnapshotGetLinks,
  attach: _statusSnapshotAttach,
  version: '3.1.0+1',
);

int _statusSnapshotEstimateSize(
  StatusSnapshot object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.chargingMode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.chargingStatus;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.vin.length * 3;
  return bytesCount;
}

void _statusSnapshotSerialize(
  StatusSnapshot object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.batteryLevel);
  writer.writeDouble(offsets[1], object.batteryResistance);
  writer.writeString(offsets[2], object.chargingMode);
  writer.writeString(offsets[3], object.chargingStatus);
  writer.writeLong(offsets[4], object.fuelLevel);
  writer.writeDouble(offsets[5], object.latitude);
  writer.writeDouble(offsets[6], object.longitude);
  writer.writeDouble(offsets[7], object.mileage);
  writer.writeDouble(offsets[8], object.speed);
  writer.writeDateTime(offsets[9], object.timestamp);
  writer.writeString(offsets[10], object.vin);
}

StatusSnapshot _statusSnapshotDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StatusSnapshot();
  object.batteryLevel = reader.readLongOrNull(offsets[0]);
  object.batteryResistance = reader.readDoubleOrNull(offsets[1]);
  object.chargingMode = reader.readStringOrNull(offsets[2]);
  object.chargingStatus = reader.readStringOrNull(offsets[3]);
  object.fuelLevel = reader.readLongOrNull(offsets[4]);
  object.id = id;
  object.latitude = reader.readDoubleOrNull(offsets[5]);
  object.longitude = reader.readDoubleOrNull(offsets[6]);
  object.mileage = reader.readDoubleOrNull(offsets[7]);
  object.speed = reader.readDoubleOrNull(offsets[8]);
  object.timestamp = reader.readDateTime(offsets[9]);
  object.vin = reader.readString(offsets[10]);
  return object;
}

P _statusSnapshotDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _statusSnapshotGetId(StatusSnapshot object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _statusSnapshotGetLinks(StatusSnapshot object) {
  return [];
}

void _statusSnapshotAttach(
    IsarCollection<dynamic> col, Id id, StatusSnapshot object) {
  object.id = id;
}

extension StatusSnapshotQueryWhereSort
    on QueryBuilder<StatusSnapshot, StatusSnapshot, QWhere> {
  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension StatusSnapshotQueryWhere
    on QueryBuilder<StatusSnapshot, StatusSnapshot, QWhereClause> {
  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterWhereClause> idBetween(
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

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterWhereClause> vinEqualTo(
      String vin) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'vin',
        value: [vin],
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterWhereClause> vinNotEqualTo(
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

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterWhereClause>
      timestampEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterWhereClause>
      timestampNotEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterWhereClause>
      timestampGreaterThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [timestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterWhereClause>
      timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [],
        upper: [timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterWhereClause>
      timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [lowerTimestamp],
        includeLower: includeLower,
        upper: [upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StatusSnapshotQueryFilter
    on QueryBuilder<StatusSnapshot, StatusSnapshot, QFilterCondition> {
  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      batteryLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'batteryLevel',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      batteryLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'batteryLevel',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      batteryLevelEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batteryLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      batteryLevelGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'batteryLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      batteryLevelLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'batteryLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      batteryLevelBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'batteryLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      batteryResistanceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'batteryResistance',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      batteryResistanceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'batteryResistance',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      batteryResistanceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batteryResistance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      batteryResistanceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'batteryResistance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      batteryResistanceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'batteryResistance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      batteryResistanceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'batteryResistance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingModeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'chargingMode',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingModeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'chargingMode',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingModeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chargingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingModeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chargingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingModeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chargingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingModeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chargingMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chargingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chargingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chargingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chargingMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chargingMode',
        value: '',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chargingMode',
        value: '',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingStatusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'chargingStatus',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingStatusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'chargingStatus',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingStatusEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chargingStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingStatusGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chargingStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingStatusLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chargingStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingStatusBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chargingStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chargingStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chargingStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chargingStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chargingStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chargingStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      chargingStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chargingStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      fuelLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fuelLevel',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      fuelLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fuelLevel',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      fuelLevelEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fuelLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      fuelLevelGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fuelLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      fuelLevelLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fuelLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      fuelLevelBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fuelLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
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

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      latitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'latitude',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      latitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'latitude',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      latitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      latitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      latitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      latitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      longitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'longitude',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      longitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'longitude',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      longitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      longitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      longitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      longitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      mileageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mileage',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      mileageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mileage',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      mileageEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mileage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      mileageGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mileage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      mileageLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mileage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      mileageBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mileage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      speedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'speed',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      speedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'speed',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      speedEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      speedGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'speed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      speedLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'speed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      speedBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'speed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      vinEqualTo(
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

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
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

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      vinLessThan(
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

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      vinBetween(
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

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
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

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      vinEndsWith(
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

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      vinContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      vinMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vin',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      vinIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vin',
        value: '',
      ));
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterFilterCondition>
      vinIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vin',
        value: '',
      ));
    });
  }
}

extension StatusSnapshotQueryObject
    on QueryBuilder<StatusSnapshot, StatusSnapshot, QFilterCondition> {}

extension StatusSnapshotQueryLinks
    on QueryBuilder<StatusSnapshot, StatusSnapshot, QFilterCondition> {}

extension StatusSnapshotQuerySortBy
    on QueryBuilder<StatusSnapshot, StatusSnapshot, QSortBy> {
  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      sortByBatteryLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryLevel', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      sortByBatteryLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryLevel', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      sortByBatteryResistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryResistance', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      sortByBatteryResistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryResistance', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      sortByChargingMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chargingMode', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      sortByChargingModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chargingMode', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      sortByChargingStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chargingStatus', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      sortByChargingStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chargingStatus', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> sortByFuelLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelLevel', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      sortByFuelLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelLevel', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> sortByMileage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mileage', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      sortByMileageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mileage', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> sortBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> sortBySpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> sortByVin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vin', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> sortByVinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vin', Sort.desc);
    });
  }
}

extension StatusSnapshotQuerySortThenBy
    on QueryBuilder<StatusSnapshot, StatusSnapshot, QSortThenBy> {
  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      thenByBatteryLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryLevel', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      thenByBatteryLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryLevel', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      thenByBatteryResistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryResistance', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      thenByBatteryResistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batteryResistance', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      thenByChargingMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chargingMode', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      thenByChargingModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chargingMode', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      thenByChargingStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chargingStatus', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      thenByChargingStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chargingStatus', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> thenByFuelLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelLevel', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      thenByFuelLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelLevel', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> thenByMileage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mileage', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      thenByMileageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mileage', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> thenBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> thenBySpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> thenByVin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vin', Sort.asc);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QAfterSortBy> thenByVinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vin', Sort.desc);
    });
  }
}

extension StatusSnapshotQueryWhereDistinct
    on QueryBuilder<StatusSnapshot, StatusSnapshot, QDistinct> {
  QueryBuilder<StatusSnapshot, StatusSnapshot, QDistinct>
      distinctByBatteryLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batteryLevel');
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QDistinct>
      distinctByBatteryResistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batteryResistance');
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QDistinct>
      distinctByChargingMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chargingMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QDistinct>
      distinctByChargingStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chargingStatus',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QDistinct>
      distinctByFuelLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fuelLevel');
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QDistinct>
      distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QDistinct> distinctByMileage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mileage');
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QDistinct> distinctBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speed');
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<StatusSnapshot, StatusSnapshot, QDistinct> distinctByVin(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vin', caseSensitive: caseSensitive);
    });
  }
}

extension StatusSnapshotQueryProperty
    on QueryBuilder<StatusSnapshot, StatusSnapshot, QQueryProperty> {
  QueryBuilder<StatusSnapshot, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StatusSnapshot, int?, QQueryOperations> batteryLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batteryLevel');
    });
  }

  QueryBuilder<StatusSnapshot, double?, QQueryOperations>
      batteryResistanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batteryResistance');
    });
  }

  QueryBuilder<StatusSnapshot, String?, QQueryOperations>
      chargingModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chargingMode');
    });
  }

  QueryBuilder<StatusSnapshot, String?, QQueryOperations>
      chargingStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chargingStatus');
    });
  }

  QueryBuilder<StatusSnapshot, int?, QQueryOperations> fuelLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fuelLevel');
    });
  }

  QueryBuilder<StatusSnapshot, double?, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<StatusSnapshot, double?, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<StatusSnapshot, double?, QQueryOperations> mileageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mileage');
    });
  }

  QueryBuilder<StatusSnapshot, double?, QQueryOperations> speedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speed');
    });
  }

  QueryBuilder<StatusSnapshot, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<StatusSnapshot, String, QQueryOperations> vinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vin');
    });
  }
}
