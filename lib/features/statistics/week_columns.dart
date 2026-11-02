import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../shared/format.dart';
import '../../shared/theme.dart';
import 'workout_card.dart';

/// The workouts of one week side by side, one column each, in rows of three
/// filled in turn like electron shells (4 = 3 + 1): a row of one sits in the
/// middle, two on the thirds, three fill the width (user's layout,
/// 2026-10-18).
class WeekColumns extends StatelessWidget {
  const WeekColumns({super.key, required this.start, required this.byDay});

  /// Midnight of the week's first day.
  final DateTime start;
  final Map<DateTime, List<WorkoutSummary>> byDay;

  static const _gap = 8.0;

  @override
  Widget build(BuildContext context) {
    final workouts = [
      for (var i = 0; i < 7; i++)
        ...?byDay[DateTime(start.year, start.month, start.day + i)],
    ];
    if (workouts.isEmpty) return const SizedBox();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final column = (width - 2 * _gap) / 3;
        final children = <Widget>[];
        for (var from = 0; from < workouts.length; from += 3) {
          final n = workouts.length - from < 3 ? workouts.length - from : 3;
          if (from > 0) children.add(const SizedBox(height: _gap));
          // Centred on the middle, on the thirds, or filling the row.
          final (lead, gap) = switch (n) {
            1 => ((width - column) / 2, 0.0),
            2 => (width / 3 - column / 2, width / 3 - column),
            _ => (0.0, _gap),
          };
          children.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: lead),
                  for (final (i, w)
                      in workouts.sublist(from, from + n).indexed) ...[
                    if (i > 0) SizedBox(width: gap),
                    SizedBox(
                      width: column,
                      child: WeekColumnCard(workout: w),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        return Column(children: children);
      },
    );
  }
}

/// One workout as a short card: day, title on one line (so the dividers line
/// up), divider, body figure, then the number of exercises. The figure opens
/// in 3D, the rest of the card opens the workout (user's picks, 2026-10-18).
class WeekColumnCard extends StatelessWidget {
  const WeekColumnCard({super.key, required this.workout});

  final WorkoutSummary workout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final started = workout.session.startedAt;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/statistics/workout/${workout.session.id}'),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // The week's title already names the month.
                '${weekdayName(started)} ${started.day}',
                style: textTheme.labelMedium.faint,
              ),
              Text(
                workout.title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(height: 14),
              WorkoutFigures(workout: workout, height: 96),
              const SizedBox(height: 6),
              Text(
                countOf(workout.exerciseNames.length, 'exercise'),
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
