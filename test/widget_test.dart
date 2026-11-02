import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/features/routines/sets_picker.dart';
import 'package:gym_tracker/app.dart';
import 'package:gym_tracker/data/database.dart';
import 'package:gym_tracker/data/providers.dart';
import 'package:gym_tracker/features/exercises/body_model/body_view.dart';
import 'package:gym_tracker/features/exercises/exercise_detail_screen.dart';
import 'package:gym_tracker/shared/format.dart';
import 'package:gym_tracker/shared/theme.dart';

import 'test_db.dart';

/// Starts the app on a fresh test database and returns it.
Future<AppDatabase> _pumpApp(WidgetTester tester) async {
  final db = testDatabase();
  addTearDown(db.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const GymTrackerApp(),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}

/// Saves a routine, by default "Upper body day" with the bench press and
/// pull-ups. Returns its id.
Future<int> _addRoutine(
  WidgetTester tester,
  AppDatabase db, {
  String name = 'Upper body day',
  List<String> exercises = const ['Barbell Bench Press', 'Pullups'],
  List<bool> superset = const [],
}) async {
  final id = await tester.runAsync(() async {
    final ids = await exerciseIds(db);
    return db.routinesDao.saveRoutine(
      name: name,
      exerciseIds: [for (final e in exercises) ids[e]!],
      superset: superset,
    );
  });
  await tester.pumpAndSettle();
  return id!;
}

Finder _inDialog(String text) =>
    find.descendant(of: find.byType(AlertDialog), matching: find.text(text));

/// pumpAndSettle never settles while the workout clock runs (it redraws every
/// frame), so step through a second instead.
Future<void> _pumpRunning(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Bench: 60 kg × 10, ticked. The first Done starts the clock, so from here
/// until Finish the screen redraws every frame.
Future<void> _logFirstSet(WidgetTester tester) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), '60');
  await tester.enterText(fields.at(1), '10');
  await tester.pumpAndSettle();
  await tester.tap(find.byType(Checkbox).first);
  await _pumpRunning(tester);
}

/// Taps [finder] and lets the screen settle.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Drift cleans up stream queries on a zero-length timer; let it fire.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

void main() {
  testWidgets('shell shows five tabs and opens on Record', (tester) async {
    await _pumpApp(tester);

    for (final label in [
      'Routines',
      'Statistics',
      'Record',
      'Exercises',
      'Settings',
    ]) {
      expect(find.widgetWithText(NavigationDestination, label), findsOneWidget);
    }
    expect(find.text('Choose a routine'), findsOneWidget);

    await _tap(
      tester,
      find.widgetWithText(NavigationDestination, 'Statistics'),
    );
    expect(
      find.text('No workouts in ${monthName(DateTime.now())}'),
      findsOneWidget,
    );
    await _unmount(tester);
  });

  testWidgets('Record tab: red lamp while a workout is open', (tester) async {
    final db = await _pumpApp(tester);
    final lamp = find.byWidgetPredicate(
      (w) =>
          w is DecoratedBox &&
          w.decoration ==
              const BoxDecoration(
                color: recordingColour,
                shape: BoxShape.circle,
              ),
    );
    expect(lamp, findsNothing);

    final id = await tester.runAsync(() async {
      final id = await db.workoutsDao.startWorkout();
      await Future.delayed(const Duration(milliseconds: 50));
      return id;
    });
    await _pumpRunning(tester);
    expect(lamp, findsOneWidget);

    await tester.runAsync(() async {
      await db.workoutsDao.finishWorkout(id!);
      await Future.delayed(const Duration(milliseconds: 50));
    });
    await _pumpRunning(tester);
    expect(lamp, findsNothing);
    await _unmount(tester);
  });

  testWidgets('create a routine from the library', (tester) async {
    final db = await _pumpApp(tester);
    await _tap(tester, find.widgetWithText(NavigationDestination, 'Routines'));
    expect(find.textContaining('No routines yet.'), findsOneWidget);

    await _tap(tester, find.byTooltip('New routine'));
    await _tap(tester, find.text('Add exercises'));

    await tester.enterText(find.byType(TextField), 'bar');
    await tester.pumpAndSettle();
    expect(find.text('Triceps Pushdown'), findsNothing);
    await tester.tap(find.text('Barbell Squat'));
    await tester.tap(find.text('Barbell Bench Press'));
    await tester.pump();
    await _tap(tester, find.text('Add (2)'));

    expect(find.text('Barbell Squat'), findsOneWidget);

    // ⋮ → Edit: the squat's options, saved right away.
    await _tap(tester, find.byTooltip('Exercise options').first);
    await _tap(tester, find.text('Edit'));
    expect(find.text('Weight counted as'), findsOneWidget);
    await _tap(tester, find.text('Per side'));
    expect(find.text('Bar weight'), findsOneWidget);
    final squat = await tester.runAsync(
      () async => (await db.exercisesDao.exerciseCatalog())
          .firstWhere((c) => c.exercise.name == 'Barbell Squat')
          .exercise,
    );
    expect(squat!.counting, WeightCounting.perSide);
    await tester.tapAt(const Offset(10, 10)); // closes the sheet
    await tester.pumpAndSettle();

    // Swap the squat for the pushdown via ⋮ → Change exercise.
    await _tap(tester, find.byTooltip('Exercise options').first);
    await _tap(tester, find.text('Change exercise'));
    await tester.tap(find.text('Triceps Pushdown'));
    await tester.pump();
    await _tap(tester, find.text('Add (1)'));
    expect(find.text('Barbell Squat'), findsNothing);
    expect(find.text('Triceps Pushdown'), findsOneWidget);

    // ⋮ → Remove drops the bench press.
    await _tap(tester, find.byTooltip('Exercise options').last);
    await _tap(tester, find.text('Remove'));
    expect(find.text('Barbell Bench Press'), findsNothing);
    await _tap(tester, find.text('Save'));

    expect(find.text('Routine 1'), findsOneWidget);
    expect(find.text('1 exercise'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('delete a routine from its page, then undo', (tester) async {
    await _addRoutine(tester, await _pumpApp(tester));
    await _tap(tester, find.widgetWithText(NavigationDestination, 'Routines'));
    expect(find.byTooltip('New routine'), findsOneWidget);
    await _tap(tester, find.text('Upper body day'));

    await _tap(tester, find.byTooltip('Delete routine'));
    expect(find.text('Deleted "Upper body day"'), findsOneWidget);
    expect(find.textContaining('No routines yet.'), findsOneWidget);

    await _tap(tester, find.text('Undo'));
    expect(find.text('Upper body day'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('routine editor: drag to superset, out again, move a block', (
    tester,
  ) async {
    final db = await _pumpApp(tester);
    final routine = await _addRoutine(
      tester,
      db,
      exercises: ['Barbell Bench Press', 'Pullups', 'Triceps Pushdown'],
    );
    await _tap(tester, find.widgetWithText(NavigationDestination, 'Routines'));
    await _tap(tester, find.text('Upper body day'));

    Finder row(String name) => find.widgetWithText(ListTile, name).first;
    Finder handle(String name) => find.descendant(
      of: row(name),
      matching: find.byIcon(Icons.drag_handle),
    );
    // Drags [from] to [to]; [whileHovering] runs before letting go.
    Future<void> drag(
      Finder from,
      Offset to, [
      void Function()? whileHovering,
    ]) async {
      final gesture = await tester.startGesture(tester.getCenter(from));
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump();
      await gesture.moveTo(to);
      await tester.pump();
      whileHovering?.call();
      await gesture.up();
      await tester.pumpAndSettle();
    }

    // The bench press onto the middle of the pushdown: a superset.
    await drag(
      handle('Barbell Bench Press'),
      tester.getCenter(row('Triceps Pushdown')),
      () {
        expect(find.text('Superset with Triceps Pushdown'), findsOneWidget);
      },
    );
    expect(find.text('Superset'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(
      tester.getTopLeft(row('Barbell Bench Press')).dy,
      greaterThan(tester.getTopLeft(row('Triceps Pushdown')).dy),
    );

    // Dragged out below everything: it leaves, and so the superset is gone.
    await drag(
      handle('Barbell Bench Press'),
      tester.getCenter(find.text('Add exercises')),
      () => expect(find.text('Move here'), findsOneWidget),
    );
    expect(find.text('Superset'), findsNothing);

    // Pull-ups + pushdown, then the whole block below the bench press.
    await drag(handle('Triceps Pushdown'), tester.getCenter(row('Pullups')));
    expect(find.text('Superset'), findsOneWidget);
    final blockHandle = find.byIcon(Icons.drag_handle).first;
    final benchBottom = tester.getBottomLeft(row('Barbell Bench Press')).dy;
    await drag(blockHandle, Offset(200, benchBottom - 4));

    await _tap(tester, find.text('Save'));
    final entries = await tester.runAsync(
      () => db.routinesDao.routineEntries(routine),
    );
    expect(
      [for (final e in entries!) e.exercise.name],
      ['Barbell Bench Press', 'Pullups', 'Triceps Pushdown'],
    );
    expect([for (final e in entries) e.superset], [false, false, true]);
    await _unmount(tester);
  });

  testWidgets('routine editor: sets per exercise, superset ⋮', (tester) async {
    final db = await _pumpApp(tester);
    final routine = await _addRoutine(
      tester,
      db,
      exercises: ['Barbell Bench Press', 'Pullups', 'Triceps Pushdown'],
      superset: [false, true, false],
    );
    await _tap(tester, find.widgetWithText(NavigationDestination, 'Routines'));
    await _tap(tester, find.text('Upper body day'));

    Future<void> pickSets(
      Finder menu,
      String choice, {
      bool toggleWarmup = false,
    }) async {
      await _tap(tester, menu);
      await _tap(tester, find.text('Sets'));
      if (toggleWarmup) {
        await tester.tap(find.text('W'));
        await tester.pump();
      }
      await _tap(tester, find.text(choice));
    }

    // One exercise's sets are in its Edit sheet, next to its options; they
    // apply as they are tapped.
    Future<void> editSets(Finder menu, String choice) async {
      await _tap(tester, menu);
      await _tap(tester, find.text('Edit'));
      expect(find.text('Sets in this routine'), findsOneWidget);
      await _tap(tester, find.text(choice));
      Navigator.of(tester.element(find.byType(SetsSelector))).pop();
      await tester.pumpAndSettle();
    }

    // The superset's ⋮ sets both members, with a warm-up; the pushdown gets
    // its own.
    await pickSets(find.byTooltip('Superset options'), '3', toggleWarmup: true);
    expect(find.text('barbell · W + 3 sets'), findsOneWidget);
    expect(find.text('body only · W + 3 sets'), findsOneWidget);
    await editSets(find.byTooltip('Exercise options').last, '4');
    expect(find.text('cable · 4 sets'), findsOneWidget);
    // Pull-ups back to "as last time": no count shown.
    await editSets(find.byTooltip('Exercise options').at(1), 'As last time');
    expect(find.text('body only'), findsOneWidget);

    await _tap(tester, find.byTooltip('Superset options'));
    await _tap(tester, find.text('Ungroup'));
    expect(find.text('Superset'), findsNothing);

    await _tap(tester, find.text('Save'));
    final entries = await tester.runAsync(
      () => db.routinesDao.routineEntries(routine),
    );
    expect(
      [for (final e in entries!) (e.superset, e.sets, e.warmup)],
      [(false, 3, true), (false, null, false), (false, 4, false)],
    );
    await _unmount(tester);
  });

  testWidgets('record a workout from a routine', (tester) async {
    final db = await _pumpApp(tester);
    await _addRoutine(tester, db);

    await _tap(tester, find.text('Upper body day'));
    // One exercise per page: bench first, pull-ups behind "Next".
    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(find.text('First time'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('BW'), findsNothing);
    expect(find.text('Tap Done when you finish a set'), findsOneWidget);

    await _logFirstSet(tester);
    // Under the clock, and in the ticked set's Rest column ("→17:03").
    expect(find.textContaining('Next set at'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^→\d')), findsOneWidget);
    // The only set's cell now shows the rest in progress, not "3:00".
    expect(find.text('3:00'), findsNothing);

    await tester.tap(find.text('Pullups')); // next ›
    await _pumpRunning(tester);
    expect(find.text('Pullups'), findsOneWidget);
    expect(find.text('BW'), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsOneWidget); // ‹ previous

    // The weight carries the load: blank = BW, +kg added, -kg assisted.
    Future<(LoadType, double?)> pullupLoad(String typed) async {
      await tester.enterText(find.byType(TextField).first, typed);
      await _pumpRunning(tester);
      final w = (await tester.runAsync(db.workoutsDao.activeWorkout))!;
      final s = w.exercises[1].sets.single;
      return (s.loadType, s.weightKg);
    }

    expect(await pullupLoad('10'), (LoadType.weighted, 10.0));
    expect(await pullupLoad('-20'), (LoadType.assisted, 20.0));
    expect(await pullupLoad(''), (LoadType.bodyweight, null));

    await tester.tap(find.text('Finish'));
    await _pumpRunning(tester);
    expect(find.text('1 unticked set will be discarded.'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Finish'),
      ),
    );
    await _pumpRunning(tester);
    expect(find.text('Workout saved.'), findsOneWidget);
    expect(find.text('Choose a routine'), findsOneWidget);
    expect(find.textContaining('last: '), findsOneWidget);

    // The next time shows last time's sets in the Previous column; tapping
    // one copies it back after an edit.
    await _tap(tester, find.text('Upper body day'));
    expect(
      find.byWidgetPredicate(
        (w) => w is Tooltip && w.message!.startsWith('Last time: '),
      ),
      findsOneWidget,
    );
    expect(find.text('60×10'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), '70');
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await _tap(tester, find.text('60×10'));
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
      '60',
    );
    await _unmount(tester);
  });
  testWidgets('countdown rest becomes the big number while resting', (
    tester,
  ) async {
    final db = await _pumpApp(tester);
    await _addRoutine(tester, db);
    await tester.runAsync(
      () => db.settingsDao.updateSettings(
        const SettingsTableCompanion(restStyle: Value(RestStyle.countdown)),
      ),
    );
    await _tap(tester, find.text('Upper body day'));
    await tester.enterText(find.byType(TextField).at(1), '10');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox).first);
    // The countdown redraws every frame: no pumpAndSettle while it runs.
    await _pumpRunning(tester);

    // Big number: the rest (3:00 counting down), the only timer shown.
    expect(find.text('Rest left'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is Text && RegExp(r'^2:5\d$').hasMatch(w.data ?? ''),
      ),
      findsOneWidget,
    );
    expect(find.text('…'), findsOneWidget); // its Rest column
    await _unmount(tester);
  });

  testWidgets('reset the workout clock', (tester) async {
    // Phone-sized screen, so the big clock (2:46:40) must fit in 412 px.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final db = await _pumpApp(tester);

    bool resetEnabled() =>
        tester
            .widget<ButtonStyleButton>(
              find.ancestor(
                of: find.text('Reset'),
                matching: find.bySubtype<ButtonStyleButton>(),
              ),
            )
            .onPressed !=
        null;

    await _tap(tester, find.text('Start empty workout'));
    expect(find.text('0:00'), findsOneWidget);
    expect(find.text('.00'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(resetEnabled(), isFalse);

    // A long paused workout: 2 h 46 min 40 s.
    await tester.runAsync(() async {
      await db.setClock((await db.active()).session.id, 10000000);
    });
    await tester.pumpAndSettle();
    expect(find.text('2:46:40'), findsOneWidget);

    expect(find.text('Resume'), findsOneWidget);
    expect(resetEnabled(), isTrue);
    await _tap(tester, find.text('Reset'));
    expect(find.text('0:00'), findsOneWidget);
    expect(find.text('Undo'), findsNothing); // no snackbar
    expect(resetEnabled(), isFalse);
    expect(find.byTooltip('Start clock'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('search the library and open an exercise', (tester) async {
    await _pumpApp(tester);
    await _tap(tester, find.widgetWithText(NavigationDestination, 'Exercises'));

    await tester.enterText(find.byType(TextField), 'pull-up');
    await tester.pumpAndSettle();
    expect(find.text('Barbell Squat'), findsNothing);
    await _tap(tester, find.text('Pullups'));

    expect(find.text('Body only'), findsOneWidget);
    // Coarse groups first; the roles only under More information.
    expect(find.text('Main: lats', findRichText: true), findsOneWidget);
    expect(find.text('Secondary: biceps', findRichText: true), findsOneWidget);
    expect(find.text('•  Lats'), findsNothing);
    expect(find.text('Target'), findsOneWidget); // the legend
    await _tap(tester, find.text('More information'));
    expect(find.text('Target'), findsNWidgets(2)); // + the role heading
    expect(find.text('•  Lats'), findsOneWidget);
    expect(find.text('•  Biceps'), findsOneWidget);
    expect(find.byType(BodyFigures), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Not done yet.'),
      200,
      scrollable: find.descendant(
        of: find.byType(ExerciseDetailScreen),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Not done yet.'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('create a custom exercise from the picker', (tester) async {
    await _pumpApp(tester);
    await _tap(tester, find.widgetWithText(NavigationDestination, 'Routines'));
    await _tap(tester, find.byTooltip('New routine'));
    await _tap(tester, find.text('Add exercises'));

    await tester.enterText(find.byType(TextField), 'Landmine Press');
    await tester.pumpAndSettle();
    expect(find.text('No matching exercises.'), findsNothing);
    await _tap(tester, find.text('Create “Landmine Press”'));

    // Saving without a target muscle is refused.
    await _tap(tester, find.text('Save'));
    expect(find.text('Pick at least one target muscle.'), findsOneWidget);

    await tester.tap(find.text('Chest').first);
    await tester.tap(find.text('Triceps').last);
    await tester.pump();
    await _tap(tester, find.text('Save'));

    // Back in the picker with the new exercise ticked.
    expect(find.text('Add (1)'), findsOneWidget);
    expect(find.text('Chest · custom'), findsOneWidget);
    await _tap(tester, find.text('Add (1)'));
    expect(find.text('Landmine Press'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('back during a workout: Cancel stays, Pause hides it', (
    tester,
  ) async {
    final db = await _pumpApp(tester);
    await _addRoutine(tester, db);
    await _tap(tester, find.text('Upper body day'));
    await tester.tap(find.byTooltip('Start clock'));
    await tester.pump();

    // Android back reaches the Record branch and asks; Cancel stays.
    await tester.binding.handlePopRoute();
    await _pumpRunning(tester);
    expect(find.text('Leave workout?'), findsOneWidget);
    await tester.tap(_inDialog('Cancel'));
    await _pumpRunning(tester);
    expect(find.text('Leave workout?'), findsNothing);
    expect(find.text('Barbell Bench Press'), findsOneWidget);

    // Pause: back to the chooser with a resume bar, clock paused.
    await tester.binding.handlePopRoute();
    await _pumpRunning(tester);
    await _tap(tester, _inDialog('Pause'));
    expect(find.text('Choose a routine'), findsOneWidget);
    expect(find.text('Resume workout'), findsOneWidget);
    expect(find.textContaining('Upper body day · '), findsOneWidget);
    final paused = await tester.runAsync(db.workoutsDao.activeWorkout);
    expect(paused!.session.clockRunningSince, isNull);

    // Starting another workout is refused while one is open.
    await _tap(tester, find.text('Start empty workout'));
    expect(find.text('Workout in progress'), findsOneWidget);
    await _tap(tester, _inDialog('Cancel'));
    expect(find.text('Resume workout'), findsOneWidget);

    await _tap(tester, find.text('Upper body day'));
    await _tap(tester, _inDialog('Resume'));
    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(find.text('Resume workout'), findsNothing);
    final resumed = await tester.runAsync(db.workoutsDao.activeWorkout);
    expect(resumed!.session.id, paused.session.id);

    // The resume bar itself also leads back.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await _tap(tester, _inDialog('Pause'));
    await _tap(tester, find.text('Resume workout'));
    expect(find.text('Barbell Bench Press'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('back, Finish: the workout is saved, in the calendar, opens', (
    tester,
  ) async {
    await _addRoutine(tester, await _pumpApp(tester));
    await _tap(tester, find.text('Upper body day'));
    await _logFirstSet(tester);
    await tester.binding.handlePopRoute();
    await _pumpRunning(tester);
    await tester.tap(_inDialog('Finish'));
    await _pumpRunning(tester);
    expect(find.text('1 unticked set will be discarded.'), findsOneWidget);
    await tester.tap(_inDialog('Finish'));
    await _pumpRunning(tester);
    expect(find.text('Workout saved.'), findsOneWidget);
    expect(find.text('Choose a routine'), findsOneWidget);
    expect(find.text('Resume workout'), findsNothing);

    await _tap(tester, find.text('Statistics'));
    expect(
      find.text('1 workout in ${monthName(DateTime.now())}'),
      findsOneWidget,
    );
    final now = DateTime.now();
    await _tap(tester, find.text('Week'));
    expect(find.text('Week ${isoWeek(now)}'), findsOneWidget);
    expect(find.text('1 workout', skipOffstage: false), findsOneWidget);
    expect(find.text('1 exercise'), findsOneWidget); // its column
    await _tap(tester, find.text('Year'));
    expect(find.text('${now.year}'), findsOneWidget);
    final month = find.text(monthName(now), skipOffstage: false);
    await tester.ensureVisible(month); // the year is taller than the screen
    await tester.pumpAndSettle();
    await _tap(tester, month); // opens the month
    expect(find.text(formatMonth(now)), findsOneWidget);

    // Today's cell (bold): the grid also shows the neighbouring months' days.
    await _tap(
      tester,
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            w.data == '${now.day}' &&
            w.style?.fontWeight == FontWeight.bold,
      ),
    );
    expect(find.text(formatDate(DateTime.now())), findsOneWidget);
    final card = find.textContaining('1 set', skipOffstage: false);
    await tester.ensureVisible(card); // below the calendar on a small screen
    await tester.pumpAndSettle();
    await _tap(tester, card);
    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(find.text('60×10'), findsOneWidget);

    await _tap(tester, find.byTooltip('Delete workout'));
    await _tap(tester, _inDialog('Delete'));
    expect(find.text('Workout deleted.'), findsOneWidget);
    expect(
      find.text('No workouts in ${monthName(DateTime.now())}'),
      findsOneWidget,
    );
    await _unmount(tester);
  });

  testWidgets('the year view stops where the month calendar does', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _tap(tester, find.text('Statistics'));
    await _tap(tester, find.text('Year'));
    final now = DateTime.now();
    Future<void> tapTimes(String tooltip, int times) async {
      for (var i = 0; i < times; i++) {
        await tester.tap(find.byTooltip(tooltip));
        await tester.pump();
      }
    }

    await tapTimes('Next year', 12);
    await _tap(tester, find.text('Month'));
    final last = now.year + 10;
    expect(find.text(formatMonth(DateTime(last, now.month))), findsOneWidget);

    await _tap(tester, find.text('Year'));
    await tapTimes('Previous year', last - 2000 + 2);
    await _tap(tester, find.text('Week'));
    await _tap(tester, find.text('Year'));
    expect(find.text('2000'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('switching to lb converts shown weights', (tester) async {
    final db = await _pumpApp(tester);
    await _addRoutine(
      tester,
      db,
      name: 'Bench day',
      exercises: ['Barbell Bench Press'],
    );
    await _tap(tester, find.text('Bench day'));
    await tester.enterText(find.byType(TextField).first, '100');
    await tester.pumpAndSettle();

    await _tap(tester, find.widgetWithText(NavigationDestination, 'Settings'));
    expect(find.text('kg · km · cm'), findsOneWidget);
    await _tap(tester, find.text('Units'));
    await _tap(tester, find.text('lb'));
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('lb · km · cm'), findsOneWidget);

    await _tap(tester, find.widgetWithText(NavigationDestination, 'Record'));
    expect(find.text('220.46'), findsOneWidget);
    final set = await tester.runAsync(() => db.select(db.sets).getSingle());
    expect(set!.weightKg, 100);
    await _unmount(tester);
  });

  testWidgets('Settings → Dates sets the first day of the week', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _tap(tester, find.widgetWithText(NavigationDestination, 'Settings'));
    expect(find.text('Week starts on Monday'), findsOneWidget);
    await _tap(tester, find.text('Dates'));
    await _tap(tester, find.text('Monday')); // opens the menu
    await _tap(tester, find.text('Sunday').last);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Week starts on Sunday'), findsOneWidget);

    await _tap(
      tester,
      find.widgetWithText(NavigationDestination, 'Statistics'),
    );
    // The calendar's weekday row now starts on Sunday.
    final sun = tester.getTopLeft(find.text('Sun')).dx;
    final mon = tester.getTopLeft(find.text('Mon')).dx;
    expect(sun, lessThan(mon));
    await _tap(tester, find.text('Week'));
    final now = DateTime.now();
    final sunday = DateTime(now.year, now.month, now.day - now.weekday % 7);
    expect(
      find.text('Week ${weekNumber(sunday, DateTime.sunday)}'),
      findsOneWidget,
    );
    await _unmount(tester);
  });

  testWidgets('Settings → Workout picks the rest alert', (tester) async {
    // Phone-sized screen, so the whole page fits.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final db = await _pumpApp(tester);

    await _tap(tester, find.widgetWithText(NavigationDestination, 'Settings'));
    expect(find.text('Timer · rest alert: vibration + sound'), findsOneWidget);
    await _tap(tester, find.text('Workout'));
    await _tap(tester, find.text('Vibration'));
    final settings = await tester.runAsync(
      () => db.settingsDao.watchSettings().first,
    );
    expect(settings!.restAlert, RestAlert.vibration);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Timer · rest alert: vibration'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('per side: type one side, the bar is added', (tester) async {
    final db = await _pumpApp(tester);
    await tester.runAsync(() async {
      final squat = (await exerciseIds(db))['Barbell Squat']!;
      await db.exercisesDao.setWeightCounting(squat, WeightCounting.perSide);
      await db.routinesDao.saveRoutine(name: 'Legs', exerciseIds: [squat]);
    });
    await tester.pumpAndSettle();
    await _tap(tester, find.text('Legs'));

    expect(find.text('Per side'), findsOneWidget); // column header
    expect(find.text('First time'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '30');
    await tester.pumpAndSettle();
    final set = await tester.runAsync(() => db.select(db.sets).getSingle());
    expect(set!.weightKg, 80);
    await _unmount(tester);
  });

  testWidgets('superset page: add / remove rounds, uneven sets from ⋮', (
    tester,
  ) async {
    final db = await _pumpApp(tester);
    await _addRoutine(
      tester,
      db,
      name: 'Superset day',
      superset: [false, true],
    );
    await _tap(tester, find.text('Superset day'));

    Future<List<int>> setCounts() async => [
      for (final e in (await tester.runAsync(
        db.workoutsDao.activeWorkout,
      ))!.exercises)
        e.sets.length,
    ];

    expect(await setCounts(), [1, 1]);
    await _tap(tester, find.text('Add round'));
    expect(await setCounts(), [2, 2]);
    await _tap(tester, find.text('Remove round'));
    expect(await setCounts(), [1, 1]);

    // Exercise A's menu: one more set for A only, then take it away again.
    await _tap(tester, find.byTooltip('Exercise options').first);
    await _tap(tester, find.text('Add set'));
    expect(await setCounts(), [2, 1]);
    await _tap(tester, find.byTooltip('Exercise options').first);
    await _tap(tester, find.text('Remove last set'));
    expect(await setCounts(), [1, 1]);

    // Removing every round disables Remove.
    await _tap(tester, find.text('Remove round'));
    expect(await setCounts(), [0, 0]);
    expect(
      tester
          .widget<ButtonStyleButton>(
            find.ancestor(
              of: find.text('Remove round'),
              matching: find.bySubtype<ButtonStyleButton>(),
            ),
          )
          .enabled,
      isFalse,
    );
    await _unmount(tester);
  });

  testWidgets('removing a ticked set asks first; unticked goes at once', (
    tester,
  ) async {
    final db = await _pumpApp(tester);
    await _addRoutine(tester, db);
    await _tap(tester, find.text('Upper body day'));

    Future<int> benchSets() async =>
        (await tester.runAsync(db.workoutsDao.activeWorkout))!
            .exercises
            .first
            .sets
            .length;

    // An unticked set: no question.
    await _tap(tester, find.text('Add set'));
    expect(await benchSets(), 2);
    await _tap(tester, find.text('Remove set'));
    expect(find.byType(AlertDialog), findsNothing);
    expect(await benchSets(), 1);

    // A ticked one: Cancel keeps it, Remove removes it.
    await _logFirstSet(tester);
    await tester.tap(find.text('Remove set'));
    await _pumpRunning(tester);
    expect(find.text('Remove a done set?'), findsOneWidget);
    expect(find.text('Set 1 (60×10) is ticked.'), findsOneWidget);
    await tester.tap(_inDialog('Cancel'));
    await _pumpRunning(tester);
    expect(await benchSets(), 1);

    // Swiping a ticked row asks the same (from the Previous column: the text
    // fields take horizontal drags themselves).
    await tester.dragFrom(
      tester.getTopLeft(find.byType(Dismissible).first) + const Offset(90, 20),
      const Offset(-600, 0),
    );
    await _pumpRunning(tester);
    expect(find.text('Remove a done set?'), findsOneWidget);
    await tester.tap(_inDialog('Cancel'));
    await _pumpRunning(tester);
    expect(await benchSets(), 1);

    await tester.tap(find.text('Remove set'));
    await _pumpRunning(tester);
    await tester.tap(_inDialog('Remove'));
    await _pumpRunning(tester);
    expect(await benchSets(), 0);
    await _unmount(tester);
  });
}
