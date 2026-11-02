import 'package:flutter/material.dart';

import '../../shared/format.dart';

/// A whole year: twelve small months of dots, workout days white (user's
/// pick, 2026-10-18). Tap a month to open it; the chevrons and a horizontal
/// swipe change the year, from [firstYear] to [lastYear].
class YearCalendar extends StatelessWidget {
  const YearCalendar({
    super.key,
    required this.year,
    required this.firstYear,
    required this.lastYear,
    required this.workoutDays,
    required this.onMonthTap,
    required this.onYearChanged,
    required this.firstWeekday,
  });

  final int year;
  final int firstYear;
  final int lastYear;

  /// Midnight of every day with a workout.
  final Set<DateTime> workoutDays;
  final ValueChanged<DateTime> onMonthTap;
  final ValueChanged<int> onYearChanged;

  /// [DateTime.monday] … [DateTime.sunday].
  final int firstWeekday;

  /// Goes to [to]; null past the limits.
  VoidCallback? _goTo(int to) =>
      to < firstYear || to > lastYear ? null : () => onYearChanged(to);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final months = [for (var m = 1; m <= 12; m++) DateTime(year, m)];
    return GestureDetector(
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v.abs() > 200) _goTo(year + (v < 0 ? 1 : -1))?.call();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous year',
                  onPressed: _goTo(year - 1),
                ),
                Expanded(
                  child: Text(
                    '$year',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next year',
                  onPressed: _goTo(year + 1),
                ),
              ],
            ),
          ),
          // Rows of three, each as tall as its longest month.
          for (var r = 0; r < 12; r += 3)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final m in months.sublist(r, r + 3))
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _MiniMonth(month: m, year: this),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One month as a grid of days, with its name above.
class _MiniMonth extends StatelessWidget {
  const _MiniMonth({required this.month, required this.year});

  final DateTime month;
  final YearCalendar year;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final lead = (month.weekday - year.firstWeekday) % 7;
    final today = DateTime.now();
    final current = DateUtils.isSameMonth(month, today);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => year.onMonthTap(month),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 4),
              child: Text(
                monthName(month),
                style: textTheme.labelMedium?.copyWith(
                  color: current
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.white70,
                  fontWeight: current ? FontWeight.bold : null,
                ),
              ),
            ),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 0; i < lead; i++) const SizedBox(),
                for (var d = 1; d <= days; d++)
                  _dayCell(DateTime(month.year, month.month, d), today, scheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayCell(DateTime day, DateTime today, ColorScheme scheme) => Center(
    child: Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: year.workoutDays.contains(day) ? scheme.primary : Colors.white12,
        border: DateUtils.isSameDay(day, today)
            ? Border.all(color: scheme.onSurface, width: 1.5)
            : null,
      ),
    ),
  );
}
