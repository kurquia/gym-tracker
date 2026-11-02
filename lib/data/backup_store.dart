// Automatic and manual backups, and where they are kept: the phone's shared
// storage or a folder on the desktop.

import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show QueryExecutor;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'backup.dart';
import 'database.dart';

/// Where backups are kept.
abstract interface class BackupStore {
  /// The folder, as shown in Settings → Backup.
  String get location;

  /// Copies [file] into the store as [name].
  Future<void> save(File file, String name);

  /// The file names in the store.
  Future<List<String>> names();

  Future<void> delete(String name);
}

/// Documents/Gym Tracker in the phone's shared storage: it survives an
/// uninstall and shows in the Files app. Written through MediaStore
/// (MainActivity.kt), which needs no permission for the app's own files.
class AndroidBackupStore implements BackupStore {
  static const _channel = MethodChannel('gym_tracker/backups');

  @override
  String get location => 'Documents/Gym Tracker';

  @override
  Future<void> save(File file, String name) =>
      _channel.invokeMethod('save', {'path': file.path, 'name': name});

  @override
  Future<List<String>> names() async =>
      await _channel.invokeListMethod<String>('names') ?? [];

  @override
  Future<void> delete(String name) =>
      _channel.invokeMethod('delete', {'name': name});
}

/// A plain folder: ~/Documents/gym_tracker_backups on the desktop, next to
/// the copies made by the tool/ scripts.
class DirectoryBackupStore implements BackupStore {
  DirectoryBackupStore(this.directory);

  final Directory directory;

  @override
  String get location => directory.path;

  @override
  Future<void> save(File file, String name) async {
    await directory.create(recursive: true);
    await file.copy(p.join(directory.path, name));
  }

  @override
  Future<List<String>> names() async => [
    if (directory.existsSync())
      for (final f in directory.listSync().whereType<File>())
        p.basename(f.path),
  ];

  @override
  Future<void> delete(String name) =>
      File(p.join(directory.path, name)).delete();
}

/// Backups of [db] into [store]: automatic ones after every finished workout
/// and daily (the newest 30 kept), and ones made by hand (kept).
class Backups {
  Backups(
    this.db,
    this.store, {
    required this.workDirectory,
    this.openCopy = AppDatabase.new,
  });

  final AppDatabase db;
  final BackupStore store;

  /// Opens a backup being restored (tests pass their seed files).
  final AppDatabase Function(QueryExecutor) openCopy;

  /// Private folder for scratch copies and the last automatic backup.
  final Future<Directory> Function() workDirectory;

  /// Why the last automatic backup failed; null once one succeeds.
  String? lastError;

  final _changed = StreamController<void>.broadcast();

  /// Fires after every backup.
  Stream<void> get changed => _changed.stream;

  Future<void> _queue = Future.value();
  DateTime? _dailyCheckedAt;

  /// Runs [task] after the earlier ones, so two backups never write at once.
  Future<T> _serial<T>(Future<T> Function() task) {
    final result = _queue.then((_) => task());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  /// A [backupName] for now that isn't taken (two in one second get "-2").
  Future<String> _freeName({bool auto = false, String? label}) async {
    final taken = (await store.names()).toSet();
    final now = DateTime.now();
    var name = backupName(now, db.schemaVersion, auto: auto, label: label);
    for (var i = 2; taken.contains(name); i++) {
      name = backupName(
        now,
        db.schemaVersion,
        auto: auto,
        label: [?label, '$i'].join('-'),
      );
    }
    return name;
  }

  Future<File> _copy(String name) async {
    final file = File(p.join((await workDirectory()).path, name));
    if (file.existsSync()) file.deleteSync();
    await db.writeCopy(file.path);
    return file;
  }

  /// An automatic backup; with [onlyIfChanged], skipped when the data equals
  /// the last automatic one. Deletes automatic backups beyond the newest 30.
  /// Returns the backup's name, or null when skipped.
  Future<String?> auto({bool onlyIfChanged = false}) => _serial(() async {
    final copy = await _copy('auto.sqlite');
    final last = File(p.join(copy.parent.path, 'last_auto_backup.sqlite'));
    if (onlyIfChanged &&
        last.existsSync() &&
        listEquals(copy.readAsBytesSync(), last.readAsBytesSync())) {
      copy.deleteSync();
      return null;
    }
    final name = await _freeName(auto: true);
    await store.save(copy, name);
    await copy.rename(last.path);
    for (final old in autoBackupsToPrune(await store.names())) {
      await store.delete(old);
    }
    _changed.add(null);
    return name;
  });

  /// After a finished workout, or once a day (newest backup over a day old,
  /// data changed; checked at most hourly). Failures are kept in [lastError],
  /// never thrown: this runs in the background.
  Future<void> autoInBackground({bool daily = false}) async {
    try {
      if (daily) {
        final now = DateTime.now();
        if (_dailyCheckedAt != null &&
            now.difference(_dailyCheckedAt!) < const Duration(hours: 1)) {
          return;
        }
        _dailyCheckedAt = now;
        final newest = await lastBackup();
        if (newest != null &&
            now.difference(newest) < const Duration(days: 1)) {
          return;
        }
      }
      await auto(onlyIfChanged: daily);
      lastError = null;
    } catch (e) {
      lastError = '$e';
      debugPrint('automatic backup failed: $e');
    }
  }

  /// A backup made by hand, kept until deleted. Returns the file (to share).
  Future<File> backUpNow({String? label}) => _serial(() async {
    final name = await _freeName(label: label);
    final share = Directory(p.join((await workDirectory()).path, 'share'));
    if (share.existsSync()) share.deleteSync(recursive: true);
    share.createSync();
    final file = File(p.join(share.path, name));
    await db.writeCopy(file.path);
    await store.save(file, name);
    _changed.add(null);
    return file;
  });

  /// When the newest backup in the store was made.
  Future<DateTime?> lastBackup() async {
    final times = [for (final n in await store.names()) ?backupTime(n)]..sort();
    return times.lastOrNull;
  }

  /// Puts a picked file in the work folder, ready for [inspect] and
  /// [restore].
  Future<File> stage(Uint8List bytes) async {
    final file = File(p.join((await workDirectory()).path, 'restore.sqlite'));
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Throws a [BackupException] for a file that can't be restored.
  BackupInfo inspect(File staged) =>
      inspectBackup(staged.path, newestSchema: db.schemaVersion);

  /// Backs up the current data (kept, "before-restore"), then replaces it
  /// with [staged].
  Future<void> restore(File staged) async {
    await backUpNow(label: 'before-restore');
    await _serial(
      () => db.restoreFrom(
        staged.path,
        scratchPath: p.join(staged.parent.path, 'restore-upgraded.sqlite'),
        open: openCopy,
      ),
    );
    staged.deleteSync();
  }
}
