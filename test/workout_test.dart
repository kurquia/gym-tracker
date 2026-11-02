import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/database.dart';
import 'package:gym_tracker/shared/format.dart';

import 'test_db.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  Future<void> tickAll() async {
    for (final e in (await db.active()).exercises) {
      for (final s in e.sets) {
        await db.workoutsDao.updateSet(
          s.id,
          SetsCompanion(completedAt: Value(DateTime.now())),
        );
      }
    }
  }

  test('per side: plates on one side plus the bar make the weight', () async {
    final squat = (await exerciseIds(db))['Barbell Squat']!;
    await db.exercisesDao.setWeightCounting(
      squat,
      WeightCounting.perSide,
      barKg: 15,
    );
    final e = await db.exercisesDao.exercise(squat);
    expect(e.kgFromTyped(30), 75);
    expect(e.typedFromKg(75), 30);
    expect(e.kgFromTyped(0), 15); // the empty bar

    await db.exercisesDao.setWeightCounting(squat, WeightCounting.total);
    final total = await db.exercisesDao.exercise(squat);
    expect(total.kgFromTyped(80), 80);
    expect(total.bar, 20); // back to the default bar
  });

  test('the equipment decides how a weight can be counted', () async {
    final ids = await exerciseIds(db);
    final bench = await db.exercisesDao.exercise(ids['Barbell Bench Press']!);
    expect(bench.countingChoices, [
      WeightCounting.total,
      WeightCounting.perSide,
    ]);
    expect((await db.exercisesDao.exercise(ids['Pullups']!)).countingChoices, [
      WeightCounting.total,
    ]);

    // A choice the equipment doesn't allow falls back to its default.
    final pushdown = ids['Triceps Pushdown']!; // cable
    await db.exercisesDao.setWeightCounting(
      pushdown,
      WeightCounting.perDumbbell,
    );
    expect(
      (await db.exercisesDao.exercise(pushdown)).counting,
      WeightCounting.total,
    );
  });

  test('setup is set on the exercise; finished workouts keep theirs', () async {
    final press = (await exerciseIds(db))['Barbell Bench Press']!;
    await db.exercisesDao.addSetupField(
      press,
      'Incline',
      unit: '°',
      value: '30',
    );
    await db.exercisesDao.addSetupField(press, 'Grip');
    await db.exercisesDao.setExerciseNote(press, '  Bench by the window  ');

    final first = await db.startWith([press]);
    var entry = (await db.active()).exercises.single;
    expect(entry.exercise.note, 'Bench by the window');
    expect(setupSummary(entry.setup), 'Incline 30°'); // Grip has no value
    await db.exercisesDao.setEntryNote(entry.entry.id, 'Shoulder a bit stiff');
    await tickAll();
    await db.workoutsDao.finishWorkout(first);

    // A new angle shows in the next workout; the old one keeps 30°.
    final incline = entry.setup.first.field;
    await db.exercisesDao.setSetupFieldValue(incline.id, '45');
    await db.startWith([press]);
    entry = (await db.active()).exercises.single;
    expect(entry.entry.note, isNull); // today's note starts empty
    expect(setupSummary(entry.setup), 'Incline 45°');
    final log = (await db.historyDao.workoutLog(first))!.exercises.single;
    expect(setupSummary(log.setup), 'Incline 30°');
    expect(log.entry.note, 'Shoulder a bit stiff');

    // Blank clears a value; removing a field removes it everywhere.
    await db.exercisesDao.setSetupFieldValue(incline.id, ' ');
    expect((await db.exercisesDao.setupFieldsOf(press)).first.value, isNull);
    await db.exercisesDao.removeSetupField(incline.id);
    expect(
      (await db.historyDao.workoutLog(first))!.exercises.single.setup
          .map((s) => s.field.name),
      ['Grip'],
    );
  });

  test('incline/decline get the angle, cable exercises the pulley', () {
    Exercise named(String name) =>
        Exercise(id: 1, name: name, isCustom: false, musclesVerified: false);
    List<String> presets(String name, [String? equipment]) => [
      for (final p in setupPresets(
        named(name).copyWith(equipment: Value(equipment)),
      ))
        p.name,
    ];
    expect(presets('Incline Dumbbell Press'), ['Incline']);
    expect(presets('Decline Crunch'), ['Decline']);
    expect(presets('Barbell Squat', 'barbell'), isEmpty);
    expect(presets('Triceps Pushdown', 'cable'), ['Pulley']);

    final pulley = SetupField(
      id: 1,
      exerciseId: 1,
      position: 0,
      name: 'Pulley',
      value: 'Double',
    );
    expect(setupSummary([(field: pulley, value: 'Double')]), 'Double pulley');
  });

  test('supersets: from the routine, rest only after a full round', () async {
    final ids = await exerciseIds(db);
    final routine = await db.routinesDao.saveRoutine(
      name: 'Upper',
      exerciseIds: [
        ids['Barbell Bench Press']!,
        ids['Pullups']!,
        ids['Triceps Pushdown']!,
      ],
      superset: [false, true, false], // bench + pull-ups
    );
    expect(
      [
        for (final e in await db.routinesDao.routineEntries(routine))
          e.superset,
      ],
      [false, true, false],
    );

    await db.workoutsDao.startWorkout(routineId: routine);
    var w = await db.active();
    final pages = groupSupersets(
      w.exercises,
      (e) => e.entry.supersetWithPrevious,
    );
    expect([for (final p in pages) p.length], [2, 1]);

    // Bench, then straight on to pull-ups; after pull-ups the full rest.
    final bench = w.exercises[0].sets.single;
    final pullup = w.exercises[1].sets.single;
    expect(w.nextInRound(bench)?.exercise.name, 'Pullups');
    expect(w.nextInRound(pullup), isNull);
    await db.workoutsDao.tickSet(bench.id, done: true);
    w = await db.active();
    final ticked = w.lastTicked!;
    expect(
      w.restEndAt(DateTime.now()),
      Duration(milliseconds: ticked.completedClockMillis!),
    );
    await db.workoutsDao.tickSet(pullup.id, done: true);
    w = await db.active();
    expect(
      w.restEndAt(DateTime.now()),
      Duration(milliseconds: w.lastTicked!.completedClockMillis!) +
          const Duration(minutes: 3),
    );

    // Moving the pushdown earlier moves it past the whole superset.
    await db.workoutsDao.moveExercise(w.exercises[2].entry.id, -1);
    w = await db.active();
    expect(
      [for (final e in w.exercises) e.exercise.name],
      ['Triceps Pushdown', 'Barbell Bench Press', 'Pullups'],
    );
    expect(
      [for (final e in w.exercises) e.entry.supersetWithPrevious],
      [false, false, true],
    );

    // Removing the bench leaves pull-ups on a page of their own.
    await db.workoutsDao.removeExercise(w.exercises[1].entry.id);
    w = await db.active();
    expect(w.exercises.last.entry.supersetWithPrevious, isFalse);

    // Superset with next, then leave again.
    await db.workoutsDao.supersetWithNext(w.exercises[0].entry.id);
    w = await db.active();
    expect(w.exercises[1].entry.supersetWithPrevious, isTrue);
    await db.workoutsDao.leaveSuperset(w.exercises[1].entry.id);
    w = await db.active();
    expect(w.exercises[1].entry.supersetWithPrevious, isFalse);
  });

  test('a routine\'s number of sets: warm-ups stay, working sets follow '
      'the target, last time\'s values are copied', () async {
    final ids = await exerciseIds(db);
    final bench = ids['Barbell Bench Press']!;
    final squat = ids['Barbell Squat']!;

    // Last time: bench = warm-up 40 × 10, then 60 × 9, 60 × 8.
    final first = await db.startWith([bench]);
    var entry = (await db.active()).exercises.single;
    await db.workoutsDao.updateSet(
      entry.sets.single.id,
      const SetsCompanion(
        kind: Value(SetKind.warmup),
        weightKg: Value(40),
        reps: Value(10),
      ),
    );
    for (final reps in [9, 8]) {
      await db.workoutsDao.addSet(entry.entry.id);
      entry = (await db.active()).exercises.single;
      await db.workoutsDao.updateSet(
        entry.sets.last.id,
        SetsCompanion(weightKg: const Value(60), reps: Value(reps)),
      );
    }
    await tickAll();
    await db.workoutsDao.finishWorkout(first);

    Future<List<(bool, double?, int?)>> startWith(
      int? benchSets, {
      bool warmup = false,
    }) async {
      final routine = await db.routinesDao.saveRoutine(
        name: 'R',
        exerciseIds: [bench, squat],
        sets: [benchSets, 3],
        warmup: [warmup, true],
      );
      final session = await db.workoutsDao.startWorkout(routineId: routine);
      final w = await db.active();
      // Squat was never done: an empty warm-up and three empty sets.
      expect(
        [for (final s in w.exercises[1].sets) (s.isWarmup, s.weightKg)],
        [(true, null), (false, null), (false, null), (false, null)],
      );
      final rows = [
        for (final s in w.exercises[0].sets) (s.isWarmup, s.weightKg, s.reps),
      ];
      await db.workoutsDao.discardWorkout(session);
      return rows;
    }

    expect(await startWith(null), [
      (true, 40.0, 10),
      (false, 60.0, 9),
      (false, 60.0, 8),
    ]);
    expect(await startWith(1), [(false, 60.0, 9)]);
    expect(await startWith(1, warmup: true), [
      (true, 40.0, 10),
      (false, 60.0, 9),
    ]);
    expect(await startWith(4, warmup: true), [
      (true, 40.0, 10),
      (false, 60.0, 9),
      (false, 60.0, 8),
      (false, 60.0, 8),
      (false, 60.0, 8),
    ]);
  });

  test('a first workout gets one empty set per exercise', () async {
    final ids = await exerciseIds(db);
    final routineId = await db.routinesDao.saveRoutine(
      name: 'Push',
      exerciseIds: [ids['Barbell Bench Press']!, ids['Pullups']!],
    );
    await db.workoutsDao.startWorkout(routineId: routineId);

    final w = await db.active();
    expect(w.title, 'Push');
    expect(
      [for (final e in w.exercises) e.exercise.name],
      ['Barbell Bench Press', 'Pullups'],
    );
    expect(w.exercises[0].sets.single.loadType, LoadType.weight);
    expect(w.exercises[1].sets.single.loadType, LoadType.bodyweight);
    expect(w.exercises[0].previous, isNull);
  });

  test('finish keeps ticked sets; next workout pre-fills from it', () async {
    final ids = await exerciseIds(db);
    final bench = ids['Barbell Bench Press']!;
    final sessionId = await db.startWith([bench]);

    var entry = (await db.active()).exercises.single;
    await db.workoutsDao.updateSet(
      entry.sets.single.id,
      const SetsCompanion(weightKg: Value(60), reps: Value(10)),
    );
    await db.workoutsDao.addSet(entry.entry.id); // copies 60 × 10
    await db.workoutsDao.addSet(entry.entry.id);
    entry = (await db.active()).exercises.single;
    expect(
      [for (final s in entry.sets) (s.weightKg, s.reps)],
      [(60.0, 10), (60.0, 10), (60.0, 10)],
    );

    // Tick two of three; the third is dropped on finish.
    for (final s in entry.sets.take(2)) {
      await db.workoutsDao.updateSet(
        s.id,
        SetsCompanion(completedAt: Value(DateTime.now())),
      );
    }
    expect(await db.workoutsDao.finishWorkout(sessionId), isTrue);
    expect(await db.workoutsDao.activeWorkout(), isNull);

    final previous = (await db.historyDao.previousSets(bench))!;
    expect(previous.sets, hasLength(2));

    await db.startWith([bench]);
    final again = (await db.active()).exercises.single;
    expect(again.previous!.sets, hasLength(2));
    expect(
      [for (final s in again.sets) (s.weightKg, s.reps, s.completedAt)],
      [(60.0, 10, null), (60.0, 10, null)],
    );
  });

  test(
    'history lists finished workouts with their exercises and sets',
    () async {
      final ids = await exerciseIds(db);
      final sessionId = await db.startWith([
        ids['Barbell Squat']!,
        ids['Pullups']!,
      ]);
      var entries = (await db.active()).exercises;
      await db.workoutsDao.addSet(entries.first.entry.id);
      expect(
        await db.historyDao.workoutHistory(),
        isEmpty,
      ); // still in progress

      await tickAll();
      await db.workoutsDao.finishWorkout(sessionId);
      // A new one in progress is not history either.
      await db.workoutsDao.startWorkout();

      final history = await db.historyDao.workoutHistory();
      expect(history, hasLength(1));
      expect(history.single.title, 'Workout');
      expect(history.single.exerciseNames, ['Barbell Squat', 'Pullups']);
      expect(history.single.setCount, 3);

      final log = (await db.historyDao.workoutLog(sessionId))!;
      expect(
        [for (final e in log.exercises) e.exercise.name],
        ['Barbell Squat', 'Pullups'],
      );
      expect([for (final e in log.exercises) e.sets.length], [2, 1]);
      expect(await db.historyDao.workoutLog(sessionId + 100), isNull);
    },
  );

  test('finishing with nothing ticked discards the workout', () async {
    final ids = await exerciseIds(db);
    final sessionId = await db.startWith([ids['Barbell Squat']!]);
    expect(await db.workoutsDao.finishWorkout(sessionId), isFalse);
    expect(await db.select(db.sessions).get(), isEmpty);
  });

  test('ticking a set records the workout-clock reading', () async {
    final ids = await exerciseIds(db);
    final sessionId = await db.startWith([ids['Barbell Squat']!]);
    // Clock at 14:03, paused, so the reading is exact.
    await db.setClock(sessionId, (14 * 60 + 3) * 1000);
    final set = (await db.active()).exercises.single.sets.single;

    await db.workoutsDao.tickSet(set.id, done: true);
    var w = await db.active();
    var ticked = w.exercises.single.sets.single;
    expect(ticked.completedAt, isNotNull);
    expect(ticked.completedClockMillis, (14 * 60 + 3) * 1000);
    expect(w.lastTicked?.id, set.id);
    // Working set, default rest: next set at 17:03.
    expect(
      ticked.restEndOn(const Duration(hours: 1)),
      const Duration(minutes: 17, seconds: 3),
    );

    await db.workoutsDao.tickSet(set.id, done: false);
    w = await db.active();
    ticked = w.exercises.single.sets.single;
    expect((ticked.completedAt, ticked.completedClockMillis), (null, null));
    expect(w.lastTicked, isNull);
  });

  test('the first tick starts a clock that was never started', () async {
    final ids = await exerciseIds(db);
    final sessionId = await db.startWith([ids['Barbell Squat']!]);
    await db.workoutsDao.addSet((await db.active()).exercises.single.entry.id);
    final sets = (await db.active()).exercises.single.sets;

    await db.workoutsDao.tickSet(sets[0].id, done: true);
    var w = await db.active();
    expect(w.session.clockRunningSince, isNotNull);
    expect(w.lastTicked!.completedClockMillis, 0);
    expect(w.restLeft(DateTime.now())!.inSeconds, inInclusiveRange(178, 180));

    // A clock the user paused stays paused on the next tick, and the rest
    // stands still with it.
    await db.workoutsDao.toggleClock(sessionId);
    // Paused at exactly 1:00, so the tick below has a definite reading.
    await db.setClock(sessionId, 60000);
    await db.workoutsDao.tickSet(sets[1].id, done: true);
    w = await db.active();
    expect(w.session.clockRunningSince, isNull);
    final left = w.restLeft(DateTime.now());
    expect(w.restLeft(DateTime.now().add(const Duration(minutes: 5))), left);

    // A reset puts the tick ahead of the clock: that rest is over.
    await db.workoutsDao.resetClock(sessionId);
    w = await db.active();
    expect(w.restLeft(DateTime.now()), isNull);
  });

  test('rest defaults by kind and is copied from last time', () async {
    final ids = await exerciseIds(db);
    final bench = ids['Barbell Bench Press']!;
    final sessionId = await db.startWith([bench]);
    var entry = (await db.active()).exercises.single;
    final warmup = entry.sets.single;
    await db.workoutsDao.updateSet(
      warmup.id,
      const SetsCompanion(kind: Value(SetKind.warmup), reps: Value(10)),
    );
    entry = (await db.active()).exercises.single;
    expect(entry.sets.single.restFor(), const Duration(minutes: 1));

    // A working set copied from a warm-up gets the working default, then a
    // custom 2:30 rest.
    await db.workoutsDao.updateSet(
      warmup.id,
      const SetsCompanion(restSeconds: Value(45)),
    );
    await db.workoutsDao.addSet(entry.entry.id);
    entry = (await db.active()).exercises.single;
    expect(entry.sets.last.restFor(), const Duration(minutes: 3));
    await db.workoutsDao.updateSet(
      entry.sets.last.id,
      const SetsCompanion(restSeconds: Value(150)),
    );
    await tickAll();
    await db.workoutsDao.finishWorkout(sessionId);

    await db.startWith([bench]);
    final again = (await db.active()).exercises.single;
    expect([for (final s in again.sets) s.restFor().inSeconds], [45, 150]);
  });

  test('drop sets: straight on, and they come back next time', () async {
    final ids = await exerciseIds(db);
    final bench = ids['Barbell Bench Press']!;
    final sessionId = await db.startWith([bench]);
    var entry = (await db.active()).exercises.single;
    await db.workoutsDao.addSet(entry.entry.id);
    await db.workoutsDao.addSet(entry.entry.id);
    entry = (await db.active()).exercises.single;
    await db.workoutsDao.updateSet(
      entry.sets[2].id,
      const SetsCompanion(kind: Value(SetKind.drop)),
    );
    // Clock at 14:03, paused, so the reading is exact.
    await db.setClock(sessionId, (14 * 60 + 3) * 1000);

    // Set 1 rests as usual; set 2 is followed by the drop: no rest.
    await db.workoutsDao.tickSet(entry.sets[0].id, done: true);
    var w = await db.active();
    expect(
      w.restEndAt(DateTime.now()),
      const Duration(minutes: 17, seconds: 3),
    );
    await db.workoutsDao.tickSet(entry.sets[1].id, done: true);
    w = await db.active();
    expect(w.dropFollows(w.lastTicked!), isTrue);
    expect(
      w.restEndAt(DateTime.now()),
      const Duration(minutes: 14, seconds: 3),
    );
    expect(setLabels(w.exercises.single.sets), ['1', '2', 'D']);
    await db.workoutsDao.updateSet(
      entry.sets[1].id,
      const SetsCompanion(kind: Value(SetKind.failure)),
    );
    w = await db.active();
    expect(setLabels(w.exercises.single.sets), ['1', '2F', 'D']);

    await tickAll();
    await db.workoutsDao.finishWorkout(sessionId);
    await db.startWith([bench]);
    entry = (await db.active()).exercises.single;
    expect(
      [for (final s in entry.sets) s.kind],
      [SetKind.normal, SetKind.failure, SetKind.drop],
    );
    // A set beyond last time's is a normal one, even after a drop.
    await db.workoutsDao.addSet(entry.entry.id);
    entry = (await db.active()).exercises.single;
    expect(entry.sets.last.kind, SetKind.normal);
  });

  test('routine last-done date updates after finishing', () async {
    final ids = await exerciseIds(db);
    final routineId = await db.routinesDao.saveRoutine(
      name: 'Legs',
      exerciseIds: [ids['Barbell Squat']!],
    );
    expect(await db.routinesDao.watchRoutineLastDone().first, isEmpty);
    final sessionId = await db.workoutsDao.startWorkout(routineId: routineId);
    final set = (await db.active()).exercises.single.sets.single;
    await db.workoutsDao.updateSet(set.id, const SetsCompanion(reps: Value(5)));
    await tickAll();
    await db.workoutsDao.finishWorkout(sessionId);
    expect((await db.routinesDao.watchRoutineLastDone().first).keys, [
      routineId,
    ]);
  });

  test('clock starts paused, runs, and banks time when paused', () async {
    final sessionId = await db.workoutsDao.startWorkout();
    var w = await db.active();
    expect(w.session.clockRunningSince, isNull);
    expect(w.clockAt(DateTime.now()), Duration.zero);

    await db.workoutsDao.toggleClock(sessionId);
    w = await db.active();
    expect(w.session.clockRunningSince, isNotNull);
    final later = DateTime.now().add(const Duration(minutes: 5));
    expect(w.clockAt(later).inMinutes, 5);

    await db.workoutsDao.toggleClock(sessionId);
    w = await db.active();
    expect(w.session.clockRunningSince, isNull);
  });

  test('resetting a running clock keeps it running from zero', () async {
    final sessionId = await db.workoutsDao.startWorkout();
    // Whole seconds: drift stores date-times as Unix seconds.
    final now = DateTime.now();
    final runningSince = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute - 7,
      now.second,
    );
    await db.setClock(sessionId, 120000, runningSince: runningSince);

    await db.workoutsDao.resetClock(sessionId);
    final w = await db.active();
    expect(w.session.clockMillis, 0);
    expect(w.session.clockRunningSince, isNotNull);
    expect(w.clockAt(DateTime.now()).inMinutes, 0);
  });

  test('pausing banks the clock to the millisecond', () async {
    final sessionId = await db.workoutsDao.startWorkout();
    final since = DateTime.now().subtract(const Duration(milliseconds: 1500));
    await db.setClock(sessionId, 250, runningSince: since);
    await db.workoutsDao.toggleClock(sessionId);
    final banked = (await db.active()).session.clockMillis;
    // 0.25 s banked + ~1.5 s run; whole seconds would have lost the 0.75 s.
    expect(banked, inInclusiveRange(1750, 2500));
  });

  test('resetting a paused clock leaves it paused at zero', () async {
    final sessionId = await db.workoutsDao.startWorkout();
    await db.setClock(sessionId, 300000);

    await db.workoutsDao.resetClock(sessionId);
    final w = await db.active();
    expect(w.session.clockMillis, 0);
    expect(w.session.clockRunningSince, isNull);
  });
}
