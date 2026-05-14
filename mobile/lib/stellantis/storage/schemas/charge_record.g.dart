// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charge_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChargeRecordCollection on Isar {
  IsarCollection<ChargeRecord> get chargeRecords => this.collection();
}

const ChargeRecordSchema = CollectionSchema(
  name: r'ChargeRecord',
  id: 1965698601839243160,
  properties: {
    r'chargingMode': PropertySchema(
      id: 0,
      name: r'chargingMode',
      type: IsarType.string,
    ),
    r'co2': PropertySchema(
      id: 1,
      name: r'co2',
      type: IsarType.double,
    ),
    r'endLevel': PropertySchema(
      id: 2,
      name: r'endLevel',
      type: IsarType.double,
    ),
    r'kw': PropertySchema(
      id: 3,
      name: r'kw',
      type: IsarType.double,
    ),
    r'mileage': PropertySchema(
      id: 4,
      name: r'mileage',
      type: IsarType.double,
    ),
    r'price': PropertySchema(
      id: 5,
      name: r'price',
      type: IsarType.double,
    ),
    r'startAt': PropertySchema(
      id: 6,
      name: r'startAt',
      type: IsarType.dateTime,
    ),
    r'startLevel': PropertySchema(
      id: 7,
      name: r'startLevel',
      type: IsarType.double,
    ),
    r'stopAt': PropertySchema(
      id: 8,
      name: r'stopAt',
      type: IsarType.dateTime,
    ),
    r'vin': PropertySchema(
      id: 9,
      name: r'vin',
      type: IsarType.string,
    )
  },
  estimateSize: _chargeRecordEstimateSize,
  serialize: _chargeRecordSerialize,
  deserialize: _chargeRecordDeserialize,
  deserializeProp: _chargeRecordDeserializeProp,
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
    r'startAt': IndexSchema(
      id: 4187465024431158613,
      name: r'startAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _chargeRecordGetId,
  getLinks: _chargeRecordGetLinks,
  attach: _chargeRecordAttach,
  version: '3.1.0+1',
);

int _chargeRecordEstimateSize(
  ChargeRecord object,
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
  bytesCount += 3 + object.vin.length * 3;
  return bytesCount;
}

void _chargeRecordSerialize(
  ChargeRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.chargingMode);
  writer.writeDouble(offsets[1], object.co2);
  writer.writeDouble(offsets[2], object.endLevel);
  writer.writeDouble(offsets[3], object.kw);
  writer.writeDouble(offsets[4], object.mileage);
  writer.writeDouble(offsets[5], object.price);
  writer.writeDateTime(offsets[6], object.startAt);
  writer.writeDouble(offsets[7], object.startLevel);
  writer.writeDateTime(offsets[8], object.stopAt);
  writer.writeString(offsets[9], object.vin);
}

ChargeRecord _chargeRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChargeRecord();
  object.chargingMode = reader.readStringOrNull(offsets[0]);
  object.co2 = reader.readDoubleOrNull(offsets[1]);
  object.endLevel = reader.readDoubleOrNull(offsets[2]);
  object.id = id;
  object.kw = reader.readDoubleOrNull(offsets[3]);
  object.mileage = reader.readDoubleOrNull(offsets[4]);
  object.price = reader.readDoubleOrNull(offsets[5]);
  object.startAt = reader.readDateTime(offsets[6]);
  object.startLevel = reader.readDoubleOrNull(offsets[7]);
  object.stopAt = reader.readDateTimeOrNull(offsets[8]);
  object.vin = reader.readString(offsets[9]);
  return object;
}

P _chargeRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _chargeRecordGetId(ChargeRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _chargeRecordGetLinks(ChargeRecord object) {
  return [];
}

void _chargeRecordAttach(
    IsarCollection<dynamic> col, Id id, ChargeRecord object) {
  object.id = id;
}

extension ChargeRecordQueryWhereSort
    on QueryBuilder<ChargeRecord, ChargeRecord, QWhere> {
  QueryBuilder<ChargeRecord, ChargeRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterWhere> anyStartAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startAt'),
      );
    });
  }
}

extension ChargeRecordQueryWhere
    on QueryBuilder<ChargeRecord, ChargeRecord, QWhereClause> {
  QueryBuilder<ChargeRecord, ChargeRecord, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterWhereClause> idBetween(
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterWhereClause> vinEqualTo(
      String vin) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'vin',
        value: [vin],
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterWhereClause> vinNotEqualTo(
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterWhereClause> startAtEqualTo(
      DateTime startAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'startAt',
        value: [startAt],
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterWhereClause> startAtNotEqualTo(
      DateTime startAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startAt',
              lower: [],
              upper: [startAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startAt',
              lower: [startAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startAt',
              lower: [startAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startAt',
              lower: [],
              upper: [startAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterWhereClause>
      startAtGreaterThan(
    DateTime startAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startAt',
        lower: [startAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterWhereClause> startAtLessThan(
    DateTime startAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startAt',
        lower: [],
        upper: [startAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterWhereClause> startAtBetween(
    DateTime lowerStartAt,
    DateTime upperStartAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startAt',
        lower: [lowerStartAt],
        includeLower: includeLower,
        upper: [upperStartAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ChargeRecordQueryFilter
    on QueryBuilder<ChargeRecord, ChargeRecord, QFilterCondition> {
  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      chargingModeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'chargingMode',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      chargingModeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'chargingMode',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      chargingModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chargingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      chargingModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chargingMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      chargingModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chargingMode',
        value: '',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      chargingModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chargingMode',
        value: '',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> co2IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'co2',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      co2IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'co2',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> co2EqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'co2',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      co2GreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'co2',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> co2LessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'co2',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> co2Between(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'co2',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      endLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endLevel',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      endLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endLevel',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      endLevelEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endLevel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      endLevelGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endLevel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      endLevelLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endLevel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      endLevelBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> kwIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'kw',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      kwIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'kw',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> kwEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kw',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> kwGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kw',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> kwLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kw',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> kwBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kw',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      mileageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mileage',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      mileageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mileage',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      priceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'price',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      priceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'price',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> priceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'price',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      priceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'price',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> priceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'price',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> priceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'price',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      startAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      startAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      startAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      startAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      startLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startLevel',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      startLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startLevel',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      startLevelEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startLevel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      startLevelGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startLevel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      startLevelLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startLevel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      startLevelBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      stopAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stopAt',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      stopAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stopAt',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> stopAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stopAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      stopAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stopAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      stopAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stopAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> stopAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stopAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> vinEqualTo(
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> vinLessThan(
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> vinBetween(
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> vinStartsWith(
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> vinEndsWith(
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> vinContains(
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> vinMatches(
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

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition> vinIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vin',
        value: '',
      ));
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterFilterCondition>
      vinIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vin',
        value: '',
      ));
    });
  }
}

extension ChargeRecordQueryObject
    on QueryBuilder<ChargeRecord, ChargeRecord, QFilterCondition> {}

extension ChargeRecordQueryLinks
    on QueryBuilder<ChargeRecord, ChargeRecord, QFilterCondition> {}

extension ChargeRecordQuerySortBy
    on QueryBuilder<ChargeRecord, ChargeRecord, QSortBy> {
  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByChargingMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chargingMode', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy>
      sortByChargingModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chargingMode', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByCo2() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'co2', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByCo2Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'co2', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByEndLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endLevel', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByEndLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endLevel', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByKw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kw', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByKwDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kw', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByMileage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mileage', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByMileageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mileage', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByStartAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startAt', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByStartAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startAt', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByStartLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startLevel', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy>
      sortByStartLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startLevel', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByStopAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopAt', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByStopAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopAt', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByVin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vin', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> sortByVinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vin', Sort.desc);
    });
  }
}

extension ChargeRecordQuerySortThenBy
    on QueryBuilder<ChargeRecord, ChargeRecord, QSortThenBy> {
  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByChargingMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chargingMode', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy>
      thenByChargingModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chargingMode', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByCo2() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'co2', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByCo2Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'co2', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByEndLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endLevel', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByEndLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endLevel', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByKw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kw', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByKwDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kw', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByMileage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mileage', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByMileageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mileage', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByStartAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startAt', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByStartAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startAt', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByStartLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startLevel', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy>
      thenByStartLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startLevel', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByStopAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopAt', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByStopAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopAt', Sort.desc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByVin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vin', Sort.asc);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QAfterSortBy> thenByVinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vin', Sort.desc);
    });
  }
}

extension ChargeRecordQueryWhereDistinct
    on QueryBuilder<ChargeRecord, ChargeRecord, QDistinct> {
  QueryBuilder<ChargeRecord, ChargeRecord, QDistinct> distinctByChargingMode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chargingMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QDistinct> distinctByCo2() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'co2');
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QDistinct> distinctByEndLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endLevel');
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QDistinct> distinctByKw() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kw');
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QDistinct> distinctByMileage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mileage');
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QDistinct> distinctByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'price');
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QDistinct> distinctByStartAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startAt');
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QDistinct> distinctByStartLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startLevel');
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QDistinct> distinctByStopAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stopAt');
    });
  }

  QueryBuilder<ChargeRecord, ChargeRecord, QDistinct> distinctByVin(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vin', caseSensitive: caseSensitive);
    });
  }
}

extension ChargeRecordQueryProperty
    on QueryBuilder<ChargeRecord, ChargeRecord, QQueryProperty> {
  QueryBuilder<ChargeRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ChargeRecord, String?, QQueryOperations> chargingModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chargingMode');
    });
  }

  QueryBuilder<ChargeRecord, double?, QQueryOperations> co2Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'co2');
    });
  }

  QueryBuilder<ChargeRecord, double?, QQueryOperations> endLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endLevel');
    });
  }

  QueryBuilder<ChargeRecord, double?, QQueryOperations> kwProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kw');
    });
  }

  QueryBuilder<ChargeRecord, double?, QQueryOperations> mileageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mileage');
    });
  }

  QueryBuilder<ChargeRecord, double?, QQueryOperations> priceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'price');
    });
  }

  QueryBuilder<ChargeRecord, DateTime, QQueryOperations> startAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startAt');
    });
  }

  QueryBuilder<ChargeRecord, double?, QQueryOperations> startLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startLevel');
    });
  }

  QueryBuilder<ChargeRecord, DateTime?, QQueryOperations> stopAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stopAt');
    });
  }

  QueryBuilder<ChargeRecord, String, QQueryOperations> vinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vin');
    });
  }
}
