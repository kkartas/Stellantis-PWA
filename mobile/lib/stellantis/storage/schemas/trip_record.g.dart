// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTripRecordCollection on Isar {
  IsarCollection<TripRecord> get tripRecords => this.collection();
}

const TripRecordSchema = CollectionSchema(
  name: r'TripRecord',
  id: 6367060663204451859,
  properties: {
    r'consumption': PropertySchema(
      id: 0,
      name: r'consumption',
      type: IsarType.double,
    ),
    r'consumptionFuel': PropertySchema(
      id: 1,
      name: r'consumptionFuel',
      type: IsarType.double,
    ),
    r'distance': PropertySchema(
      id: 2,
      name: r'distance',
      type: IsarType.double,
    ),
    r'endAt': PropertySchema(
      id: 3,
      name: r'endAt',
      type: IsarType.dateTime,
    ),
    r'mileage': PropertySchema(
      id: 4,
      name: r'mileage',
      type: IsarType.double,
    ),
    r'speedAverage': PropertySchema(
      id: 5,
      name: r'speedAverage',
      type: IsarType.double,
    ),
    r'startAt': PropertySchema(
      id: 6,
      name: r'startAt',
      type: IsarType.dateTime,
    ),
    r'vin': PropertySchema(
      id: 7,
      name: r'vin',
      type: IsarType.string,
    )
  },
  estimateSize: _tripRecordEstimateSize,
  serialize: _tripRecordSerialize,
  deserialize: _tripRecordDeserialize,
  deserializeProp: _tripRecordDeserializeProp,
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
  getId: _tripRecordGetId,
  getLinks: _tripRecordGetLinks,
  attach: _tripRecordAttach,
  version: '3.1.0+1',
);

int _tripRecordEstimateSize(
  TripRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.vin.length * 3;
  return bytesCount;
}

void _tripRecordSerialize(
  TripRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.consumption);
  writer.writeDouble(offsets[1], object.consumptionFuel);
  writer.writeDouble(offsets[2], object.distance);
  writer.writeDateTime(offsets[3], object.endAt);
  writer.writeDouble(offsets[4], object.mileage);
  writer.writeDouble(offsets[5], object.speedAverage);
  writer.writeDateTime(offsets[6], object.startAt);
  writer.writeString(offsets[7], object.vin);
}

TripRecord _tripRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TripRecord();
  object.consumption = reader.readDoubleOrNull(offsets[0]);
  object.consumptionFuel = reader.readDoubleOrNull(offsets[1]);
  object.distance = reader.readDouble(offsets[2]);
  object.endAt = reader.readDateTimeOrNull(offsets[3]);
  object.id = id;
  object.mileage = reader.readDoubleOrNull(offsets[4]);
  object.speedAverage = reader.readDoubleOrNull(offsets[5]);
  object.startAt = reader.readDateTime(offsets[6]);
  object.vin = reader.readString(offsets[7]);
  return object;
}

P _tripRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tripRecordGetId(TripRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tripRecordGetLinks(TripRecord object) {
  return [];
}

void _tripRecordAttach(IsarCollection<dynamic> col, Id id, TripRecord object) {
  object.id = id;
}

extension TripRecordQueryWhereSort
    on QueryBuilder<TripRecord, TripRecord, QWhere> {
  QueryBuilder<TripRecord, TripRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterWhere> anyStartAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startAt'),
      );
    });
  }
}

extension TripRecordQueryWhere
    on QueryBuilder<TripRecord, TripRecord, QWhereClause> {
  QueryBuilder<TripRecord, TripRecord, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<TripRecord, TripRecord, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterWhereClause> idBetween(
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

  QueryBuilder<TripRecord, TripRecord, QAfterWhereClause> vinEqualTo(
      String vin) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'vin',
        value: [vin],
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterWhereClause> vinNotEqualTo(
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

  QueryBuilder<TripRecord, TripRecord, QAfterWhereClause> startAtEqualTo(
      DateTime startAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'startAt',
        value: [startAt],
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterWhereClause> startAtNotEqualTo(
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

  QueryBuilder<TripRecord, TripRecord, QAfterWhereClause> startAtGreaterThan(
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

  QueryBuilder<TripRecord, TripRecord, QAfterWhereClause> startAtLessThan(
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

  QueryBuilder<TripRecord, TripRecord, QAfterWhereClause> startAtBetween(
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

extension TripRecordQueryFilter
    on QueryBuilder<TripRecord, TripRecord, QFilterCondition> {
  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      consumptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'consumption',
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      consumptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'consumption',
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      consumptionEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consumption',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      consumptionGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'consumption',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      consumptionLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'consumption',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      consumptionBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'consumption',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      consumptionFuelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'consumptionFuel',
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      consumptionFuelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'consumptionFuel',
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      consumptionFuelEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consumptionFuel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      consumptionFuelGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'consumptionFuel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      consumptionFuelLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'consumptionFuel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      consumptionFuelBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'consumptionFuel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> distanceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'distance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      distanceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'distance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> distanceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'distance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> distanceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'distance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> endAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endAt',
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> endAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endAt',
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> endAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> endAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> endAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> endAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> mileageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mileage',
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      mileageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mileage',
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> mileageEqualTo(
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> mileageLessThan(
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> mileageBetween(
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      speedAverageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'speedAverage',
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      speedAverageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'speedAverage',
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      speedAverageEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speedAverage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      speedAverageGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'speedAverage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      speedAverageLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'speedAverage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
      speedAverageBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'speedAverage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> startAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition>
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> startAtLessThan(
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> startAtBetween(
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> vinEqualTo(
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> vinGreaterThan(
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> vinLessThan(
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> vinBetween(
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> vinStartsWith(
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> vinEndsWith(
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> vinContains(
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> vinMatches(
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

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> vinIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vin',
        value: '',
      ));
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterFilterCondition> vinIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vin',
        value: '',
      ));
    });
  }
}

extension TripRecordQueryObject
    on QueryBuilder<TripRecord, TripRecord, QFilterCondition> {}

extension TripRecordQueryLinks
    on QueryBuilder<TripRecord, TripRecord, QFilterCondition> {}

extension TripRecordQuerySortBy
    on QueryBuilder<TripRecord, TripRecord, QSortBy> {
  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> sortByConsumption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumption', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> sortByConsumptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumption', Sort.desc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> sortByConsumptionFuel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumptionFuel', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy>
      sortByConsumptionFuelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumptionFuel', Sort.desc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> sortByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> sortByDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.desc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> sortByEndAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endAt', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> sortByEndAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endAt', Sort.desc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> sortByMileage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mileage', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> sortByMileageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mileage', Sort.desc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> sortBySpeedAverage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedAverage', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> sortBySpeedAverageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedAverage', Sort.desc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> sortByStartAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startAt', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> sortByStartAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startAt', Sort.desc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> sortByVin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vin', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> sortByVinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vin', Sort.desc);
    });
  }
}

extension TripRecordQuerySortThenBy
    on QueryBuilder<TripRecord, TripRecord, QSortThenBy> {
  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenByConsumption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumption', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenByConsumptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumption', Sort.desc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenByConsumptionFuel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumptionFuel', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy>
      thenByConsumptionFuelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumptionFuel', Sort.desc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenByDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.desc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenByEndAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endAt', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenByEndAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endAt', Sort.desc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenByMileage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mileage', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenByMileageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mileage', Sort.desc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenBySpeedAverage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedAverage', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenBySpeedAverageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedAverage', Sort.desc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenByStartAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startAt', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenByStartAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startAt', Sort.desc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenByVin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vin', Sort.asc);
    });
  }

  QueryBuilder<TripRecord, TripRecord, QAfterSortBy> thenByVinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vin', Sort.desc);
    });
  }
}

extension TripRecordQueryWhereDistinct
    on QueryBuilder<TripRecord, TripRecord, QDistinct> {
  QueryBuilder<TripRecord, TripRecord, QDistinct> distinctByConsumption() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consumption');
    });
  }

  QueryBuilder<TripRecord, TripRecord, QDistinct> distinctByConsumptionFuel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consumptionFuel');
    });
  }

  QueryBuilder<TripRecord, TripRecord, QDistinct> distinctByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'distance');
    });
  }

  QueryBuilder<TripRecord, TripRecord, QDistinct> distinctByEndAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endAt');
    });
  }

  QueryBuilder<TripRecord, TripRecord, QDistinct> distinctByMileage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mileage');
    });
  }

  QueryBuilder<TripRecord, TripRecord, QDistinct> distinctBySpeedAverage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speedAverage');
    });
  }

  QueryBuilder<TripRecord, TripRecord, QDistinct> distinctByStartAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startAt');
    });
  }

  QueryBuilder<TripRecord, TripRecord, QDistinct> distinctByVin(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vin', caseSensitive: caseSensitive);
    });
  }
}

extension TripRecordQueryProperty
    on QueryBuilder<TripRecord, TripRecord, QQueryProperty> {
  QueryBuilder<TripRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TripRecord, double?, QQueryOperations> consumptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consumption');
    });
  }

  QueryBuilder<TripRecord, double?, QQueryOperations>
      consumptionFuelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consumptionFuel');
    });
  }

  QueryBuilder<TripRecord, double, QQueryOperations> distanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'distance');
    });
  }

  QueryBuilder<TripRecord, DateTime?, QQueryOperations> endAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endAt');
    });
  }

  QueryBuilder<TripRecord, double?, QQueryOperations> mileageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mileage');
    });
  }

  QueryBuilder<TripRecord, double?, QQueryOperations> speedAverageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speedAverage');
    });
  }

  QueryBuilder<TripRecord, DateTime, QQueryOperations> startAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startAt');
    });
  }

  QueryBuilder<TripRecord, String, QQueryOperations> vinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vin');
    });
  }
}
