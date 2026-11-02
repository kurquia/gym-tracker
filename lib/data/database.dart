import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';

import 'daos/exercises_dao.dart';
import 'daos/history_dao.dart';
import 'daos/routines_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/workouts_dao.dart';
import 'tables.dart';

export 'daos/exercises_dao.dart';
export 'daos/history_dao.dart';
export 'daos/routines_dao.dart';
export 'daos/settings_dao.dart';
export 'daos/workouts_dao.dart';
export 'progress.dart';
export 'tables.dart';
export 'workout_logic.dart';

part 'database.g.dart';

/// The database: its tables, migrations and seed. The queries live in the
/// DAOs, one per area (`db.routinesDao.watchRoutines()`).
@DriftDatabase(
  tables: [
    Muscles,
    Exercises,
    ExerciseMuscles,
    Routines,
    RoutineExercises,
    Sessions,
    SessionExercises,
    Sets,
    SettingsTable,
    SetupFields,
    SetupValues,
  ],
  daos: [SettingsDao, ExercisesDao, RoutinesDao, WorkoutsDao, HistoryDao],
)
class AppDatabase extends _$AppDatabase {
  /// [loadSeed] returns the exercises JSON (assets/data/exercises.json format),
  /// [loadCurated] the hand-checked muscles of some of them
  /// (assets/data/curated_muscles.json format).
  AppDatabase(
    super.executor, {
    Future<String> Function()? loadSeed,
    Future<String> Function()? loadCurated,
  }) : _loadSeed =
           loadSeed ??
           (() => rootBundle.loadString('assets/data/exercises.json')),
       _loadCurated =
           loadCurated ??
           (() => rootBundle.loadString('assets/data/curated_muscles.json'));

  /// The app's on-device database.
  /// Shared across isolates so the notification's Pause/Resume button (run
  /// in a background isolate) writes through the same connection and the
  /// open screens update at once.
  factory AppDatabase.open() => AppDatabase(
    driftDatabase(
      name: 'gym_tracker',
      native: const DriftNativeOptions(shareAcrossIsolates: true),
    ),
  );

  final Future<String> Function() _loadSeed;
  final Future<String> Function() _loadCurated;

  @override
  int get schemaVersion => 18;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seed();
    },
    onUpgrade: (m, from, to) async {
      // Older backups are refused (oldestSchema in backup.dart).
      // v13: a routine's number of sets per exercise.
      if (from < 13) await m.addColumn(routineExercises, routineExercises.sets);
      // v14: … and whether it starts with a warm-up.
      if (from < 14) {
        await m.addColumn(routineExercises, routineExercises.warmup);
      }
      // v15: Settings → Dates.
      if (from < 15) {
        await m.addColumn(settingsTable, settingsTable.firstWeekday);
      }
      // v16: Settings → Workout → Notification clock.
      if (from < 16) {
        await m.addColumn(settingsTable, settingsTable.notificationClock);
      }
      // v17: set types; the warm-up flag becomes a kind.
      if (from < 17) {
        await m.alterTable(
          TableMigration(
            sets,
            columnTransformer: {
              sets.kind: const CustomExpression<String>(
                "CASE WHEN is_warmup THEN 'warmup' ELSE 'normal' END",
              ),
            },
            newColumns: [sets.kind],
          ),
        );
      }
      // v18: the muscles of the incline dumbbell press are hand-checked
      // (curated_muscles.json, applied in beforeOpen); no table changes.
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await _applyCurated();
    },
  );

  Future<void> _seed() async {
    final data = jsonDecode(await _loadSeed()) as Map<String, dynamic>;
    final entries = (data['exercises'] as List).cast<Map<String, dynamic>>();

    final muscleIds = {
      for (final e in entries) ...[
        ...(e['primary'] as List).cast<String>(),
        ...(e['secondary'] as List).cast<String>(),
      ],
    };
    await batch((b) {
      b.insertAll(muscles, [
        for (final id in muscleIds)
          MusclesCompanion.insert(id: id, name: _titleCase(id)),
      ]);
      b.insertAll(exercises, [
        for (final e in entries)
          ExercisesCompanion.insert(
            sourceId: Value(e['id'] as String),
            name: e['name'] as String,
            equipment: Value(e['equipment'] as String?),
            category: Value(e['category'] as String?),
          ),
      ]);
    });

    final idBySource = {
      for (final row in await select(exercises).get()) row.sourceId: row.id,
    };
    await batch((b) {
      for (final e in entries) {
        final id = idBySource[e['id']]!;
        for (final (key, role) in [
          ('primary', MuscleRole.target),
          ('secondary', MuscleRole.synergist),
        ]) {
          b.insertAll(exerciseMuscles, [
            for (final m in (e[key] as List).cast<String>())
              ExerciseMusclesCompanion.insert(
                exerciseId: id,
                muscleId: m,
                role: role,
              ),
          ], mode: InsertMode.insertOrIgnore);
        }
      }
    });
  }

  /// The muscles of curated entry [sourceId] in curated_muscles.json's
  /// "exercises" map. An entry with "same_as" copies another entry's list;
  /// its own "muscles" then change a muscle's role or add one, and "remove"
  /// drops muscles by id.
  static List<({String id, MuscleRole role})> curatedMuscles(
    Map<String, Map> entries,
    String sourceId,
  ) {
    final entry = entries[sourceId]!;
    final own = [
      for (final m in (entry['muscles'] as List? ?? const []).cast<Map>())
        (id: m['id'] as String, role: MuscleRole.values.byName(m['role'])),
    ];
    final base = entry['same_as'] as String?;
    if (base == null) return own;
    final removed = (entry['remove'] as List? ?? const []).cast<String>();
    final changed = {for (final m in own) m.id: m};
    final inherited = [
      for (final m in curatedMuscles(entries, base))
        if (!removed.contains(m.id)) changed[m.id] ?? m,
    ];
    return [
      ...inherited,
      for (final m in own)
        if (!inherited.any((i) => i.id == m.id)) m,
    ];
  }

  /// The exercise of curated entry [sourceId]: the library one, or the custom
  /// one of that name (the imported history's Archer push-up has no source id;
  /// entry `Archer_push-up` is its name with underscores).
  Future<Exercise?> _curatedExercise(String sourceId) async {
    final library = await (select(
      exercises,
    )..where((e) => e.sourceId.equals(sourceId))).getSingleOrNull();
    if (library != null) return library;
    final name = sourceId.replaceAll('_', ' ');
    final custom =
        await (select(exercises)
              ..where((e) => e.isCustom.equals(true) & e.name.equals(name))
              ..limit(1))
            .get();
    return custom.firstOrNull;
  }

  /// Gives the exercises in curated_muscles.json their hand-checked muscles
  /// (instead of free-exercise-db's coarse guess; muscle ids are the part ids
  /// of the 3D model) and marks them verified. Runs at every start and only
  /// rewrites an exercise whose muscles differ from the file, so curating
  /// more exercises reaches existing databases with the next build.
  /// Exercises neither in the library nor custom are skipped.
  Future<void> _applyCurated() async {
    final data = jsonDecode(await _loadCurated()) as Map<String, dynamic>;
    final curated = (data['exercises'] as Map).cast<String, Map>();
    for (final sourceId in curated.keys) {
      final exercise = await _curatedExercise(sourceId);
      if (exercise == null) continue;
      final rows = curatedMuscles(curated, sourceId);
      final current = await (select(
        exerciseMuscles,
      )..where((em) => em.exerciseId.equals(exercise.id))).get();
      final same =
          current.length == rows.length &&
          current.every(
            (c) => rows.any((r) => r.id == c.muscleId && r.role == c.role),
          );
      if (same && exercise.musclesVerified) continue;
      await transaction(() async {
        await batch((b) {
          b.insertAll(muscles, [
            for (final r in rows)
              MusclesCompanion.insert(id: r.id, name: _partName(r.id)),
          ], mode: InsertMode.insertOrIgnore);
        });
        await (delete(
          exerciseMuscles,
        )..where((em) => em.exerciseId.equals(exercise.id))).go();
        await batch((b) {
          b.insertAll(exerciseMuscles, [
            for (final r in rows)
              ExerciseMusclesCompanion.insert(
                exerciseId: exercise.id,
                muscleId: r.id,
                role: r.role,
              ),
          ]);
        });
        await (update(exercises)..where((e) => e.id.equals(exercise.id))).write(
          const ExercisesCompanion(musclesVerified: Value(true)),
        );
      });
    }
  }

  /// A 3D-model part id as text: "long_head_of_triceps_brachii" → "Long head
  /// of triceps brachii".
  static String _partName(String id) {
    final words = id.replaceAll('_', ' ');
    return words[0].toUpperCase() + words.substring(1);
  }

  static String _titleCase(String s) =>
      s.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
}
