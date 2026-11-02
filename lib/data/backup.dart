import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

import 'database.dart';

// A backup is a whole copy of the SQLite file. A restore runs it through the
// normal migrations first, so backups from older app versions restore too.

/// The oldest schema [AppDatabase]'s migrations start from.
const oldestSchema = 12;

/// What a backup file holds, read without changing it.
class BackupInfo {
  const BackupInfo({required this.workouts, this.lastWorkout});

  /// Finished workouts.
  final int workouts;
  final DateTime? lastWorkout;
}

/// A file this app version can't restore; [message] says why.
class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Reads [path] as a backup: a Gym Tracker database, intact, from
/// [oldestSchema] up to [newestSchema] (the app's schema version).
BackupInfo inspectBackup(String path, {required int newestSchema}) {
  final Database db;
  try {
    db = sqlite3.open(path, mode: OpenMode.readOnly);
  } on SqliteException {
    throw const BackupException('The file could not be opened.');
  }
  try {
    final integrity = db.select('PRAGMA integrity_check').first.values.first;
    if (integrity != 'ok') {
      throw const BackupException('The file is damaged.');
    }
    final tables = {
      for (final row in db.select(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      ))
        row['name'] as String,
    };
    final version = db.select('PRAGMA user_version').first.values.first as int;
    if (!tables.containsAll(['sessions', 'exercises'])) {
      throw const BackupException('This is not a Gym Tracker backup.');
    }
    if (version < oldestSchema) {
      throw BackupException(
        'This backup is too old to restore (database v$version).',
      );
    }
    if (version > newestSchema) {
      throw BackupException(
        'This backup is from a newer version of the app (database v$version); '
        'update the app first.',
      );
    }
    final row = db
        .select(
          'SELECT count(*) AS n, max(started_at) AS last FROM sessions '
          'WHERE ended_at IS NOT NULL',
        )
        .first;
    final last = row['last'] as int?;
    return BackupInfo(
      workouts: row['n'] as int,
      lastWorkout: last == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(last * 1000),
    );
  } on SqliteException {
    throw const BackupException('This is not a Gym Tracker backup.');
  } finally {
    db.close();
  }
}

extension DatabaseBackup on AppDatabase {
  /// Writes a consistent copy of the whole database to [path], which must not
  /// exist yet. Unchanged data gives a byte-identical file.
  Future<void> writeCopy(String path) =>
      customStatement('VACUUM INTO ?', [path]);

  /// Replaces all data with the backup at [path] (checked with
  /// [inspectBackup] first).
  ///
  /// The backup is upgraded to the current schema in a scratch copy at
  /// [scratchPath], opened with [open]; then every table is copied into this
  /// database in one transaction. The database file itself is never swapped,
  /// so the connection shared with the notification's isolate stays valid
  /// and every open screen updates.
  Future<void> restoreFrom(
    String path, {
    required String scratchPath,
    AppDatabase Function(QueryExecutor) open = AppDatabase.new,
  }) async {
    final scratch = await File(path).copy(scratchPath);
    try {
      // A second database class on purpose: another file, closed below.
      final warn = driftRuntimeOptions.dontWarnAboutMultipleDatabases;
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final upgraded = open(NativeDatabase(scratch));
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = warn;
      await upgraded.customSelect('SELECT 1').get(); // runs the migrations
      await upgraded.close();

      await customStatement('ATTACH DATABASE ? AS backup', [scratchPath]);
      try {
        await transaction(() async {
          // Checked at commit, so inserts may come in any order; deletes go
          // children first for any RESTRICT key, which acts at once.
          await customStatement('PRAGMA defer_foreign_keys = ON');
          for (final table in allTables.toList().reversed) {
            await customStatement(
              'DELETE FROM main."${table.actualTableName}"',
            );
          }
          for (final table in allTables) {
            final columns = [for (final c in table.$columns) '"${c.name}"']
                .join(', ');
            await customStatement(
              'INSERT INTO main."${table.actualTableName}" ($columns) '
              'SELECT $columns FROM backup."${table.actualTableName}"',
            );
          }
        });
      } finally {
        await customStatement('DETACH DATABASE backup');
      }
      markTablesUpdated(allTables);
    } finally {
      if (scratch.existsSync()) scratch.deleteSync();
    }
  }
}

/// `gym_tracker-auto-v18-2026-10-25-004112.sqlite` for an automatic backup,
/// `gym_tracker-v18-2026-10-25-004112[-label].sqlite` for one made by hand.
String backupName(
  DateTime time,
  int schemaVersion, {
  bool auto = false,
  String? label,
}) {
  String two(int n) => n.toString().padLeft(2, '0');
  final stamp =
      '${time.year}-${two(time.month)}-${two(time.day)}-'
      '${two(time.hour)}${two(time.minute)}${two(time.second)}';
  return 'gym_tracker-${auto ? 'auto-' : ''}v$schemaVersion-$stamp'
      '${label == null ? '' : '-$label'}.sqlite';
}

final _backupPattern = RegExp(
  r'^gym_tracker-(auto-)?v\d+-(\d{4})-(\d\d)-(\d\d)-(\d\d)(\d\d)(\d\d)'
  r'(-[\w-]+)?\.sqlite$',
);

/// When the backup called [name] was made; null for files this app didn't
/// name (the desktop scripts' copies, for one).
DateTime? backupTime(String name) {
  final m = _backupPattern.firstMatch(name);
  if (m == null) return null;
  final n = [for (var i = 2; i <= 7; i++) int.parse(m.group(i)!)];
  return DateTime(n[0], n[1], n[2], n[3], n[4], n[5]);
}

bool isAutoBackup(String name) =>
    _backupPattern.firstMatch(name)?.group(1) != null;

/// The automatic backups among [names] to delete so the newest [keep]
/// remain. Backups made by hand and other files are never deleted.
List<String> autoBackupsToPrune(Iterable<String> names, {int keep = 30}) {
  final auto = [...names.where(isAutoBackup)]
    ..sort((a, b) => backupTime(b)!.compareTo(backupTime(a)!));
  return auto.skip(keep).toList();
}
