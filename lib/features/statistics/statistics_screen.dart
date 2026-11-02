import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/placeholder_body.dart';
import 'exercise_progress_view.dart';
import 'week_columns.dart';
import 'workout_card.dart';
import 'year_calendar.dart';

enum CalendarView { week, month, year }

/// What Statistics shows, picked from the ☰ menu.
enum StatisticsMode { calendar, exercises }

/// Calendar (week, month or year) with workout days filled in, tap a day for
/// its workouts; or one exercise's progress.
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  CalendarView _view = CalendarView.month;
  StatisticsMode _mode = StatisticsMode.calendar;
  int? _exerciseId;
  ChartRange _range = ChartRange.month3;
  ProgressPlot _plot = ProgressPlot.oneRepMax;

  /// `build` watches it.
  int get _firstWeekday => ref.read(firstWeekdayProvider);

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  /// The limits of every calendar view: TableCalendar fails outside them.
  static final _firstDay = DateTime(2000);
  DateTime get _lastDay => DateTime(DateTime.now().year + 10, 12, 31);

  /// Midnight of the first day of [d]'s week.
  DateTime _weekStart(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - _firstWeekday) % 7);

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(workoutHistoryProvider);
    ref.watch(firstWeekdayProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          PopupMenuButton<StatisticsMode>(
            icon: const Icon(Icons.menu),
            tooltip: 'Show',
            onSelected: (mode) => setState(() => _mode = mode),
            itemBuilder: (_) => [
              for (final (mode, label) in [
                (StatisticsMode.calendar, 'Calendar'),
                (StatisticsMode.exercises, 'Exercises'),
              ])
                CheckedPopupMenuItem(
                  value: mode,
                  checked: mode == _mode,
                  child: Text(label),
                ),
            ],
          ),
        ],
      ),
      body: _mode == StatisticsMode.exercises
          ? ExerciseProgressView(
              exerciseId: _exerciseId,
              onPick: (id) => setState(() => _exerciseId = id),
              range: _range,
              onRange: (r) => setState(() => _range = r),
              plot: _plot,
              onPlot: (p) => setState(() => _plot = p),
            )
          : history.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  PlaceholderBody(text: 'Could not load workouts.\n$e'),
              data: (all) {
                final byDay = <DateTime, List<WorkoutSummary>>{};
                for (final w in all) {
                  byDay
                      .putIfAbsent(_dayOf(w.session.startedAt), () => [])
                      .add(w);
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    const SizedBox(height: 8),
                    _viewSwitch(),
                    const SizedBox(height: 4),
                    if (_view == CalendarView.year)
                      YearCalendar(
                        year: _focused.year,
                        firstYear: _firstDay.year,
                        lastYear: _lastDay.year,
                        workoutDays: byDay.keys.toSet(),
                        firstWeekday: _firstWeekday,
                        onMonthTap: (month) => setState(() {
                          _view = CalendarView.month;
                          _focused = month;
                          _selected = null;
                        }),
                        onYearChanged: (year) => setState(
                          () => _focused = DateTime(year, _focused.month),
                        ),
                      )
                    else
                      _calendar(context, byDay),
                    if (_view == CalendarView.week) ...[
                      const SizedBox(height: 16),
                      WeekColumns(start: _weekStart(_focused), byDay: byDay),
                      // The header names the week; the count goes under its boxes.
                      const SizedBox(height: 16),
                      _summary(context, all),
                    ] else ...[
                      const SizedBox(height: 8),
                      _summary(context, all),
                      if (_view == CalendarView.month)
                        if (_selected case final day?)
                          ..._dayWorkouts(context, day, byDay),
                    ],
                  ],
                );
              },
            ),
    );
  }

  Widget _viewSwitch() => Center(
    child: SegmentedButton<CalendarView>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: CalendarView.week, label: Text('Week')),
        ButtonSegment(value: CalendarView.month, label: Text('Month')),
        ButtonSegment(value: CalendarView.year, label: Text('Year')),
      ],
      selected: {_view},
      onSelectionChanged: (v) => setState(() {
        _view = v.single;
        _selected = null;
      }),
    ),
  );

  Widget _calendar(
    BuildContext context,
    Map<DateTime, List<WorkoutSummary>> byDay,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final muted = textTheme.bodySmall.faint;
    return TableCalendar<void>(
      firstDay: _firstDay,
      lastDay: _lastDay,
      focusedDay: _focused,
      currentDay: now,
      startingDayOfWeek: StartingDayOfWeek.values[_firstWeekday - 1],
      calendarFormat: _view == CalendarView.week
          ? CalendarFormat.week
          : CalendarFormat.month,
      availableGestures: AvailableGestures.horizontalSwipe,
      rowHeight: 48,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextFormatter: (d, _) => formatMonth(d),
        titleTextStyle: textTheme.titleMedium!,
        leftChevronIcon: const Icon(Icons.chevron_left),
        rightChevronIcon: const Icon(Icons.chevron_right),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        dowTextFormatter: (d, _) => weekdayName(d),
        weekdayStyle: muted!,
        weekendStyle: muted,
      ),
      // The week view shows all its workouts below; days aren't picked there.
      selectedDayPredicate: (d) =>
          _view == CalendarView.month && isSameDay(d, _selected),
      onDaySelected: (day, focused) => setState(() {
        if (_view == CalendarView.month) _selected = _dayOf(day);
        _focused = focused;
      }),
      onPageChanged: (focused) => setState(() => _focused = focused),
      calendarBuilders: CalendarBuilders(
        // "Week 39" big, its days under it.
        headerTitleBuilder: _view == CalendarView.week
            ? (context, focused) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Week ${weekNumber(_weekStart(focused), _firstWeekday)}',
                    style: textTheme.headlineSmall,
                  ),
                  Text(_weekTitle(focused), style: textTheme.bodyMedium.muted),
                ],
              )
            : null,
        prioritizedBuilder: (context, day, focused) => _DayCell(
          day: day,
          workout: byDay.containsKey(_dayOf(day)),
          today: isSameDay(day, now),
          selected: isSameDay(day, _selected),
          outside: _view == CalendarView.month && day.month != focused.month,
        ),
      ),
    );
  }

  /// "13 – 19 October 2026", "29 September – 5 October 2026"
  String _weekTitle(DateTime focused) {
    final start = _weekStart(focused);
    final end = DateTime(start.year, start.month, start.day + 6);
    final from = start.month == end.month
        ? '${start.day}'
        : start.year == end.year
        ? '${start.day} ${monthName(start)}'
        : '${start.day} ${formatMonth(start)}';
    return '$from – ${end.day} ${formatMonth(end)}';
  }

  Widget _summary(BuildContext context, List<WorkoutSummary> all) {
    final DateTime from, to;
    final String span;
    switch (_view) {
      case CalendarView.week:
        from = _weekStart(_focused);
        to = DateTime(from.year, from.month, from.day + 7);
        span = '';
      case CalendarView.month:
        from = DateTime(_focused.year, _focused.month);
        to = DateTime(_focused.year, _focused.month + 1);
        span = monthName(_focused);
      case CalendarView.year:
        from = DateTime(_focused.year);
        to = DateTime(_focused.year + 1);
        span = '${_focused.year}';
    }
    final n = all.where((w) {
      final t = w.session.startedAt;
      return !t.isBefore(from) && t.isBefore(to);
    }).length;
    final count = n == 0 ? 'No workouts' : countOf(n, 'workout');
    return Text(
      span.isEmpty ? count : '$count in $span',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium.muted,
    );
  }

  List<Widget> _dayWorkouts(
    BuildContext context,
    DateTime day,
    Map<DateTime, List<WorkoutSummary>> byDay,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final workouts = byDay[day] ?? const [];
    return [
      const SizedBox(height: 24),
      Text(formatDate(day), style: textTheme.titleMedium),
      const SizedBox(height: 8),
      if (workouts.isEmpty)
        Text('No workout this day.', style: textTheme.bodyMedium.faint),
      for (final w in workouts) WorkoutCard(workout: w),
    ];
  }
}

/// A day number; workout days are filled white discs, the selected day has a
/// ring around it and today a faint one.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.workout,
    required this.today,
    required this.selected,
    required this.outside,
  });

  final DateTime day;
  final bool workout;
  final bool today;
  final bool selected;
  final bool outside;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = workout
        ? (outside ? Colors.white24 : scheme.primary)
        : Colors.transparent;
    final textColor = workout && !outside
        ? scheme.onPrimary
        : (outside ? Colors.white24 : Theme.of(context).colorScheme.onSurface);
    final ring = selected
        ? Border.all(color: scheme.primary, width: 2)
        : today
        ? Border.all(color: Colors.white54)
        : null;
    return Center(
      child: Container(
        width: 42,
        height: 42,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(shape: BoxShape.circle, border: ring),
        child: DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, color: fill),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: today ? FontWeight.bold : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
