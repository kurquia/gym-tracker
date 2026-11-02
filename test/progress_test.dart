import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/database.dart';

import 'test_db.dart';

WorkoutSet _set(
  double? kg,
  int? reps, {
  bool warmup = false,
  SetKind kind = SetKind.normal,
  LoadType load = LoadType.weight,
}) => WorkoutSet(
  id: 0,
  sessionExerciseId: 0,
  position: 0,
  kind: warmup ? SetKind.warmup : kind,
  loadType: load,
  weightKg: kg,
  reps: reps,
);

void main() {
  test('Mitter estimate', () {
    expect(estimatedOneRepMax(60, 10), closeTo(79.73, 0.01));
    expect(estimatedOneRepMax(100, 1), closeTo(100.53, 0.01));
  });

  test('strength history: best working set, records', () {
    final points = strengthHistory([
      PreviousSets(DateTime(2026, 9, 1), [
        _set(40, 10, warmup: true),
        _set(60, 10),
        _set(70, 3),
      ]),
      // Only warm-ups, bodyweight and too many reps: left out.
      PreviousSets(DateTime(2026, 9, 3), [
        _set(80, 1, warmup: true),
        _set(null, 12, load: LoadType.bodyweight),
        _set(30, 20),
      ]),
      PreviousSets(DateTime(2026, 9, 5), [_set(62.5, 8), _set(62.5, 6)]),
      PreviousSets(DateTime(2026, 9, 8), [_set(65, 8)]),
    ]);
    expect([for (final p in points) p.date.day], [1, 5, 8]);
    expect(points[0].best.weightKg, 60); // 79.7 kg beats 70 × 3 = 74.9
    expect([for (final p in points) p.isRecord], [true, false, true]);
  });

  test('exercise history: finished sessions only, oldest first', () async {
    final db = testDatabase();
    addTearDown(db.close);
    final bench = (await exerciseIds(db))['Barbell Bench Press']!;

    await db.logSet(bench, 60);
    await db.logSet(bench, 65);
    await db.logSet(bench, 70, finish: false); // still in progress

    final history = await db.historyDao.exerciseHistory(bench);
    expect([for (final s in history) s.sets.single.weightKg], [60, 65]);
  });
  test('best per week and month; a bucket with a record is a record', () {
    final points = strengthHistory([
      PreviousSets(DateTime(2026, 9, 28), [_set(60, 10)]), // Mon, record
      PreviousSets(DateTime(2026, 9, 30), [_set(55, 10)]),
      PreviousSets(DateTime(2026, 10, 5), [_set(58, 10)]), // next Mon
      PreviousSets(DateTime(2026, 10, 9), [_set(57, 10)]),
    ]);
    final weeks = bestPer(points, Bucket.week);
    expect([for (final p in weeks) p.date.day], [28, 5]);
    expect([for (final p in weeks) p.isRecord], [true, false]);
    // Sat 3 + Sun 4 Oct: one week from Monday, two from Sunday.
    final weekend = strengthHistory([
      PreviousSets(DateTime(2026, 10, 3), [_set(60, 10)]),
      PreviousSets(DateTime(2026, 10, 4), [_set(61, 10)]),
    ]);
    expect(bestPer(weekend, Bucket.week), hasLength(1));
    expect(
      bestPer(weekend, Bucket.week, firstWeekday: DateTime.sunday),
      hasLength(2),
    );
    final months = bestPer(points, Bucket.month);
    expect(
      [for (final p in months) (p.date.month, p.isRecord)],
      [(9, true), (10, false)],
    );
  });

  test('buckets by span shown, range starts', () {
    expect(Bucket.forSpan(const Duration(days: 92)), Bucket.workout);
    expect(Bucket.forSpan(const Duration(days: 365)), Bucket.week);
    expect(Bucket.forSpan(const Duration(days: 1000)), Bucket.month);
    expect(
      ChartRange.month3.start(DateTime(2026, 10, 19)),
      DateTime(2026, 7, 19),
    );
    expect(ChartRange.max.start(DateTime(2026, 10, 19)), isNull);
  });

  test('volume: plain-weight working sets, summed per week', () {
    final points = volumeHistory([
      PreviousSets(DateTime(2026, 9, 28), [
        _set(40, 10, warmup: true),
        _set(60, 10),
        _set(60, 8),
        _set(null, 12, load: LoadType.bodyweight),
      ]),
      PreviousSets(DateTime(2026, 9, 30), [_set(50, 10)]),
      PreviousSets(DateTime(2026, 10, 2), [_set(50, 10, warmup: true)]),
      PreviousSets(DateTime(2026, 10, 5), [_set(70, 5)]),
    ]);
    expect(
      [for (final p in points) (p.kg, p.sets)],
      [(1080, 3), (500, 1), (350, 1)],
    );
    final weeks = sumPer(points, Bucket.week);
    expect(
      [for (final p in weeks) (p.date, p.kg, p.sets)],
      [(DateTime(2026, 9, 28), 1580, 4), (DateTime(2026, 10, 5), 350, 1)],
    );
    // A week without a workout gets no point, not a 0.
    final gap = sumPer([points.first, points.last], Bucket.week);
    expect(
      [for (final p in gap) p.date],
      [DateTime(2026, 9, 28), DateTime(2026, 10, 5)],
    );
    final skipped = sumPer([
      VolumePoint(DateTime(2026, 9, 1), 100, 1, 10),
      VolumePoint(DateTime(2026, 9, 22), 100, 1, 10),
    ], Bucket.week);
    expect(skipped.length, 2);
  });

  test(
    'workouts per week: weeks without one count, under a week reads as 1',
    () {
      final from = DateTime(2026, 9, 1);
      expect(workoutsPerWeek(13, from, from.add(const Duration(days: 91))), 1);
      expect(workoutsPerWeek(1, from, from.add(const Duration(days: 2))), 1);
    },
  );

  test('set types: drop sets count as sets and volume, not for the 1RM', () {
    final sessions = [
      PreviousSets(DateTime(2026, 10, 1), [
        _set(60, 3, kind: SetKind.failure), // 64.2 kg estimated
        _set(50, 12, kind: SetKind.drop), // 70.7 kg, but a drop
        _set(30, 30, kind: SetKind.drop),
      ]),
    ];
    final strength = strengthHistory(sessions).single;
    expect(strength.best.weightKg, 60);
    final volume = volumeHistory(sessions).single;
    expect((volume.kg, volume.sets), (180 + 600 + 900, 1 + 2 * dropSetCount));
  });

  test('bodyweight exercises: volume counts reps, whatever the load', () {
    final sessions = [
      PreviousSets(DateTime(2026, 10, 1), [
        _set(null, 5, warmup: true, load: LoadType.bodyweight),
        _set(null, 10, load: LoadType.bodyweight),
        _set(10, 6, load: LoadType.weighted),
        _set(20, 8, load: LoadType.assisted),
      ]),
    ];
    expect(mostlyBodyweight(sessions), isTrue);
    final volume = volumeHistory(sessions).single;
    expect((volume.kg, volume.sets, volume.reps), (0, 3, 24));
    expect(
      mostlyBodyweight([
        PreviousSets(DateTime(2026, 10, 1), [
          _set(60, 10),
          _set(60, 10),
          _set(null, 12, load: LoadType.bodyweight),
        ]),
      ]),
      isFalse,
    );
  });
}
