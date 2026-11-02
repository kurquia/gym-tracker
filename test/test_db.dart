import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show QueryExecutor, Value;
import 'package:drift/native.dart';
import 'package:gym_tracker/data/database.dart';

/// In-memory database seeded with a few exercises, for widget tests; on
/// [executor] instead when given, seeded with [exercises] and [curated]
/// (curated_muscles.json format) when given.
AppDatabase testDatabase([
  QueryExecutor? executor,
  List<Map<String, Object?>>? exercises,
  String? curated,
]) => AppDatabase(
  executor ?? NativeDatabase.memory(),
  loadCurated: () async => curated ?? jsonEncode({'exercises': {}}),
  loadSeed: () async => jsonEncode({
    'exercises':
        exercises ??
        [
          seedExercise(
            'Barbell Bench Press',
            ['chest'],
            ['triceps'],
            'barbell',
          ),
          seedExercise('Barbell Squat', ['quadriceps'], ['glutes'], 'barbell'),
          seedExercise('Triceps Pushdown', ['triceps'], [], 'cable'),
          seedExercise('Pullups', ['lats'], ['biceps'], 'body only'),
        ],
  }),
);

/// In-memory database with the real exercises and curated muscles.
AppDatabase realDatabase() => AppDatabase(
  NativeDatabase.memory(),
  loadSeed: () => File('assets/data/exercises.json').readAsString(),
  loadCurated: () => File('assets/data/curated_muscles.json').readAsString(),
);

/// Exercise name → id.
Future<Map<String, int>> exerciseIds(AppDatabase db) async => {
  for (final c in await db.exercisesDao.exerciseCatalog())
    c.exercise.name: c.exercise.id,
};

/// One exercise in the seed JSON.
Map<String, Object?> seedExercise(
  String name,
  List<String> primary,
  List<String> secondary,
  String equipment,
) => {
  'id': name.replaceAll(' ', '_'),
  'name': name,
  'primary': primary,
  'secondary': secondary,
  'equipment': equipment,
  'category': 'strength',
};

extension TestWorkouts on AppDatabase {
  /// The open workout.
  Future<ActiveWorkout> active() async => (await workoutsDao.activeWorkout())!;

  /// Starts an empty workout with [exerciseIds]; returns its session id.
  Future<int> startWith(List<int> exerciseIds) async {
    final session = await workoutsDao.startWorkout();
    await workoutsDao.addExercises(session, exerciseIds);
    return session;
  }

  /// A workout with one ticked set of [kg] × 5, finished unless [finish] is
  /// false. Returns its session id.
  Future<int> logSet(int exercise, double kg, {bool finish = true}) async {
    final session = await startWith([exercise]);
    final set = (await active()).exercises.single.sets.single;
    await workoutsDao.updateSet(
      set.id,
      SetsCompanion(
        weightKg: Value(kg),
        reps: const Value(5),
        completedAt: Value(DateTime.now()),
      ),
    );
    if (finish) await workoutsDao.finishWorkout(session);
    return session;
  }

  /// Sets the clock of workout [session]: [millis] banked, running since
  /// [runningSince], or paused.
  Future<void> setClock(int session, int millis, {DateTime? runningSince}) =>
      (update(sessions)..where((s) => s.id.equals(session))).write(
        SessionsCompanion(
          clockMillis: Value(millis),
          clockRunningSinceMillis: Value(runningSince?.millisecondsSinceEpoch),
        ),
      );
}
