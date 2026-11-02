import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/database.dart';
import 'package:gym_tracker/features/record/workout_notification.dart';

import 'test_db.dart';

void main() {
  late AppDatabase db;
  late int sessionId;

  setUp(() async {
    db = testDatabase();
    final squat = (await exerciseIds(db))['Barbell Squat']!;
    sessionId = await db.startWith([squat]);
  });
  tearDown(() => db.close());

  test('no workout, no notification', () {
    expect(notificationContent(null, RestStyle.clock, DateTime.now()), isNull);
  });

  test('running clock: ticks from the clock start', () async {
    final since = DateTime(2026, 10, 15, 21, 0);
    await db.setClock(sessionId, 120000, runningSince: since);
    final c = notificationContent(
      await db.active(),
      RestStyle.clock,
      since.add(const Duration(minutes: 5)),
    )!;
    expect(c.title, 'Workout');
    expect(c.text, '');
    // 2:00 banked before 21:00 → the clock reads 0:00 at 20:58.
    expect(c.ticksFrom, DateTime(2026, 10, 15, 20, 58)); // Pause button
    expect(c.countDown, isFalse);
  });

  test('paused clock with a ticked set: stands still', () async {
    await db.setClock(sessionId, (14 * 60 + 3) * 1000);
    final set = (await db.active()).exercises.single.sets.single;
    await db.workoutsDao.tickSet(set.id, done: true);
    final c = notificationContent(
      await db.active(),
      RestStyle.clock,
      DateTime.now(),
    )!;
    expect(c.text, 'Paused · Next set at 17:03');
    expect(c.ticksFrom, isNull); // Resume button
    expect(c.stoppedAt, const Duration(minutes: 14, seconds: 3));
  });

  test('countdown style counts down the rest on the clock', () async {
    final set = (await db.active()).exercises.single.sets.single;
    // The first tick starts the clock at 0:00; the rest ends at clock 3:00.
    await db.workoutsDao.tickSet(set.id, done: true);
    var w = await db.active();
    final start = w.session.clockRunningSince!;
    final restEnd = start.add(const Duration(minutes: 3));

    final during = notificationContent(
      w,
      RestStyle.countdown,
      restEnd.subtract(const Duration(seconds: 30)),
    )!;
    expect(during.text, 'Rest');
    expect(during.ticksFrom, restEnd);
    expect(during.countDown, isTrue);

    final after = notificationContent(
      w,
      RestStyle.countdown,
      restEnd.add(const Duration(seconds: 1)),
    )!;
    expect(after.text, 'Rest over');
    expect(after.countDown, isFalse);

    // Paused 1:00 into the rest: the rest stands still with the clock.
    await db.setClock(sessionId, 60000);
    w = await db.active();
    final paused = notificationContent(
      w,
      RestStyle.countdown,
      DateTime.now().add(const Duration(hours: 1)),
    )!;
    expect(paused.text, 'Rest paused');
    expect(paused.ticksFrom, isNull);
    expect(paused.stoppedAt, const Duration(minutes: 2));
  });

  test(
    'the rest alert goes off when the rest ends, not while paused',
    () async {
      expect(restAlertAt(await db.active(), DateTime.now()), isNull); // no rest

      final set = (await db.active()).exercises.single.sets.single;
      await db.workoutsDao.tickSet(
        set.id,
        done: true,
      ); // starts the clock and a 3:00 rest
      var w = await db.active();
      final restEnd = w.session.clockRunningSince!.add(
        const Duration(minutes: 3),
      );
      final now = restEnd.subtract(const Duration(minutes: 1));
      expect(restAlertAt(w, now), restEnd);
      expect(restAlertAt(w, restEnd.add(const Duration(seconds: 1))), isNull);

      await db.setClock(sessionId, 60000); // paused 1:00 into the rest
      w = await db.active();
      expect(restAlertAt(w, DateTime.now()), isNull);
    },
  );

  test('each alert choice gets its own Android channel', () {
    expect({
      for (final a in RestAlert.values) restAlertChannel(a),
    }, hasLength(RestAlert.values.length));
  });
}
