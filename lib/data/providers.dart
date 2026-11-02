// The Riverpod providers: mostly live data from the database, for the screens
// to watch.

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'backup_store.dart';
import 'database.dart';

/// The single database instance. Tests override this with an in-memory one.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

/// Backups of the database; null in tests (they'd write into the real
/// backup folder) and on platforms without a backup folder.
final backupsProvider = Provider<Backups?>((ref) {
  if (Platform.environment.containsKey('FLUTTER_TEST')) return null;
  final BackupStore store;
  if (Platform.isAndroid) {
    store = AndroidBackupStore();
  } else if (Platform.isLinux) {
    store = DirectoryBackupStore(
      Directory(
        p.join(
          Platform.environment['HOME']!,
          'Documents',
          'gym_tracker_backups',
        ),
      ),
    );
  } else {
    return null;
  }
  return Backups(
    ref.watch(databaseProvider),
    store,
    workDirectory: () async {
      final support = await getApplicationSupportDirectory();
      return Directory(p.join(support.path, 'backups'))
        ..createSync(recursive: true);
    },
  );
});

/// When the newest backup was made, re-read after every backup.
final lastBackupProvider = StreamProvider<DateTime?>((ref) async* {
  final backups = ref.watch(backupsProvider);
  if (backups == null) {
    yield null;
    return;
  }
  yield await backups.lastBackup();
  await for (final _ in backups.changed) {
    yield await backups.lastBackup();
  }
});

final settingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(databaseProvider).settingsDao.watchSettings(),
);

/// Shorthand used wherever weights are shown or typed.
final weightUnitProvider = Provider<WeightUnit>(
  (ref) => ref.watch(settingsProvider).value?.weightUnit ?? WeightUnit.kg,
);

/// Settings → Dates: the first day of the week, [DateTime.monday] …
final firstWeekdayProvider = Provider<int>(
  (ref) => (ref.watch(settingsProvider).value ?? SettingsDao.defaultSettings)
      .firstWeekday
      .weekday,
);

final routinesProvider = StreamProvider<List<RoutineSummary>>(
  (ref) => ref.watch(databaseProvider).routinesDao.watchRoutines(),
);

final exerciseCatalogProvider = StreamProvider<List<CatalogEntry>>(
  (ref) => ref.watch(databaseProvider).exercisesDao.watchExerciseCatalog(),
);

final exerciseDetailProvider = StreamProvider.autoDispose
    .family<ExerciseDetail?, int>(
      (ref, id) =>
          ref.watch(databaseProvider).exercisesDao.watchExerciseDetail(id),
    );

final equipmentNamesProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(databaseProvider).exercisesDao.equipmentNames(),
);

final musclesProvider = FutureProvider<List<Muscle>>(
  (ref) => ref.watch(databaseProvider).exercisesDao.allMuscles(),
);

final activeWorkoutProvider = StreamProvider<ActiveWorkout?>(
  (ref) => ref.watch(databaseProvider).workoutsDao.watchActiveWorkout(),
);

final routineLastDoneProvider = StreamProvider<Map<int, DateTime>>(
  (ref) => ref.watch(databaseProvider).routinesDao.watchRoutineLastDone(),
);

final workoutHistoryProvider = StreamProvider<List<WorkoutSummary>>(
  (ref) => ref.watch(databaseProvider).historyDao.watchWorkoutHistory(),
);

final loggedExercisesProvider =
    StreamProvider<List<({Exercise exercise, int sessions})>>(
      (ref) => ref.watch(databaseProvider).historyDao.watchLoggedExercises(),
    );

final exerciseHistoryProvider = StreamProvider.autoDispose
    .family<List<PreviousSets>, int>(
      (ref, id) =>
          ref.watch(databaseProvider).historyDao.watchExerciseHistory(id),
    );

final workoutLogProvider = StreamProvider.autoDispose.family<WorkoutLog?, int>(
  (ref, id) => ref.watch(databaseProvider).historyDao.watchWorkoutLog(id),
);
