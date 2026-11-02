import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../data/workout_logic.dart';
import '../theme.dart';

/// Bottom-tab scaffold. Each tab keeps its own navigation state.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Routines'),
          NavigationDestination(
            icon: Icon(Icons.timeline),
            label: 'Statistics',
          ),
          NavigationDestination(icon: _RecordIcon(), label: 'Record'),
          NavigationDestination(
            icon: Icon(Icons.menu_book),
            label: 'Exercises',
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

/// The Record tab's icon, with a red lamp while a workout is open.
class _RecordIcon extends ConsumerWidget {
  const _RecordIcon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clockRunning = ref.watch(
      activeWorkoutProvider.select((w) {
        final session = w.value?.session;
        return session == null ? null : session.clockRunningSince != null;
      }),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.fitness_center),
        if (clockRunning != null)
          Positioned(
            top: -2,
            right: -3,
            child: _RecordingDot(fading: clockRunning),
          ),
      ],
    );
  }
}

/// Fades slowly in and out while the clock runs, like a camera's REC lamp;
/// steady while it's paused or not started.
class _RecordingDot extends StatefulWidget {
  const _RecordingDot({required this.fading});

  final bool fading;

  @override
  State<_RecordingDot> createState() => _RecordingDotState();
}

class _RecordingDotState extends State<_RecordingDot>
    with SingleTickerProviderStateMixin {
  late final _fade = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
    lowerBound: 0.25,
    value: 1,
  );

  @override
  void initState() {
    super.initState();
    _follow();
  }

  @override
  void didUpdateWidget(_RecordingDot old) {
    super.didUpdateWidget(old);
    if (old.fading != widget.fading) _follow();
  }

  void _follow() {
    if (widget.fading) {
      _fade.repeat(reverse: true);
    } else {
      _fade.value = 1;
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          color: recordingColour,
          shape: BoxShape.circle,
        ),
        child: SizedBox.square(dimension: 10),
      ),
    );
  }
}
