import 'package:drift/drift.dart';

import '../database.dart';
import 'reread.dart';

part 'exercises_dao.g.dart';

/// An exercise plus the ids of its target muscles, for search and filtering.
class CatalogEntry {
  const CatalogEntry(this.exercise, this.targetMuscleIds);
  final Exercise exercise;
  final List<String> targetMuscleIds;
}

/// One exercise with its muscles by role and its most recent sets.
class ExerciseDetail {
  const ExerciseDetail(
    this.exercise,
    this.muscles,
    this.lastTime,
    this.setupFields,
  );
  final Exercise exercise;
  final Map<MuscleRole, List<Muscle>> muscles;
  final PreviousSets? lastTime;
  final List<SetupField> setupFields;
}

/// The exercise library, custom exercises, setup fields and notes.
@DriftAccessor(
  tables: [
    Muscles,
    Exercises,
    ExerciseMuscles,
    RoutineExercises,
    Sessions,
    SessionExercises,
    Sets,
    SetupFields,
    SetupValues,
  ],
)
class ExercisesDao extends DatabaseAccessor<AppDatabase>
    with _$ExercisesDaoMixin {
  ExercisesDao(super.attachedDatabase);

  Future<List<Muscle>> allMuscles() =>
      (select(muscles)..orderBy([(m) => OrderingTerm.asc(m.name)])).get();

  /// All exercises sorted by name, each with its target muscles.
  Future<List<CatalogEntry>> exerciseCatalog() async {
    final all =
        await (select(exercises)..orderBy([
              (e) => OrderingTerm.asc(e.name.collate(Collate.noCase)),
            ]))
            .get();
    final targets = await (select(
      exerciseMuscles,
    )..where((em) => em.role.equalsValue(MuscleRole.target))).get();
    final byExercise = <int, List<String>>{};
    for (final t in targets) {
      byExercise.putIfAbsent(t.exerciseId, () => []).add(t.muscleId);
    }
    return [for (final e in all) CatalogEntry(e, byExercise[e.id] ?? const [])];
  }

  Stream<List<CatalogEntry>> watchExerciseCatalog() =>
      rereadOn([exercises, exerciseMuscles], exerciseCatalog);

  Future<Exercise> exercise(int id) =>
      (select(exercises)..where((e) => e.id.equals(id))).getSingle();

  /// Distinct equipment names in the library, sorted.
  Future<List<String>> equipmentNames() {
    final query = selectOnly(exercises, distinct: true)
      ..addColumns([exercises.equipment])
      ..where(exercises.equipment.isNotNull())
      ..orderBy([OrderingTerm.asc(exercises.equipment)]);
    return query.map((r) => r.read(exercises.equipment)!).get();
  }

  /// Whether another exercise already has [name] (ignoring case).
  Future<bool> exerciseNameTaken(String name, {int? exceptId}) async {
    final query = select(exercises)
      ..where(
        (e) =>
            e.name.lower().equals(name.toLowerCase()) &
            (exceptId == null
                ? const Constant(true)
                : e.id.equals(exceptId).not()),
      )
      ..limit(1);
    return await query.getSingleOrNull() != null;
  }

  Future<ExerciseDetail?> exerciseDetail(int id) async {
    final exercise = await (select(
      exercises,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    if (exercise == null) return null;
    final rows =
        await (select(exerciseMuscles).join([
                innerJoin(
                  muscles,
                  muscles.id.equalsExp(exerciseMuscles.muscleId),
                ),
              ])
              ..where(exerciseMuscles.exerciseId.equals(id))
              ..orderBy([OrderingTerm.asc(muscles.name)]))
            .get();
    final byRole = <MuscleRole, List<Muscle>>{};
    for (final r in rows) {
      byRole
          .putIfAbsent(r.readTable(exerciseMuscles).role, () => [])
          .add(r.readTable(muscles));
    }
    return ExerciseDetail(
      exercise,
      byRole,
      await attachedDatabase.historyDao.previousSets(id),
      await setupFieldsOf(id),
    );
  }

  Stream<ExerciseDetail?> watchExerciseDetail(int id) => rereadOn([
    exercises,
    exerciseMuscles,
    sessions,
    sets,
    setupFields,
  ], () => exerciseDetail(id));

  Future<List<SetupField>> setupFieldsOf(int exerciseId) =>
      (select(setupFields)
            ..where((f) => f.exerciseId.equals(exerciseId))
            ..orderBy([(f) => OrderingTerm.asc(f.position)]))
          .get();

  Future<void> addSetupField(
    int exerciseId,
    String name, {
    String? unit,
    String? value,
  }) => transaction(() async {
    final position = (await setupFieldsOf(exerciseId)).length;
    await into(setupFields).insert(
      SetupFieldsCompanion.insert(
        exerciseId: exerciseId,
        position: position,
        name: name,
        unit: Value(unit),
        value: Value(value == null ? null : _blankToNull(value)),
      ),
    );
  });

  /// Sets a setup field's current value; blank clears it.
  Future<void> setSetupFieldValue(int fieldId, String value) =>
      (update(setupFields)..where((f) => f.id.equals(fieldId))).write(
        SetupFieldsCompanion(value: Value(_blankToNull(value))),
      );

  /// Removes the field and its values in every workout.
  Future<void> removeSetupField(int fieldId) =>
      (delete(setupFields)..where((f) => f.id.equals(fieldId))).go();

  /// Every setup field of [entry]'s exercise, with its value as kept by
  /// that (finished) workout.
  Future<List<SetupEntry>> setupOf(SessionExercise entry) async {
    final values = {
      for (final v in await (select(
        setupValues,
      )..where((v) => v.sessionExerciseId.equals(entry.id))).get())
        v.fieldId: v.value,
    };
    return [
      for (final f in await setupFieldsOf(entry.exerciseId))
        (field: f, value: values[f.id]),
    ];
  }

  static String? _blankToNull(String text) =>
      text.trim().isEmpty ? null : text.trim();

  /// The exercise's permanent note; blank clears it.
  Future<void> setExerciseNote(int exerciseId, String note) =>
      (update(exercises)..where((e) => e.id.equals(exerciseId))).write(
        ExercisesCompanion(note: Value(_blankToNull(note))),
      );

  /// One workout's note on an exercise; blank clears it.
  Future<void> setEntryNote(int sessionExerciseId, String note) =>
      (update(sessionExercises)..where((e) => e.id.equals(sessionExerciseId)))
          .write(SessionExercisesCompanion(note: Value(_blankToNull(note))));

  /// Keeps the current setup values with a workout being finished.
  Future<void> keepSetup(List<SessionExercise> entries) async {
    for (final entry in entries) {
      for (final f in await setupFieldsOf(entry.exerciseId)) {
        if (f.value case final value?) {
          await into(setupValues).insertOnConflictUpdate(
            SetupValuesCompanion.insert(
              sessionExerciseId: entry.id,
              fieldId: f.id,
              value: value,
            ),
          );
        }
      }
    }
  }

  /// Sets how [exerciseId]'s weight is typed, and its bar for per side.
  Future<void> setWeightCounting(
    int exerciseId,
    WeightCounting counting, {
    double? barKg,
  }) => (update(exercises)..where((e) => e.id.equals(exerciseId))).write(
    ExercisesCompanion(weightCounting: Value(counting), barKg: Value(barKg)),
  );

  /// Creates a custom exercise ([id] null) or replaces a custom exercise's
  /// name, equipment and muscles. Returns its id.
  Future<int> saveCustomExercise({
    int? id,
    required String name,
    String? equipment,
    required List<String> targetMuscleIds,
    List<String> synergistMuscleIds = const [],
  }) => transaction(() async {
    final row = ExercisesCompanion(
      name: Value(name),
      equipment: Value(equipment),
    );
    final exerciseId =
        id ??
        await into(exercises).insert(
          row.copyWith(
            isCustom: const Value(true),
            category: const Value('strength'),
          ),
        );
    if (id != null) {
      await _requireCustom(id);
      await (update(exercises)..where((e) => e.id.equals(id))).write(row);
      await (delete(
        exerciseMuscles,
      )..where((em) => em.exerciseId.equals(id))).go();
    }
    await batch(
      (b) => b.insertAll(exerciseMuscles, [
        for (final m in targetMuscleIds)
          ExerciseMusclesCompanion.insert(
            exerciseId: exerciseId,
            muscleId: m,
            role: MuscleRole.target,
          ),
        for (final m in synergistMuscleIds)
          if (!targetMuscleIds.contains(m))
            ExerciseMusclesCompanion.insert(
              exerciseId: exerciseId,
              muscleId: m,
              role: MuscleRole.synergist,
            ),
      ]),
    );
    return exerciseId;
  });

  /// Deletes a custom exercise unless a routine or workout uses it.
  /// Returns false when it is in use.
  Future<bool> deleteCustomExercise(int id) => transaction(() async {
    await _requireCustom(id);
    final inRoutine =
        await (select(routineExercises)
              ..where((re) => re.exerciseId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    final inWorkout =
        await (select(sessionExercises)
              ..where((se) => se.exerciseId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (inRoutine != null || inWorkout != null) return false;
    await (delete(exercises)..where((e) => e.id.equals(id))).go();
    return true;
  });

  /// Library exercises are never edited or deleted through the custom calls.
  Future<void> _requireCustom(int id) async {
    if (!(await exercise(id)).isCustom) {
      throw ArgumentError.value(id, 'id', 'not a custom exercise');
    }
  }
}
