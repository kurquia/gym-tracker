import 'package:drift/drift.dart';

import '../database.dart';

part 'routines_dao.g.dart';

class RoutineSummary {
  const RoutineSummary(this.routine, this.exerciseCount);
  final Routine routine;
  final int exerciseCount;
}

/// Everything needed to undo a routine deletion.
typedef DeletedRoutine = ({
  Routine routine,
  List<int> exerciseIds,
  List<bool> superset,
  List<int?> sets,
  List<bool> warmup,
});

/// Routines: list, save, delete with undo, and when each was last done.
@DriftAccessor(tables: [Exercises, Routines, RoutineExercises, Sessions])
class RoutinesDao extends DatabaseAccessor<AppDatabase>
    with _$RoutinesDaoMixin {
  RoutinesDao(super.attachedDatabase);

  Stream<List<RoutineSummary>> watchRoutines() {
    final count = routineExercises.position.count();
    final query =
        select(routines).join([
            leftOuterJoin(
              routineExercises,
              routineExercises.routineId.equalsExp(routines.id),
            ),
          ])
          ..addColumns([count])
          ..groupBy([routines.id])
          ..orderBy([OrderingTerm.asc(routines.id)]);
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          RoutineSummary(r.readTable(routines), r.read(count)!),
      ],
    );
  }

  Future<Routine> routine(int id) =>
      (select(routines)..where((r) => r.id.equals(id))).getSingle();

  /// The routine's exercises in order, each with whether it is in a superset
  /// with the one before.
  Future<List<({Exercise exercise, bool superset, int? sets, bool warmup})>>
  routineEntries(int routineId) {
    final query =
        select(routineExercises).join([
            innerJoin(
              exercises,
              exercises.id.equalsExp(routineExercises.exerciseId),
            ),
          ])
          ..where(routineExercises.routineId.equals(routineId))
          ..orderBy([OrderingTerm.asc(routineExercises.position)]);
    return query
        .map(
          (r) => (
            exercise: r.readTable(exercises),
            superset: r.readTable(routineExercises).supersetWithPrevious,
            sets: r.readTable(routineExercises).sets,
            warmup: r.readTable(routineExercises).warmup,
          ),
        )
        .get();
  }

  /// Creates the routine (when [id] is null) or replaces its name and exercises.
  /// [superset], [sets] and [warmup] line up with [exerciseIds]: true = in a
  /// superset with the exercise before; the number of working sets (null = as
  /// last time); with a number, start with warm-ups. Returns the routine's id.
  Future<int> saveRoutine({
    int? id,
    required String name,
    required List<int> exerciseIds,
    List<bool> superset = const [],
    List<int?> sets = const [],
    List<bool> warmup = const [],
  }) => transaction(() async {
    final routineId =
        id ?? await into(routines).insert(RoutinesCompanion.insert(name: name));
    if (id != null) {
      await (update(routines)..where((r) => r.id.equals(id))).write(
        RoutinesCompanion(name: Value(name)),
      );
    }
    await _replaceRoutineExercises(
      routineId,
      exerciseIds,
      superset,
      sets,
      warmup,
    );
    return routineId;
  });

  Future<void> _replaceRoutineExercises(
    int routineId,
    List<int> exerciseIds,
    List<bool> superset,
    List<int?> sets,
    List<bool> warmup,
  ) async {
    await (delete(
      routineExercises,
    )..where((re) => re.routineId.equals(routineId))).go();
    await batch(
      (b) => b.insertAll(routineExercises, [
        for (final (i, exerciseId) in exerciseIds.indexed)
          RoutineExercisesCompanion.insert(
            routineId: routineId,
            position: i,
            exerciseId: exerciseId,
            supersetWithPrevious: Value(
              i > 0 && (superset.elementAtOrNull(i) ?? false),
            ),
            sets: Value(sets.elementAtOrNull(i)),
            warmup: Value(warmup.elementAtOrNull(i) ?? false),
          ),
      ]),
    );
  }

  Future<DeletedRoutine> deleteRoutine(int id) => transaction(() async {
    final entries = await routineEntries(id);
    final deleted = (
      routine: await routine(id),
      exerciseIds: [for (final e in entries) e.exercise.id],
      superset: [for (final e in entries) e.superset],
      sets: [for (final e in entries) e.sets],
      warmup: [for (final e in entries) e.warmup],
    );
    await (delete(routines)..where((r) => r.id.equals(id))).go();
    return deleted;
  });

  /// Undoes [deleteRoutine], keeping the original id.
  Future<void> restoreRoutine(DeletedRoutine deleted) => transaction(() async {
    await into(routines).insert(deleted.routine);
    await _replaceRoutineExercises(
      deleted.routine.id,
      deleted.exerciseIds,
      deleted.superset,
      deleted.sets,
      deleted.warmup,
    );
  });

  /// "Routine N" with the smallest N not already used.
  Future<String> nextRoutineName() async {
    final names = {for (final r in await select(routines).get()) r.name};
    var n = 1;
    while (names.contains('Routine $n')) {
      n++;
    }
    return 'Routine $n';
  }

  /// routine id → when it was last finished.
  Stream<Map<int, DateTime>> watchRoutineLastDone() =>
      (select(sessions)
            ..where((s) => s.endedAt.isNotNull() & s.routineId.isNotNull()))
          .watch()
          .map((all) {
            final last = <int, DateTime>{};
            for (final s in all) {
              final prev = last[s.routineId!];
              if (prev == null || s.startedAt.isAfter(prev)) {
                last[s.routineId!] = s.startedAt;
              }
            }
            return last;
          });
}
