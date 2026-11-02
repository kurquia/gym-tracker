import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/database.dart';
import 'package:gym_tracker/features/exercises/body_model/body_model.dart';
import 'package:gym_tracker/features/exercises/body_model/body_view.dart';
import 'package:gym_tracker/features/exercises/body_model/muscle_map.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' show Value;

import 'test_db.dart';

void main() {
  final model = BodyModel.parse(
    ByteData.sublistView(File(bodyModelAsset).readAsBytesSync()),
  );

  Color colorOf(BodyHighlight h, String part) =>
      Color(h.partColors(model)[model.partIds.indexOf(part)]);

  test('fine muscles colour single parts', () {
    const h = BodyHighlight(
      {'clavicular_head_of_pectoralis_major'},
      {'sternocostal_head_of_pectoralis_major', 'serratus_anterior'},
    );
    expect(
      colorOf(h, 'clavicular_head_of_pectoralis_major'),
      BodyColors.target,
    );
    expect(
      colorOf(h, 'sternocostal_head_of_pectoralis_major'),
      BodyColors.secondary,
    );
    expect(colorOf(h, 'serratus_anterior'), BodyColors.secondary);
    // The rest of the chest is not lit by a fine muscle.
    expect(colorOf(h, 'abdominal_part_of_pectoralis_major'), BodyColors.muscle);
    expect(colorOf(h, 'pectoralis_minor'), BodyColors.muscle);
  });

  test('coarse groups still colour all their parts', () {
    const h = BodyHighlight({'chest'}, {'triceps'});
    expect(colorOf(h, 'pectoralis_minor'), BodyColors.target);
    expect(colorOf(h, 'long_head_of_triceps_brachii'), BodyColors.secondary);
    // Not part of any coarse group.
    expect(colorOf(h, 'serratus_anterior'), BodyColors.muscle);
  });

  test('a target by group beats a secondary by part (combined workouts)', () {
    const h = BodyHighlight(
      {'chest'},
      {'sternocostal_head_of_pectoralis_major'},
    );
    expect(
      colorOf(h, 'sternocostal_head_of_pectoralis_major'),
      BodyColors.target,
    );
  });

  test('bone, tendon and skin keep their colours', () {
    const h = BodyHighlight({'chest'}, {});
    expect(colorOf(h, 'bone'), BodyColors.bone);
    expect(colorOf(h, 'tendon'), BodyColors.bone);
    expect(colorOf(h, 'skin'), BodyColors.skin);
  });

  test('roles: stabilizers are fixators, below synergists', () {
    final h = BodyHighlight.ofExercise({
      MuscleRole.target: [const Muscle(id: 'chest', name: 'Chest')],
      MuscleRole.synergist: [
        const Muscle(id: 'serratus_anterior', name: 'Serratus anterior'),
      ],
      MuscleRole.stabilizer: [
        const Muscle(id: 'serratus_anterior', name: 'Serratus anterior'),
        const Muscle(id: 'coracobrachialis', name: 'Coracobrachialis'),
      ],
    });
    expect(h.targets, {'chest'});
    expect(h.secondaries, {'serratus_anterior'});
    expect(h.fixators, {'coracobrachialis'});
    expect(colorOf(h, 'coracobrachialis'), BodyColors.fixator);
    expect(const BodyHighlight({}, {}, {'coracobrachialis'}).onModel, isTrue);
  });

  test('a workout takes the strongest role of each muscle', () {
    final h = BodyHighlight.fromRoles({
      MuscleRole.target: {'quadriceps'},
      MuscleRole.synergist: {'gluteus_maximus'},
      MuscleRole.stabilizer: {
        'quadriceps',
        'gluteus_maximus',
        'rectus_abdominis',
      },
    });
    expect(h.targets, {'quadriceps'});
    expect(h.secondaries, {'gluteus_maximus'});
    expect(h.fixators, {'rectus_abdominis'});
  });

  test('a one-exercise workout looks like the exercise page', () async {
    // The real muscles: the curated exercises have every role.
    final db = realDatabase();
    addTearDown(db.close);
    for (final name in [
      'Barbell Squat',
      'Dumbbell Shoulder Press',
      'Incline Dumbbell Press',
      'Barbell Bench Press - Medium Grip',
      'Alternate Hammer Curl', // not curated: free-exercise-db has no fixators
    ]) {
      final id = (await exerciseIds(db))[name]!;
      final sessionId = await db.workoutsDao.startWorkout();
      await db.workoutsDao.addExercises(sessionId, [id]);
      final entry = (await db.workoutsDao.activeWorkout())!.exercises.single;
      await db.workoutsDao.addSet(entry.entry.id);
      final set =
          (await db.workoutsDao.activeWorkout())!.exercises.single.sets.first;
      await db.workoutsDao.updateSet(
        set.id,
        SetsCompanion(completedAt: Value(DateTime.now())),
      );
      await db.workoutsDao.finishWorkout(sessionId);
      final workout = (await db.historyDao.workoutHistory()).last;
      final page = BodyHighlight.ofExercise(
        (await db.exercisesDao.exerciseDetail(id))!.muscles,
      );
      final card = BodyHighlight.fromRoles(workout.muscles);
      expect(
        page.fixators,
        name == 'Alternate Hammer Curl' ? isEmpty : isNotEmpty,
      );
      expect(card.targets, page.targets, reason: name);
      expect(card.secondaries, page.secondaries, reason: name);
      expect(card.fixators, page.fixators, reason: name);
      expect(card.partColors(model), page.partColors(model), reason: name);
    }
  });

  test('showing only some colours greys the others', () {
    const h = BodyHighlight({'chest'}, {'triceps'}, {'serratus_anterior'});
    final target = h.showing({BodyKey.target});
    expect(colorOf(target, 'pectoralis_minor'), BodyColors.target);
    expect(colorOf(target, 'long_head_of_triceps_brachii'), BodyColors.muscle);
    expect(colorOf(target, 'serratus_anterior'), BodyColors.muscle);
    final noTarget = h.showing({BodyKey.secondary, BodyKey.fixator});
    expect(colorOf(noTarget, 'pectoralis_minor'), BodyColors.muscle);
    expect(colorOf(noTarget, 'serratus_anterior'), BodyColors.fixator);
  });

  test('a fine muscle alone is on the model', () {
    expect(const BodyHighlight({'coracobrachialis'}, {}).onModel, isTrue);
    expect(const BodyHighlight({}, {'serratus_anterior'}).onModel, isTrue);
    expect(const BodyHighlight({'nothing'}, {}).onModel, isFalse);
  });

  test('ungrouped parts are on the model and not in a coarse group', () {
    expect(model.partIds.toSet().containsAll(ungroupedParts), isTrue);
    for (final id in ungroupedParts) {
      expect(isFineMuscle(id), isTrue);
      expect(coarseGroupOf(id), isNull);
    }
    expect(coarseGroupOf('pectoralis_minor'), 'chest');
    expect(coarseGroupOf('chest'), 'chest');
    expect(isFineMuscle('chest'), isFalse);
  });
}
