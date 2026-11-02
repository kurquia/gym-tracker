// Workout logic in plain Dart, without database queries: how weights are
// typed, rests, the workout clock, supersets and setup summaries.

import 'database.dart';

extension ExerciseWeights on Exercise {
  /// The ways this exercise's weight can be typed; the equipment decides.
  List<WeightCounting> get countingChoices => switch (equipment) {
    'barbell' ||
    'e-z curl bar' ||
    'machine' => const [WeightCounting.total, WeightCounting.perSide],
    'dumbbell' || 'kettlebells' => const [WeightCounting.perDumbbell],
    _ => const [WeightCounting.total],
  };

  /// The chosen way if the equipment allows it, else the equipment's first.
  WeightCounting get counting => countingChoices.contains(weightCounting)
      ? weightCounting!
      : countingChoices.first;

  /// What [WeightCounting.perSide] adds: a bar, or a machine's sled / base.
  double get bar =>
      barKg ??
      switch (equipment) {
        'machine' => 0,
        'e-z curl bar' => 10,
        _ => 20,
      };

  /// What is typed for a stored plain weight (per side: one side's plates).
  double typedFromKg(double kg) =>
      counting == WeightCounting.perSide ? (kg - bar) / 2 : kg;

  /// The stored weight for a typed one.
  double kgFromTyped(double typed) =>
      counting == WeightCounting.perSide ? 2 * typed + bar : typed;
}

extension WorkoutSetKind on WorkoutSet {
  bool get isWarmup => kind == SetKind.warmup;
}

extension WorkoutSetRest on WorkoutSet {
  static const warmupDefault = Duration(minutes: 1);
  static const workingDefault = Duration(minutes: 3);

  /// The rest after this set. Within a superset round ([midRound]: another
  /// exercise of the round comes next) or before a drop set it defaults to
  /// none.
  Duration restFor({bool midRound = false}) => restSeconds != null
      ? Duration(seconds: restSeconds!)
      : midRound
      ? Duration.zero
      : isWarmup
      ? warmupDefault
      : workingDefault;

  /// Workout-clock reading at which the rest after this set ends ("next set
  /// at"); null until ticked, or when the tick lies ahead of [clock] (the
  /// clock was reset since, so this rest no longer means anything).
  Duration? restEndOn(Duration clock, {bool midRound = false}) =>
      completedClockMillis != null &&
          completedClockMillis! <= clock.inMilliseconds
      ? Duration(milliseconds: completedClockMillis!) +
            restFor(midRound: midRound)
      : null;
}

/// A setup field every exercise of a kind has, created automatically.
class SetupPreset {
  const SetupPreset(this.name, {this.unit, this.choices});
  final String name;
  final String? unit;

  /// The only answers, picked from a list; null = typed freely.
  final List<String>? choices;
}

/// Cable machines: how many pulleys the cable runs over (2 = 2:1).
const pulleyPreset = SetupPreset(
  'Pulley',
  choices: ['Single', 'Double', 'Triple', 'Quadruple'],
);

/// The setup fields an exercise always has: the bench angle of incline and
/// decline exercises, the pulley of cable exercises.
List<SetupPreset> setupPresets(Exercise e) {
  final name = e.name.toLowerCase();
  return [
    if (name.contains('incline')) const SetupPreset('Incline', unit: '°'),
    if (name.contains('decline')) const SetupPreset('Decline', unit: '°'),
    if (e.equipment == 'cable') pulleyPreset,
  ];
}

/// A setup field with its value in one workout (null = not filled in).
typedef SetupEntry = ({SetupField field, String? value});

/// "Incline 30° · Safeties 4 hole"; fields without a value are left out.
String setupSummary(List<SetupEntry> setup) => [
  for (final (:field, :value) in setup)
    if (value != null && field.name == pulleyPreset.name)
      '$value pulley' // "Double pulley"
    else if (value != null)
      '${field.name} $value${switch (field.unit) {
        null => '',
        // A symbol sticks to the number, a word gets a space.
        final u when u.startsWith(RegExp('[A-Za-z]')) => ' $u',
        final u => u,
      }}',
].join(' · ');

/// The sets an exercise got in its most recent finished session.
class PreviousSets {
  const PreviousSets(this.date, this.sets);
  final DateTime date;
  final List<WorkoutSet> sets;
}

class WorkoutExercise {
  const WorkoutExercise(
    this.entry,
    this.exercise,
    this.sets,
    this.previous,
    this.setup,
  );

  /// Also holds today's note.
  final SessionExercise entry;
  final Exercise exercise;
  final List<WorkoutSet> sets;
  final PreviousSets? previous;

  /// Every setup field of the exercise with its current value.
  final List<SetupEntry> setup;

  List<WorkoutSet> get warmups => [
    for (final s in sets)
      if (s.isWarmup) s,
  ];
  List<WorkoutSet> get working => [
    for (final s in sets)
      if (!s.isWarmup) s,
  ];
}

/// The in-progress session with everything the Record screen shows.
class ActiveWorkout {
  const ActiveWorkout(this.session, this.title, this.exercises);
  final Session session;
  final String title;
  final List<WorkoutExercise> exercises;

  /// The most recently ticked set: the rest in progress follows it. Ticks
  /// are stored to the second, so on a tie the set further down wins.
  WorkoutSet? get lastTicked {
    WorkoutSet? last;
    for (final e in exercises) {
      for (final s in e.sets) {
        if (s.completedAt != null &&
            (last == null || !s.completedAt!.isBefore(last.completedAt!))) {
          last = s;
        }
      }
    }
    return last;
  }

  Duration clockAt(DateTime now) => session.clockAt(now);

  /// Clock reading at which the rest after [lastTicked] ends; null when
  /// nothing is ticked, or the tick lies ahead of the clock (it was reset).
  Duration? restEndAt(DateTime now) => switch (lastTicked) {
    final s? => s.restEndOn(
      clockAt(now),
      midRound: nextInRound(s) != null || dropFollows(s),
    ),
    null => null,
  };

  /// Whether [s]'s exercise goes on with a drop set straight after it.
  bool dropFollows(WorkoutSet s) {
    for (final e in exercises) {
      final i = e.sets.indexWhere((x) => x.id == s.id);
      if (i != -1) return e.sets.elementAtOrNull(i + 1)?.kind == SetKind.drop;
    }
    return false;
  }

  /// The exercise that follows [s]'s in the same superset round, if any.
  /// Rounds pair working sets (the n-th of each exercise); warm-ups aren't
  /// in a round.
  WorkoutExercise? nextInRound(WorkoutSet s) {
    if (s.isWarmup) return null;
    final i = exercises.indexWhere((e) => e.entry.id == s.sessionExerciseId);
    if (i == -1 ||
        i + 1 >= exercises.length ||
        !exercises[i + 1].entry.supersetWithPrevious) {
      return null;
    }
    final round = exercises[i].working.indexWhere((w) => w.id == s.id);
    final next = exercises[i + 1];
    return round < next.working.length ? next : null;
  }

  /// Rest left, on the workout clock (so it stands still while the clock is
  /// paused); null as for [restEndAt], and once the rest is over.
  Duration? restLeft(DateTime now) => switch (restEndAt(now)) {
    final end? when end > clockAt(now) => end - clockAt(now),
    _ => null,
  };
}

extension SessionClock on Session {
  /// When the clock was last started; null while paused.
  DateTime? get clockRunningSince => clockRunningSinceMillis == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(clockRunningSinceMillis!);

  /// Time banked before the current run.
  Duration get clockBanked => Duration(milliseconds: clockMillis);

  /// The workout clock's reading at [now].
  Duration clockAt(DateTime now) {
    final since = clockRunningSince;
    return clockBanked +
        (since == null ? Duration.zero : now.difference(since));
  }
}

/// Splits [items] into pages: a new page starts unless the item is in a
/// superset with the one before.
List<List<T>> groupSupersets<T>(
  List<T> items,
  bool Function(T) supersetWithPrevious,
) {
  final pages = <List<T>>[];
  for (final item in items) {
    if (pages.isNotEmpty && supersetWithPrevious(item)) {
      pages.last.add(item);
    } else {
      pages.add([item]);
    }
  }
  return pages;
}
