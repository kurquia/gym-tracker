import 'dart:io';

import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/backup.dart';
import 'package:gym_tracker/data/backup_store.dart';
import 'package:gym_tracker/data/database.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'drift/default/generated/schema.dart';
import 'test_db.dart';

void main() {
  late Directory dir;
  late AppDatabase db;
  late int bench;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('backup_test');
    db = testDatabase();
    bench = (await exerciseIds(db))['Barbell Bench Press']!;
  });
  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  Future<int> logWorkout(double kg) => db.logSet(bench, kg);

  Future<List<double?>> loggedKg() async => [
    for (final s in await db.historyDao.exerciseHistory(bench))
      s.sets.single.weightKg,
  ];

  String path(String name) => p.join(dir.path, name);

  BackupInfo inspect(String name) =>
      inspectBackup(path(name), newestSchema: db.schemaVersion);

  test('a copy reads back as a backup with its workouts', () async {
    await logWorkout(60);
    await logWorkout(65);
    await db.writeCopy(path('copy.sqlite'));

    final info = inspect('copy.sqlite');
    expect(info.workouts, 2);
    expect(info.lastWorkout, isNotNull);
  });

  test('restore replaces all data and updates open streams', () async {
    await logWorkout(60);
    final kept = await logWorkout(65);
    await db.writeCopy(path('copy.sqlite'));

    await logWorkout(70);
    await db.workoutsDao.discardWorkout(kept);
    expect(await loggedKg(), [60, 70]);

    final counts = db.select(db.sessions).watch().map((rows) => rows.length);
    expect(await counts.first, 2);
    final next = counts.skip(1).first;

    await db.restoreFrom(
      path('copy.sqlite'),
      scratchPath: path('scratch.sqlite'),
      open: testDatabase,
    );
    expect(await loggedKg(), [60, 65]);
    expect(await next, 2);
    expect(
      (await db.select(db.sessions).get()).map((s) => s.id),
      contains(kept),
    );
    expect(File(path('scratch.sqlite')).existsSync(), isFalse);
  });

  test('a backup from an older schema is upgraded, then restored', () async {
    final old = await SchemaVerifier(GeneratedHelper()).schemaAt(16);
    old.rawDatabase
      ..execute(
        'INSERT INTO sessions (started_at, ended_at, clock_millis) '
        'VALUES (1760000000, 1760003600, 0)',
      )
      ..execute('VACUUM INTO ?', [path('v16.sqlite')]);
    old.rawDatabase.close();

    expect(inspect('v16.sqlite').workouts, 1);
    await logWorkout(60);
    await db.restoreFrom(
      path('v16.sqlite'),
      scratchPath: path('scratch.sqlite'),
      open: testDatabase,
    );
    final sessions = await db.select(db.sessions).get();
    expect(sessions.single.startedAt.millisecondsSinceEpoch, 1760000000 * 1000);
  });

  test('files that are not backups, or too new, are refused', () {
    File(path('notes.txt')).writeAsStringSync('not a database');
    expect(() => inspect('notes.txt'), throwsA(isA<BackupException>()));

    sqlite3.open(path('other.sqlite'))
      ..execute('CREATE TABLE t (x)')
      ..execute('PRAGMA user_version = 3')
      ..close();
    expect(
      () => inspect('other.sqlite'),
      throwsA(
        isA<BackupException>().having(
          (e) => e.message,
          'message',
          contains('not a Gym Tracker backup'),
        ),
      ),
    );
  });

  test('a backup from a newer app version is refused', () async {
    await db.writeCopy(path('copy.sqlite'));
    sqlite3.open(path('copy.sqlite'))
      ..execute('PRAGMA user_version = 99')
      ..close();
    expect(
      () => inspect('copy.sqlite'),
      throwsA(
        isA<BackupException>().having(
          (e) => e.message,
          'message',
          contains('newer version'),
        ),
      ),
    );
  });

  test('a backup older than the oldest migration is refused', () async {
    await db.writeCopy(path('copy.sqlite'));
    sqlite3.open(path('copy.sqlite'))
      ..execute('PRAGMA user_version = ${oldestSchema - 1}')
      ..close();
    expect(
      () => inspect('copy.sqlite'),
      throwsA(
        isA<BackupException>().having(
          (e) => e.message,
          'message',
          contains('too old'),
        ),
      ),
    );
  });

  test('names: automatic or by hand, time read back', () {
    final t = DateTime(2026, 10, 25, 0, 41, 12);
    final auto = backupName(t, 18, auto: true);
    final manual = backupName(t, 18, label: 'before-restore');
    expect(auto, 'gym_tracker-auto-v18-2026-10-25-004112.sqlite');
    expect(manual, 'gym_tracker-v18-2026-10-25-004112-before-restore.sqlite');
    expect(backupTime(auto), t);
    expect(backupTime(manual), t);
    expect(isAutoBackup(auto), isTrue);
    expect(isAutoBackup(manual), isFalse);
    // A copy made by hand.
    expect(
      backupTime('gym_tracker-phone-v17-2026-10-25-workouts.sqlite'),
      null,
    );
  });

  test('pruning keeps the newest automatic backups, never others', () {
    final autos = [
      for (var day = 1; day <= 5; day++)
        backupName(DateTime(2026, 10, day), 18, auto: true),
    ];
    final others = [
      backupName(DateTime(2026, 9), 18),
      'gym_tracker-phone-v17-2026-10-25-workouts.sqlite',
    ];
    expect(autoBackupsToPrune([...others, ...autos.reversed], keep: 3), [
      autos[1],
      autos[0],
    ]);
  });

  test('automatic backups skip unchanged data; by hand always', () async {
    final store = DirectoryBackupStore(Directory(path('store')));
    final work = Directory(path('work'))..createSync();
    final backups = Backups(db, store, workDirectory: () async => work);

    expect(await backups.lastBackup(), isNull);
    final first = await backups.auto();
    expect(first, isNotNull);
    expect(await backups.auto(onlyIfChanged: true), isNull);
    await logWorkout(60);
    expect(await backups.auto(onlyIfChanged: true), isNotNull);
    await backups.backUpNow();
    expect((await store.names()).where(isAutoBackup), hasLength(2));
    expect(await store.names(), hasLength(3));
    expect(await backups.lastBackup(), isNotNull);
  });

  test('restore through the service backs up the current data first', () async {
    final store = DirectoryBackupStore(Directory(path('store')));
    final work = Directory(path('work'))..createSync();
    final backups = Backups(
      db,
      store,
      workDirectory: () async => work,
      openCopy: testDatabase,
    );
    await logWorkout(60);
    await db.writeCopy(path('copy.sqlite'));
    await logWorkout(65);

    final staged = await backups.stage(
      File(path('copy.sqlite')).readAsBytesSync(),
    );
    expect(backups.inspect(staged).workouts, 1);
    await backups.restore(staged);
    expect(await loggedKg(), [60]);
    final before = (await store.names()).single;
    expect(before, contains('before-restore'));
    expect(inspect(p.join('store', before)).workouts, 2);
    expect(staged.existsSync(), isFalse);
  });
}
