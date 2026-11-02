import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/database.dart';
import 'package:gym_tracker/shared/format.dart';

void main() {
  test('weights are shown and typed in the chosen unit, stored in kg', () {
    expect(formatWeight(60, WeightUnit.kg), '60');
    expect(formatWeight(57.5, WeightUnit.kg), '57.5');
    expect(formatWeight(20, WeightUnit.lb), '44.09');

    final kg = parseWeight('45', WeightUnit.lb)!;
    expect(kg, closeTo(20.4117, 1e-4));
    expect(formatWeight(kg, WeightUnit.lb), '45');
    expect(parseWeight('57,5', WeightUnit.kg), 57.5);
    expect(parseWeight('', WeightUnit.lb), isNull);
  });

  test('ISO week numbers and workout lengths', () {
    expect(isoWeek(DateTime(2026, 10, 18)), 42); // a Sunday
    expect(isoWeek(DateTime(2026, 10, 12)), 42);
    expect(isoWeek(DateTime(2027, 1, 1)), 53); // Friday: still 2026's week
    expect(isoWeek(DateTime(2024, 12, 30)), 1); // Monday: already 2025's
    // Sunday and Saturday weeks: week 1 holds 1 January.
    expect(weekNumber(DateTime(2026, 10, 18), DateTime.sunday), 43);
    expect(weekNumber(DateTime(2025, 12, 28), DateTime.sunday), 1);
    expect(weekNumber(DateTime(2026, 1, 4), DateTime.sunday), 2);
    expect(weekNumber(DateTime(2025, 12, 27), DateTime.saturday), 1);
    expect(weekNumber(DateTime(2025, 12, 20), DateTime.saturday), 52);
    expect(weekNumber(DateTime(2026, 10, 12), DateTime.monday), 42);
    // The year a week number belongs to.
    expect(weekYear(DateTime(2024, 12, 30), DateTime.monday), 2025);
    expect(weekYear(DateTime(2026, 12, 28), DateTime.monday), 2026);
    expect(weekYear(DateTime(2025, 12, 28), DateTime.sunday), 2026);
    expect(weekYear(DateTime(2025, 12, 20), DateTime.saturday), 2025);
    expect(formatHoursMinutes(const Duration(minutes: 45)), '45 min');
    expect(formatHoursMinutes(const Duration(minutes: 65)), '1 h 05');
  });

  test('days ago counts calendar days, not 24 hours', () {
    final now = DateTime(2026, 11, 2, 0, 30);
    expect(daysAgo(DateTime(2026, 11, 2), now), 'today');
    expect(daysAgo(DateTime(2026, 11, 1, 23), now), 'yesterday');
    expect(daysAgo(DateTime(2026, 10, 29, 18), now), '4 days ago');
  });
}
