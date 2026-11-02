import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/database.dart';
import 'package:gym_tracker/features/exercises/body_model/muscle_map.dart';

import 'test_db.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  test('seeds all free-exercise-db exercises and muscles', () async {
    final db = realDatabase();
    addTearDown(db.close);
    final catalog = await db.exercisesDao.exerciseCatalog();
    expect(catalog, hasLength(876));
    // 17 coarse groups + the hand-checked fine muscles (curated_muscles.json).
    final muscles = await db.exercisesDao.allMuscles();
    expect(muscles.where((m) => !isFineMuscle(m.id)), hasLength(17));
    final curated =
        (jsonDecode(File('assets/data/curated_muscles.json').readAsStringSync())
                as Map)['exercises']
            as Map;
    final curatedIds = {
      for (final id in curated.keys)
        for (final m in AppDatabase.curatedMuscles(
          curated.cast(),
          id as String,
        ))
          m.id,
    };
    expect(
      muscles.where((m) => isFineMuscle(m.id)).map((m) => m.id).toSet(),
      curatedIds,
    );

    final frontSquat = catalog.singleWhere(
      (c) => c.exercise.name == 'Front Squat (Clean Grip)',
    );
    expect(frontSquat.targetMuscleIds, ['quadriceps']);
    expect(frontSquat.exercise.musclesVerified, isFalse);

    final synergists =
        await (db.select(db.exerciseMuscles)..where(
              (em) =>
                  em.exerciseId.equals(frontSquat.exercise.id) &
                  em.role.equalsValue(MuscleRole.synergist),
            ))
            .get();
    expect(synergists.map((s) => s.muscleId).toSet(), {
      'abdominals',
      'glutes',
      'hamstrings',
    });
  });

  test('every exercise has at least one target muscle', () async {
    final db = realDatabase();
    addTearDown(db.close);
    final catalog = await db.exercisesDao.exerciseCatalog();
    expect(catalog.where((c) => c.targetMuscleIds.isEmpty), isEmpty);
  });

  test('create, list, edit and delete a routine', () async {
    final catalog = await db.exercisesDao.exerciseCatalog();
    final ids = [for (final c in catalog.take(3)) c.exercise.id];

    final id = await db.routinesDao.saveRoutine(
      name: 'Push day',
      exerciseIds: ids,
    );
    var routines = await db.routinesDao.watchRoutines().first;
    expect(routines.single.routine.name, 'Push day');
    expect(routines.single.exerciseCount, 3);

    await db.routinesDao.saveRoutine(
      id: id,
      name: 'Push',
      exerciseIds: [ids[2], ids[0]],
    );
    expect((await db.routinesDao.routine(id)).name, 'Push');
    expect(
      [for (final e in await db.routinesDao.routineEntries(id)) e.exercise.id],
      [ids[2], ids[0]],
    );

    final deleted = await db.routinesDao.deleteRoutine(id);
    expect(await db.routinesDao.watchRoutines().first, isEmpty);
    expect(await db.select(db.routineExercises).get(), isEmpty);

    await db.routinesDao.restoreRoutine(deleted);
    routines = await db.routinesDao.watchRoutines().first;
    expect(routines.single.routine.id, id);
    expect(routines.single.exerciseCount, 2);
  });

  test('default routine names fill the first gap', () async {
    expect(await db.routinesDao.nextRoutineName(), 'Routine 1');
    await db.routinesDao.saveRoutine(name: 'Routine 1', exerciseIds: []);
    await db.routinesDao.saveRoutine(name: 'Routine 3', exerciseIds: []);
    expect(await db.routinesDao.nextRoutineName(), 'Routine 2');
  });

  test('exercises in a routine cannot be deleted', () async {
    final exerciseId =
        (await db.exercisesDao.exerciseCatalog()).first.exercise.id;
    await db.routinesDao.saveRoutine(name: 'R', exerciseIds: [exerciseId]);
    expect(
      () =>
          (db.delete(db.exercises)..where((e) => e.id.equals(exerciseId))).go(),
      throwsA(isA<SqliteException>()),
    );
  });
  test('custom exercises: create, edit, delete unless used', () async {
    final id = await db.exercisesDao.saveCustomExercise(
      name: 'Landmine Press',
      equipment: 'barbell',
      targetMuscleIds: ['lats'],
      synergistMuscleIds: ['triceps', 'lats'],
    );
    var entry = (await db.exercisesDao.exerciseCatalog()).singleWhere(
      (c) => c.exercise.id == id,
    );
    expect(entry.exercise.isCustom, isTrue);
    expect(entry.targetMuscleIds, ['lats']);
    var detail = (await db.exercisesDao.exerciseDetail(id))!;
    expect(
      [for (final m in detail.muscles[MuscleRole.synergist]!) m.id],
      ['triceps'],
    );
    expect(await db.exercisesDao.exerciseNameTaken('landmine press'), isTrue);
    expect(
      await db.exercisesDao.exerciseNameTaken('Landmine Press', exceptId: id),
      isFalse,
    );

    await db.exercisesDao.saveCustomExercise(
      id: id,
      name: 'Landmine Press (one arm)',
      targetMuscleIds: ['chest'],
    );
    detail = (await db.exercisesDao.exerciseDetail(id))!;
    expect(detail.exercise.name, 'Landmine Press (one arm)');
    expect(detail.exercise.equipment, isNull);
    expect(detail.muscles.keys, [MuscleRole.target]);

    final routineId = await db.routinesDao.saveRoutine(
      name: 'R',
      exerciseIds: [id],
    );
    expect(await db.exercisesDao.deleteCustomExercise(id), isFalse);
    await db.routinesDao.deleteRoutine(routineId);
    expect(await db.exercisesDao.deleteCustomExercise(id), isTrue);
    expect(await db.exercisesDao.exerciseDetail(id), isNull);
    expect(
      await (db.select(
        db.exerciseMuscles,
      )..where((em) => em.exerciseId.equals(id))).get(),
      isEmpty,
    );
  });

  test('library exercises cannot be edited or deleted as custom', () async {
    final first = (await db.exercisesDao.exerciseCatalog()).first.exercise;
    await expectLater(
      db.exercisesDao.saveCustomExercise(
        id: first.id,
        name: 'Renamed',
        targetMuscleIds: ['chest'],
      ),
      throwsArgumentError,
    );
    await expectLater(
      db.exercisesDao.deleteCustomExercise(first.id),
      throwsArgumentError,
    );
    final detail = (await db.exercisesDao.exerciseDetail(first.id))!;
    expect(detail.exercise.name, first.name);
    expect(detail.muscles[MuscleRole.target], isNotEmpty);
  });
  test('settings default to metric and remember changes', () async {
    expect(
      await db.settingsDao.watchSettings().first,
      SettingsDao.defaultSettings,
    );
    await db.settingsDao.updateSettings(
      const SettingsTableCompanion(weightUnit: Value(WeightUnit.lb)),
    );
    await db.settingsDao.updateSettings(
      const SettingsTableCompanion(lengthUnit: Value(LengthUnit.inch)),
    );
    final s = await db.settingsDao.watchSettings().first;
    expect(s.weightUnit, WeightUnit.lb);
    expect(s.distanceUnit, DistanceUnit.km);
    expect(s.lengthUnit, LengthUnit.inch);
  });
}
