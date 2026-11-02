import 'package:drift/drift.dart';

import '../database.dart';
import 'reread.dart';

part 'history_dao.g.dart';

/// A finished workout as the Statistics calendar lists it.
class WorkoutSummary {
  const WorkoutSummary(
    this.session,
    this.title,
    this.exerciseNames,
    this.exerciseSets,
    this.muscles,
  );
  final Session session;
  final String title;

  /// In workout order.
  final List<String> exerciseNames;

  /// Sets per exercise, in the order of [exerciseNames].
  final List<int> exerciseSets;

  /// All sets, warm-ups included.
  int get setCount => exerciseSets.fold(0, (a, b) => a + b);

  /// Muscle ids by role over all its exercises: a muscle is under every
  /// role some exercise gives it (BodyHighlight.fromRoles picks the
  /// strongest, as for one exercise).
  final Map<MuscleRole, Set<String>> muscles;
}

/// A finished workout with every exercise and its sets.
class WorkoutLog {
  const WorkoutLog(this.session, this.title, this.exercises);
  final Session session;
  final String title;
  final List<
    ({
      SessionExercise entry,
      Exercise exercise,
      List<WorkoutSet> sets,
      List<SetupEntry> setup,
    })
  >
  exercises;
}

/// Finished workouts: last time's sets, the workout list and logs.
@DriftAccessor(
  tables: [
    Exercises,
    ExerciseMuscles,
    Routines,
    Sessions,
    SessionExercises,
    Sets,
    SetupFields,
    SetupValues,
  ],
)
class HistoryDao extends DatabaseAccessor<AppDatabase> with _$HistoryDaoMixin {
  HistoryDao(super.attachedDatabase);

  /// Sessions with their routine; read the title with [titleOf].
  JoinedSelectStatement<HasResultSet, dynamic> sessionsWithRoutine() => select(
    sessions,
  ).join([leftOuterJoin(routines, routines.id.equalsExp(sessions.routineId))]);

  /// The title of a [sessionsWithRoutine] row.
  String titleOf(TypedResult row) =>
      row.readTableOrNull(routines)?.name ?? 'Workout';

  /// [sessionId]'s exercises in order.
  Future<List<({SessionExercise entry, Exercise exercise})>> sessionEntries(
    int sessionId,
  ) {
    final query =
        select(sessionExercises).join([
            innerJoin(
              exercises,
              exercises.id.equalsExp(sessionExercises.exerciseId),
            ),
          ])
          ..where(sessionExercises.sessionId.equals(sessionId))
          ..orderBy([OrderingTerm.asc(sessionExercises.position)]);
    return query
        .map(
          (r) => (
            entry: r.readTable(sessionExercises),
            exercise: r.readTable(exercises),
          ),
        )
        .get();
  }

  /// [exerciseId]'s sets from its most recent finished session.
  Future<PreviousSets?> previousSets(int exerciseId) async {
    final last =
        await (select(sessions).join([
                innerJoin(
                  sessionExercises,
                  sessionExercises.sessionId.equalsExp(sessions.id),
                ),
                innerJoin(
                  sets,
                  sets.sessionExerciseId.equalsExp(sessionExercises.id),
                ),
              ])
              ..where(
                sessionExercises.exerciseId.equals(exerciseId) &
                    sessions.endedAt.isNotNull(),
              )
              ..orderBy([
                OrderingTerm.desc(sessions.startedAt),
                OrderingTerm.desc(sessions.id),
              ])
              ..limit(1))
            .map((r) => r.readTable(sessions).id)
            .getSingleOrNull();
    if (last == null) return null;
    return (await exerciseHistory(exerciseId, sessionId: last)).lastOrNull;
  }

  /// Exercises done in finished workouts, the most often done first.
  Future<List<({Exercise exercise, int sessions})>> loggedExercises() async {
    final count = sessionExercises.sessionId.count(distinct: true);
    final rows =
        await (select(exercises).join([
                innerJoin(
                  sessionExercises,
                  sessionExercises.exerciseId.equalsExp(exercises.id),
                ),
                innerJoin(
                  sessions,
                  sessions.id.equalsExp(sessionExercises.sessionId),
                ),
              ])
              ..where(sessions.endedAt.isNotNull())
              ..addColumns([count])
              ..groupBy([exercises.id])
              ..orderBy([
                OrderingTerm.desc(count),
                OrderingTerm.asc(exercises.name),
              ]))
            .get();
    return [
      for (final r in rows)
        (exercise: r.readTable(exercises), sessions: r.read(count)!),
    ];
  }

  Stream<List<({Exercise exercise, int sessions})>> watchLoggedExercises() =>
      rereadOn([sessions, sessionExercises, exercises], loggedExercises);

  /// [exerciseId]'s sets in every finished session, oldest first; with
  /// [sessionId], in that session only.
  Future<List<PreviousSets>> exerciseHistory(
    int exerciseId, {
    int? sessionId,
  }) async {
    final rows =
        await (select(sets).join([
                innerJoin(
                  sessionExercises,
                  sessionExercises.id.equalsExp(sets.sessionExerciseId),
                ),
                innerJoin(
                  sessions,
                  sessions.id.equalsExp(sessionExercises.sessionId),
                ),
              ])
              ..where(
                sessionExercises.exerciseId.equals(exerciseId) &
                    sessions.endedAt.isNotNull() &
                    (sessionId == null
                        ? const Constant(true)
                        : sessions.id.equals(sessionId)),
              )
              ..orderBy([
                OrderingTerm.asc(sessions.startedAt),
                OrderingTerm.asc(sessions.id),
                OrderingTerm.asc(sessionExercises.position),
                OrderingTerm.asc(sets.position),
              ]))
            .get();
    final bySession = <int, PreviousSets>{};
    for (final r in rows) {
      final session = r.readTable(sessions);
      bySession
          .putIfAbsent(session.id, () => PreviousSets(session.startedAt, []))
          .sets
          .add(r.readTable(sets));
    }
    return bySession.values.toList();
  }

  Stream<List<PreviousSets>> watchExerciseHistory(int exerciseId) => rereadOn([
    sessions,
    sessionExercises,
    sets,
  ], () => exerciseHistory(exerciseId));

  /// Every finished workout, oldest first.
  Future<List<WorkoutSummary>> workoutHistory() async {
    final done =
        await (sessionsWithRoutine()
              ..where(sessions.endedAt.isNotNull())
              ..orderBy([
                OrderingTerm.asc(sessions.startedAt),
                OrderingTerm.asc(sessions.id),
              ]))
            .get();
    final setCount = sets.id.count();
    final entries =
        await (selectOnly(sessionExercises).join([
                innerJoin(
                  exercises,
                  exercises.id.equalsExp(sessionExercises.exerciseId),
                ),
                leftOuterJoin(
                  sets,
                  sets.sessionExerciseId.equalsExp(sessionExercises.id),
                ),
              ])
              ..addColumns([
                sessionExercises.sessionId,
                exercises.name,
                setCount,
              ])
              ..groupBy([sessionExercises.id])
              ..orderBy([OrderingTerm.asc(sessionExercises.position)]))
            .get();
    final names = <int, List<String>>{};
    final perExercise = <int, List<int>>{};
    for (final e in entries) {
      final id = e.read(sessionExercises.sessionId)!;
      names.putIfAbsent(id, () => []).add(e.read(exercises.name)!);
      perExercise.putIfAbsent(id, () => []).add(e.read(setCount)!);
    }
    final worked =
        await (selectOnly(sessionExercises, distinct: true).join([
              innerJoin(
                exerciseMuscles,
                exerciseMuscles.exerciseId.equalsExp(
                  sessionExercises.exerciseId,
                ),
              ),
            ])..addColumns([
              sessionExercises.sessionId,
              exerciseMuscles.muscleId,
              exerciseMuscles.role,
            ]))
            .get();
    final muscles = <int, Map<MuscleRole, Set<String>>>{};
    for (final m in worked) {
      muscles
          .putIfAbsent(m.read(sessionExercises.sessionId)!, () => {})
          .putIfAbsent(m.readWithConverter(exerciseMuscles.role)!, () => {})
          .add(m.read(exerciseMuscles.muscleId)!);
    }
    return [
      for (final r in done)
        if (r.readTable(sessions) case final s)
          WorkoutSummary(
            s,
            titleOf(r),
            names[s.id] ?? const [],
            perExercise[s.id] ?? const [],
            muscles[s.id] ?? const {},
          ),
    ];
  }

  Stream<List<WorkoutSummary>> watchWorkoutHistory() => rereadOn([
    sessions,
    sessionExercises,
    sets,
    exercises,
    exerciseMuscles,
    routines,
  ], workoutHistory);

  Future<WorkoutLog?> workoutLog(int sessionId) async {
    final row =
        await (sessionsWithRoutine()..where(sessions.id.equals(sessionId)))
            .getSingleOrNull();
    if (row == null) return null;
    return WorkoutLog(row.readTable(sessions), titleOf(row), [
      for (final (:entry, :exercise) in await sessionEntries(sessionId))
        (
          entry: entry,
          exercise: exercise,
          sets: await attachedDatabase.workoutsDao.setsOf(entry.id),
          setup: await attachedDatabase.exercisesDao.setupOf(entry),
        ),
    ]);
  }

  Stream<WorkoutLog?> watchWorkoutLog(int sessionId) => rereadOn([
    sessions,
    sessionExercises,
    sets,
    exercises,
    routines,
    setupFields,
    setupValues,
  ], () => workoutLog(sessionId));
}
