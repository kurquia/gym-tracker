import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/database.dart';
import 'package:gym_tracker/features/exercises/body_model/body_model.dart';
import 'package:gym_tracker/features/exercises/body_model/muscle_map.dart';

import 'test_db.dart';

void main() {
  final curated = File('assets/data/curated_muscles.json').readAsStringSync();
  final entries = (jsonDecode(curated)['exercises'] as Map).cast<String, Map>();

  test('curated muscles are parts of the 3D model with a known role', () {
    final model = BodyModel.parse(
      ByteData.sublistView(File(bodyModelAsset).readAsBytesSync()),
    );
    for (final MapEntry(key: name, value: entry) in entries.entries) {
      final ids = <String>[];
      for (final m in (entry['muscles'] as List? ?? const []).cast<Map>()) {
        ids.add(m['id'] as String);
        expect(MuscleRole.values.map((r) => r.name), contains(m['role']));
      }
      expect(ids.toSet(), hasLength(ids.length), reason: name);
      if (entry['same_as'] case final String base) {
        expect(entries, contains(base), reason: name);
      } else {
        expect(ids, isNotEmpty, reason: name);
      }
      for (final m in AppDatabase.curatedMuscles(entries, name)) {
        expect(model.partIds, contains(m.id), reason: name);
        expect(isFineMuscle(m.id), isTrue, reason: '$name: ${m.id}');
      }
    }
  });

  test('a same_as variant copies its base, changes and removes', () {
    final entries = <String, Map>{
      'Base': {
        'muscles': [
          {'id': 'a', 'role': 'target'},
          {'id': 'b', 'role': 'synergist'},
          {'id': 'c', 'role': 'stabilizer'},
        ],
      },
      'Variant': {
        'same_as': 'Base',
        'muscles': [
          {'id': 'b', 'role': 'target'},
          {'id': 'd', 'role': 'synergist'},
        ],
        'remove': ['c'],
      },
    };
    expect(AppDatabase.curatedMuscles(entries, 'Variant'), [
      (id: 'a', role: MuscleRole.target),
      (id: 'b', role: MuscleRole.target),
      (id: 'd', role: MuscleRole.synergist),
    ]);
  });

  test('new curation reaches an existing database on the next start', () async {
    final file = File(
      '${Directory.systemTemp.createTempSync('curated').path}/db.sqlite',
    );
    addTearDown(() => file.parent.deleteSync(recursive: true));
    Future<ExerciseDetail> curl(String curatedJson) async {
      final db = testDatabase(NativeDatabase(file), [
        seedExercise('Barbell Curl', ['biceps'], ['forearms'], 'barbell'),
      ], curatedJson);
      try {
        final id = (await db.exercisesDao.exerciseCatalog()).single.exercise.id;
        return (await db.exercisesDao.exerciseDetail(id))!;
      } finally {
        await db.close();
      }
    }

    final before = await curl(jsonEncode({'exercises': {}}));
    expect(before.exercise.musclesVerified, isFalse);
    expect(before.muscles[MuscleRole.target]!.single.id, 'biceps');

    final after = await curl(
      jsonEncode({
        'exercises': {
          'Barbell_Curl': {
            'muscles': [
              {'id': 'long_head_of_biceps_brachii', 'role': 'target'},
            ],
          },
        },
      }),
    );
    expect(after.exercise.musclesVerified, isTrue);
    expect(after.muscles.keys, [MuscleRole.target]);
    expect(
      after.muscles[MuscleRole.target]!.single.id,
      'long_head_of_biceps_brachii',
    );
  });

  test('a custom exercise is curated by its name', () async {
    final file = File(
      '${Directory.systemTemp.createTempSync('curated').path}/db.sqlite',
    );
    addTearDown(() => file.parent.deleteSync(recursive: true));
    final first = testDatabase(NativeDatabase(file), const []);
    final id = await first
        .into(first.exercises)
        .insert(
          ExercisesCompanion.insert(
            name: 'Leg raise',
            isCustom: const Value(true),
          ),
        );
    await first.close();

    final db = testDatabase(
      NativeDatabase(file),
      const [],
      jsonEncode({
        'exercises': {
          'Leg_raise': {
            'muscles': [
              {'id': 'iliacus', 'role': 'target'},
            ],
          },
        },
      }),
    );
    addTearDown(db.close);
    final detail = (await db.exercisesDao.exerciseDetail(id))!;
    expect(detail.exercise.musclesVerified, isTrue);
    expect(detail.muscles[MuscleRole.target]!.single.id, 'iliacus');
  });

  test(
    'a fresh database has the incline dumbbell press hand-checked',
    () async {
      final db = testDatabase(NativeDatabase.memory(), [
        seedExercise(
          'Incline Dumbbell Press',
          ['chest'],
          ['shoulders', 'triceps'],
          'dumbbell',
        ),
        seedExercise(
          'Alternate Hammer Curl',
          ['biceps'],
          ['forearms'],
          'dumbbell',
        ),
      ], curated);
      addTearDown(db.close);

      final ids = await exerciseIds(db);
      final press = (await db.exercisesDao.exerciseDetail(
        ids['Incline Dumbbell Press']!,
      ))!;
      expect(press.exercise.musclesVerified, isTrue);
      Set<String> of(MuscleRole r) => {
        for (final m in press.muscles[r] ?? const <Muscle>[]) m.id,
      };
      expect(of(MuscleRole.target), {'clavicular_head_of_pectoralis_major'});
      expect(
        of(MuscleRole.synergist),
        containsAll([
          'sternocostal_head_of_pectoralis_major',
          'clavicular_part_of_deltoid',
          'long_head_of_triceps_brachii',
          'coracobrachialis',
        ]),
      );
      expect(of(MuscleRole.stabilizer), {
        'short_head_of_biceps_brachii',
        'serratus_anterior',
        'pectoralis_minor',
      });
      expect(
        press.muscles[MuscleRole.target]!.single.name,
        'Clavicular head of pectoralis major',
      );

      // Other exercises keep free-exercise-db's coarse muscles.
      final curl = (await db.exercisesDao.exerciseDetail(
        ids['Alternate Hammer Curl']!,
      ))!;
      expect(curl.exercise.musclesVerified, isFalse);
      expect(curl.muscles[MuscleRole.target]!.single.id, 'biceps');

      // In the catalog a fine target filters under its coarse group.
      final inCatalog = (await db.exercisesDao.exerciseCatalog()).firstWhere(
        (c) => c.exercise.id == press.exercise.id,
      );
      expect(inCatalog.targetMuscleIds, [
        'clavicular_head_of_pectoralis_major',
      ]);
      expect(coarseGroupOf(inCatalog.targetMuscleIds.single), 'chest');
    },
  );
}
