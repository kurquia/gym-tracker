// Schema checks for database upgrades, from drift's make-migrations: every
// older schema snapshot in drift_schemas/ must upgrade to exactly the schema
// a fresh install gets. Below them, the data an upgrade keeps or transforms.
//
// After a schema bump: `tool/schema_snapshot.sh` adds the new snapshot and
// regenerates generated/ (not make-migrations); this file is kept.
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/database.dart';

import 'generated/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  // Only upgrades to the newest version: the app always upgrades all the way,
  // and its migration builds new tables with their newest columns, so it
  // never stops at a version in between.
  const versions = GeneratedHelper.versions;
  final newest = versions.last;
  for (final from in versions.take(versions.length - 1)) {
    test('upgrade from v$from to v$newest gives the fresh schema', () async {
      final schema = await verifier.schemaAt(from);
      final db = AppDatabase(
        schema.newConnection(),
        loadCurated: () =>
            File('assets/data/curated_muscles.json').readAsString(),
      );
      await verifier.migrateAndValidate(db, newest);
      await db.close();
    });
  }

  test('the newest snapshot is the current schema version', () {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, newest);
  });

  /// The app's database opened on a v[version] snapshot holding [sql]'s rows.
  Future<AppDatabase> upgraded(int version, String sql) async {
    final schema = await verifier.schemaAt(version);
    addTearDown(schema.close);
    schema.rawDatabase.execute(sql);
    final db = AppDatabase(
      schema.newConnection(),
      loadSeed: () => throw StateError('an upgrade must not reseed'),
      loadCurated: () async =>
          File('assets/data/curated_muscles.json').readAsStringSync(),
    );
    addTearDown(db.close);
    return db;
  }

  test('upgrade from v12 keeps routines, history and settings', () async {
    final db = await upgraded(12, '''
      INSERT INTO exercises (id, name, equipment)
        VALUES (1, 'Dumbbell row', 'dumbbell'), (2, 'Squat', 'barbell');
      INSERT INTO routines (id, name) VALUES (1, 'Full body');
      INSERT INTO routine_exercises (routine_id, position, exercise_id)
        VALUES (1, 0, 2), (1, 1, 1);
      INSERT INTO sessions (id, routine_id, started_at, ended_at, clock_millis)
        VALUES (1, 1, 1760000000, 1760003600, 3125000);
      INSERT INTO session_exercises (id, session_id, exercise_id, position)
        VALUES (1, 1, 2, 0), (2, 1, 1, 1);
      INSERT INTO sets (session_exercise_id, position, is_warmup, weight_kg,
          reps, completed_at, completed_clock_millis, rest_seconds)
        VALUES (1, 0, 1, 60, 5, 1760000100, 100000, 90),
               (1, 1, 0, 100, 5, 1760000400, 400000, NULL),
               (2, 0, 0, 30, 10, 1760000900, 900000, NULL);
      INSERT INTO settings (id, weight_unit, rest_style, rest_alert)
        VALUES (1, 'lb', 'countdown', 'vibration');
      -- A stray column from a dev build, still in old phone backups.
      ALTER TABLE settings ADD COLUMN rest_alert_sound INTEGER NOT NULL
        DEFAULT 1 CHECK (rest_alert_sound IN (0, 1));
    ''');

    final entries = await db.routinesDao.routineEntries(1);
    expect(
      [
        for (final e in entries)
          (e.exercise.name, e.superset, e.sets, e.warmup),
      ],
      [('Squat', false, null, false), ('Dumbbell row', false, null, false)],
    );
    final row = await db.exercisesDao.exercise(1);
    expect((row.counting, row.note), (WeightCounting.perDumbbell, null));
    final squat = await db.exercisesDao.exercise(2);
    expect(
      (squat.counting, squat.barKg, squat.bar),
      (WeightCounting.total, null, 20),
    );

    final history = (await db.historyDao.workoutHistory()).single;
    expect(history.title, 'Full body');
    expect(history.exerciseNames, ['Squat', 'Dumbbell row']);
    expect(history.exerciseSets, [2, 1]);
    expect(history.session.clockMillis, 3125000);
    final previous = (await db.historyDao.previousSets(2))!;
    expect(previous.date, DateTime.fromMillisecondsSinceEpoch(1760000000000));
    expect(
      [
        for (final s in previous.sets)
          (
            s.isWarmup,
            s.weightKg,
            s.reps,
            s.completedClockMillis,
            s.restSeconds,
          ),
      ],
      [(true, 60.0, 5, 100000, 90), (false, 100.0, 5, 400000, null)],
    );
    final log = (await db.historyDao.workoutLog(1))!;
    expect(
      [
        for (final e in log.exercises)
          (e.entry.note, e.entry.supersetWithPrevious, e.setup.length),
      ],
      [(null, false, 0), (null, false, 0)],
    );

    // Settings keep their values; the new one gets its default, and the
    // table can still be written next to the stray column.
    var settings = await db.settingsDao.watchSettings().first;
    expect(
      (
        settings.weightUnit,
        settings.restStyle,
        settings.restAlert,
        settings.firstWeekday,
      ),
      (
        WeightUnit.lb,
        RestStyle.countdown,
        RestAlert.vibration,
        FirstWeekday.monday,
      ),
    );
    await db.settingsDao.updateSettings(
      const SettingsTableCompanion(firstWeekday: Value(FirstWeekday.sunday)),
    );
    settings = await db.settingsDao.watchSettings().first;
    expect(
      (settings.weightUnit, settings.firstWeekday),
      (WeightUnit.lb, FirstWeekday.sunday),
    );

    // The routine starts from last time's sets, with the new setup fields.
    await db.exercisesDao.addSetupField(2, 'Safeties', value: '4');
    await db.workoutsDao.startWorkout(routineId: 1);
    final w = (await db.workoutsDao.activeWorkout())!;
    expect(w.title, 'Full body');
    expect([for (final s in w.exercises.first.sets) s.weightKg], [60.0, 100.0]);
    expect(setupSummary(w.exercises.first.setup), 'Safeties 4');
  });

  test(
    'upgrade from v17: the incline dumbbell press gets its fine muscles',
    () async {
      final db = await upgraded(17, '''
      INSERT INTO muscles (id, name)
        VALUES ('chest', 'Chest'), ('shoulders', 'Shoulders'),
               ('triceps', 'Triceps'), ('biceps', 'Biceps');
      INSERT INTO exercises (id, source_id, name, equipment)
        VALUES (1, 'Incline_Dumbbell_Press', 'Incline Dumbbell Press', 'dumbbell'),
               (2, 'Alternate_Hammer_Curl', 'Alternate Hammer Curl', 'dumbbell'),
               (3, NULL, 'My own press', NULL);
      INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
        VALUES (1, 'chest', 'target'), (1, 'shoulders', 'synergist'),
               (1, 'triceps', 'synergist'), (2, 'biceps', 'target'),
               (3, 'chest', 'target');
    ''');

      final press = (await db.exercisesDao.exerciseDetail(1))!;
      expect(press.exercise.musclesVerified, isTrue);
      expect(
        {for (final m in press.muscles[MuscleRole.target]!) m.id},
        {'clavicular_head_of_pectoralis_major'},
      );
      expect(
        {for (final m in press.muscles[MuscleRole.stabilizer]!) m.id},
        {
          'short_head_of_biceps_brachii',
          'serratus_anterior',
          'pectoralis_minor',
        },
      );

      // Other exercises, library and custom, are untouched.
      for (final (id, muscle) in [(2, 'biceps'), (3, 'chest')]) {
        final other = (await db.exercisesDao.exerciseDetail(id))!;
        expect(other.exercise.musclesVerified, isFalse);
        expect(other.muscles[MuscleRole.target]!.single.id, muscle);
      }
    },
  );
}
