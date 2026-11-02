import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Id of the open workout the user paused away from (back button → Pause),
/// so Record shows the routine chooser with a resume bar instead.
/// In-memory only: after an app restart the workout simply shows again.
class HiddenWorkout extends Notifier<int?> {
  @override
  int? build() => null;

  void hide(int sessionId) => state = sessionId;

  void resume() => state = null;
}

final hiddenWorkoutProvider = NotifierProvider<HiddenWorkout, int?>(
  HiddenWorkout.new,
);
