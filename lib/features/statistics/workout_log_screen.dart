import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/confirm.dart';
import '../../shared/widgets/placeholder_body.dart';
import '../exercises/body_model/body_view.dart';

/// A finished workout: every exercise with its sets.
class WorkoutLogScreen extends ConsumerWidget {
  const WorkoutLogScreen({super.key, required this.sessionId});

  final int sessionId;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    WorkoutLog w,
  ) async {
    final sets = w.exercises.fold(0, (n, e) => n + e.sets.length);
    final ok = await confirm(
      context,
      title: 'Delete workout?',
      message:
          '${formatDate(w.session.startedAt)}: ${w.exercises.length} '
          'exercises, $sets sets. This can\'t be undone.',
      action: 'Delete',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    // Leave the page first, so it never shows "Workout not found".
    final db = ref.read(databaseProvider);
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    await db.workoutsDao.discardWorkout(sessionId);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Workout deleted.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(workoutLogProvider(sessionId));
    final unit = ref.watch(weightUnitProvider);
    final textTheme = Theme.of(context).textTheme;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final muted = textTheme.bodyMedium?.copyWith(
      color: onSurface.withValues(alpha: 0.7),
    );
    return log.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: PlaceholderBody(text: 'Could not load the workout.\n$e'),
      ),
      data: (w) {
        if (w == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const PlaceholderBody(text: 'Workout not found.'),
          );
        }
        final s = w.session;
        return Scaffold(
          appBar: AppBar(
            title: Text(w.title),
            actions: [
              IconButton(
                tooltip: 'Delete workout',
                color: Theme.of(context).colorScheme.error,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, ref, w),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // The date in Record's Previous amber, as by each exercise there.
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: formatDate(s.startedAt),
                      style: const TextStyle(color: previousColour),
                    ),
                    TextSpan(
                      text: [
                        '',
                        formatTimeOfDay(s.startedAt),
                        if (s.clockMillis > 0)
                          formatClock(Duration(milliseconds: s.clockMillis)),
                      ].join(' · '),
                    ),
                  ],
                ),
                style: muted,
              ),
              if (s.notes case final notes?) ...[
                const SizedBox(height: 4),
                Text(
                  notes,
                  style: textTheme.bodySmall?.copyWith(
                    color: onSurface.withValues(alpha: 0.54),
                  ),
                ),
              ],
              for (final e in w.exercises) ...[
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.exercise.name, style: textTheme.titleMedium),
                          if (setupSummary(e.setup) case final setup
                              when setup.isNotEmpty)
                            Text(setup, style: muted),
                          if (e.entry.note case final note?)
                            Text(
                              note,
                              style: muted?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          const SizedBox(height: 4),
                          for (final (i, label) in setLabels(e.sets).indexed)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      label,
                                      style: textTheme.labelLarge?.copyWith(
                                        color: setKindColour(
                                          e.sets[i].kind,
                                          onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    formatSet(e.sets[i], unit, markKind: false),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    _ExerciseFigures(
                      sessionId: sessionId,
                      exerciseId: e.exercise.id,
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Front and back of the body with one exercise's muscles coloured as on its
/// page; tapping one opens it in 3D. Nothing when none is on the model.
class _ExerciseFigures extends ConsumerWidget {
  const _ExerciseFigures({required this.sessionId, required this.exerciseId});

  final int sessionId;
  final int exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const width = 110.0, height = 110.0;
    final detail = ref.watch(exerciseDetailProvider(exerciseId)).value;
    if (detail == null) return SizedBox(width: width);
    final highlight = BodyHighlight.ofExercise(detail.muscles);
    if (!highlight.onModel) return SizedBox(width: width);
    return SizedBox(
      width: width,
      height: height,
      child: BodyFigures(
        highlight: highlight,
        route: '/statistics/workout/$sessionId/exercise/$exerciseId/3d',
      ),
    );
  }
}
