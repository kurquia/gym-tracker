// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MusclesTable extends Muscles with TableInfo<$MusclesTable, Muscle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MusclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'muscles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Muscle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Muscle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Muscle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $MusclesTable createAlias(String alias) {
    return $MusclesTable(attachedDatabase, alias);
  }
}

class Muscle extends DataClass implements Insertable<Muscle> {
  final String id;
  final String name;
  const Muscle({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  MusclesCompanion toCompanion(bool nullToAbsent) {
    return MusclesCompanion(id: Value(id), name: Value(name));
  }

  factory Muscle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Muscle(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Muscle copyWith({String? id, String? name}) =>
      Muscle(id: id ?? this.id, name: name ?? this.name);
  Muscle copyWithCompanion(MusclesCompanion data) {
    return Muscle(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Muscle(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Muscle && other.id == this.id && other.name == this.name);
}

class MusclesCompanion extends UpdateCompanion<Muscle> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const MusclesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MusclesCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Muscle> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MusclesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return MusclesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MusclesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _musclesVerifiedMeta = const VerificationMeta(
    'musclesVerified',
  );
  @override
  late final GeneratedColumn<bool> musclesVerified = GeneratedColumn<bool>(
    'muscles_verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("muscles_verified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<WeightCounting?, String>
  weightCounting = GeneratedColumn<String>(
    'weight_counting',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<WeightCounting?>($ExercisesTable.$converterweightCountingn);
  static const VerificationMeta _barKgMeta = const VerificationMeta('barKg');
  @override
  late final GeneratedColumn<double> barKg = GeneratedColumn<double>(
    'bar_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    name,
    equipment,
    category,
    isCustom,
    musclesVerified,
    weightCounting,
    barKg,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('muscles_verified')) {
      context.handle(
        _musclesVerifiedMeta,
        musclesVerified.isAcceptableOrUnknown(
          data['muscles_verified']!,
          _musclesVerifiedMeta,
        ),
      );
    }
    if (data.containsKey('bar_kg')) {
      context.handle(
        _barKgMeta,
        barKg.isAcceptableOrUnknown(data['bar_kg']!, _barKgMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      musclesVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}muscles_verified'],
      )!,
      weightCounting: $ExercisesTable.$converterweightCountingn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weight_counting'],
        ),
      ),
      barKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bar_kg'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WeightCounting, String, String>
  $converterweightCounting = const EnumNameConverter<WeightCounting>(
    WeightCounting.values,
  );
  static JsonTypeConverter2<WeightCounting?, String?, String?>
  $converterweightCountingn = JsonTypeConverter2.asNullable(
    $converterweightCounting,
  );
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final int id;

  /// free-exercise-db id; null for custom exercises.
  final String? sourceId;
  final String name;
  final String? equipment;
  final String? category;
  final bool isCustom;

  /// False while the muscles are free-exercise-db's coarse guess.
  final bool musclesVerified;

  /// Null = automatic: the first of [ExerciseWeights.countingChoices].
  final WeightCounting? weightCounting;

  /// The bar (or machine base) for [WeightCounting.perSide]; null = the
  /// equipment's default.
  final double? barKg;

  /// Free text shown every time in Record ("box + two 20 kg plates under it").
  final String? note;
  const Exercise({
    required this.id,
    this.sourceId,
    required this.name,
    this.equipment,
    this.category,
    required this.isCustom,
    required this.musclesVerified,
    this.weightCounting,
    this.barKg,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || equipment != null) {
      map['equipment'] = Variable<String>(equipment);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['is_custom'] = Variable<bool>(isCustom);
    map['muscles_verified'] = Variable<bool>(musclesVerified);
    if (!nullToAbsent || weightCounting != null) {
      map['weight_counting'] = Variable<String>(
        $ExercisesTable.$converterweightCountingn.toSql(weightCounting),
      );
    }
    if (!nullToAbsent || barKg != null) {
      map['bar_kg'] = Variable<double>(barKg);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      name: Value(name),
      equipment: equipment == null && nullToAbsent
          ? const Value.absent()
          : Value(equipment),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      isCustom: Value(isCustom),
      musclesVerified: Value(musclesVerified),
      weightCounting: weightCounting == null && nullToAbsent
          ? const Value.absent()
          : Value(weightCounting),
      barKg: barKg == null && nullToAbsent
          ? const Value.absent()
          : Value(barKg),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      name: serializer.fromJson<String>(json['name']),
      equipment: serializer.fromJson<String?>(json['equipment']),
      category: serializer.fromJson<String?>(json['category']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      musclesVerified: serializer.fromJson<bool>(json['musclesVerified']),
      weightCounting: $ExercisesTable.$converterweightCountingn.fromJson(
        serializer.fromJson<String?>(json['weightCounting']),
      ),
      barKg: serializer.fromJson<double?>(json['barKg']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceId': serializer.toJson<String?>(sourceId),
      'name': serializer.toJson<String>(name),
      'equipment': serializer.toJson<String?>(equipment),
      'category': serializer.toJson<String?>(category),
      'isCustom': serializer.toJson<bool>(isCustom),
      'musclesVerified': serializer.toJson<bool>(musclesVerified),
      'weightCounting': serializer.toJson<String?>(
        $ExercisesTable.$converterweightCountingn.toJson(weightCounting),
      ),
      'barKg': serializer.toJson<double?>(barKg),
      'note': serializer.toJson<String?>(note),
    };
  }

  Exercise copyWith({
    int? id,
    Value<String?> sourceId = const Value.absent(),
    String? name,
    Value<String?> equipment = const Value.absent(),
    Value<String?> category = const Value.absent(),
    bool? isCustom,
    bool? musclesVerified,
    Value<WeightCounting?> weightCounting = const Value.absent(),
    Value<double?> barKg = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Exercise(
    id: id ?? this.id,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    name: name ?? this.name,
    equipment: equipment.present ? equipment.value : this.equipment,
    category: category.present ? category.value : this.category,
    isCustom: isCustom ?? this.isCustom,
    musclesVerified: musclesVerified ?? this.musclesVerified,
    weightCounting: weightCounting.present
        ? weightCounting.value
        : this.weightCounting,
    barKg: barKg.present ? barKg.value : this.barKg,
    note: note.present ? note.value : this.note,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      name: data.name.present ? data.name.value : this.name,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      category: data.category.present ? data.category.value : this.category,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      musclesVerified: data.musclesVerified.present
          ? data.musclesVerified.value
          : this.musclesVerified,
      weightCounting: data.weightCounting.present
          ? data.weightCounting.value
          : this.weightCounting,
      barKg: data.barKg.present ? data.barKg.value : this.barKg,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('equipment: $equipment, ')
          ..write('category: $category, ')
          ..write('isCustom: $isCustom, ')
          ..write('musclesVerified: $musclesVerified, ')
          ..write('weightCounting: $weightCounting, ')
          ..write('barKg: $barKg, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    name,
    equipment,
    category,
    isCustom,
    musclesVerified,
    weightCounting,
    barKg,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.name == this.name &&
          other.equipment == this.equipment &&
          other.category == this.category &&
          other.isCustom == this.isCustom &&
          other.musclesVerified == this.musclesVerified &&
          other.weightCounting == this.weightCounting &&
          other.barKg == this.barKg &&
          other.note == this.note);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String?> sourceId;
  final Value<String> name;
  final Value<String?> equipment;
  final Value<String?> category;
  final Value<bool> isCustom;
  final Value<bool> musclesVerified;
  final Value<WeightCounting?> weightCounting;
  final Value<double?> barKg;
  final Value<String?> note;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.name = const Value.absent(),
    this.equipment = const Value.absent(),
    this.category = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.musclesVerified = const Value.absent(),
    this.weightCounting = const Value.absent(),
    this.barKg = const Value.absent(),
    this.note = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    required String name,
    this.equipment = const Value.absent(),
    this.category = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.musclesVerified = const Value.absent(),
    this.weightCounting = const Value.absent(),
    this.barKg = const Value.absent(),
    this.note = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<String>? sourceId,
    Expression<String>? name,
    Expression<String>? equipment,
    Expression<String>? category,
    Expression<bool>? isCustom,
    Expression<bool>? musclesVerified,
    Expression<String>? weightCounting,
    Expression<double>? barKg,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (name != null) 'name': name,
      if (equipment != null) 'equipment': equipment,
      if (category != null) 'category': category,
      if (isCustom != null) 'is_custom': isCustom,
      if (musclesVerified != null) 'muscles_verified': musclesVerified,
      if (weightCounting != null) 'weight_counting': weightCounting,
      if (barKg != null) 'bar_kg': barKg,
      if (note != null) 'note': note,
    });
  }

  ExercisesCompanion copyWith({
    Value<int>? id,
    Value<String?>? sourceId,
    Value<String>? name,
    Value<String?>? equipment,
    Value<String?>? category,
    Value<bool>? isCustom,
    Value<bool>? musclesVerified,
    Value<WeightCounting?>? weightCounting,
    Value<double?>? barKg,
    Value<String?>? note,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      name: name ?? this.name,
      equipment: equipment ?? this.equipment,
      category: category ?? this.category,
      isCustom: isCustom ?? this.isCustom,
      musclesVerified: musclesVerified ?? this.musclesVerified,
      weightCounting: weightCounting ?? this.weightCounting,
      barKg: barKg ?? this.barKg,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (musclesVerified.present) {
      map['muscles_verified'] = Variable<bool>(musclesVerified.value);
    }
    if (weightCounting.present) {
      map['weight_counting'] = Variable<String>(
        $ExercisesTable.$converterweightCountingn.toSql(weightCounting.value),
      );
    }
    if (barKg.present) {
      map['bar_kg'] = Variable<double>(barKg.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('equipment: $equipment, ')
          ..write('category: $category, ')
          ..write('isCustom: $isCustom, ')
          ..write('musclesVerified: $musclesVerified, ')
          ..write('weightCounting: $weightCounting, ')
          ..write('barKg: $barKg, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $ExerciseMusclesTable extends ExerciseMuscles
    with TableInfo<$ExerciseMusclesTable, ExerciseMuscle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseMusclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _muscleIdMeta = const VerificationMeta(
    'muscleId',
  );
  @override
  late final GeneratedColumn<String> muscleId = GeneratedColumn<String>(
    'muscle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES muscles (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MuscleRole, String> role =
      GeneratedColumn<String>(
        'role',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MuscleRole>($ExerciseMusclesTable.$converterrole);
  @override
  List<GeneratedColumn> get $columns => [exerciseId, muscleId, role];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_muscles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseMuscle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('muscle_id')) {
      context.handle(
        _muscleIdMeta,
        muscleId.isAcceptableOrUnknown(data['muscle_id']!, _muscleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_muscleIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId, muscleId};
  @override
  ExerciseMuscle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseMuscle(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      muscleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle_id'],
      )!,
      role: $ExerciseMusclesTable.$converterrole.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}role'],
        )!,
      ),
    );
  }

  @override
  $ExerciseMusclesTable createAlias(String alias) {
    return $ExerciseMusclesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MuscleRole, String, String> $converterrole =
      const EnumNameConverter<MuscleRole>(MuscleRole.values);
}

class ExerciseMuscle extends DataClass implements Insertable<ExerciseMuscle> {
  final int exerciseId;
  final String muscleId;
  final MuscleRole role;
  const ExerciseMuscle({
    required this.exerciseId,
    required this.muscleId,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<int>(exerciseId);
    map['muscle_id'] = Variable<String>(muscleId);
    {
      map['role'] = Variable<String>(
        $ExerciseMusclesTable.$converterrole.toSql(role),
      );
    }
    return map;
  }

  ExerciseMusclesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseMusclesCompanion(
      exerciseId: Value(exerciseId),
      muscleId: Value(muscleId),
      role: Value(role),
    );
  }

  factory ExerciseMuscle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseMuscle(
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      muscleId: serializer.fromJson<String>(json['muscleId']),
      role: $ExerciseMusclesTable.$converterrole.fromJson(
        serializer.fromJson<String>(json['role']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<int>(exerciseId),
      'muscleId': serializer.toJson<String>(muscleId),
      'role': serializer.toJson<String>(
        $ExerciseMusclesTable.$converterrole.toJson(role),
      ),
    };
  }

  ExerciseMuscle copyWith({
    int? exerciseId,
    String? muscleId,
    MuscleRole? role,
  }) => ExerciseMuscle(
    exerciseId: exerciseId ?? this.exerciseId,
    muscleId: muscleId ?? this.muscleId,
    role: role ?? this.role,
  );
  ExerciseMuscle copyWithCompanion(ExerciseMusclesCompanion data) {
    return ExerciseMuscle(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      muscleId: data.muscleId.present ? data.muscleId.value : this.muscleId,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMuscle(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscleId: $muscleId, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, muscleId, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseMuscle &&
          other.exerciseId == this.exerciseId &&
          other.muscleId == this.muscleId &&
          other.role == this.role);
}

class ExerciseMusclesCompanion extends UpdateCompanion<ExerciseMuscle> {
  final Value<int> exerciseId;
  final Value<String> muscleId;
  final Value<MuscleRole> role;
  final Value<int> rowid;
  const ExerciseMusclesCompanion({
    this.exerciseId = const Value.absent(),
    this.muscleId = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseMusclesCompanion.insert({
    required int exerciseId,
    required String muscleId,
    required MuscleRole role,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       muscleId = Value(muscleId),
       role = Value(role);
  static Insertable<ExerciseMuscle> custom({
    Expression<int>? exerciseId,
    Expression<String>? muscleId,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (muscleId != null) 'muscle_id': muscleId,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseMusclesCompanion copyWith({
    Value<int>? exerciseId,
    Value<String>? muscleId,
    Value<MuscleRole>? role,
    Value<int>? rowid,
  }) {
    return ExerciseMusclesCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      muscleId: muscleId ?? this.muscleId,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (muscleId.present) {
      map['muscle_id'] = Variable<String>(muscleId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(
        $ExerciseMusclesTable.$converterrole.toSql(role.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMusclesCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscleId: $muscleId, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTable extends Routines with TableInfo<$RoutinesTable, Routine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<Routine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Routine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Routine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }
}

class Routine extends DataClass implements Insertable<Routine> {
  final int id;
  final String name;
  final DateTime createdAt;
  const Routine({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Routine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Routine(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Routine copyWith({int? id, String? name, DateTime? createdAt}) => Routine(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  Routine copyWithCompanion(RoutinesCompanion data) {
    return Routine(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Routine(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Routine &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class RoutinesCompanion extends UpdateCompanion<Routine> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const RoutinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RoutinesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Routine> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RoutinesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return RoutinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RoutineExercisesTable extends RoutineExercises
    with TableInfo<$RoutineExercisesTable, RoutineExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<int> routineId = GeneratedColumn<int>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _supersetWithPreviousMeta =
      const VerificationMeta('supersetWithPrevious');
  @override
  late final GeneratedColumn<bool> supersetWithPrevious = GeneratedColumn<bool>(
    'superset_with_previous',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("superset_with_previous" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumn<int> sets = GeneratedColumn<int>(
    'sets',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _warmupMeta = const VerificationMeta('warmup');
  @override
  late final GeneratedColumn<bool> warmup = GeneratedColumn<bool>(
    'warmup',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("warmup" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    routineId,
    position,
    exerciseId,
    supersetWithPrevious,
    sets,
    warmup,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('superset_with_previous')) {
      context.handle(
        _supersetWithPreviousMeta,
        supersetWithPrevious.isAcceptableOrUnknown(
          data['superset_with_previous']!,
          _supersetWithPreviousMeta,
        ),
      );
    }
    if (data.containsKey('sets')) {
      context.handle(
        _setsMeta,
        sets.isAcceptableOrUnknown(data['sets']!, _setsMeta),
      );
    }
    if (data.containsKey('warmup')) {
      context.handle(
        _warmupMeta,
        warmup.isAcceptableOrUnknown(data['warmup']!, _warmupMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {routineId, position};
  @override
  RoutineExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineExercise(
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      supersetWithPrevious: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}superset_with_previous'],
      )!,
      sets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sets'],
      ),
      warmup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}warmup'],
      )!,
    );
  }

  @override
  $RoutineExercisesTable createAlias(String alias) {
    return $RoutineExercisesTable(attachedDatabase, alias);
  }
}

class RoutineExercise extends DataClass implements Insertable<RoutineExercise> {
  final int routineId;
  final int position;
  final int exerciseId;

  /// In a superset with the exercise before it.
  final bool supersetWithPrevious;

  /// How many working sets a workout starts with; null = as many as last time.
  final int? sets;

  /// With [sets]: start with warm-ups too (last time's, or one empty one).
  final bool warmup;
  const RoutineExercise({
    required this.routineId,
    required this.position,
    required this.exerciseId,
    required this.supersetWithPrevious,
    this.sets,
    required this.warmup,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['routine_id'] = Variable<int>(routineId);
    map['position'] = Variable<int>(position);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['superset_with_previous'] = Variable<bool>(supersetWithPrevious);
    if (!nullToAbsent || sets != null) {
      map['sets'] = Variable<int>(sets);
    }
    map['warmup'] = Variable<bool>(warmup);
    return map;
  }

  RoutineExercisesCompanion toCompanion(bool nullToAbsent) {
    return RoutineExercisesCompanion(
      routineId: Value(routineId),
      position: Value(position),
      exerciseId: Value(exerciseId),
      supersetWithPrevious: Value(supersetWithPrevious),
      sets: sets == null && nullToAbsent ? const Value.absent() : Value(sets),
      warmup: Value(warmup),
    );
  }

  factory RoutineExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineExercise(
      routineId: serializer.fromJson<int>(json['routineId']),
      position: serializer.fromJson<int>(json['position']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      supersetWithPrevious: serializer.fromJson<bool>(
        json['supersetWithPrevious'],
      ),
      sets: serializer.fromJson<int?>(json['sets']),
      warmup: serializer.fromJson<bool>(json['warmup']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'routineId': serializer.toJson<int>(routineId),
      'position': serializer.toJson<int>(position),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'supersetWithPrevious': serializer.toJson<bool>(supersetWithPrevious),
      'sets': serializer.toJson<int?>(sets),
      'warmup': serializer.toJson<bool>(warmup),
    };
  }

  RoutineExercise copyWith({
    int? routineId,
    int? position,
    int? exerciseId,
    bool? supersetWithPrevious,
    Value<int?> sets = const Value.absent(),
    bool? warmup,
  }) => RoutineExercise(
    routineId: routineId ?? this.routineId,
    position: position ?? this.position,
    exerciseId: exerciseId ?? this.exerciseId,
    supersetWithPrevious: supersetWithPrevious ?? this.supersetWithPrevious,
    sets: sets.present ? sets.value : this.sets,
    warmup: warmup ?? this.warmup,
  );
  RoutineExercise copyWithCompanion(RoutineExercisesCompanion data) {
    return RoutineExercise(
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      position: data.position.present ? data.position.value : this.position,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      supersetWithPrevious: data.supersetWithPrevious.present
          ? data.supersetWithPrevious.value
          : this.supersetWithPrevious,
      sets: data.sets.present ? data.sets.value : this.sets,
      warmup: data.warmup.present ? data.warmup.value : this.warmup,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineExercise(')
          ..write('routineId: $routineId, ')
          ..write('position: $position, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('supersetWithPrevious: $supersetWithPrevious, ')
          ..write('sets: $sets, ')
          ..write('warmup: $warmup')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    routineId,
    position,
    exerciseId,
    supersetWithPrevious,
    sets,
    warmup,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineExercise &&
          other.routineId == this.routineId &&
          other.position == this.position &&
          other.exerciseId == this.exerciseId &&
          other.supersetWithPrevious == this.supersetWithPrevious &&
          other.sets == this.sets &&
          other.warmup == this.warmup);
}

class RoutineExercisesCompanion extends UpdateCompanion<RoutineExercise> {
  final Value<int> routineId;
  final Value<int> position;
  final Value<int> exerciseId;
  final Value<bool> supersetWithPrevious;
  final Value<int?> sets;
  final Value<bool> warmup;
  final Value<int> rowid;
  const RoutineExercisesCompanion({
    this.routineId = const Value.absent(),
    this.position = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.supersetWithPrevious = const Value.absent(),
    this.sets = const Value.absent(),
    this.warmup = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineExercisesCompanion.insert({
    required int routineId,
    required int position,
    required int exerciseId,
    this.supersetWithPrevious = const Value.absent(),
    this.sets = const Value.absent(),
    this.warmup = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : routineId = Value(routineId),
       position = Value(position),
       exerciseId = Value(exerciseId);
  static Insertable<RoutineExercise> custom({
    Expression<int>? routineId,
    Expression<int>? position,
    Expression<int>? exerciseId,
    Expression<bool>? supersetWithPrevious,
    Expression<int>? sets,
    Expression<bool>? warmup,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (routineId != null) 'routine_id': routineId,
      if (position != null) 'position': position,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (supersetWithPrevious != null)
        'superset_with_previous': supersetWithPrevious,
      if (sets != null) 'sets': sets,
      if (warmup != null) 'warmup': warmup,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineExercisesCompanion copyWith({
    Value<int>? routineId,
    Value<int>? position,
    Value<int>? exerciseId,
    Value<bool>? supersetWithPrevious,
    Value<int?>? sets,
    Value<bool>? warmup,
    Value<int>? rowid,
  }) {
    return RoutineExercisesCompanion(
      routineId: routineId ?? this.routineId,
      position: position ?? this.position,
      exerciseId: exerciseId ?? this.exerciseId,
      supersetWithPrevious: supersetWithPrevious ?? this.supersetWithPrevious,
      sets: sets ?? this.sets,
      warmup: warmup ?? this.warmup,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (routineId.present) {
      map['routine_id'] = Variable<int>(routineId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (supersetWithPrevious.present) {
      map['superset_with_previous'] = Variable<bool>(
        supersetWithPrevious.value,
      );
    }
    if (sets.present) {
      map['sets'] = Variable<int>(sets.value);
    }
    if (warmup.present) {
      map['warmup'] = Variable<bool>(warmup.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineExercisesCompanion(')
          ..write('routineId: $routineId, ')
          ..write('position: $position, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('supersetWithPrevious: $supersetWithPrevious, ')
          ..write('sets: $sets, ')
          ..write('warmup: $warmup, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<int> routineId = GeneratedColumn<int>(
    'routine_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clockMillisMeta = const VerificationMeta(
    'clockMillis',
  );
  @override
  late final GeneratedColumn<int> clockMillis = GeneratedColumn<int>(
    'clock_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _clockRunningSinceMillisMeta =
      const VerificationMeta('clockRunningSinceMillis');
  @override
  late final GeneratedColumn<int> clockRunningSinceMillis =
      GeneratedColumn<int>(
        'clock_running_since_millis',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    startedAt,
    endedAt,
    notes,
    clockMillis,
    clockRunningSinceMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('clock_millis')) {
      context.handle(
        _clockMillisMeta,
        clockMillis.isAcceptableOrUnknown(
          data['clock_millis']!,
          _clockMillisMeta,
        ),
      );
    }
    if (data.containsKey('clock_running_since_millis')) {
      context.handle(
        _clockRunningSinceMillisMeta,
        clockRunningSinceMillis.isAcceptableOrUnknown(
          data['clock_running_since_millis']!,
          _clockRunningSinceMillisMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      clockMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clock_millis'],
      )!,
      clockRunningSinceMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clock_running_since_millis'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final int? routineId;
  final DateTime startedAt;

  /// Null while the workout is in progress.
  final DateTime? endedAt;
  final String? notes;

  /// Workout-clock milliseconds banked before the current run. The user
  /// starts and pauses the clock; it is not tied to [startedAt]. Milliseconds
  /// (not drift's whole-second date-times) because the clock shows hundredths.
  final int clockMillis;

  /// When the clock was last started, in Unix milliseconds; null while
  /// paused. Read it as a date via [SessionClock.clockRunningSince].
  final int? clockRunningSinceMillis;
  const Session({
    required this.id,
    this.routineId,
    required this.startedAt,
    this.endedAt,
    this.notes,
    required this.clockMillis,
    this.clockRunningSinceMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || routineId != null) {
      map['routine_id'] = Variable<int>(routineId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['clock_millis'] = Variable<int>(clockMillis);
    if (!nullToAbsent || clockRunningSinceMillis != null) {
      map['clock_running_since_millis'] = Variable<int>(
        clockRunningSinceMillis,
      );
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      routineId: routineId == null && nullToAbsent
          ? const Value.absent()
          : Value(routineId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      clockMillis: Value(clockMillis),
      clockRunningSinceMillis: clockRunningSinceMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(clockRunningSinceMillis),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      routineId: serializer.fromJson<int?>(json['routineId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      clockMillis: serializer.fromJson<int>(json['clockMillis']),
      clockRunningSinceMillis: serializer.fromJson<int?>(
        json['clockRunningSinceMillis'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routineId': serializer.toJson<int?>(routineId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'notes': serializer.toJson<String?>(notes),
      'clockMillis': serializer.toJson<int>(clockMillis),
      'clockRunningSinceMillis': serializer.toJson<int?>(
        clockRunningSinceMillis,
      ),
    };
  }

  Session copyWith({
    int? id,
    Value<int?> routineId = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? clockMillis,
    Value<int?> clockRunningSinceMillis = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    routineId: routineId.present ? routineId.value : this.routineId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    notes: notes.present ? notes.value : this.notes,
    clockMillis: clockMillis ?? this.clockMillis,
    clockRunningSinceMillis: clockRunningSinceMillis.present
        ? clockRunningSinceMillis.value
        : this.clockRunningSinceMillis,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      clockMillis: data.clockMillis.present
          ? data.clockMillis.value
          : this.clockMillis,
      clockRunningSinceMillis: data.clockRunningSinceMillis.present
          ? data.clockRunningSinceMillis.value
          : this.clockRunningSinceMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('notes: $notes, ')
          ..write('clockMillis: $clockMillis, ')
          ..write('clockRunningSinceMillis: $clockRunningSinceMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routineId,
    startedAt,
    endedAt,
    notes,
    clockMillis,
    clockRunningSinceMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.notes == this.notes &&
          other.clockMillis == this.clockMillis &&
          other.clockRunningSinceMillis == this.clockRunningSinceMillis);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<int?> routineId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String?> notes;
  final Value<int> clockMillis;
  final Value<int?> clockRunningSinceMillis;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.clockMillis = const Value.absent(),
    this.clockRunningSinceMillis = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.clockMillis = const Value.absent(),
    this.clockRunningSinceMillis = const Value.absent(),
  }) : startedAt = Value(startedAt);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<int>? routineId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? notes,
    Expression<int>? clockMillis,
    Expression<int>? clockRunningSinceMillis,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (notes != null) 'notes': notes,
      if (clockMillis != null) 'clock_millis': clockMillis,
      if (clockRunningSinceMillis != null)
        'clock_running_since_millis': clockRunningSinceMillis,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? routineId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String?>? notes,
    Value<int>? clockMillis,
    Value<int?>? clockRunningSinceMillis,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      notes: notes ?? this.notes,
      clockMillis: clockMillis ?? this.clockMillis,
      clockRunningSinceMillis:
          clockRunningSinceMillis ?? this.clockRunningSinceMillis,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<int>(routineId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (clockMillis.present) {
      map['clock_millis'] = Variable<int>(clockMillis.value);
    }
    if (clockRunningSinceMillis.present) {
      map['clock_running_since_millis'] = Variable<int>(
        clockRunningSinceMillis.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('notes: $notes, ')
          ..write('clockMillis: $clockMillis, ')
          ..write('clockRunningSinceMillis: $clockRunningSinceMillis')
          ..write(')'))
        .toString();
  }
}

class $SessionExercisesTable extends SessionExercises
    with TableInfo<$SessionExercisesTable, SessionExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supersetWithPreviousMeta =
      const VerificationMeta('supersetWithPrevious');
  @override
  late final GeneratedColumn<bool> supersetWithPrevious = GeneratedColumn<bool>(
    'superset_with_previous',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("superset_with_previous" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    exerciseId,
    position,
    note,
    supersetWithPrevious,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('superset_with_previous')) {
      context.handle(
        _supersetWithPreviousMeta,
        supersetWithPrevious.isAcceptableOrUnknown(
          data['superset_with_previous']!,
          _supersetWithPreviousMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      supersetWithPrevious: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}superset_with_previous'],
      )!,
    );
  }

  @override
  $SessionExercisesTable createAlias(String alias) {
    return $SessionExercisesTable(attachedDatabase, alias);
  }
}

class SessionExercise extends DataClass implements Insertable<SessionExercise> {
  final int id;
  final int sessionId;
  final int exerciseId;
  final int position;

  /// This workout's note on the exercise ("left knee felt off").
  final String? note;

  /// In a superset with the exercise before it: one page in Record, sets
  /// alternate, the rest comes after a full round.
  final bool supersetWithPrevious;
  const SessionExercise({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.position,
    this.note,
    required this.supersetWithPrevious,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['superset_with_previous'] = Variable<bool>(supersetWithPrevious);
    return map;
  }

  SessionExercisesCompanion toCompanion(bool nullToAbsent) {
    return SessionExercisesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      position: Value(position),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      supersetWithPrevious: Value(supersetWithPrevious),
    );
  }

  factory SessionExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionExercise(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      position: serializer.fromJson<int>(json['position']),
      note: serializer.fromJson<String?>(json['note']),
      supersetWithPrevious: serializer.fromJson<bool>(
        json['supersetWithPrevious'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'position': serializer.toJson<int>(position),
      'note': serializer.toJson<String?>(note),
      'supersetWithPrevious': serializer.toJson<bool>(supersetWithPrevious),
    };
  }

  SessionExercise copyWith({
    int? id,
    int? sessionId,
    int? exerciseId,
    int? position,
    Value<String?> note = const Value.absent(),
    bool? supersetWithPrevious,
  }) => SessionExercise(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    position: position ?? this.position,
    note: note.present ? note.value : this.note,
    supersetWithPrevious: supersetWithPrevious ?? this.supersetWithPrevious,
  );
  SessionExercise copyWithCompanion(SessionExercisesCompanion data) {
    return SessionExercise(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      position: data.position.present ? data.position.value : this.position,
      note: data.note.present ? data.note.value : this.note,
      supersetWithPrevious: data.supersetWithPrevious.present
          ? data.supersetWithPrevious.value
          : this.supersetWithPrevious,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionExercise(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('note: $note, ')
          ..write('supersetWithPrevious: $supersetWithPrevious')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    exerciseId,
    position,
    note,
    supersetWithPrevious,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionExercise &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.position == this.position &&
          other.note == this.note &&
          other.supersetWithPrevious == this.supersetWithPrevious);
}

class SessionExercisesCompanion extends UpdateCompanion<SessionExercise> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> exerciseId;
  final Value<int> position;
  final Value<String?> note;
  final Value<bool> supersetWithPrevious;
  const SessionExercisesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.note = const Value.absent(),
    this.supersetWithPrevious = const Value.absent(),
  });
  SessionExercisesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int exerciseId,
    required int position,
    this.note = const Value.absent(),
    this.supersetWithPrevious = const Value.absent(),
  }) : sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       position = Value(position);
  static Insertable<SessionExercise> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? exerciseId,
    Expression<int>? position,
    Expression<String>? note,
    Expression<bool>? supersetWithPrevious,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (position != null) 'position': position,
      if (note != null) 'note': note,
      if (supersetWithPrevious != null)
        'superset_with_previous': supersetWithPrevious,
    });
  }

  SessionExercisesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? exerciseId,
    Value<int>? position,
    Value<String?>? note,
    Value<bool>? supersetWithPrevious,
  }) {
    return SessionExercisesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      note: note ?? this.note,
      supersetWithPrevious: supersetWithPrevious ?? this.supersetWithPrevious,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (supersetWithPrevious.present) {
      map['superset_with_previous'] = Variable<bool>(
        supersetWithPrevious.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionExercisesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('note: $note, ')
          ..write('supersetWithPrevious: $supersetWithPrevious')
          ..write(')'))
        .toString();
  }
}

class $SetsTable extends Sets with TableInfo<$SetsTable, WorkoutSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionExerciseIdMeta = const VerificationMeta(
    'sessionExerciseId',
  );
  @override
  late final GeneratedColumn<int> sessionExerciseId = GeneratedColumn<int>(
    'session_exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES session_exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SetKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SetKind.normal.name),
      ).withConverter<SetKind>($SetsTable.$converterkind);
  @override
  late final GeneratedColumnWithTypeConverter<LoadType, String> loadType =
      GeneratedColumn<String>(
        'load_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(LoadType.weight.name),
      ).withConverter<LoadType>($SetsTable.$converterloadType);
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedClockMillisMeta =
      const VerificationMeta('completedClockMillis');
  @override
  late final GeneratedColumn<int> completedClockMillis = GeneratedColumn<int>(
    'completed_clock_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionExerciseId,
    position,
    kind,
    loadType,
    weightKg,
    reps,
    completedAt,
    completedClockMillis,
    restSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_exercise_id')) {
      context.handle(
        _sessionExerciseIdMeta,
        sessionExerciseId.isAcceptableOrUnknown(
          data['session_exercise_id']!,
          _sessionExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionExerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('completed_clock_millis')) {
      context.handle(
        _completedClockMillisMeta,
        completedClockMillis.isAcceptableOrUnknown(
          data['completed_clock_millis']!,
          _completedClockMillisMeta,
        ),
      );
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      kind: $SetsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      loadType: $SetsTable.$converterloadType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}load_type'],
        )!,
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      completedClockMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_clock_millis'],
      ),
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      ),
    );
  }

  @override
  $SetsTable createAlias(String alias) {
    return $SetsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SetKind, String, String> $converterkind =
      const EnumNameConverter<SetKind>(SetKind.values);
  static JsonTypeConverter2<LoadType, String, String> $converterloadType =
      const EnumNameConverter<LoadType>(LoadType.values);
}

class WorkoutSet extends DataClass implements Insertable<WorkoutSet> {
  final int id;
  final int sessionExerciseId;
  final int position;
  final SetKind kind;
  final LoadType loadType;

  /// Always kg, as a magnitude (see [loadType]); null until entered.
  final double? weightKg;
  final int? reps;

  /// Set when the user ticks the set; unticked sets are dropped on finish.
  final DateTime? completedAt;

  /// Workout-clock reading at the tick, in milliseconds: the rest after this
  /// set runs on the workout clock (pausing the clock pauses the rest).
  final int? completedClockMillis;

  /// Rest after this set; null = the default for its kind (see [WorkoutSetRest]).
  final int? restSeconds;
  const WorkoutSet({
    required this.id,
    required this.sessionExerciseId,
    required this.position,
    required this.kind,
    required this.loadType,
    this.weightKg,
    this.reps,
    this.completedAt,
    this.completedClockMillis,
    this.restSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_exercise_id'] = Variable<int>(sessionExerciseId);
    map['position'] = Variable<int>(position);
    {
      map['kind'] = Variable<String>($SetsTable.$converterkind.toSql(kind));
    }
    {
      map['load_type'] = Variable<String>(
        $SetsTable.$converterloadType.toSql(loadType),
      );
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || completedClockMillis != null) {
      map['completed_clock_millis'] = Variable<int>(completedClockMillis);
    }
    if (!nullToAbsent || restSeconds != null) {
      map['rest_seconds'] = Variable<int>(restSeconds);
    }
    return map;
  }

  SetsCompanion toCompanion(bool nullToAbsent) {
    return SetsCompanion(
      id: Value(id),
      sessionExerciseId: Value(sessionExerciseId),
      position: Value(position),
      kind: Value(kind),
      loadType: Value(loadType),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      completedClockMillis: completedClockMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(completedClockMillis),
      restSeconds: restSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(restSeconds),
    );
  }

  factory WorkoutSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSet(
      id: serializer.fromJson<int>(json['id']),
      sessionExerciseId: serializer.fromJson<int>(json['sessionExerciseId']),
      position: serializer.fromJson<int>(json['position']),
      kind: $SetsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      loadType: $SetsTable.$converterloadType.fromJson(
        serializer.fromJson<String>(json['loadType']),
      ),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      reps: serializer.fromJson<int?>(json['reps']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      completedClockMillis: serializer.fromJson<int?>(
        json['completedClockMillis'],
      ),
      restSeconds: serializer.fromJson<int?>(json['restSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionExerciseId': serializer.toJson<int>(sessionExerciseId),
      'position': serializer.toJson<int>(position),
      'kind': serializer.toJson<String>($SetsTable.$converterkind.toJson(kind)),
      'loadType': serializer.toJson<String>(
        $SetsTable.$converterloadType.toJson(loadType),
      ),
      'weightKg': serializer.toJson<double?>(weightKg),
      'reps': serializer.toJson<int?>(reps),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'completedClockMillis': serializer.toJson<int?>(completedClockMillis),
      'restSeconds': serializer.toJson<int?>(restSeconds),
    };
  }

  WorkoutSet copyWith({
    int? id,
    int? sessionExerciseId,
    int? position,
    SetKind? kind,
    LoadType? loadType,
    Value<double?> weightKg = const Value.absent(),
    Value<int?> reps = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<int?> completedClockMillis = const Value.absent(),
    Value<int?> restSeconds = const Value.absent(),
  }) => WorkoutSet(
    id: id ?? this.id,
    sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
    position: position ?? this.position,
    kind: kind ?? this.kind,
    loadType: loadType ?? this.loadType,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    reps: reps.present ? reps.value : this.reps,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    completedClockMillis: completedClockMillis.present
        ? completedClockMillis.value
        : this.completedClockMillis,
    restSeconds: restSeconds.present ? restSeconds.value : this.restSeconds,
  );
  WorkoutSet copyWithCompanion(SetsCompanion data) {
    return WorkoutSet(
      id: data.id.present ? data.id.value : this.id,
      sessionExerciseId: data.sessionExerciseId.present
          ? data.sessionExerciseId.value
          : this.sessionExerciseId,
      position: data.position.present ? data.position.value : this.position,
      kind: data.kind.present ? data.kind.value : this.kind,
      loadType: data.loadType.present ? data.loadType.value : this.loadType,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      reps: data.reps.present ? data.reps.value : this.reps,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      completedClockMillis: data.completedClockMillis.present
          ? data.completedClockMillis.value
          : this.completedClockMillis,
      restSeconds: data.restSeconds.present
          ? data.restSeconds.value
          : this.restSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSet(')
          ..write('id: $id, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('position: $position, ')
          ..write('kind: $kind, ')
          ..write('loadType: $loadType, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('completedAt: $completedAt, ')
          ..write('completedClockMillis: $completedClockMillis, ')
          ..write('restSeconds: $restSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionExerciseId,
    position,
    kind,
    loadType,
    weightKg,
    reps,
    completedAt,
    completedClockMillis,
    restSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSet &&
          other.id == this.id &&
          other.sessionExerciseId == this.sessionExerciseId &&
          other.position == this.position &&
          other.kind == this.kind &&
          other.loadType == this.loadType &&
          other.weightKg == this.weightKg &&
          other.reps == this.reps &&
          other.completedAt == this.completedAt &&
          other.completedClockMillis == this.completedClockMillis &&
          other.restSeconds == this.restSeconds);
}

class SetsCompanion extends UpdateCompanion<WorkoutSet> {
  final Value<int> id;
  final Value<int> sessionExerciseId;
  final Value<int> position;
  final Value<SetKind> kind;
  final Value<LoadType> loadType;
  final Value<double?> weightKg;
  final Value<int?> reps;
  final Value<DateTime?> completedAt;
  final Value<int?> completedClockMillis;
  final Value<int?> restSeconds;
  const SetsCompanion({
    this.id = const Value.absent(),
    this.sessionExerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.kind = const Value.absent(),
    this.loadType = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completedClockMillis = const Value.absent(),
    this.restSeconds = const Value.absent(),
  });
  SetsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionExerciseId,
    required int position,
    this.kind = const Value.absent(),
    this.loadType = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completedClockMillis = const Value.absent(),
    this.restSeconds = const Value.absent(),
  }) : sessionExerciseId = Value(sessionExerciseId),
       position = Value(position);
  static Insertable<WorkoutSet> custom({
    Expression<int>? id,
    Expression<int>? sessionExerciseId,
    Expression<int>? position,
    Expression<String>? kind,
    Expression<String>? loadType,
    Expression<double>? weightKg,
    Expression<int>? reps,
    Expression<DateTime>? completedAt,
    Expression<int>? completedClockMillis,
    Expression<int>? restSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionExerciseId != null) 'session_exercise_id': sessionExerciseId,
      if (position != null) 'position': position,
      if (kind != null) 'kind': kind,
      if (loadType != null) 'load_type': loadType,
      if (weightKg != null) 'weight_kg': weightKg,
      if (reps != null) 'reps': reps,
      if (completedAt != null) 'completed_at': completedAt,
      if (completedClockMillis != null)
        'completed_clock_millis': completedClockMillis,
      if (restSeconds != null) 'rest_seconds': restSeconds,
    });
  }

  SetsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionExerciseId,
    Value<int>? position,
    Value<SetKind>? kind,
    Value<LoadType>? loadType,
    Value<double?>? weightKg,
    Value<int?>? reps,
    Value<DateTime?>? completedAt,
    Value<int?>? completedClockMillis,
    Value<int?>? restSeconds,
  }) {
    return SetsCompanion(
      id: id ?? this.id,
      sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
      position: position ?? this.position,
      kind: kind ?? this.kind,
      loadType: loadType ?? this.loadType,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      completedAt: completedAt ?? this.completedAt,
      completedClockMillis: completedClockMillis ?? this.completedClockMillis,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionExerciseId.present) {
      map['session_exercise_id'] = Variable<int>(sessionExerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $SetsTable.$converterkind.toSql(kind.value),
      );
    }
    if (loadType.present) {
      map['load_type'] = Variable<String>(
        $SetsTable.$converterloadType.toSql(loadType.value),
      );
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (completedClockMillis.present) {
      map['completed_clock_millis'] = Variable<int>(completedClockMillis.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetsCompanion(')
          ..write('id: $id, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('position: $position, ')
          ..write('kind: $kind, ')
          ..write('loadType: $loadType, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('completedAt: $completedAt, ')
          ..write('completedClockMillis: $completedClockMillis, ')
          ..write('restSeconds: $restSeconds')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, AppSettings> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WeightUnit, String> weightUnit =
      GeneratedColumn<String>(
        'weight_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(WeightUnit.kg.name),
      ).withConverter<WeightUnit>($SettingsTableTable.$converterweightUnit);
  @override
  late final GeneratedColumnWithTypeConverter<DistanceUnit, String>
  distanceUnit = GeneratedColumn<String>(
    'distance_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(DistanceUnit.km.name),
  ).withConverter<DistanceUnit>($SettingsTableTable.$converterdistanceUnit);
  @override
  late final GeneratedColumnWithTypeConverter<LengthUnit, String> lengthUnit =
      GeneratedColumn<String>(
        'length_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(LengthUnit.cm.name),
      ).withConverter<LengthUnit>($SettingsTableTable.$converterlengthUnit);
  @override
  late final GeneratedColumnWithTypeConverter<RestStyle, String> restStyle =
      GeneratedColumn<String>(
        'rest_style',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(RestStyle.clock.name),
      ).withConverter<RestStyle>($SettingsTableTable.$converterrestStyle);
  @override
  late final GeneratedColumnWithTypeConverter<RestAlert, String> restAlert =
      GeneratedColumn<String>(
        'rest_alert',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(RestAlert.vibrationAndSound.name),
      ).withConverter<RestAlert>($SettingsTableTable.$converterrestAlert);
  @override
  late final GeneratedColumnWithTypeConverter<FirstWeekday, String>
  firstWeekday = GeneratedColumn<String>(
    'first_weekday',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(FirstWeekday.monday.name),
  ).withConverter<FirstWeekday>($SettingsTableTable.$converterfirstWeekday);
  @override
  late final GeneratedColumnWithTypeConverter<NotificationClock, String>
  notificationClock =
      GeneratedColumn<String>(
        'notification_clock',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(NotificationClock.live.name),
      ).withConverter<NotificationClock>(
        $SettingsTableTable.$converternotificationClock,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weightUnit,
    distanceUnit,
    lengthUnit,
    restStyle,
    restAlert,
    firstWeekday,
    notificationClock,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettings> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettings map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettings(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      weightUnit: $SettingsTableTable.$converterweightUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weight_unit'],
        )!,
      ),
      distanceUnit: $SettingsTableTable.$converterdistanceUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}distance_unit'],
        )!,
      ),
      lengthUnit: $SettingsTableTable.$converterlengthUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}length_unit'],
        )!,
      ),
      restStyle: $SettingsTableTable.$converterrestStyle.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rest_style'],
        )!,
      ),
      restAlert: $SettingsTableTable.$converterrestAlert.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rest_alert'],
        )!,
      ),
      firstWeekday: $SettingsTableTable.$converterfirstWeekday.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}first_weekday'],
        )!,
      ),
      notificationClock: $SettingsTableTable.$converternotificationClock
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}notification_clock'],
            )!,
          ),
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WeightUnit, String, String> $converterweightUnit =
      const EnumNameConverter<WeightUnit>(WeightUnit.values);
  static JsonTypeConverter2<DistanceUnit, String, String>
  $converterdistanceUnit = const EnumNameConverter<DistanceUnit>(
    DistanceUnit.values,
  );
  static JsonTypeConverter2<LengthUnit, String, String> $converterlengthUnit =
      const EnumNameConverter<LengthUnit>(LengthUnit.values);
  static JsonTypeConverter2<RestStyle, String, String> $converterrestStyle =
      const EnumNameConverter<RestStyle>(RestStyle.values);
  static JsonTypeConverter2<RestAlert, String, String> $converterrestAlert =
      const EnumNameConverter<RestAlert>(RestAlert.values);
  static JsonTypeConverter2<FirstWeekday, String, String>
  $converterfirstWeekday = const EnumNameConverter<FirstWeekday>(
    FirstWeekday.values,
  );
  static JsonTypeConverter2<NotificationClock, String, String>
  $converternotificationClock = const EnumNameConverter<NotificationClock>(
    NotificationClock.values,
  );
}

class AppSettings extends DataClass implements Insertable<AppSettings> {
  final int id;
  final WeightUnit weightUnit;
  final DistanceUnit distanceUnit;
  final LengthUnit lengthUnit;
  final RestStyle restStyle;
  final RestAlert restAlert;
  final FirstWeekday firstWeekday;
  final NotificationClock notificationClock;
  const AppSettings({
    required this.id,
    required this.weightUnit,
    required this.distanceUnit,
    required this.lengthUnit,
    required this.restStyle,
    required this.restAlert,
    required this.firstWeekday,
    required this.notificationClock,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['weight_unit'] = Variable<String>(
        $SettingsTableTable.$converterweightUnit.toSql(weightUnit),
      );
    }
    {
      map['distance_unit'] = Variable<String>(
        $SettingsTableTable.$converterdistanceUnit.toSql(distanceUnit),
      );
    }
    {
      map['length_unit'] = Variable<String>(
        $SettingsTableTable.$converterlengthUnit.toSql(lengthUnit),
      );
    }
    {
      map['rest_style'] = Variable<String>(
        $SettingsTableTable.$converterrestStyle.toSql(restStyle),
      );
    }
    {
      map['rest_alert'] = Variable<String>(
        $SettingsTableTable.$converterrestAlert.toSql(restAlert),
      );
    }
    {
      map['first_weekday'] = Variable<String>(
        $SettingsTableTable.$converterfirstWeekday.toSql(firstWeekday),
      );
    }
    {
      map['notification_clock'] = Variable<String>(
        $SettingsTableTable.$converternotificationClock.toSql(
          notificationClock,
        ),
      );
    }
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      id: Value(id),
      weightUnit: Value(weightUnit),
      distanceUnit: Value(distanceUnit),
      lengthUnit: Value(lengthUnit),
      restStyle: Value(restStyle),
      restAlert: Value(restAlert),
      firstWeekday: Value(firstWeekday),
      notificationClock: Value(notificationClock),
    );
  }

  factory AppSettings.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettings(
      id: serializer.fromJson<int>(json['id']),
      weightUnit: $SettingsTableTable.$converterweightUnit.fromJson(
        serializer.fromJson<String>(json['weightUnit']),
      ),
      distanceUnit: $SettingsTableTable.$converterdistanceUnit.fromJson(
        serializer.fromJson<String>(json['distanceUnit']),
      ),
      lengthUnit: $SettingsTableTable.$converterlengthUnit.fromJson(
        serializer.fromJson<String>(json['lengthUnit']),
      ),
      restStyle: $SettingsTableTable.$converterrestStyle.fromJson(
        serializer.fromJson<String>(json['restStyle']),
      ),
      restAlert: $SettingsTableTable.$converterrestAlert.fromJson(
        serializer.fromJson<String>(json['restAlert']),
      ),
      firstWeekday: $SettingsTableTable.$converterfirstWeekday.fromJson(
        serializer.fromJson<String>(json['firstWeekday']),
      ),
      notificationClock: $SettingsTableTable.$converternotificationClock
          .fromJson(serializer.fromJson<String>(json['notificationClock'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weightUnit': serializer.toJson<String>(
        $SettingsTableTable.$converterweightUnit.toJson(weightUnit),
      ),
      'distanceUnit': serializer.toJson<String>(
        $SettingsTableTable.$converterdistanceUnit.toJson(distanceUnit),
      ),
      'lengthUnit': serializer.toJson<String>(
        $SettingsTableTable.$converterlengthUnit.toJson(lengthUnit),
      ),
      'restStyle': serializer.toJson<String>(
        $SettingsTableTable.$converterrestStyle.toJson(restStyle),
      ),
      'restAlert': serializer.toJson<String>(
        $SettingsTableTable.$converterrestAlert.toJson(restAlert),
      ),
      'firstWeekday': serializer.toJson<String>(
        $SettingsTableTable.$converterfirstWeekday.toJson(firstWeekday),
      ),
      'notificationClock': serializer.toJson<String>(
        $SettingsTableTable.$converternotificationClock.toJson(
          notificationClock,
        ),
      ),
    };
  }

  AppSettings copyWith({
    int? id,
    WeightUnit? weightUnit,
    DistanceUnit? distanceUnit,
    LengthUnit? lengthUnit,
    RestStyle? restStyle,
    RestAlert? restAlert,
    FirstWeekday? firstWeekday,
    NotificationClock? notificationClock,
  }) => AppSettings(
    id: id ?? this.id,
    weightUnit: weightUnit ?? this.weightUnit,
    distanceUnit: distanceUnit ?? this.distanceUnit,
    lengthUnit: lengthUnit ?? this.lengthUnit,
    restStyle: restStyle ?? this.restStyle,
    restAlert: restAlert ?? this.restAlert,
    firstWeekday: firstWeekday ?? this.firstWeekday,
    notificationClock: notificationClock ?? this.notificationClock,
  );
  AppSettings copyWithCompanion(SettingsTableCompanion data) {
    return AppSettings(
      id: data.id.present ? data.id.value : this.id,
      weightUnit: data.weightUnit.present
          ? data.weightUnit.value
          : this.weightUnit,
      distanceUnit: data.distanceUnit.present
          ? data.distanceUnit.value
          : this.distanceUnit,
      lengthUnit: data.lengthUnit.present
          ? data.lengthUnit.value
          : this.lengthUnit,
      restStyle: data.restStyle.present ? data.restStyle.value : this.restStyle,
      restAlert: data.restAlert.present ? data.restAlert.value : this.restAlert,
      firstWeekday: data.firstWeekday.present
          ? data.firstWeekday.value
          : this.firstWeekday,
      notificationClock: data.notificationClock.present
          ? data.notificationClock.value
          : this.notificationClock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettings(')
          ..write('id: $id, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('lengthUnit: $lengthUnit, ')
          ..write('restStyle: $restStyle, ')
          ..write('restAlert: $restAlert, ')
          ..write('firstWeekday: $firstWeekday, ')
          ..write('notificationClock: $notificationClock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    weightUnit,
    distanceUnit,
    lengthUnit,
    restStyle,
    restAlert,
    firstWeekday,
    notificationClock,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettings &&
          other.id == this.id &&
          other.weightUnit == this.weightUnit &&
          other.distanceUnit == this.distanceUnit &&
          other.lengthUnit == this.lengthUnit &&
          other.restStyle == this.restStyle &&
          other.restAlert == this.restAlert &&
          other.firstWeekday == this.firstWeekday &&
          other.notificationClock == this.notificationClock);
}

class SettingsTableCompanion extends UpdateCompanion<AppSettings> {
  final Value<int> id;
  final Value<WeightUnit> weightUnit;
  final Value<DistanceUnit> distanceUnit;
  final Value<LengthUnit> lengthUnit;
  final Value<RestStyle> restStyle;
  final Value<RestAlert> restAlert;
  final Value<FirstWeekday> firstWeekday;
  final Value<NotificationClock> notificationClock;
  const SettingsTableCompanion({
    this.id = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.lengthUnit = const Value.absent(),
    this.restStyle = const Value.absent(),
    this.restAlert = const Value.absent(),
    this.firstWeekday = const Value.absent(),
    this.notificationClock = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.lengthUnit = const Value.absent(),
    this.restStyle = const Value.absent(),
    this.restAlert = const Value.absent(),
    this.firstWeekday = const Value.absent(),
    this.notificationClock = const Value.absent(),
  });
  static Insertable<AppSettings> custom({
    Expression<int>? id,
    Expression<String>? weightUnit,
    Expression<String>? distanceUnit,
    Expression<String>? lengthUnit,
    Expression<String>? restStyle,
    Expression<String>? restAlert,
    Expression<String>? firstWeekday,
    Expression<String>? notificationClock,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (distanceUnit != null) 'distance_unit': distanceUnit,
      if (lengthUnit != null) 'length_unit': lengthUnit,
      if (restStyle != null) 'rest_style': restStyle,
      if (restAlert != null) 'rest_alert': restAlert,
      if (firstWeekday != null) 'first_weekday': firstWeekday,
      if (notificationClock != null) 'notification_clock': notificationClock,
    });
  }

  SettingsTableCompanion copyWith({
    Value<int>? id,
    Value<WeightUnit>? weightUnit,
    Value<DistanceUnit>? distanceUnit,
    Value<LengthUnit>? lengthUnit,
    Value<RestStyle>? restStyle,
    Value<RestAlert>? restAlert,
    Value<FirstWeekday>? firstWeekday,
    Value<NotificationClock>? notificationClock,
  }) {
    return SettingsTableCompanion(
      id: id ?? this.id,
      weightUnit: weightUnit ?? this.weightUnit,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      lengthUnit: lengthUnit ?? this.lengthUnit,
      restStyle: restStyle ?? this.restStyle,
      restAlert: restAlert ?? this.restAlert,
      firstWeekday: firstWeekday ?? this.firstWeekday,
      notificationClock: notificationClock ?? this.notificationClock,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<String>(
        $SettingsTableTable.$converterweightUnit.toSql(weightUnit.value),
      );
    }
    if (distanceUnit.present) {
      map['distance_unit'] = Variable<String>(
        $SettingsTableTable.$converterdistanceUnit.toSql(distanceUnit.value),
      );
    }
    if (lengthUnit.present) {
      map['length_unit'] = Variable<String>(
        $SettingsTableTable.$converterlengthUnit.toSql(lengthUnit.value),
      );
    }
    if (restStyle.present) {
      map['rest_style'] = Variable<String>(
        $SettingsTableTable.$converterrestStyle.toSql(restStyle.value),
      );
    }
    if (restAlert.present) {
      map['rest_alert'] = Variable<String>(
        $SettingsTableTable.$converterrestAlert.toSql(restAlert.value),
      );
    }
    if (firstWeekday.present) {
      map['first_weekday'] = Variable<String>(
        $SettingsTableTable.$converterfirstWeekday.toSql(firstWeekday.value),
      );
    }
    if (notificationClock.present) {
      map['notification_clock'] = Variable<String>(
        $SettingsTableTable.$converternotificationClock.toSql(
          notificationClock.value,
        ),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('lengthUnit: $lengthUnit, ')
          ..write('restStyle: $restStyle, ')
          ..write('restAlert: $restAlert, ')
          ..write('firstWeekday: $firstWeekday, ')
          ..write('notificationClock: $notificationClock')
          ..write(')'))
        .toString();
  }
}

class $SetupFieldsTable extends SetupFields
    with TableInfo<$SetupFieldsTable, SetupField> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetupFieldsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseId,
    position,
    name,
    unit,
    value,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setup_fields';
  @override
  VerificationContext validateIntegrity(
    Insertable<SetupField> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SetupField map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetupField(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $SetupFieldsTable createAlias(String alias) {
    return $SetupFieldsTable(attachedDatabase, alias);
  }
}

class SetupField extends DataClass implements Insertable<SetupField> {
  final int id;
  final int exerciseId;
  final int position;
  final String name;
  final String? unit;

  /// The current value; null = not set.
  final String? value;
  const SetupField({
    required this.id,
    required this.exerciseId,
    required this.position,
    required this.name,
    this.unit,
    this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['position'] = Variable<int>(position);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  SetupFieldsCompanion toCompanion(bool nullToAbsent) {
    return SetupFieldsCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      position: Value(position),
      name: Value(name),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory SetupField.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetupField(
      id: serializer.fromJson<int>(json['id']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      position: serializer.fromJson<int>(json['position']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String?>(json['unit']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'position': serializer.toJson<int>(position),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String?>(unit),
      'value': serializer.toJson<String?>(value),
    };
  }

  SetupField copyWith({
    int? id,
    int? exerciseId,
    int? position,
    String? name,
    Value<String?> unit = const Value.absent(),
    Value<String?> value = const Value.absent(),
  }) => SetupField(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    position: position ?? this.position,
    name: name ?? this.name,
    unit: unit.present ? unit.value : this.unit,
    value: value.present ? value.value : this.value,
  );
  SetupField copyWithCompanion(SetupFieldsCompanion data) {
    return SetupField(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      position: data.position.present ? data.position.value : this.position,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetupField(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, exerciseId, position, name, unit, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetupField &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.position == this.position &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.value == this.value);
}

class SetupFieldsCompanion extends UpdateCompanion<SetupField> {
  final Value<int> id;
  final Value<int> exerciseId;
  final Value<int> position;
  final Value<String> name;
  final Value<String?> unit;
  final Value<String?> value;
  const SetupFieldsCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.value = const Value.absent(),
  });
  SetupFieldsCompanion.insert({
    this.id = const Value.absent(),
    required int exerciseId,
    required int position,
    required String name,
    this.unit = const Value.absent(),
    this.value = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       position = Value(position),
       name = Value(name);
  static Insertable<SetupField> custom({
    Expression<int>? id,
    Expression<int>? exerciseId,
    Expression<int>? position,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (position != null) 'position': position,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (value != null) 'value': value,
    });
  }

  SetupFieldsCompanion copyWith({
    Value<int>? id,
    Value<int>? exerciseId,
    Value<int>? position,
    Value<String>? name,
    Value<String?>? unit,
    Value<String?>? value,
  }) {
    return SetupFieldsCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetupFieldsCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $SetupValuesTable extends SetupValues
    with TableInfo<$SetupValuesTable, SetupValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetupValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionExerciseIdMeta = const VerificationMeta(
    'sessionExerciseId',
  );
  @override
  late final GeneratedColumn<int> sessionExerciseId = GeneratedColumn<int>(
    'session_exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES session_exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fieldIdMeta = const VerificationMeta(
    'fieldId',
  );
  @override
  late final GeneratedColumn<int> fieldId = GeneratedColumn<int>(
    'field_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES setup_fields (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sessionExerciseId, fieldId, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setup_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<SetupValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_exercise_id')) {
      context.handle(
        _sessionExerciseIdMeta,
        sessionExerciseId.isAcceptableOrUnknown(
          data['session_exercise_id']!,
          _sessionExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionExerciseIdMeta);
    }
    if (data.containsKey('field_id')) {
      context.handle(
        _fieldIdMeta,
        fieldId.isAcceptableOrUnknown(data['field_id']!, _fieldIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionExerciseId, fieldId};
  @override
  SetupValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetupValue(
      sessionExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_exercise_id'],
      )!,
      fieldId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}field_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SetupValuesTable createAlias(String alias) {
    return $SetupValuesTable(attachedDatabase, alias);
  }
}

class SetupValue extends DataClass implements Insertable<SetupValue> {
  final int sessionExerciseId;
  final int fieldId;
  final String value;
  const SetupValue({
    required this.sessionExerciseId,
    required this.fieldId,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_exercise_id'] = Variable<int>(sessionExerciseId);
    map['field_id'] = Variable<int>(fieldId);
    map['value'] = Variable<String>(value);
    return map;
  }

  SetupValuesCompanion toCompanion(bool nullToAbsent) {
    return SetupValuesCompanion(
      sessionExerciseId: Value(sessionExerciseId),
      fieldId: Value(fieldId),
      value: Value(value),
    );
  }

  factory SetupValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetupValue(
      sessionExerciseId: serializer.fromJson<int>(json['sessionExerciseId']),
      fieldId: serializer.fromJson<int>(json['fieldId']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionExerciseId': serializer.toJson<int>(sessionExerciseId),
      'fieldId': serializer.toJson<int>(fieldId),
      'value': serializer.toJson<String>(value),
    };
  }

  SetupValue copyWith({int? sessionExerciseId, int? fieldId, String? value}) =>
      SetupValue(
        sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
        fieldId: fieldId ?? this.fieldId,
        value: value ?? this.value,
      );
  SetupValue copyWithCompanion(SetupValuesCompanion data) {
    return SetupValue(
      sessionExerciseId: data.sessionExerciseId.present
          ? data.sessionExerciseId.value
          : this.sessionExerciseId,
      fieldId: data.fieldId.present ? data.fieldId.value : this.fieldId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetupValue(')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('fieldId: $fieldId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sessionExerciseId, fieldId, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetupValue &&
          other.sessionExerciseId == this.sessionExerciseId &&
          other.fieldId == this.fieldId &&
          other.value == this.value);
}

class SetupValuesCompanion extends UpdateCompanion<SetupValue> {
  final Value<int> sessionExerciseId;
  final Value<int> fieldId;
  final Value<String> value;
  final Value<int> rowid;
  const SetupValuesCompanion({
    this.sessionExerciseId = const Value.absent(),
    this.fieldId = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SetupValuesCompanion.insert({
    required int sessionExerciseId,
    required int fieldId,
    required String value,
    this.rowid = const Value.absent(),
  }) : sessionExerciseId = Value(sessionExerciseId),
       fieldId = Value(fieldId),
       value = Value(value);
  static Insertable<SetupValue> custom({
    Expression<int>? sessionExerciseId,
    Expression<int>? fieldId,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionExerciseId != null) 'session_exercise_id': sessionExerciseId,
      if (fieldId != null) 'field_id': fieldId,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SetupValuesCompanion copyWith({
    Value<int>? sessionExerciseId,
    Value<int>? fieldId,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SetupValuesCompanion(
      sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
      fieldId: fieldId ?? this.fieldId,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionExerciseId.present) {
      map['session_exercise_id'] = Variable<int>(sessionExerciseId.value);
    }
    if (fieldId.present) {
      map['field_id'] = Variable<int>(fieldId.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetupValuesCompanion(')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('fieldId: $fieldId, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MusclesTable muscles = $MusclesTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $ExerciseMusclesTable exerciseMuscles = $ExerciseMusclesTable(
    this,
  );
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $RoutineExercisesTable routineExercises = $RoutineExercisesTable(
    this,
  );
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SessionExercisesTable sessionExercises = $SessionExercisesTable(
    this,
  );
  late final $SetsTable sets = $SetsTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $SetupFieldsTable setupFields = $SetupFieldsTable(this);
  late final $SetupValuesTable setupValues = $SetupValuesTable(this);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final ExercisesDao exercisesDao = ExercisesDao(this as AppDatabase);
  late final RoutinesDao routinesDao = RoutinesDao(this as AppDatabase);
  late final WorkoutsDao workoutsDao = WorkoutsDao(this as AppDatabase);
  late final HistoryDao historyDao = HistoryDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    muscles,
    exercises,
    exerciseMuscles,
    routines,
    routineExercises,
    sessions,
    sessionExercises,
    sets,
    settingsTable,
    setupFields,
    setupValues,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_muscles', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'session_exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('setup_fields', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'session_exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('setup_values', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'setup_fields',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('setup_values', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MusclesTableCreateCompanionBuilder = MusclesCompanion Function({
  required String id,
  required String name,
  Value<int> rowid,
});
typedef $$MusclesTableUpdateCompanionBuilder = MusclesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> rowid,
});

final class $$MusclesTableReferences
    extends BaseReferences<_$AppDatabase, $MusclesTable, Muscle> {
  $$MusclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExerciseMusclesTable, List<ExerciseMuscle>>
  _exerciseMusclesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseMuscles,
    aliasName: 'muscles__id__exercise_muscles__muscle_id',
  );

  $$ExerciseMusclesTableProcessedTableManager get exerciseMusclesRefs {
    final manager = $$ExerciseMusclesTableTableManager(
      $_db,
      $_db.exerciseMuscles,
    ).filter((f) => f.muscleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseMusclesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MusclesTableFilterComposer
    extends Composer<_$AppDatabase, $MusclesTable> {
  $$MusclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseMusclesRefs(
    Expression<bool> Function($$ExerciseMusclesTableFilterComposer f) f,
  ) {
    final $$ExerciseMusclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscles,
      getReferencedColumn: (t) => t.muscleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMusclesTableFilterComposer(
            $db: $db,
            $table: $db.exerciseMuscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MusclesTableOrderingComposer
    extends Composer<_$AppDatabase, $MusclesTable> {
  $$MusclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MusclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MusclesTable> {
  $$MusclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> exerciseMusclesRefs<T extends Object>(
    Expression<T> Function($$ExerciseMusclesTableAnnotationComposer a) f,
  ) {
    final $$ExerciseMusclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscles,
      getReferencedColumn: (t) => t.muscleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMusclesTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseMuscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MusclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MusclesTable,
          Muscle,
          $$MusclesTableFilterComposer,
          $$MusclesTableOrderingComposer,
          $$MusclesTableAnnotationComposer,
          $$MusclesTableCreateCompanionBuilder,
          $$MusclesTableUpdateCompanionBuilder,
          (Muscle, $$MusclesTableReferences),
          Muscle,
          PrefetchHooks Function({bool exerciseMusclesRefs})
        > {
  $$MusclesTableTableManager(_$AppDatabase db, $MusclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MusclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MusclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MusclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => MusclesCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) => MusclesCompanion.insert(id: id, name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MusclesTable, Muscle>(table),
                  $$MusclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseMusclesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exerciseMusclesRefs) db.exerciseMuscles,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseMusclesRefs)
                    await $_getPrefetchedData<
                      Muscle,
                      $MusclesTable,
                      ExerciseMuscle
                    >(
                      currentTable: table,
                      referencedTable: $$MusclesTableReferences
                          ._exerciseMusclesRefsTable(db),
                      managerFromTypedResult: (p0) => $$MusclesTableReferences(
                        db,
                        table,
                        p0,
                      ).exerciseMusclesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.muscleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MusclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MusclesTable,
      Muscle,
      $$MusclesTableFilterComposer,
      $$MusclesTableOrderingComposer,
      $$MusclesTableAnnotationComposer,
      $$MusclesTableCreateCompanionBuilder,
      $$MusclesTableUpdateCompanionBuilder,
      (Muscle, $$MusclesTableReferences),
      Muscle,
      PrefetchHooks Function({bool exerciseMusclesRefs})
    >;
typedef $$ExercisesTableCreateCompanionBuilder = ExercisesCompanion Function({
  Value<int> id,
  Value<String?> sourceId,
  required String name,
  Value<String?> equipment,
  Value<String?> category,
  Value<bool> isCustom,
  Value<bool> musclesVerified,
  Value<WeightCounting?> weightCounting,
  Value<double?> barKg,
  Value<String?> note,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<int> id,
  Value<String?> sourceId,
  Value<String> name,
  Value<String?> equipment,
  Value<String?> category,
  Value<bool> isCustom,
  Value<bool> musclesVerified,
  Value<WeightCounting?> weightCounting,
  Value<double?> barKg,
  Value<String?> note,
});

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExerciseMusclesTable, List<ExerciseMuscle>>
  _exerciseMusclesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseMuscles,
    aliasName: 'exercises__id__exercise_muscles__exercise_id',
  );

  $$ExerciseMusclesTableProcessedTableManager get exerciseMusclesRefs {
    final manager = $$ExerciseMusclesTableTableManager(
      $_db,
      $_db.exerciseMuscles,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseMusclesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RoutineExercisesTable, List<RoutineExercise>>
  _routineExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routineExercises,
    aliasName: 'exercises__id__routine_exercises__exercise_id',
  );

  $$RoutineExercisesTableProcessedTableManager get routineExercisesRefs {
    final manager = $$RoutineExercisesTableTableManager(
      $_db,
      $_db.routineExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routineExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionExercisesTable, List<SessionExercise>>
  _sessionExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionExercises,
    aliasName: 'exercises__id__session_exercises__exercise_id',
  );

  $$SessionExercisesTableProcessedTableManager get sessionExercisesRefs {
    final manager = $$SessionExercisesTableTableManager(
      $_db,
      $_db.sessionExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sessionExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SetupFieldsTable, List<SetupField>>
  _setupFieldsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.setupFields,
    aliasName: 'exercises__id__setup_fields__exercise_id',
  );

  $$SetupFieldsTableProcessedTableManager get setupFieldsRefs {
    final manager = $$SetupFieldsTableTableManager(
      $_db,
      $_db.setupFields,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_setupFieldsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get musclesVerified => $composableBuilder(
    column: $table.musclesVerified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WeightCounting?, WeightCounting, String>
  get weightCounting => $composableBuilder(
    column: $table.weightCounting,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get barKg => $composableBuilder(
    column: $table.barKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseMusclesRefs(
    Expression<bool> Function($$ExerciseMusclesTableFilterComposer f) f,
  ) {
    final $$ExerciseMusclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscles,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMusclesTableFilterComposer(
            $db: $db,
            $table: $db.exerciseMuscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> routineExercisesRefs(
    Expression<bool> Function($$RoutineExercisesTableFilterComposer f) f,
  ) {
    final $$RoutineExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableFilterComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionExercisesRefs(
    Expression<bool> Function($$SessionExercisesTableFilterComposer f) f,
  ) {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableFilterComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> setupFieldsRefs(
    Expression<bool> Function($$SetupFieldsTableFilterComposer f) f,
  ) {
    final $$SetupFieldsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setupFields,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetupFieldsTableFilterComposer(
            $db: $db,
            $table: $db.setupFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get musclesVerified => $composableBuilder(
    column: $table.musclesVerified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightCounting => $composableBuilder(
    column: $table.weightCounting,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get barKg => $composableBuilder(
    column: $table.barKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<bool> get musclesVerified => $composableBuilder(
    column: $table.musclesVerified,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<WeightCounting?, String>
  get weightCounting => $composableBuilder(
    column: $table.weightCounting,
    builder: (column) => column,
  );

  GeneratedColumn<double> get barKg =>
      $composableBuilder(column: $table.barKg, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  Expression<T> exerciseMusclesRefs<T extends Object>(
    Expression<T> Function($$ExerciseMusclesTableAnnotationComposer a) f,
  ) {
    final $$ExerciseMusclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscles,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMusclesTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseMuscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> routineExercisesRefs<T extends Object>(
    Expression<T> Function($$RoutineExercisesTableAnnotationComposer a) f,
  ) {
    final $$RoutineExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionExercisesRefs<T extends Object>(
    Expression<T> Function($$SessionExercisesTableAnnotationComposer a) f,
  ) {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> setupFieldsRefs<T extends Object>(
    Expression<T> Function($$SetupFieldsTableAnnotationComposer a) f,
  ) {
    final $$SetupFieldsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setupFields,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetupFieldsTableAnnotationComposer(
            $db: $db,
            $table: $db.setupFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({
            bool exerciseMusclesRefs,
            bool routineExercisesRefs,
            bool sessionExercisesRefs,
            bool setupFieldsRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> equipment = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<bool> musclesVerified = const Value.absent(),
                Value<WeightCounting?> weightCounting = const Value.absent(),
                Value<double?> barKg = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                sourceId: sourceId,
                name: name,
                equipment: equipment,
                category: category,
                isCustom: isCustom,
                musclesVerified: musclesVerified,
                weightCounting: weightCounting,
                barKg: barKg,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                required String name,
                Value<String?> equipment = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<bool> musclesVerified = const Value.absent(),
                Value<WeightCounting?> weightCounting = const Value.absent(),
                Value<double?> barKg = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                sourceId: sourceId,
                name: name,
                equipment: equipment,
                category: category,
                isCustom: isCustom,
                musclesVerified: musclesVerified,
                weightCounting: weightCounting,
                barKg: barKg,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExercisesTable, Exercise>(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                exerciseMusclesRefs = false,
                routineExercisesRefs = false,
                sessionExercisesRefs = false,
                setupFieldsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseMusclesRefs) db.exerciseMuscles,
                    if (routineExercisesRefs) db.routineExercises,
                    if (sessionExercisesRefs) db.sessionExercises,
                    if (setupFieldsRefs) db.setupFields,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseMusclesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          ExerciseMuscle
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseMusclesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseMusclesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (routineExercisesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          RoutineExercise
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._routineExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).routineExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionExercisesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          SessionExercise
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._sessionExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (setupFieldsRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          SetupField
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._setupFieldsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).setupFieldsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({
        bool exerciseMusclesRefs,
        bool routineExercisesRefs,
        bool sessionExercisesRefs,
        bool setupFieldsRefs,
      })
    >;
typedef $$ExerciseMusclesTableCreateCompanionBuilder =
    ExerciseMusclesCompanion Function({
      required int exerciseId,
      required String muscleId,
      required MuscleRole role,
      Value<int> rowid,
    });
typedef $$ExerciseMusclesTableUpdateCompanionBuilder =
    ExerciseMusclesCompanion Function({
      Value<int> exerciseId,
      Value<String> muscleId,
      Value<MuscleRole> role,
      Value<int> rowid,
    });

final class $$ExerciseMusclesTableReferences
    extends
        BaseReferences<_$AppDatabase, $ExerciseMusclesTable, ExerciseMuscle> {
  $$ExerciseMusclesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('exercise_muscles__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MusclesTable _muscleIdTable(_$AppDatabase db) =>
      db.muscles.createAlias('exercise_muscles__muscle_id__muscles__id');

  $$MusclesTableProcessedTableManager get muscleId {
    final $_column = $_itemColumn<String>('muscle_id')!;

    final manager = $$MusclesTableTableManager(
      $_db,
      $_db.muscles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_muscleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseMusclesTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<MuscleRole, MuscleRole, String> get role =>
      $composableBuilder(
        column: $table.role,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MusclesTableFilterComposer get muscleId {
    final $$MusclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleId,
      referencedTable: $db.muscles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MusclesTableFilterComposer(
            $db: $db,
            $table: $db.muscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMusclesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MusclesTableOrderingComposer get muscleId {
    final $$MusclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleId,
      referencedTable: $db.muscles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MusclesTableOrderingComposer(
            $db: $db,
            $table: $db.muscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMusclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<MuscleRole, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MusclesTableAnnotationComposer get muscleId {
    final $$MusclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleId,
      referencedTable: $db.muscles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MusclesTableAnnotationComposer(
            $db: $db,
            $table: $db.muscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMusclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseMusclesTable,
          ExerciseMuscle,
          $$ExerciseMusclesTableFilterComposer,
          $$ExerciseMusclesTableOrderingComposer,
          $$ExerciseMusclesTableAnnotationComposer,
          $$ExerciseMusclesTableCreateCompanionBuilder,
          $$ExerciseMusclesTableUpdateCompanionBuilder,
          (ExerciseMuscle, $$ExerciseMusclesTableReferences),
          ExerciseMuscle,
          PrefetchHooks Function({bool exerciseId, bool muscleId})
        > {
  $$ExerciseMusclesTableTableManager(
    _$AppDatabase db,
    $ExerciseMusclesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseMusclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseMusclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseMusclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> exerciseId = const Value.absent(),
                Value<String> muscleId = const Value.absent(),
                Value<MuscleRole> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMusclesCompanion(
                exerciseId: exerciseId,
                muscleId: muscleId,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int exerciseId,
                required String muscleId,
                required MuscleRole role,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMusclesCompanion.insert(
                exerciseId: exerciseId,
                muscleId: muscleId,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciseMusclesTable, ExerciseMuscle>(table),
                  $$ExerciseMusclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false, muscleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (exerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.exerciseId,
                        referencedTable: $$ExerciseMusclesTableReferences
                            ._exerciseIdTable(db),
                        referencedColumn: $$ExerciseMusclesTableReferences
                            ._exerciseIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (muscleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.muscleId,
                        referencedTable: $$ExerciseMusclesTableReferences
                            ._muscleIdTable(db),
                        referencedColumn: $$ExerciseMusclesTableReferences
                            ._muscleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExerciseMusclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseMusclesTable,
      ExerciseMuscle,
      $$ExerciseMusclesTableFilterComposer,
      $$ExerciseMusclesTableOrderingComposer,
      $$ExerciseMusclesTableAnnotationComposer,
      $$ExerciseMusclesTableCreateCompanionBuilder,
      $$ExerciseMusclesTableUpdateCompanionBuilder,
      (ExerciseMuscle, $$ExerciseMusclesTableReferences),
      ExerciseMuscle,
      PrefetchHooks Function({bool exerciseId, bool muscleId})
    >;
typedef $$RoutinesTableCreateCompanionBuilder = RoutinesCompanion Function({
  Value<int> id,
  required String name,
  Value<DateTime> createdAt,
});
typedef $$RoutinesTableUpdateCompanionBuilder = RoutinesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<DateTime> createdAt,
});

final class $$RoutinesTableReferences
    extends BaseReferences<_$AppDatabase, $RoutinesTable, Routine> {
  $$RoutinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoutineExercisesTable, List<RoutineExercise>>
  _routineExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routineExercises,
    aliasName: 'routines__id__routine_exercises__routine_id',
  );

  $$RoutineExercisesTableProcessedTableManager get routineExercisesRefs {
    final manager = $$RoutineExercisesTableTableManager(
      $_db,
      $_db.routineExercises,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routineExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: 'routines__id__sessions__routine_id',
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutinesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routineExercisesRefs(
    Expression<bool> Function($$RoutineExercisesTableFilterComposer f) f,
  ) {
    final $$RoutineExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableFilterComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> routineExercisesRefs<T extends Object>(
    Expression<T> Function($$RoutineExercisesTableAnnotationComposer a) f,
  ) {
    final $$RoutineExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutinesTable,
          Routine,
          $$RoutinesTableFilterComposer,
          $$RoutinesTableOrderingComposer,
          $$RoutinesTableAnnotationComposer,
          $$RoutinesTableCreateCompanionBuilder,
          $$RoutinesTableUpdateCompanionBuilder,
          (Routine, $$RoutinesTableReferences),
          Routine,
          PrefetchHooks Function({bool routineExercisesRefs, bool sessionsRefs})
        > {
  $$RoutinesTableTableManager(_$AppDatabase db, $RoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) => RoutinesCompanion(id: id, name: name, createdAt: createdAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => RoutinesCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutinesTable, Routine>(table),
                  $$RoutinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({routineExercisesRefs = false, sessionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routineExercisesRefs) db.routineExercises,
                    if (sessionsRefs) db.sessions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (routineExercisesRefs)
                        await $_getPrefetchedData<
                          Routine,
                          $RoutinesTable,
                          RoutineExercise
                        >(
                          currentTable: table,
                          referencedTable: $$RoutinesTableReferences
                              ._routineExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutinesTableReferences(
                                db,
                                table,
                                p0,
                              ).routineExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.routineId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionsRefs)
                        await $_getPrefetchedData<
                          Routine,
                          $RoutinesTable,
                          Session
                        >(
                          currentTable: table,
                          referencedTable: $$RoutinesTableReferences
                              ._sessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutinesTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.routineId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutinesTable,
      Routine,
      $$RoutinesTableFilterComposer,
      $$RoutinesTableOrderingComposer,
      $$RoutinesTableAnnotationComposer,
      $$RoutinesTableCreateCompanionBuilder,
      $$RoutinesTableUpdateCompanionBuilder,
      (Routine, $$RoutinesTableReferences),
      Routine,
      PrefetchHooks Function({bool routineExercisesRefs, bool sessionsRefs})
    >;
typedef $$RoutineExercisesTableCreateCompanionBuilder =
    RoutineExercisesCompanion Function({
      required int routineId,
      required int position,
      required int exerciseId,
      Value<bool> supersetWithPrevious,
      Value<int?> sets,
      Value<bool> warmup,
      Value<int> rowid,
    });
typedef $$RoutineExercisesTableUpdateCompanionBuilder =
    RoutineExercisesCompanion Function({
      Value<int> routineId,
      Value<int> position,
      Value<int> exerciseId,
      Value<bool> supersetWithPrevious,
      Value<int?> sets,
      Value<bool> warmup,
      Value<int> rowid,
    });

final class $$RoutineExercisesTableReferences
    extends
        BaseReferences<_$AppDatabase, $RoutineExercisesTable, RoutineExercise> {
  $$RoutineExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutinesTable _routineIdTable(_$AppDatabase db) =>
      db.routines.createAlias('routine_exercises__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<int>('routine_id')!;

    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('routine_exercises__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutineExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineExercisesTable> {
  $$RoutineExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get supersetWithPrevious => $composableBuilder(
    column: $table.supersetWithPrevious,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get warmup => $composableBuilder(
    column: $table.warmup,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineExercisesTable> {
  $$RoutineExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get supersetWithPrevious => $composableBuilder(
    column: $table.supersetWithPrevious,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get warmup => $composableBuilder(
    column: $table.warmup,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineExercisesTable> {
  $$RoutineExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get supersetWithPrevious => $composableBuilder(
    column: $table.supersetWithPrevious,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumn<bool> get warmup =>
      $composableBuilder(column: $table.warmup, builder: (column) => column);

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineExercisesTable,
          RoutineExercise,
          $$RoutineExercisesTableFilterComposer,
          $$RoutineExercisesTableOrderingComposer,
          $$RoutineExercisesTableAnnotationComposer,
          $$RoutineExercisesTableCreateCompanionBuilder,
          $$RoutineExercisesTableUpdateCompanionBuilder,
          (RoutineExercise, $$RoutineExercisesTableReferences),
          RoutineExercise,
          PrefetchHooks Function({bool routineId, bool exerciseId})
        > {
  $$RoutineExercisesTableTableManager(
    _$AppDatabase db,
    $RoutineExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> routineId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<bool> supersetWithPrevious = const Value.absent(),
                Value<int?> sets = const Value.absent(),
                Value<bool> warmup = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineExercisesCompanion(
                routineId: routineId,
                position: position,
                exerciseId: exerciseId,
                supersetWithPrevious: supersetWithPrevious,
                sets: sets,
                warmup: warmup,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int routineId,
                required int position,
                required int exerciseId,
                Value<bool> supersetWithPrevious = const Value.absent(),
                Value<int?> sets = const Value.absent(),
                Value<bool> warmup = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineExercisesCompanion.insert(
                routineId: routineId,
                position: position,
                exerciseId: exerciseId,
                supersetWithPrevious: supersetWithPrevious,
                sets: sets,
                warmup: warmup,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutineExercisesTable, RoutineExercise>(table),
                  $$RoutineExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routineId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (routineId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.routineId,
                        referencedTable: $$RoutineExercisesTableReferences
                            ._routineIdTable(db),
                        referencedColumn: $$RoutineExercisesTableReferences
                            ._routineIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (exerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.exerciseId,
                        referencedTable: $$RoutineExercisesTableReferences
                            ._exerciseIdTable(db),
                        referencedColumn: $$RoutineExercisesTableReferences
                            ._exerciseIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutineExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineExercisesTable,
      RoutineExercise,
      $$RoutineExercisesTableFilterComposer,
      $$RoutineExercisesTableOrderingComposer,
      $$RoutineExercisesTableAnnotationComposer,
      $$RoutineExercisesTableCreateCompanionBuilder,
      $$RoutineExercisesTableUpdateCompanionBuilder,
      (RoutineExercise, $$RoutineExercisesTableReferences),
      RoutineExercise,
      PrefetchHooks Function({bool routineId, bool exerciseId})
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<int?> routineId,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<String?> notes,
  Value<int> clockMillis,
  Value<int?> clockRunningSinceMillis,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<int?> routineId,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<String?> notes,
  Value<int> clockMillis,
  Value<int?> clockRunningSinceMillis,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutinesTable _routineIdTable(_$AppDatabase db) =>
      db.routines.createAlias('sessions__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager? get routineId {
    final $_column = $_itemColumn<int>('routine_id');
    if ($_column == null) return null;
    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SessionExercisesTable, List<SessionExercise>>
  _sessionExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionExercises,
    aliasName: 'sessions__id__session_exercises__session_id',
  );

  $$SessionExercisesTableProcessedTableManager get sessionExercisesRefs {
    final manager = $$SessionExercisesTableTableManager(
      $_db,
      $_db.sessionExercises,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sessionExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clockMillis => $composableBuilder(
    column: $table.clockMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clockRunningSinceMillis => $composableBuilder(
    column: $table.clockRunningSinceMillis,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sessionExercisesRefs(
    Expression<bool> Function($$SessionExercisesTableFilterComposer f) f,
  ) {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableFilterComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clockMillis => $composableBuilder(
    column: $table.clockMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clockRunningSinceMillis => $composableBuilder(
    column: $table.clockRunningSinceMillis,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get clockMillis => $composableBuilder(
    column: $table.clockMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get clockRunningSinceMillis => $composableBuilder(
    column: $table.clockRunningSinceMillis,
    builder: (column) => column,
  );

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sessionExercisesRefs<T extends Object>(
    Expression<T> Function($$SessionExercisesTableAnnotationComposer a) f,
  ) {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({bool routineId, bool sessionExercisesRefs})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> routineId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> clockMillis = const Value.absent(),
                Value<int?> clockRunningSinceMillis = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                routineId: routineId,
                startedAt: startedAt,
                endedAt: endedAt,
                notes: notes,
                clockMillis: clockMillis,
                clockRunningSinceMillis: clockRunningSinceMillis,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> routineId = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> clockMillis = const Value.absent(),
                Value<int?> clockRunningSinceMillis = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                routineId: routineId,
                startedAt: startedAt,
                endedAt: endedAt,
                notes: notes,
                clockMillis: clockMillis,
                clockRunningSinceMillis: clockRunningSinceMillis,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, Session>(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({routineId = false, sessionExercisesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionExercisesRefs) db.sessionExercises,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (routineId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.routineId,
                            referencedTable: $$SessionsTableReferences
                                ._routineIdTable(db),
                            referencedColumn: $$SessionsTableReferences
                                ._routineIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionExercisesRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          SessionExercise
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._sessionExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({bool routineId, bool sessionExercisesRefs})
    >;
typedef $$SessionExercisesTableCreateCompanionBuilder =
    SessionExercisesCompanion Function({
      Value<int> id,
      required int sessionId,
      required int exerciseId,
      required int position,
      Value<String?> note,
      Value<bool> supersetWithPrevious,
    });
typedef $$SessionExercisesTableUpdateCompanionBuilder =
    SessionExercisesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> exerciseId,
      Value<int> position,
      Value<String?> note,
      Value<bool> supersetWithPrevious,
    });

final class $$SessionExercisesTableReferences
    extends
        BaseReferences<_$AppDatabase, $SessionExercisesTable, SessionExercise> {
  $$SessionExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('session_exercises__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('session_exercises__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SetsTable, List<WorkoutSet>> _setsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sets,
    aliasName: 'session_exercises__id__sets__session_exercise_id',
  );

  $$SetsTableProcessedTableManager get setsRefs {
    final manager = $$SetsTableTableManager(
      $_db,
      $_db.sets,
    ).filter((f) => f.sessionExerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_setsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SetupValuesTable, List<SetupValue>>
  _setupValuesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.setupValues,
    aliasName: 'session_exercises__id__setup_values__session_exercise_id',
  );

  $$SetupValuesTableProcessedTableManager get setupValuesRefs {
    final manager = $$SetupValuesTableTableManager(
      $_db,
      $_db.setupValues,
    ).filter((f) => f.sessionExerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_setupValuesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get supersetWithPrevious => $composableBuilder(
    column: $table.supersetWithPrevious,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> setsRefs(
    Expression<bool> Function($$SetsTableFilterComposer f) f,
  ) {
    final $$SetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sets,
      getReferencedColumn: (t) => t.sessionExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetsTableFilterComposer(
            $db: $db,
            $table: $db.sets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> setupValuesRefs(
    Expression<bool> Function($$SetupValuesTableFilterComposer f) f,
  ) {
    final $$SetupValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setupValues,
      getReferencedColumn: (t) => t.sessionExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetupValuesTableFilterComposer(
            $db: $db,
            $table: $db.setupValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get supersetWithPrevious => $composableBuilder(
    column: $table.supersetWithPrevious,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get supersetWithPrevious => $composableBuilder(
    column: $table.supersetWithPrevious,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> setsRefs<T extends Object>(
    Expression<T> Function($$SetsTableAnnotationComposer a) f,
  ) {
    final $$SetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sets,
      getReferencedColumn: (t) => t.sessionExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetsTableAnnotationComposer(
            $db: $db,
            $table: $db.sets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> setupValuesRefs<T extends Object>(
    Expression<T> Function($$SetupValuesTableAnnotationComposer a) f,
  ) {
    final $$SetupValuesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setupValues,
      getReferencedColumn: (t) => t.sessionExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetupValuesTableAnnotationComposer(
            $db: $db,
            $table: $db.setupValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionExercisesTable,
          SessionExercise,
          $$SessionExercisesTableFilterComposer,
          $$SessionExercisesTableOrderingComposer,
          $$SessionExercisesTableAnnotationComposer,
          $$SessionExercisesTableCreateCompanionBuilder,
          $$SessionExercisesTableUpdateCompanionBuilder,
          (SessionExercise, $$SessionExercisesTableReferences),
          SessionExercise,
          PrefetchHooks Function({
            bool sessionId,
            bool exerciseId,
            bool setsRefs,
            bool setupValuesRefs,
          })
        > {
  $$SessionExercisesTableTableManager(
    _$AppDatabase db,
    $SessionExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> supersetWithPrevious = const Value.absent(),
              }) => SessionExercisesCompanion(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                position: position,
                note: note,
                supersetWithPrevious: supersetWithPrevious,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int exerciseId,
                required int position,
                Value<String?> note = const Value.absent(),
                Value<bool> supersetWithPrevious = const Value.absent(),
              }) => SessionExercisesCompanion.insert(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                position: position,
                note: note,
                supersetWithPrevious: supersetWithPrevious,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionExercisesTable, SessionExercise>(table),
                  $$SessionExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sessionId = false,
                exerciseId = false,
                setsRefs = false,
                setupValuesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (setsRefs) db.sets,
                    if (setupValuesRefs) db.setupValues,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable: $$SessionExercisesTableReferences
                                ._sessionIdTable(db),
                            referencedColumn: $$SessionExercisesTableReferences
                                ._sessionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (exerciseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.exerciseId,
                            referencedTable: $$SessionExercisesTableReferences
                                ._exerciseIdTable(db),
                            referencedColumn: $$SessionExercisesTableReferences
                                ._exerciseIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (setsRefs)
                        await $_getPrefetchedData<
                          SessionExercise,
                          $SessionExercisesTable,
                          WorkoutSet
                        >(
                          currentTable: table,
                          referencedTable: $$SessionExercisesTableReferences
                              ._setsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).setsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionExerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (setupValuesRefs)
                        await $_getPrefetchedData<
                          SessionExercise,
                          $SessionExercisesTable,
                          SetupValue
                        >(
                          currentTable: table,
                          referencedTable: $$SessionExercisesTableReferences
                              ._setupValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).setupValuesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionExerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionExercisesTable,
      SessionExercise,
      $$SessionExercisesTableFilterComposer,
      $$SessionExercisesTableOrderingComposer,
      $$SessionExercisesTableAnnotationComposer,
      $$SessionExercisesTableCreateCompanionBuilder,
      $$SessionExercisesTableUpdateCompanionBuilder,
      (SessionExercise, $$SessionExercisesTableReferences),
      SessionExercise,
      PrefetchHooks Function({
        bool sessionId,
        bool exerciseId,
        bool setsRefs,
        bool setupValuesRefs,
      })
    >;
typedef $$SetsTableCreateCompanionBuilder = SetsCompanion Function({
  Value<int> id,
  required int sessionExerciseId,
  required int position,
  Value<SetKind> kind,
  Value<LoadType> loadType,
  Value<double?> weightKg,
  Value<int?> reps,
  Value<DateTime?> completedAt,
  Value<int?> completedClockMillis,
  Value<int?> restSeconds,
});
typedef $$SetsTableUpdateCompanionBuilder = SetsCompanion Function({
  Value<int> id,
  Value<int> sessionExerciseId,
  Value<int> position,
  Value<SetKind> kind,
  Value<LoadType> loadType,
  Value<double?> weightKg,
  Value<int?> reps,
  Value<DateTime?> completedAt,
  Value<int?> completedClockMillis,
  Value<int?> restSeconds,
});

final class $$SetsTableReferences
    extends BaseReferences<_$AppDatabase, $SetsTable, WorkoutSet> {
  $$SetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionExercisesTable _sessionExerciseIdTable(_$AppDatabase db) => db
      .sessionExercises
      .createAlias('sets__session_exercise_id__session_exercises__id');

  $$SessionExercisesTableProcessedTableManager get sessionExerciseId {
    final $_column = $_itemColumn<int>('session_exercise_id')!;

    final manager = $$SessionExercisesTableTableManager(
      $_db,
      $_db.sessionExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SetsTableFilterComposer extends Composer<_$AppDatabase, $SetsTable> {
  $$SetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SetKind, SetKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<LoadType, LoadType, String> get loadType =>
      $composableBuilder(
        column: $table.loadType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedClockMillis => $composableBuilder(
    column: $table.completedClockMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionExercisesTableFilterComposer get sessionExerciseId {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableFilterComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetsTableOrderingComposer extends Composer<_$AppDatabase, $SetsTable> {
  $$SetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loadType => $composableBuilder(
    column: $table.loadType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedClockMillis => $composableBuilder(
    column: $table.completedClockMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionExercisesTableOrderingComposer get sessionExerciseId {
    final $$SessionExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetsTable> {
  $$SetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SetKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LoadType, String> get loadType =>
      $composableBuilder(column: $table.loadType, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedClockMillis => $composableBuilder(
    column: $table.completedClockMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  $$SessionExercisesTableAnnotationComposer get sessionExerciseId {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SetsTable,
          WorkoutSet,
          $$SetsTableFilterComposer,
          $$SetsTableOrderingComposer,
          $$SetsTableAnnotationComposer,
          $$SetsTableCreateCompanionBuilder,
          $$SetsTableUpdateCompanionBuilder,
          (WorkoutSet, $$SetsTableReferences),
          WorkoutSet,
          PrefetchHooks Function({bool sessionExerciseId})
        > {
  $$SetsTableTableManager(_$AppDatabase db, $SetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionExerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<SetKind> kind = const Value.absent(),
                Value<LoadType> loadType = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> completedClockMillis = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
              }) => SetsCompanion(
                id: id,
                sessionExerciseId: sessionExerciseId,
                position: position,
                kind: kind,
                loadType: loadType,
                weightKg: weightKg,
                reps: reps,
                completedAt: completedAt,
                completedClockMillis: completedClockMillis,
                restSeconds: restSeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionExerciseId,
                required int position,
                Value<SetKind> kind = const Value.absent(),
                Value<LoadType> loadType = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> completedClockMillis = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
              }) => SetsCompanion.insert(
                id: id,
                sessionExerciseId: sessionExerciseId,
                position: position,
                kind: kind,
                loadType: loadType,
                weightKg: weightKg,
                reps: reps,
                completedAt: completedAt,
                completedClockMillis: completedClockMillis,
                restSeconds: restSeconds,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SetsTable, WorkoutSet>(table),
                  $$SetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionExerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionExerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionExerciseId,
                        referencedTable: $$SetsTableReferences
                            ._sessionExerciseIdTable(db),
                        referencedColumn: $$SetsTableReferences
                            ._sessionExerciseIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SetsTable,
      WorkoutSet,
      $$SetsTableFilterComposer,
      $$SetsTableOrderingComposer,
      $$SetsTableAnnotationComposer,
      $$SetsTableCreateCompanionBuilder,
      $$SetsTableUpdateCompanionBuilder,
      (WorkoutSet, $$SetsTableReferences),
      WorkoutSet,
      PrefetchHooks Function({bool sessionExerciseId})
    >;
typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<int> id,
      Value<WeightUnit> weightUnit,
      Value<DistanceUnit> distanceUnit,
      Value<LengthUnit> lengthUnit,
      Value<RestStyle> restStyle,
      Value<RestAlert> restAlert,
      Value<FirstWeekday> firstWeekday,
      Value<NotificationClock> notificationClock,
    });
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<int> id,
      Value<WeightUnit> weightUnit,
      Value<DistanceUnit> distanceUnit,
      Value<LengthUnit> lengthUnit,
      Value<RestStyle> restStyle,
      Value<RestAlert> restAlert,
      Value<FirstWeekday> firstWeekday,
      Value<NotificationClock> notificationClock,
    });

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WeightUnit, WeightUnit, String>
  get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DistanceUnit, DistanceUnit, String>
  get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<LengthUnit, LengthUnit, String>
  get lengthUnit => $composableBuilder(
    column: $table.lengthUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<RestStyle, RestStyle, String> get restStyle =>
      $composableBuilder(
        column: $table.restStyle,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<RestAlert, RestAlert, String> get restAlert =>
      $composableBuilder(
        column: $table.restAlert,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<FirstWeekday, FirstWeekday, String>
  get firstWeekday => $composableBuilder(
    column: $table.firstWeekday,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<NotificationClock, NotificationClock, String>
  get notificationClock => $composableBuilder(
    column: $table.notificationClock,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lengthUnit => $composableBuilder(
    column: $table.lengthUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restStyle => $composableBuilder(
    column: $table.restStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restAlert => $composableBuilder(
    column: $table.restAlert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstWeekday => $composableBuilder(
    column: $table.firstWeekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationClock => $composableBuilder(
    column: $table.notificationClock,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WeightUnit, String> get weightUnit =>
      $composableBuilder(
        column: $table.weightUnit,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DistanceUnit, String> get distanceUnit =>
      $composableBuilder(
        column: $table.distanceUnit,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<LengthUnit, String> get lengthUnit =>
      $composableBuilder(
        column: $table.lengthUnit,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<RestStyle, String> get restStyle =>
      $composableBuilder(column: $table.restStyle, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RestAlert, String> get restAlert =>
      $composableBuilder(column: $table.restAlert, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FirstWeekday, String> get firstWeekday =>
      $composableBuilder(
        column: $table.firstWeekday,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<NotificationClock, String>
  get notificationClock => $composableBuilder(
    column: $table.notificationClock,
    builder: (column) => column,
  );
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          AppSettings,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (
            AppSettings,
            BaseReferences<_$AppDatabase, $SettingsTableTable, AppSettings>,
          ),
          AppSettings,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<WeightUnit> weightUnit = const Value.absent(),
                Value<DistanceUnit> distanceUnit = const Value.absent(),
                Value<LengthUnit> lengthUnit = const Value.absent(),
                Value<RestStyle> restStyle = const Value.absent(),
                Value<RestAlert> restAlert = const Value.absent(),
                Value<FirstWeekday> firstWeekday = const Value.absent(),
                Value<NotificationClock> notificationClock =
                    const Value.absent(),
              }) => SettingsTableCompanion(
                id: id,
                weightUnit: weightUnit,
                distanceUnit: distanceUnit,
                lengthUnit: lengthUnit,
                restStyle: restStyle,
                restAlert: restAlert,
                firstWeekday: firstWeekday,
                notificationClock: notificationClock,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<WeightUnit> weightUnit = const Value.absent(),
                Value<DistanceUnit> distanceUnit = const Value.absent(),
                Value<LengthUnit> lengthUnit = const Value.absent(),
                Value<RestStyle> restStyle = const Value.absent(),
                Value<RestAlert> restAlert = const Value.absent(),
                Value<FirstWeekday> firstWeekday = const Value.absent(),
                Value<NotificationClock> notificationClock =
                    const Value.absent(),
              }) => SettingsTableCompanion.insert(
                id: id,
                weightUnit: weightUnit,
                distanceUnit: distanceUnit,
                lengthUnit: lengthUnit,
                restStyle: restStyle,
                restAlert: restAlert,
                firstWeekday: firstWeekday,
                notificationClock: notificationClock,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTableTable, AppSettings>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SettingsTableTable,
                    AppSettings
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      AppSettings,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (
        AppSettings,
        BaseReferences<_$AppDatabase, $SettingsTableTable, AppSettings>,
      ),
      AppSettings,
      PrefetchHooks Function()
    >;
typedef $$SetupFieldsTableCreateCompanionBuilder =
    SetupFieldsCompanion Function({
      Value<int> id,
      required int exerciseId,
      required int position,
      required String name,
      Value<String?> unit,
      Value<String?> value,
    });
typedef $$SetupFieldsTableUpdateCompanionBuilder =
    SetupFieldsCompanion Function({
      Value<int> id,
      Value<int> exerciseId,
      Value<int> position,
      Value<String> name,
      Value<String?> unit,
      Value<String?> value,
    });

final class $$SetupFieldsTableReferences
    extends BaseReferences<_$AppDatabase, $SetupFieldsTable, SetupField> {
  $$SetupFieldsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('setup_fields__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SetupValuesTable, List<SetupValue>>
  _setupValuesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.setupValues,
    aliasName: 'setup_fields__id__setup_values__field_id',
  );

  $$SetupValuesTableProcessedTableManager get setupValuesRefs {
    final manager = $$SetupValuesTableTableManager(
      $_db,
      $_db.setupValues,
    ).filter((f) => f.fieldId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_setupValuesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SetupFieldsTableFilterComposer
    extends Composer<_$AppDatabase, $SetupFieldsTable> {
  $$SetupFieldsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> setupValuesRefs(
    Expression<bool> Function($$SetupValuesTableFilterComposer f) f,
  ) {
    final $$SetupValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setupValues,
      getReferencedColumn: (t) => t.fieldId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetupValuesTableFilterComposer(
            $db: $db,
            $table: $db.setupValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SetupFieldsTableOrderingComposer
    extends Composer<_$AppDatabase, $SetupFieldsTable> {
  $$SetupFieldsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetupFieldsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetupFieldsTable> {
  $$SetupFieldsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> setupValuesRefs<T extends Object>(
    Expression<T> Function($$SetupValuesTableAnnotationComposer a) f,
  ) {
    final $$SetupValuesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setupValues,
      getReferencedColumn: (t) => t.fieldId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetupValuesTableAnnotationComposer(
            $db: $db,
            $table: $db.setupValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SetupFieldsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SetupFieldsTable,
          SetupField,
          $$SetupFieldsTableFilterComposer,
          $$SetupFieldsTableOrderingComposer,
          $$SetupFieldsTableAnnotationComposer,
          $$SetupFieldsTableCreateCompanionBuilder,
          $$SetupFieldsTableUpdateCompanionBuilder,
          (SetupField, $$SetupFieldsTableReferences),
          SetupField,
          PrefetchHooks Function({bool exerciseId, bool setupValuesRefs})
        > {
  $$SetupFieldsTableTableManager(_$AppDatabase db, $SetupFieldsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetupFieldsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetupFieldsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetupFieldsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> value = const Value.absent(),
              }) => SetupFieldsCompanion(
                id: id,
                exerciseId: exerciseId,
                position: position,
                name: name,
                unit: unit,
                value: value,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int exerciseId,
                required int position,
                required String name,
                Value<String?> unit = const Value.absent(),
                Value<String?> value = const Value.absent(),
              }) => SetupFieldsCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                position: position,
                name: name,
                unit: unit,
                value: value,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SetupFieldsTable, SetupField>(table),
                  $$SetupFieldsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({exerciseId = false, setupValuesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (setupValuesRefs) db.setupValues,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (exerciseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.exerciseId,
                            referencedTable: $$SetupFieldsTableReferences
                                ._exerciseIdTable(db),
                            referencedColumn: $$SetupFieldsTableReferences
                                ._exerciseIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (setupValuesRefs)
                        await $_getPrefetchedData<
                          SetupField,
                          $SetupFieldsTable,
                          SetupValue
                        >(
                          currentTable: table,
                          referencedTable: $$SetupFieldsTableReferences
                              ._setupValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SetupFieldsTableReferences(
                                db,
                                table,
                                p0,
                              ).setupValuesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fieldId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SetupFieldsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SetupFieldsTable,
      SetupField,
      $$SetupFieldsTableFilterComposer,
      $$SetupFieldsTableOrderingComposer,
      $$SetupFieldsTableAnnotationComposer,
      $$SetupFieldsTableCreateCompanionBuilder,
      $$SetupFieldsTableUpdateCompanionBuilder,
      (SetupField, $$SetupFieldsTableReferences),
      SetupField,
      PrefetchHooks Function({bool exerciseId, bool setupValuesRefs})
    >;
typedef $$SetupValuesTableCreateCompanionBuilder =
    SetupValuesCompanion Function({
      required int sessionExerciseId,
      required int fieldId,
      required String value,
      Value<int> rowid,
    });
typedef $$SetupValuesTableUpdateCompanionBuilder =
    SetupValuesCompanion Function({
      Value<int> sessionExerciseId,
      Value<int> fieldId,
      Value<String> value,
      Value<int> rowid,
    });

final class $$SetupValuesTableReferences
    extends BaseReferences<_$AppDatabase, $SetupValuesTable, SetupValue> {
  $$SetupValuesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionExercisesTable _sessionExerciseIdTable(_$AppDatabase db) => db
      .sessionExercises
      .createAlias('setup_values__session_exercise_id__session_exercises__id');

  $$SessionExercisesTableProcessedTableManager get sessionExerciseId {
    final $_column = $_itemColumn<int>('session_exercise_id')!;

    final manager = $$SessionExercisesTableTableManager(
      $_db,
      $_db.sessionExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SetupFieldsTable _fieldIdTable(_$AppDatabase db) =>
      db.setupFields.createAlias('setup_values__field_id__setup_fields__id');

  $$SetupFieldsTableProcessedTableManager get fieldId {
    final $_column = $_itemColumn<int>('field_id')!;

    final manager = $$SetupFieldsTableTableManager(
      $_db,
      $_db.setupFields,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fieldIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SetupValuesTableFilterComposer
    extends Composer<_$AppDatabase, $SetupValuesTable> {
  $$SetupValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionExercisesTableFilterComposer get sessionExerciseId {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableFilterComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SetupFieldsTableFilterComposer get fieldId {
    final $$SetupFieldsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fieldId,
      referencedTable: $db.setupFields,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetupFieldsTableFilterComposer(
            $db: $db,
            $table: $db.setupFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetupValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $SetupValuesTable> {
  $$SetupValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionExercisesTableOrderingComposer get sessionExerciseId {
    final $$SessionExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SetupFieldsTableOrderingComposer get fieldId {
    final $$SetupFieldsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fieldId,
      referencedTable: $db.setupFields,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetupFieldsTableOrderingComposer(
            $db: $db,
            $table: $db.setupFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetupValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetupValuesTable> {
  $$SetupValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$SessionExercisesTableAnnotationComposer get sessionExerciseId {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SetupFieldsTableAnnotationComposer get fieldId {
    final $$SetupFieldsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fieldId,
      referencedTable: $db.setupFields,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetupFieldsTableAnnotationComposer(
            $db: $db,
            $table: $db.setupFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetupValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SetupValuesTable,
          SetupValue,
          $$SetupValuesTableFilterComposer,
          $$SetupValuesTableOrderingComposer,
          $$SetupValuesTableAnnotationComposer,
          $$SetupValuesTableCreateCompanionBuilder,
          $$SetupValuesTableUpdateCompanionBuilder,
          (SetupValue, $$SetupValuesTableReferences),
          SetupValue,
          PrefetchHooks Function({bool sessionExerciseId, bool fieldId})
        > {
  $$SetupValuesTableTableManager(_$AppDatabase db, $SetupValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetupValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetupValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetupValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sessionExerciseId = const Value.absent(),
                Value<int> fieldId = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SetupValuesCompanion(
                sessionExerciseId: sessionExerciseId,
                fieldId: fieldId,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sessionExerciseId,
                required int fieldId,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SetupValuesCompanion.insert(
                sessionExerciseId: sessionExerciseId,
                fieldId: fieldId,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SetupValuesTable, SetupValue>(table),
                  $$SetupValuesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionExerciseId = false, fieldId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionExerciseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionExerciseId,
                            referencedTable: $$SetupValuesTableReferences
                                ._sessionExerciseIdTable(db),
                            referencedColumn: $$SetupValuesTableReferences
                                ._sessionExerciseIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (fieldId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.fieldId,
                            referencedTable: $$SetupValuesTableReferences
                                ._fieldIdTable(db),
                            referencedColumn: $$SetupValuesTableReferences
                                ._fieldIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$SetupValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SetupValuesTable,
      SetupValue,
      $$SetupValuesTableFilterComposer,
      $$SetupValuesTableOrderingComposer,
      $$SetupValuesTableAnnotationComposer,
      $$SetupValuesTableCreateCompanionBuilder,
      $$SetupValuesTableUpdateCompanionBuilder,
      (SetupValue, $$SetupValuesTableReferences),
      SetupValue,
      PrefetchHooks Function({bool sessionExerciseId, bool fieldId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MusclesTableTableManager get muscles =>
      $$MusclesTableTableManager(_db, _db.muscles);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$ExerciseMusclesTableTableManager get exerciseMuscles =>
      $$ExerciseMusclesTableTableManager(_db, _db.exerciseMuscles);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db, _db.routines);
  $$RoutineExercisesTableTableManager get routineExercises =>
      $$RoutineExercisesTableTableManager(_db, _db.routineExercises);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SessionExercisesTableTableManager get sessionExercises =>
      $$SessionExercisesTableTableManager(_db, _db.sessionExercises);
  $$SetsTableTableManager get sets => $$SetsTableTableManager(_db, _db.sets);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$SetupFieldsTableTableManager get setupFields =>
      $$SetupFieldsTableTableManager(_db, _db.setupFields);
  $$SetupValuesTableTableManager get setupValues =>
      $$SetupValuesTableTableManager(_db, _db.setupValues);
}
