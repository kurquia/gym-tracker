import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../shared/widgets/placeholder_body.dart';
import 'active_workout_view.dart';
import 'choose_routine_view.dart';
import 'hidden_workout.dart';

/// Shows the workout in progress, or the routine chooser when there is none
/// or the user paused away from it.
class RecordScreen extends ConsumerWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(hiddenWorkoutProvider);
    return ref
        .watch(activeWorkoutProvider)
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(
            appBar: AppBar(title: const Text('Record')),
            body: PlaceholderBody(text: 'Could not load the workout.\n$e'),
          ),
          data: (workout) => switch (workout) {
            null => const ChooseRoutineView(),
            _ when workout.session.id == hidden => ChooseRoutineView(
              pausedWorkout: workout,
            ),
            _ => ActiveWorkoutView(workout: workout),
          },
        );
  }
}
