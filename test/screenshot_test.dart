// Renders app screens with sample data to PNG files, for design reviews
// without a phone or the desktop build. Skipped unless SCREENSHOT_DIR is set:
//   SCREENSHOT_DIR=/some/dir flutter test test/screenshot_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show InsertMode, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/app.dart';
import 'package:gym_tracker/data/database.dart';
import 'package:gym_tracker/data/providers.dart';
import 'package:gym_tracker/features/exercises/body_model/body_3d_screen.dart';
import 'package:gym_tracker/features/exercises/body_model/body_model.dart';
import 'package:gym_tracker/features/exercises/exercise_detail_screen.dart';
import 'package:gym_tracker/features/exercises/exercise_options_sheet.dart';
import 'package:gym_tracker/features/record/today_note_sheet.dart';
import 'package:gym_tracker/features/statistics/exercise_progress_view.dart';
import 'package:gym_tracker/features/statistics/workout_card.dart';
import 'package:gym_tracker/shared/theme.dart';

import 'test_db.dart';

final _dir = Platform.environment['SCREENSHOT_DIR'];

/// Real fonts instead of the test font's boxes.
Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(
        File(f).readAsBytes().then((b) => ByteData.sublistView(b)),
      );
    }
    await loader.load();
  }

  await load('TeXGyreSchola', [
    'assets/fonts/texgyreschola-regular.otf',
    'assets/fonts/texgyreschola-bold.otf',
  ]);
  final flutter = File(Platform.resolvedExecutable)
      .parent
      .parent
      .parent
      .parent
      .parent
      .parent
      .path;
  // flutter_math_fork's KaTeX fonts, from the package's folder.
  final packages = jsonDecode(
    File('.dart_tool/package_config.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final math = (packages['packages']! as List)
      .cast<Map<String, Object?>>()
      .firstWhere((p) => p['name'] == 'flutter_math_fork');
  final katex = Directory.fromUri(
    Uri.parse('${math['rootUri']}/lib/katex_fonts/fonts'),
  );
  final byFamily = <String, List<String>>{};
  for (final f in katex.listSync().whereType<File>()) {
    final family = f.uri.pathSegments.last.split('-').first;
    byFamily.putIfAbsent(family, () => []).add(f.path);
  }
  for (final MapEntry(key: family, value: files) in byFamily.entries) {
    await load('packages/flutter_math_fork/$family', files);
  }
  await load('MaterialIcons', [
    '$flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

/// A phone-sized screen with real fonts.
Future<void> _prepare(WidgetTester tester) async {
  await tester.runAsync(_loadFonts);
  tester.view
    ..physicalSize = const Size(412, 892)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// The boundary [_shoot] reads, around every screen.
final _key = GlobalKey();

/// The whole app on [db], or only [home] with the app's theme; [model] stands
/// in for the 3D body's asset.
Widget _app(AppDatabase db, {Widget? home, BodyModel? model}) =>
    RepaintBoundary(
      key: _key,
      child: ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          if (model != null)
            bodyModelProvider.overrideWith((ref) async => model),
        ],
        child: home == null
            ? const GymTrackerApp()
            : MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: buildTheme(),
                home: home,
              ),
      ),
    );

/// The desktop database (real history), or the file named by SCREENSHOT_DB
/// (a phone pull).
final _realDb = File(
  Platform.environment['SCREENSHOT_DB'] ??
      '${Platform.environment['HOME']}/Documents/gym_tracker.sqlite',
);

/// A copy of [_realDb], so the app's own stays as is.
AppDatabase _openRealCopy(String name) {
  final copy = File('$_dir/$name.sqlite');
  _realDb.copySync(copy.path);
  return AppDatabase(
    NativeDatabase(copy),
    loadCurated: () => File('assets/data/curated_muscles.json').readAsString(),
  );
}

/// Statistics → Exercises on one exercise.
Widget _progress(int exerciseId, ChartRange range, ProgressPlot plot) =>
    Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ExerciseProgressView(
        exerciseId: exerciseId,
        onPick: (_) {},
        range: range,
        onRange: (_) {},
        plot: plot,
        onPlot: (_) {},
      ),
    );

Future<void> _shoot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary =
        _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('$_dir/$name.png').writeAsBytes(png!.buffer.asUint8List());
  });
}

/// Lets the db streams deliver and the frames follow. The clock runs, so
/// pumpAndSettle would never settle.
Future<void> _settle(WidgetTester tester, [int n = 5]) async {
  for (var i = 0; i < n; i++) {
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('record page', skip: _dir == null, (tester) async {
    await _prepare(tester);

    final db = testDatabase();
    addTearDown(db.close);
    await tester.runAsync(() async {
      final ids = await exerciseIds(db);
      // Bench typed as plates per side on a 20 kg bar.
      await db.exercisesDao.setWeightCounting(
        ids['Barbell Bench Press']!,
        WeightCounting.perSide,
      );
      // Setup fields and a permanent note.
      await db.exercisesDao.addSetupField(
        ids['Barbell Bench Press']!,
        'Safeties',
        unit: 'hole',
        value: '4',
      );
      await db.exercisesDao.setExerciseNote(
        ids['Barbell Bench Press']!,
        'Rack by the window',
      );
      final routine = await db.routinesDao.saveRoutine(
        name: 'Upper body',
        exerciseIds: [
          ids['Barbell Bench Press']!,
          ids['Pullups']!,
          ids['Triceps Pushdown']!,
        ],
        superset: [false, true, false], // bench + pull-ups
      );
      // Last time: a warm-up and three working sets of bench press.
      final old = await db.workoutsDao.startWorkout(routineId: routine);
      final bench = (await db.workoutsDao.activeWorkout())!.exercises.first;
      await db.workoutsDao.updateSet(
        bench.sets.single.id,
        const SetsCompanion(
          kind: Value(SetKind.warmup),
          weightKg: Value(40),
          reps: Value(10),
        ),
      );
      for (final (kg, reps) in [(70.0, 8), (70.0, 7), (67.5, 8)]) {
        await db.workoutsDao.addSet(bench.entry.id);
        final last =
            (await db.workoutsDao.activeWorkout())!.exercises.first.sets.last;
        await db.workoutsDao.updateSet(
          last.id,
          SetsCompanion(weightKg: Value(kg), reps: Value(reps)),
        );
      }
      // … and pull-ups between them: BW × 8, 7, 6.
      final pullups = (await db.workoutsDao.activeWorkout())!.exercises[1];
      for (final (i, reps) in [8, 7, 6].indexed) {
        if (i > 0) await db.workoutsDao.addSet(pullups.entry.id);
        final last =
            (await db.workoutsDao.activeWorkout())!.exercises[1].sets.last;
        await db.workoutsDao.updateSet(
          last.id,
          SetsCompanion(reps: Value(reps)),
        );
      }
      for (final e in (await db.workoutsDao.activeWorkout())!.exercises.take(
        2,
      )) {
        for (final s in e.sets) {
          await db.workoutsDao.tickSet(s.id, done: true);
        }
      }
      await db.workoutsDao.finishWorkout(old);
      // Today: the warm-up and first working set are ticked.
      await db.workoutsDao.startWorkout(routineId: routine);
      final sets = (await db.workoutsDao.activeWorkout())!.exercises.first.sets;
      await db.workoutsDao.tickSet(sets[0].id, done: true);
      await db.workoutsDao.tickSet(sets[1].id, done: true);
    });

    await tester.pumpWidget(_app(db));
    await _settle(tester, 20);
    await _shoot(tester, 'record');

    // Scrolled down to the rounds.
    await tester.drag(find.byType(ListView).first, const Offset(0, -420));
    await tester.pump(const Duration(milliseconds: 500));
    await _shoot(tester, 'record_rounds');
    await tester.drag(find.byType(ListView).first, const Offset(0, 420));
    await tester.pump(const Duration(milliseconds: 500));

    // The last page, through the next button at the top.
    await tester.tap(find.text('Triceps Pushdown'));
    await _settle(tester);
    await _shoot(tester, 'record_2');

    // The workout menu with the Rest alert choices open.
    await tester.tap(find.byTooltip('Workout options'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Rest alert'));
    await tester.pump(const Duration(milliseconds: 300));
    await _shoot(tester, 'record_menu');

    // The exercise options sheet (Routines / Exercises → Edit).
    await tester.tapAt(const Offset(200, 800)); // closes the menu
    await tester.pump(const Duration(milliseconds: 300));
    // An incline exercise: its Incline row is there from the start.
    final incline = await tester.runAsync(
      () => db.exercisesDao.saveCustomExercise(
        name: 'Incline Dumbbell Press',
        equipment: 'dumbbell',
        targetMuscleIds: ['chest'],
      ),
    );
    showExerciseOptions(tester.element(find.byType(Scaffold).first), incline!);
    await _settle(tester);
    await _shoot(tester, 'exercise_options');

    // A cable exercise: its Pulley choice, set to double.
    await tester.tapAt(const Offset(200, 100)); // closes the options
    await tester.pump(const Duration(milliseconds: 300));
    final pushdown = await tester.runAsync(() async {
      final id = (await exerciseIds(db))['Triceps Pushdown']!;
      await db.exercisesDao.addSetupField(id, 'Pulley', value: 'Double');
      return id;
    });
    showExerciseOptions(tester.element(find.byType(Scaffold).first), pushdown!);
    await _settle(tester);
    await _shoot(tester, 'cable_options');

    // Today's note (Record → exercise ⋮ → Note for today).
    await tester.tapAt(const Offset(200, 100)); // closes the options
    await tester.pump(const Duration(milliseconds: 300));
    final item = await tester.runAsync(
      () async => (await db.workoutsDao.activeWorkout())!.exercises.first,
    );
    showTodayNote(tester.element(find.byType(Scaffold).first), item!);
    await _settle(tester);
    await _shoot(tester, 'today_note');

    // The routine editor with the superset.
    await tester.tapAt(const Offset(200, 100)); // closes the note
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(NavigationDestination, 'Routines'));
    await _settle(tester);
    await tester.tap(find.text('Upper body'));
    await _settle(tester);
    await _shoot(tester, 'routine_superset');

    // Dragging the pushdown: onto the bench press, then between rows.
    Finder tile(String name) => find.widgetWithText(ListTile, name).first;
    final drag = await tester.startGesture(
      tester.getCenter(
        find.descendant(
          of: tile('Triceps Pushdown'),
          matching: find.byIcon(Icons.drag_handle),
        ),
      ),
    );
    await drag.moveBy(const Offset(0, -20));
    await tester.pump();
    // The finger stays over the handles, as on the phone.
    await drag.moveTo(
      Offset(30, tester.getCenter(tile('Barbell Bench Press')).dy),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await _shoot(tester, 'routine_drag_onto');
    await drag.moveTo(
      tester.getBottomLeft(tile('Barbell Bench Press')) + const Offset(20, 8),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await _shoot(tester, 'routine_drag_between');
    await drag.moveTo(
      tester.getTopLeft(tile('Barbell Bench Press')) + const Offset(20, -12),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await _shoot(tester, 'routine_drag_onto_block');
    await drag.moveTo(
      Offset(30, tester.getTopLeft(find.text('Superset')).dy - 14),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await _shoot(tester, 'routine_drag_above_block');
    await drag.cancel();
    await tester.pump(const Duration(milliseconds: 100));

    // Sets per exercise: the superset's ⋮, then one exercise's.
    await tester.tap(find.byTooltip('Superset options'));
    await _settle(tester, 6);
    await _shoot(tester, 'routine_superset_menu');
    await tester.tap(find.text('Sets'));
    await _settle(tester, 6);
    await tester.tap(find.text('W'));
    await _settle(tester, 6);
    await _shoot(tester, 'routine_sets_picker_w');
    await tester.tap(find.text('3'));
    await _settle(tester, 6);
    await tester.tap(find.byTooltip('Exercise options').last);
    await _settle(tester, 6);
    await tester.tap(find.text('Edit'));
    await _settle(tester);
    await tester.tap(find.text('4'));
    await _settle(tester, 6);
    await _shoot(tester, 'routine_edit_sets');
    await tester.tapAt(const Offset(200, 60)); // closes the sheet
    await _settle(tester, 6);
    await _shoot(tester, 'routine_sets');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });

  testWidgets('recording dot', skip: _dir == null, (tester) async {
    await _prepare(tester);

    final db = testDatabase();
    addTearDown(db.close);
    await tester.runAsync(() => db.workoutsDao.startWorkout());

    await tester.pumpWidget(_app(db));
    await _settle(tester, 20);
    await _shoot(tester, 'dot_on_record');

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Statistics'),
      ),
    );
    await _settle(tester, 6);
    await _shoot(tester, 'dot_on_other_tab');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });

  testWidgets('set types', skip: _dir == null, (tester) async {
    await _prepare(tester);

    final db = testDatabase();
    addTearDown(db.close);
    await tester.runAsync(() async {
      final ids = await exerciseIds(db);
      final session = await db.workoutsDao.startWorkout();
      await db.workoutsDao.addExercises(session, [ids['Triceps Pushdown']!]);
      // Warm-up, two sets (the second to failure), then two drops.
      final kinds = [
        (SetKind.warmup, 12.5, 10),
        (SetKind.normal, 20.0, 9),
        (SetKind.failure, 20.0, 8),
        (SetKind.drop, 15.0, 8),
        (SetKind.drop, 10.0, 10),
      ];
      for (final (i, (kind, kg, reps)) in kinds.indexed) {
        final entry = (await db.workoutsDao.activeWorkout())!.exercises.single;
        if (i > 0) await db.workoutsDao.addSet(entry.entry.id);
        final last =
            (await db.workoutsDao.activeWorkout())!.exercises.single.sets.last;
        await db.workoutsDao.updateSet(
          last.id,
          SetsCompanion(
            kind: Value(kind),
            weightKg: Value(kg),
            reps: Value(reps),
          ),
        );
      }
      final sets =
          (await db.workoutsDao.activeWorkout())!.exercises.single.sets;
      // All but the last drop ticked: a done row of every type.
      for (final s in sets.take(4)) {
        await db.workoutsDao.tickSet(s.id, done: true);
      }
    });

    await tester.pumpWidget(_app(db));
    await _settle(tester, 20);
    await _shoot(tester, 'set_types');

    // The type menu, opened from the failure set's label.
    await tester.tap(find.text('2F').first);
    await _settle(tester, 6);
    await _shoot(tester, 'set_types_menu');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });

  testWidgets('statistics calendar', skip: _dir == null, (tester) async {
    await _prepare(tester);

    final db = testDatabase();
    addTearDown(db.close);
    DateTime? latest;
    // About three workouts a week for a year, with a holiday gap and a few
    // skipped days, ending yesterday.
    await tester.runAsync(() async {
      // The test seed knows only a few muscles.
      await db.batch(
        (b) => b.insertAll(db.muscles, [
          for (final id in [
            'shoulders',
            'middle back',
            'hamstrings',
            'lower back',
            'abdominals',
          ])
            MusclesCompanion.insert(id: id, name: id),
        ], mode: InsertMode.insertOrIgnore),
      );
      final ids = {
        ...await exerciseIds(db),
        for (final (name, targets, synergists) in [
          ('Incline Dumbbell Press', ['chest'], ['shoulders', 'triceps']),
          ('Lateral Raise', ['shoulders'], <String>[]),
          ('Seated Cable Row', ['middle back'], ['lats', 'biceps']),
          ('Romanian Deadlift', ['hamstrings'], ['glutes', 'lower back']),
          ('Decline Crunch', ['abdominals'], <String>[]),
        ])
          name: await db.exercisesDao.saveCustomExercise(
            name: name,
            targetMuscleIds: targets,
            synergistMuscleIds: synergists,
          ),
      };
      Future<int> routine(String name) =>
          db.into(db.routines).insert(RoutinesCompanion.insert(name: name));
      final plans = [
        (
          await routine('Pull'),
          ['Pullups', 'Seated Cable Row', 'Decline Crunch'],
        ),
        (
          await routine('Push day, heavy'),
          [
            'Barbell Bench Press',
            'Incline Dumbbell Press',
            'Lateral Raise',
            'Triceps Pushdown',
          ],
        ),
        (
          await routine('Legs'),
          ['Barbell Squat', 'Romanian Deadlift', 'Decline Crunch'],
        ),
      ];
      // The last six weeks hold 3, 1, 2, 4, 5 and 6 workouts, newest first.
      const recent = [
        [1, 3, 5],
        [3],
        [1, 4],
        [1, 2, 4, 6],
        [1, 2, 3, 5, 6],
        [1, 2, 3, 4, 5, 6],
      ];
      final today = DateTime.now();
      final end = DateTime(today.year, today.month, today.day - 1);
      final monday = DateTime(
        today.year,
        today.month,
        today.day - today.weekday + 1,
      );
      for (var i = 0; i < 365; i++) {
        final d = DateTime(end.year, end.month, end.day - i);
        final week = (monday.difference(d).inHours / (24 * 7)).ceil();
        if (week < recent.length) {
          if (!recent[week].contains(d.weekday)) continue;
        } else if (i > 120 && i < 140 ||
            !const [1, 3, 5].contains(d.weekday) ||
            (i * 7) % 11 == 3) {
          continue;
        }
        latest ??= d;
        final start = d.add(const Duration(hours: 17));
        final (routine, names) = plans[d.weekday % 3];
        final session = await db
            .into(db.sessions)
            .insert(
              SessionsCompanion.insert(
                routineId: Value(routine),
                startedAt: start,
                endedAt: Value(start.add(const Duration(hours: 1))),
                clockMillis: Value(3_600_000 + i * 61_000 % 900_000),
              ),
            );
        for (final (p, name) in names.indexed) {
          final entry = await db
              .into(db.sessionExercises)
              .insert(
                SessionExercisesCompanion.insert(
                  sessionId: session,
                  exerciseId: ids[name]!,
                  position: p,
                ),
              );
          for (var k = 0; k < 3; k++) {
            await db
                .into(db.sets)
                .insert(
                  SetsCompanion.insert(
                    sessionExerciseId: entry,
                    position: k,
                    weightKg: const Value(40),
                    reps: const Value(10),
                    completedAt: Value(start),
                  ),
                );
          }
        }
      }
    });

    await tester.pumpWidget(_app(db));
    await _settle(tester);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Statistics'));
    await _settle(tester);
    await _shoot(tester, 'calendar_month');
    await tester.tap(find.text('${latest!.day}').first);
    await _settle(tester);
    await _shoot(tester, 'calendar_month_card');
    await tester.tap(find.bySemanticsLabel(RegExp('^Back view')).first);
    await _settle(tester);
    await _shoot(tester, 'calendar_workout_3d');
    await tester.tap(find.byType(BackButton));
    await _settle(tester);
    // The card's title opens the workout log; an exercise's figure, its 3D.
    await tester.tapAt(
      tester.getTopLeft(find.byType(WorkoutCard).first) + const Offset(24, 16),
    );
    await _settle(tester);
    await _shoot(tester, 'calendar_workout_log');
    await tester.tap(find.bySemanticsLabel(RegExp('^Front view')).first);
    await _settle(tester);
    await _shoot(tester, 'calendar_workout_log_3d');
    await tester.tap(find.byType(BackButton));
    await _settle(tester);
    await tester.tap(find.byType(BackButton));
    await _settle(tester);
    await tester.tap(find.text('Week'));
    await _settle(tester);
    for (var week = 0; week < 6; week++) {
      if (week > 0) {
        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pump(const Duration(milliseconds: 400));
        await _settle(tester);
      }
      await _shoot(tester, 'calendar_week_$week');
    }
    await tester.tap(find.text('Year'));
    await _settle(tester);
    await _shoot(tester, 'calendar_year');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
  testWidgets(
    'statistics exercises',
    skip: _dir == null || !_realDb.existsSync(),
    (tester) async {
      await _prepare(tester);
      final db = _openRealCopy('real');

      await tester.pumpWidget(_app(db));
      await _settle(tester);
      await tester.tap(
        find.widgetWithText(NavigationDestination, 'Statistics'),
      );
      await _settle(tester);
      await tester.tap(find.byTooltip('Show'));
      await _settle(tester);
      await _shoot(tester, 'stats_menu');

      for (final (name, range, plot) in [
        ('Incline Dumbbell Press', ChartRange.month3, ProgressPlot.oneRepMax),
        ('Incline Dumbbell Press', ChartRange.month3, ProgressPlot.volume),
        ('Incline Dumbbell Press', ChartRange.month3, ProgressPlot.sets),
        ('Barbell Curl', ChartRange.year1, ProgressPlot.oneRepMax),
      ]) {
        final id = (await tester.runAsync(() => exerciseIds(db)))![name]!;
        await tester.pumpWidget(_app(db, home: _progress(id, range, plot)));
        await _settle(tester);
        await _shoot(
          tester,
          'progress_${name.split(' ').first.toLowerCase()}_${range.label}_'
          '${plot.name}',
        );
      }

      await tester.tap(find.byTooltip('How is this calculated?'));
      await _settle(tester);
      await _shoot(tester, 'strength_info');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(Duration.zero);
      await tester.runAsync(db.close);
    },
  );

  testWidgets('exercise search', skip: _dir == null || !_realDb.existsSync(), (
    tester,
  ) async {
    await _prepare(tester);
    final db = _openRealCopy('real_search');
    // A filter chip by its option name, with or without a count after it.
    Finder chip(String name) => find
        .byWidgetPredicate(
          (w) =>
              w is FilterChip &&
              w.label is Text &&
              ((w.label as Text).data == name ||
                  (w.label as Text).data!.startsWith('$name  ')),
        )
        .last;
    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f);
      await _settle(tester);
      await tester.tap(f);
      await _settle(tester);
    }

    await tester.pumpWidget(_app(db));
    await _settle(tester);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Exercises'));
    await _settle(tester);
    await _shoot(tester, 'search_tab');
    await tap(find.text('Muscle'));
    await tap(chip('Chest'));
    await _shoot(tester, 'search_sheet');
    await tap(find.textContaining('Show '));
    await tap(find.text('Equipment'));
    await tap(chip('Dumbbell'));
    await tap(find.textContaining('Show '));
    await _shoot(tester, 'search_filtered');

    final id = (await tester.runAsync(
      () => exerciseIds(db),
    ))!['Incline Dumbbell Press']!;
    await tester.pumpWidget(
      _app(db, home: _progress(id, ChartRange.month3, ProgressPlot.oneRepMax)),
    );
    await _settle(tester);
    await tester.tap(find.text('Incline Dumbbell Press').first);
    await _settle(tester);
    await _shoot(tester, 'search_stats');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
    await tester.runAsync(db.close);
  });

  testWidgets('exercise muscles', skip: _dir == null || !_realDb.existsSync(), (
    tester,
  ) async {
    await _prepare(tester);
    final db = _openRealCopy('real_muscles');
    final model = BodyModel.parse(
      ByteData.sublistView(File(bodyModelAsset).readAsBytesSync()),
    );
    final id = (await tester.runAsync(
      () => exerciseIds(db),
    ))!['Incline Dumbbell Press']!;

    for (final (name, screen) in [
      ('exercise_detail', ExerciseDetailScreen(exerciseId: id)),
      ('exercise_3d_front', Body3dScreen.exercise(exerciseId: id, back: false)),
      ('exercise_3d_back', Body3dScreen.exercise(exerciseId: id, back: true)),
    ]) {
      await tester.pumpWidget(_app(db, home: screen, model: model));
      await _settle(tester, 10);
      await _shoot(tester, name);
      if (name == 'exercise_3d_front') {
        // The legend hides colours: no fixators, then the target alone.
        await tester.tap(find.text('Fixator'));
        await _settle(tester, 10);
        await _shoot(tester, 'exercise_3d_no_fixators');
        await tester.tap(find.text('Synergist'));
        await _settle(tester, 10);
        await _shoot(tester, 'exercise_3d_target_only');
      }
      if (name == 'exercise_detail') {
        await tester.tap(find.text('More information'));
        await _settle(tester, 10);
        await _shoot(tester, 'exercise_detail_more');
      }
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
    await tester.runAsync(db.close);
  });

  // The README's pictures (docs/screenshots), from a phone pull:
  //   SCREENSHOT_DB=<pull> SCREENSHOT_DIR=<dir> flutter test \
  //     test/screenshot_test.dart --plain-name readme
  testWidgets('readme', skip: _dir == null || !_realDb.existsSync(), (
    tester,
  ) async {
    await _prepare(tester);
    final db = _openRealCopy('real_readme');
    final model = BodyModel.parse(
      ByteData.sublistView(File(bodyModelAsset).readAsBytesSync()),
    );
    Future<void> tap(Finder f) async {
      await tester.tap(f);
      await _settle(tester, 10);
    }

    Future<void> tab(String name) =>
        tap(find.widgetWithText(NavigationDestination, name));

    await tester.pumpWidget(_app(db, model: model));
    await _settle(tester, 20);

    await tab('Routines');
    await _shoot(tester, 'routines');
    await tap(find.text('Upper body'));
    await _shoot(tester, 'routine');
    await tap(find.byType(BackButton));

    // October, a day of the week of 5 October, then that week.
    await tab('Statistics');
    await tap(find.byIcon(Icons.chevron_left));
    await tester.pump(const Duration(milliseconds: 400));
    await _settle(tester, 10);
    await tap(find.text('8').first);
    await _shoot(tester, 'statistics_month');
    await tap(find.text('Week'));
    await _shoot(tester, 'statistics_week');

    await tap(find.byTooltip('Show'));
    await tap(find.text('Exercises').first); // the menu's, not the tab's
    await tap(find.textContaining('workouts since'));
    await tap(find.text('Incline Dumbbell Press').last);
    await tap(find.text('Max'));
    await _shoot(tester, 'statistics_1rm');

    await tab('Exercises');
    await _shoot(tester, 'exercises');
    await tester.enterText(find.byType(TextField), 'Barbell Squat');
    await _settle(tester, 10);
    await tap(find.widgetWithText(ListTile, 'Barbell Squat').first);
    await _shoot(tester, 'exercise_squat');
    await tap(find.byType(BackButton));

    // A workout on the copy: the warm-up and first working set done.
    await tester.runAsync(() async {
      final routine = await db.select(db.routines).get();
      await db.workoutsDao.startWorkout(
        routineId: routine.firstWhere((r) => r.name == 'Upper body').id,
      );
      final sets = (await db.workoutsDao.activeWorkout())!.exercises.first.sets;
      for (final s in sets.take(2)) {
        await db.workoutsDao.tickSet(s.id, done: true);
      }
    });
    await tab('Record');
    await _settle(tester, 20);
    await _shoot(tester, 'record');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
    await tester.runAsync(db.close);
  });
}
