import 'package:drift/drift.dart';

import '../database.dart';
import 'reread.dart';

part 'workouts_dao.g.dart';

/// The workout in progress: Record's reads and writes.
@DriftAccessor(
  tables: [
    Exercises,
    Sessions,
    SessionExercises,
    Sets,
    SetupFields,
    SetupValues,
  ],
)
class WorkoutsDao extends DatabaseAccessor<AppDatabase>
    with _$WorkoutsDaoMixin {
  WorkoutsDao(super.attachedDatabase);

  /// Bodyweight exercises start as [LoadType.bodyweight], others as plain kg.
  static LoadType defaultLoad(Exercise e) =>
      e.equipment == 'body only' ? LoadType.bodyweight : LoadType.weight;

  /// Starts a workout, copying each routine exercise's sets from last time
  /// (unticked), or one empty set when there is no history. Returns its id.
  Future<int> startWorkout({int? routineId}) => transaction(() async {
    final sessionId = await into(sessions).insert(
      SessionsCompanion.insert(
        routineId: Value(routineId),
        startedAt: DateTime.now(),
      ),
    );
    if (routineId != null) {
      final entries = await attachedDatabase.routinesDao.routineEntries(
        routineId,
      );
      await _addExercises(
        sessionId,
        [for (final e in entries) e.exercise.id],
        superset: [for (final e in entries) e.superset],
        sets: [for (final e in entries) e.sets],
        warmup: [for (final e in entries) e.warmup],
      );
    }
    return sessionId;
  });

  Future<void> addExercises(int sessionId, List<int> exerciseIds) =>
      transaction(() => _addExercises(sessionId, exerciseIds));

  Future<void> _addExercises(
    int sessionId,
    List<int> exerciseIds, {
    List<bool> superset = const [],
    List<int?> sets = const [],
    List<bool> warmup = const [],
  }) async {
    final existing = await (select(
      sessionExercises,
    )..where((se) => se.sessionId.equals(sessionId))).get();
    var position = existing.fold(
      -1,
      (p, se) => se.position > p ? se.position : p,
    );
    for (final (i, exerciseId) in exerciseIds.indexed) {
      final entryId = await into(sessionExercises).insert(
        SessionExercisesCompanion.insert(
          sessionId: sessionId,
          exerciseId: exerciseId,
          position: ++position,
          supersetWithPrevious: Value(
            i > 0 && (superset.elementAtOrNull(i) ?? false),
          ),
        ),
      );
      final previous = await attachedDatabase.historyDao.previousSets(
        exerciseId,
      );
      final target = sets.elementAtOrNull(i);
      // Last time's sets, or with a target: warm-ups if asked for (last
      // time's, or one empty one), then that many working sets repeating
      // last time's last one. copy null = an empty set.
      final last = previous?.sets ?? const <WorkoutSet>[];
      final warmups = [
        for (final s in last)
          if (s.isWarmup) s,
      ];
      final working = [
        for (final s in last)
          if (!s.isWarmup) s,
      ];
      final List<({WorkoutSet? copy, bool warmup})> templates = target == null
          ? [
              for (final s in last) (copy: s, warmup: s.isWarmup),
              if (last.isEmpty) (copy: null, warmup: false),
            ]
          : [
              if (warmup.elementAtOrNull(i) ?? false) ...[
                for (final s in warmups) (copy: s, warmup: true),
                if (warmups.isEmpty) (copy: null, warmup: true),
              ],
              for (var k = 0; k < target; k++)
                (
                  // Extra sets repeating last time's last one start normal.
                  copy: working.isEmpty
                      ? null
                      : k < working.length
                      ? working[k]
                      : working.last.copyWith(kind: SetKind.normal),
                  warmup: false,
                ),
            ];
      for (final (position, t) in templates.indexed) {
        if (t.copy case final old?) {
          await into(this.sets).insert(_copyOf(old, entryId, position));
        } else {
          await _emptySet(exerciseId, entryId, position, warmup: t.warmup);
        }
      }
    }
  }

  /// Inserts a blank set with [exerciseId]'s default load.
  Future<void> _emptySet(
    int exerciseId,
    int entryId,
    int position, {
    bool warmup = false,
  }) async {
    final exercise = await attachedDatabase.exercisesDao.exercise(exerciseId);
    await into(sets).insert(
      SetsCompanion.insert(
        sessionExerciseId: entryId,
        position: position,
        kind: Value(warmup ? SetKind.warmup : SetKind.normal),
        loadType: Value(defaultLoad(exercise)),
      ),
    );
  }

  static SetsCompanion _copyOf(WorkoutSet old, int entryId, int position) =>
      SetsCompanion.insert(
        sessionExerciseId: entryId,
        position: position,
        kind: Value(old.kind),
        loadType: Value(old.loadType),
        weightKg: Value(old.weightKg),
        reps: Value(old.reps),
        restSeconds: Value(old.restSeconds),
      );

  /// Adds a set copying this exercise's last set, or last time's set at the
  /// same position, so most sets only need a tick.
  Future<void> addSet(int sessionExerciseId) => transaction(() async {
    final entry = await (select(
      sessionExercises,
    )..where((se) => se.id.equals(sessionExerciseId))).getSingle();
    final current = await setsOf(sessionExerciseId);
    final position = current.isEmpty ? 0 : current.last.position + 1;
    final previous = await attachedDatabase.historyDao.previousSets(
      entry.exerciseId,
    );
    final fromLastTime = current.length < (previous?.sets.length ?? 0);
    final template = fromLastTime
        ? previous!.sets[current.length]
        : current.lastOrNull;
    if (template != null) {
      await into(sets).insert(
        _copyOf(template, sessionExerciseId, position).copyWith(
          // Last time's drop or failure set at this place comes back as one;
          // otherwise a new set is normal.
          kind: Value(
            fromLastTime && !template.isWarmup ? template.kind : SetKind.normal,
          ),
          // A warm-up's rest doesn't carry over to a working set.
          restSeconds: Value(template.isWarmup ? null : template.restSeconds),
        ),
      );
    } else {
      await _emptySet(entry.exerciseId, sessionExerciseId, position);
    }
  });

  Future<List<WorkoutSet>> setsOf(int sessionExerciseId) =>
      (select(sets)
            ..where((s) => s.sessionExerciseId.equals(sessionExerciseId))
            ..orderBy([(s) => OrderingTerm.asc(s.position)]))
          .get();

  Future<void> updateSet(int id, SetsCompanion changes) =>
      (update(sets)..where((s) => s.id.equals(id))).write(changes);

  /// Ticks or unticks a set. A tick stores the time and the workout-clock
  /// reading, which start the rest. The first tick of a workout whose clock
  /// was never started starts it (the rest runs on the clock); a clock the
  /// user paused stays paused.
  Future<void> tickSet(int id, {required bool done}) => transaction(() async {
    final session = await (select(sets).join(
      [
        innerJoin(
          sessionExercises,
          sessionExercises.id.equalsExp(sets.sessionExerciseId),
        ),
        innerJoin(sessions, sessions.id.equalsExp(sessionExercises.sessionId)),
      ],
    )..where(sets.id.equals(id))).map((r) => r.readTable(sessions)).getSingle();
    final now = DateTime.now();
    final clock = session.clockAt(now);
    if (done && clock == Duration.zero && session.clockRunningSince == null) {
      await (update(sessions)..where((s) => s.id.equals(session.id))).write(
        _clockToggled(session, now),
      );
    }
    await updateSet(
      id,
      SetsCompanion(
        completedAt: Value(done ? now : null),
        completedClockMillis: Value(done ? clock.inMilliseconds : null),
      ),
    );
  });

  Future<void> deleteSets(List<int> ids) =>
      (delete(sets)..where((s) => s.id.isIn(ids))).go();

  Future<void> removeExercise(int sessionExerciseId) => transaction(() async {
    final all = await _entriesWith(sessionExerciseId);
    final i = all.indexWhere((se) => se.id == sessionExerciseId);
    // The next one led by this one now leads its superset.
    if (!all[i].supersetWithPrevious && i + 1 < all.length) {
      await _setSuperset(all[i + 1].id, false);
    }
    await (delete(
      sessionExercises,
    )..where((se) => se.id.equals(sessionExerciseId))).go();
  });

  /// Swaps the exercise's page (its superset, or itself) with the
  /// neighbouring page ([delta] -1 = earlier, +1 = later).
  Future<void> moveExercise(int sessionExerciseId, int delta) =>
      transaction(() async {
        final all = await _entriesWith(sessionExerciseId);
        final pages = groupSupersets(all, (se) => se.supersetWithPrevious);
        final i = pages.indexWhere(
          (p) => p.any((se) => se.id == sessionExerciseId),
        );
        final j = i + delta;
        if (j < 0 || j >= pages.length) return;
        pages.insert(j, pages.removeAt(i));
        for (final (position, se) in pages.expand((p) => p).indexed) {
          await (update(
            sessionExercises,
          )..where((e) => e.id.equals(se.id))).write(
            SessionExercisesCompanion(
              position: Value(position),
              // A page never joins the one before it.
              supersetWithPrevious: Value(
                se.supersetWithPrevious && pages.every((p) => p.first != se),
              ),
            ),
          );
        }
      });

  /// All exercises of the workout that [sessionExerciseId] belongs to, in order.
  Future<List<SessionExercise>> _entriesWith(int sessionExerciseId) async {
    final entry = await (select(
      sessionExercises,
    )..where((se) => se.id.equals(sessionExerciseId))).getSingle();
    return (select(sessionExercises)
          ..where((se) => se.sessionId.equals(entry.sessionId))
          ..orderBy([(se) => OrderingTerm.asc(se.position)]))
        .get();
  }

  /// Puts the exercise in a superset with the next one in the workout.
  Future<void> supersetWithNext(int sessionExerciseId) => transaction(() async {
    final all = await _entriesWith(sessionExerciseId);
    final i = all.indexWhere((se) => se.id == sessionExerciseId);
    if (i + 1 >= all.length) return;
    await _setSuperset(all[i + 1].id, true);
  });

  /// Takes the exercise out of its superset; the exercises after it in the
  /// superset stay together.
  Future<void> leaveSuperset(int sessionExerciseId) => transaction(() async {
    final all = await _entriesWith(sessionExerciseId);
    final i = all.indexWhere((se) => se.id == sessionExerciseId);
    await _setSuperset(all[i].id, false);
    if (i + 1 < all.length) await _setSuperset(all[i + 1].id, false);
  });

  Future<void> _setSuperset(int sessionExerciseId, bool superset) =>
      (update(
        sessionExercises,
      )..where((se) => se.id.equals(sessionExerciseId))).write(
        SessionExercisesCompanion(supersetWithPrevious: Value(superset)),
      );

  Future<Session> _session(int id) =>
      (select(sessions)..where((s) => s.id.equals(id))).getSingle();

  /// Starts or pauses the workout clock.
  Future<void> toggleClock(int sessionId) => transaction(() async {
    final session = await _session(sessionId);
    await (update(sessions)..where((s) => s.id.equals(sessionId))).write(
      _clockToggled(session, DateTime.now()),
    );
  });

  /// Sets the workout clock back to zero, still running if it was running.
  Future<void> resetClock(int sessionId) => transaction(() async {
    final session = await _session(sessionId);
    final running = session.clockRunningSince != null;
    await (update(sessions)..where((s) => s.id.equals(sessionId))).write(
      SessionsCompanion(
        clockMillis: const Value(0),
        clockRunningSinceMillis: Value(
          running ? DateTime.now().millisecondsSinceEpoch : null,
        ),
      ),
    );
  });

  static SessionsCompanion _clockToggled(Session s, DateTime now) {
    final since = s.clockRunningSince;
    return since == null
        ? SessionsCompanion(
            clockRunningSinceMillis: Value(now.millisecondsSinceEpoch),
          )
        : SessionsCompanion(
            clockMillis: Value(s.clockAt(now).inMilliseconds),
            clockRunningSinceMillis: const Value(null),
          );
  }

  /// Ends the workout, dropping unticked sets and empty exercises.
  /// Returns false (and deletes the session) when nothing was ticked.
  Future<bool> finishWorkout(int sessionId) => transaction(() async {
    final session = await _session(sessionId);
    final entries = await (select(
      sessionExercises,
    )..where((se) => se.sessionId.equals(sessionId))).get();
    final entryIds = [for (final e in entries) e.id];
    await (delete(sets)..where(
          (s) => s.sessionExerciseId.isIn(entryIds) & s.completedAt.isNull(),
        ))
        .go();
    final kept = await (select(
      sets,
    )..where((s) => s.sessionExerciseId.isIn(entryIds))).get();
    final withSets = {for (final s in kept) s.sessionExerciseId};
    await (delete(sessionExercises)..where(
          (se) => se.sessionId.equals(sessionId) & se.id.isNotIn(withSets),
        ))
        .go();
    if (kept.isEmpty) {
      await discardWorkout(sessionId);
      return false;
    }
    await attachedDatabase.exercisesDao.keepSetup([
      for (final e in entries)
        if (withSets.contains(e.id)) e,
    ]);
    final now = DateTime.now();
    var finish = SessionsCompanion(endedAt: Value(now));
    if (session.clockRunningSince != null) {
      finish = _clockToggled(session, now).copyWith(endedAt: Value(now));
    }
    await (update(
      sessions,
    )..where((s) => s.id.equals(sessionId))).write(finish);
    return true;
  });

  /// Deletes a workout, in progress or finished, with its exercises and sets.
  Future<void> discardWorkout(int sessionId) =>
      (delete(sessions)..where((s) => s.id.equals(sessionId))).go();

  Future<ActiveWorkout?> activeWorkout() async {
    final history = attachedDatabase.historyDao;
    final row =
        await (history.sessionsWithRoutine()
              ..where(sessions.endedAt.isNull())
              ..orderBy([OrderingTerm.desc(sessions.id)])
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    final session = row.readTable(sessions);
    return ActiveWorkout(session, history.titleOf(row), [
      for (final (:entry, :exercise) in await history.sessionEntries(
        session.id,
      ))
        WorkoutExercise(
          entry,
          exercise,
          await setsOf(entry.id),
          await history.previousSets(exercise.id),
          [
            for (final f in await attachedDatabase.exercisesDao.setupFieldsOf(
              exercise.id,
            ))
              (field: f, value: f.value),
          ],
        ),
    ]);
  }

  Stream<ActiveWorkout?> watchActiveWorkout() => rereadOn([
    sessions,
    sessionExercises,
    sets,
    // Weight options changed mid-workout.
    exercises,
    setupFields,
    setupValues,
  ], activeWorkout);
}
