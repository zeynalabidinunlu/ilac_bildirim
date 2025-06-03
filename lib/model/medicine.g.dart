// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMedicineCollection on Isar {
  IsarCollection<Medicine> get medicines => this.collection();
}

const MedicineSchema = CollectionSchema(
  name: r'Medicine',
  id: 284787057740778982,
  properties: {
    r'description': PropertySchema(
      id: 0,
      name: r'description',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    ),
    r'notificationText': PropertySchema(
      id: 2,
      name: r'notificationText',
      type: IsarType.string,
    ),
    r'notificationTimes': PropertySchema(
      id: 3,
      name: r'notificationTimes',
      type: IsarType.dateTimeList,
    ),
    r'usageType': PropertySchema(
      id: 4,
      name: r'usageType',
      type: IsarType.stringList,
      enumMap: _MedicineusageTypeEnumValueMap,
    )
  },
  estimateSize: _medicineEstimateSize,
  serialize: _medicineSerialize,
  deserialize: _medicineDeserialize,
  deserializeProp: _medicineDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _medicineGetId,
  getLinks: _medicineGetLinks,
  attach: _medicineAttach,
  version: '3.1.0+1',
);

int _medicineEstimateSize(
  Medicine object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notificationText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notificationTimes;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final list = object.usageType;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.name.length * 3;
        }
      }
    }
  }
  return bytesCount;
}

void _medicineSerialize(
  Medicine object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.description);
  writer.writeString(offsets[1], object.name);
  writer.writeString(offsets[2], object.notificationText);
  writer.writeDateTimeList(offsets[3], object.notificationTimes);
  writer.writeStringList(
      offsets[4], object.usageType?.map((e) => e.name).toList());
}

Medicine _medicineDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Medicine();
  object.description = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.name = reader.readStringOrNull(offsets[1]);
  object.notificationText = reader.readStringOrNull(offsets[2]);
  object.notificationTimes = reader.readDateTimeList(offsets[3]);
  object.usageType = reader
      .readStringList(offsets[4])
      ?.map((e) => _MedicineusageTypeValueEnumMap[e] ?? UsageType.SABAH)
      .toList();
  return object;
}

P _medicineDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeList(offset)) as P;
    case 4:
      return (reader
          .readStringList(offset)
          ?.map((e) => _MedicineusageTypeValueEnumMap[e] ?? UsageType.SABAH)
          .toList()) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MedicineusageTypeEnumValueMap = {
  r'SABAH': r'SABAH',
  r'OGLE': r'OGLE',
  r'AKSAM': r'AKSAM',
  r'SABAH_OGLE_AKSAM': r'SABAH_OGLE_AKSAM',
};
const _MedicineusageTypeValueEnumMap = {
  r'SABAH': UsageType.SABAH,
  r'OGLE': UsageType.OGLE,
  r'AKSAM': UsageType.AKSAM,
  r'SABAH_OGLE_AKSAM': UsageType.SABAH_OGLE_AKSAM,
};

Id _medicineGetId(Medicine object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _medicineGetLinks(Medicine object) {
  return [];
}

void _medicineAttach(IsarCollection<dynamic> col, Id id, Medicine object) {
  object.id = id;
}

extension MedicineQueryWhereSort on QueryBuilder<Medicine, Medicine, QWhere> {
  QueryBuilder<Medicine, Medicine, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MedicineQueryWhere on QueryBuilder<Medicine, Medicine, QWhereClause> {
  QueryBuilder<Medicine, Medicine, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Medicine, Medicine, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterWhereClause> idBetween(
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
}

extension MedicineQueryFilter
    on QueryBuilder<Medicine, Medicine, QFilterCondition> {
  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> descriptionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> descriptionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notificationText',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notificationText',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notificationText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notificationText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notificationText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notificationText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notificationText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notificationText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notificationText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationText',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notificationText',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTimesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notificationTimes',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTimesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notificationTimes',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTimesElementEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationTimes',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTimesElementGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notificationTimes',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTimesElementLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notificationTimes',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTimesElementBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notificationTimes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTimesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notificationTimes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTimesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notificationTimes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTimesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notificationTimes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTimesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notificationTimes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTimesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notificationTimes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      notificationTimesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notificationTimes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> usageTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'usageType',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> usageTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'usageType',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      usageTypeElementEqualTo(
    UsageType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      usageTypeElementGreaterThan(
    UsageType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      usageTypeElementLessThan(
    UsageType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      usageTypeElementBetween(
    UsageType lower,
    UsageType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usageType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      usageTypeElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'usageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      usageTypeElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'usageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      usageTypeElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      usageTypeElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usageType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      usageTypeElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usageType',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      usageTypeElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usageType',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      usageTypeLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'usageType',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> usageTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'usageType',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      usageTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'usageType',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      usageTypeLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'usageType',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      usageTypeLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'usageType',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      usageTypeLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'usageType',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension MedicineQueryObject
    on QueryBuilder<Medicine, Medicine, QFilterCondition> {}

extension MedicineQueryLinks
    on QueryBuilder<Medicine, Medicine, QFilterCondition> {}

extension MedicineQuerySortBy on QueryBuilder<Medicine, Medicine, QSortBy> {
  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByNotificationText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationText', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByNotificationTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationText', Sort.desc);
    });
  }
}

extension MedicineQuerySortThenBy
    on QueryBuilder<Medicine, Medicine, QSortThenBy> {
  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByNotificationText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationText', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByNotificationTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationText', Sort.desc);
    });
  }
}

extension MedicineQueryWhereDistinct
    on QueryBuilder<Medicine, Medicine, QDistinct> {
  QueryBuilder<Medicine, Medicine, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByNotificationText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByNotificationTimes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationTimes');
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByUsageType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usageType');
    });
  }
}

extension MedicineQueryProperty
    on QueryBuilder<Medicine, Medicine, QQueryProperty> {
  QueryBuilder<Medicine, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Medicine, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<Medicine, String?, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Medicine, String?, QQueryOperations> notificationTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationText');
    });
  }

  QueryBuilder<Medicine, List<DateTime>?, QQueryOperations>
      notificationTimesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationTimes');
    });
  }

  QueryBuilder<Medicine, List<UsageType>?, QQueryOperations>
      usageTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usageType');
    });
  }
}
