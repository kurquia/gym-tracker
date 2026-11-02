// Turns data into text: dates, weights in the chosen unit, sets and the clock;
// also parses typed weights.

import '../data/database.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// "Mon 12 Oct"
String formatDay(DateTime d) =>
    '${_weekdays[d.weekday - 1]} ${d.day} ${_monthNames[d.month - 1].substring(0, 3)}';

/// "Mon 12 Oct 2026"
String formatDate(DateTime d) => '${formatDay(d)} ${d.year}';

/// "today", "yesterday", "3 days ago": calendar days from [d] to [now].
String daysAgo(DateTime d, DateTime now) {
  final days = DateTime.utc(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime.utc(d.year, d.month, d.day)).inDays;
  return switch (days) {
    0 => 'today',
    1 => 'yesterday',
    _ => '$days days ago',
  };
}

/// "October 2026"
String formatMonth(DateTime d) => '${monthName(d)} ${d.year}';

/// "October"
String monthName(DateTime d) => _monthNames[d.month - 1];

/// "Mon"
String weekdayName(DateTime d) => _weekdays[d.weekday - 1];

/// 18:05
String formatTimeOfDay(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// "body only" → "Body only"
String sentenceCase(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Exactly, by definition.
const kgPerLb = 0.45359237;

extension WeightUnitConversion on WeightUnit {
  double fromKg(double kg) => this == WeightUnit.lb ? kg / kgPerLb : kg;
  double toKg(double value) => this == WeightUnit.lb ? value * kgPerLb : value;
}

/// [kg] in [unit], at most 2 decimals: 60 → "60", 57.5 → "57.5",
/// 20 kg in lb → "44.09".
String formatWeight(double kg, WeightUnit unit) {
  final v = (unit.fromKg(kg) * 100).round() / 100;
  return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

/// "60×10", "BW×8", "+10×5", "−30×10", with " (W)", " (D)" or " (F)" for
/// warm-up, drop and failure sets. With [typedAs], plain weights as typed for
/// that exercise (e.g. per side).
String formatSet(
  WorkoutSet s,
  WeightUnit unit, {
  bool markKind = true,
  Exercise? typedAs,
}) {
  final w = s.weightKg;
  final kg = w == null
      ? '?'
      : formatWeight(
          typedAs != null && s.loadType == LoadType.weight
              ? typedAs.typedFromKg(w)
              : w,
          unit,
        );
  final load = switch (s.loadType) {
    LoadType.weight => kg,
    LoadType.bodyweight => 'BW',
    LoadType.weighted => '+$kg',
    LoadType.assisted => '−$kg',
  };
  final kind = markKind ? kindLetter(s.kind) : null;
  return '$load×${s.reps ?? '?'}${kind == null ? '' : ' ($kind)'}';
}

/// 1:02:03 or 12:03
String formatClock(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(h > 0 ? 2 : 1, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

/// Typed weight in [unit] → kg. Accepts "57,5" as well as "57.5"
/// (Danish keyboards type commas).
double? parseWeight(String text, WeightUnit unit) {
  final v = double.tryParse(text.trim().replaceAll(',', '.'));
  return v == null ? null : unit.toKg(v);
}

/// W, D or F for a warm-up, drop or failure set; null for a normal one.
String? kindLetter(SetKind kind) => switch (kind) {
  SetKind.normal => null,
  SetKind.warmup => 'W',
  SetKind.drop => 'D',
  SetKind.failure => 'F',
};

/// As in Record: 1, 2, 3 … for normal sets, a failure set keeps its number
/// ("2F"), warm-ups and drops get their letter (see [kindLetter]).
List<String> setLabels(List<WorkoutSet> sets) {
  var n = 0;
  return [
    for (final s in sets)
      switch (s.kind) {
        SetKind.normal => '${++n}',
        SetKind.failure => '${++n}F',
        SetKind.warmup || SetKind.drop => kindLetter(s.kind)!,
      },
  ];
}

/// Number of the week starting on [start]: ISO 8601 for weeks starting on
/// Monday, otherwise week 1 is the one holding 1 January (as in the US).
int weekNumber(DateTime start, int firstWeekday) {
  if (firstWeekday == DateTime.monday) return isoWeek(start);
  final last = DateTime(start.year, start.month, start.day + 6);
  final jan1 = DateTime(last.year);
  final week1 = DateTime.utc(
    jan1.year,
    1,
    1 - (jan1.weekday - firstWeekday) % 7,
  );
  return DateTime.utc(
            start.year,
            start.month,
            start.day,
          ).difference(week1).inDays ~/
          7 +
      1;
}

/// The year [weekNumber] counts the week starting on [start] in: the year of
/// its Thursday (ISO) or of its last day.
int weekYear(DateTime start, int firstWeekday) => DateTime(
  start.year,
  start.month,
  start.day + (firstWeekday == DateTime.monday ? 3 : 6),
).year;

/// ISO 8601 week number (weeks start on Monday; week 1 holds the year's
/// first Thursday).
int isoWeek(DateTime d) {
  final thursday = DateTime.utc(d.year, d.month, d.day + 4 - d.weekday);
  final jan1 = DateTime.utc(thursday.year);
  return thursday.difference(jan1).inDays ~/ 7 + 1;
}

/// "1 h 05", "45 min"
String formatHoursMinutes(Duration d) => d.inHours == 0
    ? '${d.inMinutes} min'
    : '${d.inHours} h ${(d.inMinutes % 60).toString().padLeft(2, '0')}';

/// "1 set", "3 sets".
String countOf(int n, String noun) => '$n $noun${n == 1 ? '' : 's'}';
