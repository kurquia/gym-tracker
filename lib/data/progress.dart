// Progress over time in plain Dart, without database queries: estimated
// one-rep max, records and volume, for the Statistics charts.

import 'dart:math' as math;

import 'database.dart';

/// Above this many reps an estimate says little about the one-rep max.
const maxRepsForEstimate = 12;

/// What a drop set counts for in sets per week: the user's choice (one each,
/// 2026-10-23). Sødal et al. 2023 list a top set with its drops as one set.
const dropSetCount = 1;

/// Mitter et al. (2022), 2-parameter exponential: a set to failure of
/// [reps] is at %1RM = A·e^(−b·reps), A = 1.026, b = 0.031 (bench press,
/// trained lifters, their first test).
double estimatedOneRepMax(double kg, int reps) =>
    kg / 1.026 * math.exp(0.031 * reps);

/// One session on the strength chart.
class StrengthPoint {
  const StrengthPoint(this.date, this.best, this.isRecord);
  final DateTime date;

  /// The working set with the highest estimated one-rep max.
  final WorkoutSet best;

  /// [oneRepMax] beats every earlier session.
  final bool isRecord;

  double get oneRepMax => estimatedOneRepMax(best.weightKg!, best.reps!);
}

/// Sessions oldest first, as [HistoryDao.exerciseHistory] gives them. Only
/// plain-weight working sets of 1 to [maxRepsForEstimate] reps count, not drop
/// sets (the formula assumes a fresh set); sessions without one are left out.
List<StrengthPoint> strengthHistory(List<PreviousSets> sessions) {
  final points = <StrengthPoint>[];
  var record = 0.0;
  for (final s in sessions) {
    final counted = [
      for (final set in s.sets)
        if ((set.kind == SetKind.normal || set.kind == SetKind.failure) &&
            set.loadType == LoadType.weight &&
            (set.weightKg ?? 0) > 0 &&
            (set.reps ?? 0) > 0 &&
            set.reps! <= maxRepsForEstimate)
          set,
    ];
    if (counted.isEmpty) continue;
    double e1rm(WorkoutSet set) => estimatedOneRepMax(set.weightKg!, set.reps!);
    final best = counted.reduce((a, b) => e1rm(b) > e1rm(a) ? b : a);
    final isRecord = e1rm(best) > record;
    if (isRecord) record = e1rm(best);
    points.add(StrengthPoint(s.date, best, isRecord));
  }
  return points;
}

/// The time a chart shows, back from today.
enum ChartRange {
  month1('1M', 1),
  month3('3M', 3),
  month6('6M', 6),
  year1('1Y', 12),
  max('Max', null);

  const ChartRange(this.label, this.months);
  final String label;

  /// Null = all history.
  final int? months;

  /// The first day shown, or null for all history.
  DateTime? start(DateTime today) => months == null
      ? null
      : DateTime(today.year, today.month - months!, today.day);
}

/// How many dots a chart draws: one per workout, or the best per week or month.
enum Bucket {
  workout,
  week,
  month;

  /// Workouts up to about three months shown, weeks up to about a year.
  static Bucket forSpan(Duration span) => span.inDays <= 100
      ? workout
      : span.inDays <= 400
      ? week
      : month;
}

/// Midnight on the first day of [d]'s week (from [firstWeekday]) or month;
/// [d] itself for [Bucket.workout].
DateTime bucketStart(
  DateTime d,
  Bucket bucket, {
  int firstWeekday = DateTime.monday,
}) => switch (bucket) {
  Bucket.workout => d,
  Bucket.week => DateTime(
    d.year,
    d.month,
    d.day - (d.weekday - firstWeekday) % 7,
  ),
  Bucket.month => DateTime(d.year, d.month),
};

/// The best of [points] per [bucket]; a bucket holding a record is a record.
List<StrengthPoint> bestPer(
  List<StrengthPoint> points,
  Bucket bucket, {
  int firstWeekday = DateTime.monday,
}) {
  if (bucket == Bucket.workout) return points;
  final best = <DateTime, StrengthPoint>{};
  for (final p in points) {
    final key = bucketStart(p.date, bucket, firstWeekday: firstWeekday);
    final old = best[key];
    final top = old == null || p.oneRepMax > old.oneRepMax ? p : old;
    best[key] = StrengthPoint(
      top.date,
      top.best,
      p.isRecord || (old?.isRecord ?? false),
    );
  }
  return best.values.toList();
}

/// One session's working sets, for the volume charts.
class VolumePoint {
  const VolumePoint(this.date, this.kg, this.sets, this.reps);
  final DateTime date;

  /// Σ kg × reps over plain-weight working sets.
  final double kg;

  /// Working sets with reps, whatever the load; a drop set counts
  /// [dropSetCount].
  final int sets;

  /// Σ reps over working sets, whatever the load: the volume of bodyweight
  /// exercises, which have no kg to multiply.
  final int reps;
}

/// Whether most working sets with reps are bodyweight, weighted or assisted,
/// so the volume chart counts reps instead of kg × reps.
bool mostlyBodyweight(List<PreviousSets> sessions) {
  var body = 0, plain = 0;
  for (final s in sessions) {
    for (final set in s.sets) {
      if (set.isWarmup || (set.reps ?? 0) == 0) continue;
      set.loadType == LoadType.weight ? plain++ : body++;
    }
  }
  return body > plain;
}

/// Sessions oldest first; sessions without a working set with reps are left
/// out.
List<VolumePoint> volumeHistory(List<PreviousSets> sessions) => [
  for (final s in sessions)
    if (s.sets.any((set) => !set.isWarmup && (set.reps ?? 0) > 0))
      VolumePoint(
        s.date,
        s.sets.fold(
          0.0,
          (sum, set) => !set.isWarmup && set.loadType == LoadType.weight
              ? sum + (set.weightKg ?? 0) * (set.reps ?? 0)
              : sum,
        ),
        s.sets.fold(
          0,
          (n, set) => set.isWarmup || (set.reps ?? 0) == 0
              ? n
              : n + (set.kind == SetKind.drop ? dropSetCount : 1),
        ),
        s.sets.fold(0, (n, set) => set.isWarmup ? n : n + (set.reps ?? 0)),
      ),
];

/// [points] summed per [bucket], dated at the bucket's start. Buckets without
/// a workout are left out, not drawn as 0.
List<VolumePoint> sumPer(
  List<VolumePoint> points,
  Bucket bucket, {
  int firstWeekday = DateTime.monday,
}) {
  if (bucket == Bucket.workout) return points;
  final sums = <DateTime, VolumePoint>{};
  for (final p in points) {
    final key = bucketStart(p.date, bucket, firstWeekday: firstWeekday);
    final old = sums[key];
    sums[key] = VolumePoint(
      key,
      p.kg + (old?.kg ?? 0),
      p.sets + (old?.sets ?? 0),
      p.reps + (old?.reps ?? 0),
    );
  }
  return sums.values.toList();
}

/// [workouts] per week between [from] and [to], weeks without one included;
/// never over less than a week, so a first workout reads 1, not 7.
double workoutsPerWeek(int workouts, DateTime from, DateTime to) =>
    workouts / math.max(1, to.difference(from).inHours / (7 * 24));
