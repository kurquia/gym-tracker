import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';
import '../../shared/widgets/confirm.dart';
import '../../shared/widgets/placeholder_body.dart';
import 'hidden_workout.dart';

/// The Record tab with no workout on screen: resume the paused one, or start
/// from a routine.
class ChooseRoutineView extends ConsumerWidget {
  const ChooseRoutineView({super.key, this.pausedWorkout});

  /// Open workout the user paused away from; shown as a resume bar on top.
  final ActiveWorkout? pausedWorkout;

  /// Starts a workout, unless one is paused: then offers to resume that one.
  Future<void> _start(
    BuildContext context,
    WidgetRef ref, {
    int? routineId,
  }) async {
    final paused = pausedWorkout;
    if (paused == null) {
      await ref
          .read(databaseProvider)
          .workoutsDao
          .startWorkout(routineId: routineId);
      return;
    }
    final resume = await confirm(
      context,
      title: 'Workout in progress',
      message: 'Finish or discard “${paused.title}” before starting another.',
      action: 'Resume',
    );
    if (resume && context.mounted) {
      ref.read(hiddenWorkoutProvider.notifier).resume();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);
    final lastDone = ref.watch(routineLastDoneProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(title: const Text('Record')),
      body: routines.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => PlaceholderBody(text: 'Could not load routines.\n$e'),
        data: (all) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (pausedWorkout case final w?) ...[
              Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Resume workout'),
                  subtitle: Text(
                    '${w.title} · ${formatClock(w.clockAt(DateTime.now()))}',
                  ),
                  trailing: const Icon(Icons.play_circle_outline, size: 32),
                  onTap: () =>
                      ref.read(hiddenWorkoutProvider.notifier).resume(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Choose a routine',
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            if (all.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No routines yet. Create one in the Routines tab, '
                  'or start an empty workout.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            for (final r in all)
              Card(
                child: ListTile(
                  title: Text(r.routine.name),
                  subtitle: Text(
                    [
                      countOf(r.exerciseCount, 'exercise'),
                      if (lastDone[r.routine.id] case final d?)
                        'last: ${formatDay(d)}',
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.play_circle_outline, size: 32),
                  onTap: () => _start(context, ref, routineId: r.routine.id),
                ),
              ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _start(context, ref),
              child: const Text('Start empty workout'),
            ),
          ],
        ),
      ),
    );
  }
}
