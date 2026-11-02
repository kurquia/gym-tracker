// The database tables as Dart classes, and the enums stored in their columns.

import 'package:drift/drift.dart';

/// How a muscle takes part in an exercise.
/// free-exercise-db only knows primary (→ [target]) and secondary (→ [synergist]).
/// [stabilizer] is shown as "fixator" (a muscle that holds a joint or segment
/// still so another can act).
enum MuscleRole { target, synergist, stabilizer }

class Muscles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// How an exercise's weight is typed. Stored weights are the load of one
/// implement: the whole bar, or one dumbbell; [perSide] is an input helper
/// that adds the bar to the plates of one side.
enum WeightCounting { total, perSide, perDumbbell }

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// free-exercise-db id; null for custom exercises.
  TextColumn get sourceId => text().nullable().unique()();
  TextColumn get name => text()();
  TextColumn get equipment => text().nullable()();
  TextColumn get category => text().nullable()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  /// False while the muscles are free-exercise-db's coarse guess.
  BoolColumn get musclesVerified =>
      boolean().withDefault(const Constant(false))();

  /// Null = automatic: the first of [ExerciseWeights.countingChoices].
  TextColumn get weightCounting => textEnum<WeightCounting>().nullable()();

  /// The bar (or machine base) for [WeightCounting.perSide]; null = the
  /// equipment's default.
  RealColumn get barKg => real().nullable()();

  /// Free text shown every time in Record ("box + two 20 kg plates under it").
  TextColumn get note => text().nullable()();
}

/// A bench or machine setting of an exercise ("Incline" 30 °), set in the
/// exercise's options; each finished workout keeps a copy in [SetupValues].
class SetupFields extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get exerciseId =>
      integer().references(Exercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get name => text()();
  TextColumn get unit => text().nullable()();

  /// The current value; null = not set.
  TextColumn get value => text().nullable()();
}

/// A setup field's value as it was in one finished workout (its history).
class SetupValues extends Table {
  IntColumn get sessionExerciseId => integer().references(
    SessionExercises,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get fieldId =>
      integer().references(SetupFields, #id, onDelete: KeyAction.cascade)();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {sessionExerciseId, fieldId};
}

class ExerciseMuscles extends Table {
  IntColumn get exerciseId =>
      integer().references(Exercises, #id, onDelete: KeyAction.cascade)();
  TextColumn get muscleId => text().references(Muscles, #id)();
  TextColumn get role => textEnum<MuscleRole>()();

  @override
  Set<Column> get primaryKey => {exerciseId, muscleId};
}

/// A saved list of exercises; sets, reps and weight are chosen per session.
class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class RoutineExercises extends Table {
  IntColumn get routineId =>
      integer().references(Routines, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  IntColumn get exerciseId => integer().references(Exercises, #id)();

  /// In a superset with the exercise before it.
  BoolColumn get supersetWithPrevious =>
      boolean().withDefault(const Constant(false))();

  /// How many working sets a workout starts with; null = as many as last time.
  IntColumn get sets => integer().nullable()();

  /// With [sets]: start with warm-ups too (last time's, or one empty one).
  BoolColumn get warmup => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {routineId, position};
}

/// What a set's weight means. [bodyweight] has no weight; [weighted] adds
/// [Sets.weightKg] to bodyweight, [assisted] subtracts it.
enum LoadType { weight, bodyweight, weighted, assisted }

/// A set's type, picked by tapping its number in Record. Every kind but
/// [warmup] is a working set: it counts in records, volume and sets per
/// week. A [drop] follows the set before it without rest, at a lower weight;
/// a [failure] set went to failure.
enum SetKind { normal, warmup, drop, failure }

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineId => integer().nullable().references(
    Routines,
    #id,
    onDelete: KeyAction.setNull,
  )();
  DateTimeColumn get startedAt => dateTime()();

  /// Null while the workout is in progress.
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();

  /// Workout-clock milliseconds banked before the current run. The user
  /// starts and pauses the clock; it is not tied to [startedAt]. Milliseconds
  /// (not drift's whole-second date-times) because the clock shows hundredths.
  IntColumn get clockMillis => integer().withDefault(const Constant(0))();

  /// When the clock was last started, in Unix milliseconds; null while
  /// paused. Read it as a date via [SessionClock.clockRunningSince].
  IntColumn get clockRunningSinceMillis => integer().nullable()();
}

/// One exercise slot in a session, in order.
class SessionExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get position => integer()();

  /// This workout's note on the exercise ("left knee felt off").
  TextColumn get note => text().nullable()();

  /// In a superset with the exercise before it: one page in Record, sets
  /// alternate, the rest comes after a full round.
  BoolColumn get supersetWithPrevious =>
      boolean().withDefault(const Constant(false))();
}

@DataClassName('WorkoutSet')
class Sets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionExerciseId => integer().references(
    SessionExercises,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get position => integer()();
  TextColumn get kind =>
      textEnum<SetKind>().withDefault(Constant(SetKind.normal.name))();
  TextColumn get loadType =>
      textEnum<LoadType>().withDefault(Constant(LoadType.weight.name))();

  /// Always kg, as a magnitude (see [loadType]); null until entered.
  RealColumn get weightKg => real().nullable()();
  IntColumn get reps => integer().nullable()();

  /// Set when the user ticks the set; unticked sets are dropped on finish.
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Workout-clock reading at the tick, in milliseconds: the rest after this
  /// set runs on the workout clock (pausing the clock pauses the rest).
  IntColumn get completedClockMillis => integer().nullable()();

  /// Rest after this set; null = the default for its kind (see [WorkoutSetRest]).
  IntColumn get restSeconds => integer().nullable()();
}

enum WeightUnit { kg, lb }

enum DistanceUnit { km, mi }

/// Unit for body measurements; `in` is a Dart keyword, hence [inch].
enum LengthUnit { cm, inch }

/// How the Record screen shows a rest: [clock] = "next set at 17:03" on the
/// workout clock, [countdown] = time left.
enum RestStyle { clock, countdown }

/// The day calendar weeks start on (Settings → Dates).
enum FirstWeekday {
  monday(DateTime.monday),
  sunday(DateTime.sunday),
  saturday(DateTime.saturday);

  const FirstWeekday(this.weekday);

  /// [DateTime.monday] … [DateTime.sunday].
  final int weekday;
}

/// What happens when a rest ends, also with the screen locked.
enum RestAlert {
  vibrationAndSound(vibrates: true, sounds: true),
  vibration(vibrates: true, sounds: false),
  sound(vibrates: false, sounds: true),
  off(vibrates: false, sounds: false);

  const RestAlert({required this.vibrates, required this.sounds});
  final bool vibrates;
  final bool sounds;
}

/// How the workout notification shows the clock: [live] = its own line,
/// ticked by Android even with the app closed; [redrawn] = plain text the
/// app rewrites every second (stops if the phone kills the app).
enum NotificationClock { live, redrawn }

/// App settings: a single row (id 1); missing row = all defaults.
@DataClassName('AppSettings')
class SettingsTable extends Table {
  @override
  String get tableName => 'settings';

  IntColumn get id => integer()();
  TextColumn get weightUnit =>
      textEnum<WeightUnit>().withDefault(Constant(WeightUnit.kg.name))();
  TextColumn get distanceUnit =>
      textEnum<DistanceUnit>().withDefault(Constant(DistanceUnit.km.name))();
  TextColumn get lengthUnit =>
      textEnum<LengthUnit>().withDefault(Constant(LengthUnit.cm.name))();
  TextColumn get restStyle =>
      textEnum<RestStyle>().withDefault(Constant(RestStyle.clock.name))();

  TextColumn get restAlert => textEnum<RestAlert>().withDefault(
    Constant(RestAlert.vibrationAndSound.name),
  )();

  TextColumn get firstWeekday => textEnum<FirstWeekday>().withDefault(
    Constant(FirstWeekday.monday.name),
  )();

  TextColumn get notificationClock => textEnum<NotificationClock>().withDefault(
    Constant(NotificationClock.live.name),
  )();

  @override
  Set<Column> get primaryKey => {id};
}
