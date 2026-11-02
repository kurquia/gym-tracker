import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers.dart';
import 'body_view.dart';

/// Full-screen interactive 3D body of one exercise or finished workout, opened
/// by tapping its front or [back] figure. Empty while it is still loading.
class Body3dScreen extends ConsumerWidget {
  const Body3dScreen.exercise({
    super.key,
    required int this.exerciseId,
    required this.back,
  }) : sessionId = null;

  const Body3dScreen.workout({
    super.key,
    required int this.sessionId,
    required this.back,
  }) : exerciseId = null;

  final int? exerciseId;
  final int? sessionId;
  final bool back;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseId = this.exerciseId;
    final String title;
    final BodyHighlight? highlight;
    if (exerciseId != null) {
      final detail = ref.watch(exerciseDetailProvider(exerciseId)).value;
      title = detail?.exercise.name ?? '';
      highlight = detail == null
          ? null
          : BodyHighlight.ofExercise(detail.muscles);
    } else {
      final workout = ref
          .watch(workoutHistoryProvider)
          .value
          ?.where((w) => w.session.id == sessionId)
          .firstOrNull;
      title = workout?.title ?? '';
      highlight = workout == null
          ? null
          : BodyHighlight.fromRoles(workout.muscles);
    }
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: switch (highlight) {
        null => const SizedBox.shrink(),
        final h => BodyKeyFilter(
          highlight: h,
          hint: 'Drag to turn · pinch to zoom · tap a muscle',
          builder: (context, shown, legend) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: WithBodyModel(
                    (model) => BodyView(
                      model: model,
                      highlight: shown,
                      initialYaw: back ? backYaw : frontYaw,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                legend,
              ],
            ),
          ),
        ),
      },
    );
  }
}
