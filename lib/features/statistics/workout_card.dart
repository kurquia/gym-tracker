import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../shared/format.dart';
import '../../shared/theme.dart';
import '../exercises/body_model/body_view.dart';

/// Front and back of the body with [workout]'s muscles coloured as on the
/// exercise pages (target red, synergist orange, fixator yellow; the
/// strongest role over its exercises wins); tapping one opens it in 3D.
/// Nothing when none of them is on the model.
class WorkoutFigures extends StatelessWidget {
  const WorkoutFigures({
    super.key,
    required this.workout,
    required this.height,
  });

  final WorkoutSummary workout;
  final double height;

  @override
  Widget build(BuildContext context) {
    final highlight = BodyHighlight.fromRoles(workout.muscles);
    if (!highlight.onModel) return const SizedBox();
    return SizedBox(
      height: height,
      child: BodyFigures(
        highlight: highlight,
        route: '/statistics/workout/${workout.session.id}/3d',
      ),
    );
  }
}

/// A finished workout in the month view: its exercises with their sets and
/// a small body figure of the muscles it worked. The figure opens in 3D, the
/// rest of the card opens the workout.
class WorkoutCard extends StatelessWidget {
  const WorkoutCard({super.key, required this.workout});

  final WorkoutSummary workout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final clock = Duration(milliseconds: workout.session.clockMillis);
    final header = [
      Text(
        workout.title,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      // "12 sets · 1 h 05"
      Text(
        [
          countOf(workout.setCount, 'set'),
          if (clock > Duration.zero) formatHoursMinutes(clock),
        ].join(' · '),
        style: textTheme.bodySmall.muted,
      ),
    ];
    final exercises = [
      for (final (i, name) in workout.exerciseNames.indexed)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${workout.exerciseSets[i]}',
                style: textTheme.bodyMedium.faint,
              ),
            ],
          ),
        ),
    ];
    // Figure on the right, under the divider (user's picks, 2026-10-18).
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...header,
        const Divider(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: exercises,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 104,
              child: WorkoutFigures(workout: workout, height: 132),
            ),
          ],
        ),
      ],
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/statistics/workout/${workout.session.id}'),
        child: Padding(padding: const EdgeInsets.all(12), child: body),
      ),
    );
  }
}
