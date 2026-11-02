import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/backup_store.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/confirm.dart';
import '../settings/workout_settings_screen.dart';
import 'exercise_pager.dart';
import 'hidden_workout.dart';
import 'workout_notification.dart';

enum _LeaveAction { pause, finish }

/// The open workout: the clock, the exercise pages, and leaving it (pause or
/// finish).
class ActiveWorkoutView extends ConsumerWidget {
  const ActiveWorkoutView({super.key, required this.workout});

  final ActiveWorkout workout;

  Future<void> _finish(
    BuildContext context,
    AppDatabase db,
    Backups? backups,
  ) async {
    final unticked = [
      for (final e in workout.exercises)
        for (final s in e.sets)
          if (s.completedAt == null) s,
    ].length;
    final ok = await confirm(
      context,
      title: 'Finish workout?',
      message: unticked == 0
          ? null
          : '${countOf(unticked, 'unticked set')} will be discarded.',
      action: 'Finish',
    );
    if (!ok) return;
    final saved = await db.workoutsDao.finishWorkout(workout.session.id);
    if (saved) unawaited(backups?.autoInBackground());
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved ? 'Workout saved.' : 'No sets ticked: workout discarded.',
        ),
      ),
    );
  }

  /// Android back: Cancel stays, Pause hides the workout (clock paused) behind
  /// the routine chooser, Finish runs [_finish].
  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final hidden = ref.read(hiddenWorkoutProvider.notifier);
    final backups = ref.read(backupsProvider);
    final action = await showDialog<_LeaveAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave workout?'),
        content: const Text(
          'Pause keeps it open: resume it from Record any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _LeaveAction.pause),
            child: const Text('Pause'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _LeaveAction.finish),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    switch (action) {
      case null:
        return;
      case _LeaveAction.pause:
        if (workout.session.clockRunningSince != null) {
          await db.workoutsDao.toggleClock(workout.session.id);
        }
        hidden.hide(workout.session.id);
      case _LeaveAction.finish:
        await _finish(context, db, backups);
    }
  }

  Future<void> _discard(BuildContext context, AppDatabase db) async {
    final ok = await confirm(
      context,
      title: 'Discard workout?',
      message: 'Everything logged in this workout is deleted.',
      action: 'Discard',
      destructive: true,
    );
    if (ok) await db.workoutsDao.discardWorkout(workout.session.id);
  }

  Future<void> _addExercises(BuildContext context, AppDatabase db) async {
    final picked = await context.push<List<Exercise>>(
      '/exercises/pick',
      extra: {for (final e in workout.exercises) e.exercise.id},
    );
    if (picked != null) {
      await db.workoutsDao.addExercises(workout.session.id, [
        for (final e in picked) e.id,
      ]);
    }
  }

  /// A menu entry whose choices open beside it, the current one ticked.
  static Widget _choices<T>({
    required IconData icon,
    required String title,
    required Map<T, String> labels,
    required T selected,
    required ValueChanged<T> onSelected,
  }) => SubmenuButton(
    leadingIcon: Icon(icon),
    menuChildren: [
      for (final MapEntry(key: value, value: label) in labels.entries)
        MenuItemButton(
          leadingIcon: value == selected
              ? const Icon(Icons.check)
              : const SizedBox(width: 24),
          onPressed: () => onSelected(value),
          child: Text(label),
        ),
    ],
    child: Text(title),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final settings =
        ref.watch(settingsProvider).value ?? SettingsDao.defaultSettings;
    final restStyle = settings.restStyle;
    final page = Scaffold(
      appBar: AppBar(
        title: Text(workout.title),
        actions: [
          FilledButton(
            onPressed: () => _finish(context, db, ref.read(backupsProvider)),
            child: const Text('Finish'),
          ),
          MenuAnchor(
            builder: (context, menu, _) => IconButton(
              tooltip: 'Workout options',
              icon: const Icon(Icons.more_vert),
              onPressed: () => menu.isOpen ? menu.close() : menu.open(),
            ),
            menuChildren: [
              _choices(
                icon: Icons.timer_outlined,
                title: 'Clock',
                labels: restStyleLabels,
                selected: settings.restStyle,
                onSelected: (style) => db.settingsDao.updateSettings(
                  SettingsTableCompanion(restStyle: Value(style)),
                ),
              ),
              _choices(
                icon: Icons.notifications_outlined,
                title: 'Rest alert',
                labels: restAlertLabels,
                selected: settings.restAlert,
                onSelected: (alert) => db.settingsDao.updateSettings(
                  SettingsTableCompanion(restAlert: Value(alert)),
                ),
              ),
              const Divider(),
              MenuItemButton(
                style: MenuItemButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  iconColor: Theme.of(context).colorScheme.error,
                ),
                leadingIcon: const Icon(Icons.delete_outline),
                onPressed: () => _discard(context, db),
                child: const Text('Discard workout'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _Clock(
            workout: workout,
            restStyle: restStyle,
            onToggle: () => db.workoutsDao.toggleClock(workout.session.id),
            onReset: () => db.workoutsDao.resetClock(workout.session.id),
          ),
          const Divider(height: 1),
          Expanded(
            child: ExercisePager(
              workout: workout,
              onAddExercises: () => _addExercises(context, db),
            ),
          ),
        ],
      ),
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave(context, ref);
      },
      child: page,
    );
  }
}

/// The big workout clock with hundredths, its Reset and Start / Pause /
/// Resume buttons, and the rest after the last ticked set ("Next set at" on
/// the clock, or a countdown).
class _Clock extends StatefulWidget {
  const _Clock({
    required this.workout,
    required this.restStyle,
    required this.onToggle,
    required this.onReset,
  });

  final ActiveWorkout workout;
  final RestStyle restStyle;
  final VoidCallback onToggle;
  final VoidCallback onReset;

  @override
  State<_Clock> createState() => _ClockState();
}

class _ClockState extends State<_Clock> with SingleTickerProviderStateMixin {
  /// Redraws every frame while the clock or a countdown moves.
  late final _ticker = createTicker((_) => setState(() {}));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_Clock old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (_moving && !_ticker.isActive) {
      _ticker.start();
    } else if (!_moving && _ticker.isActive) {
      _ticker.stop();
    }
  }

  /// The rest runs on the workout clock, so only a running clock moves.
  bool get _moving => widget.workout.session.clockRunningSince != null;

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final session = widget.workout.session;
    final paused = session.clockRunningSince == null;
    final clock = widget.workout.clockAt(now);
    // Countdown style: while a rest runs, the countdown is the big number and
    // the only timer shown.
    final restLeft = widget.restStyle == RestStyle.countdown
        ? widget.workout.restLeft(now)
        : null;
    final resting = restLeft != null;
    // A countdown rounds up to the hundredth, so it never shows 0.00 early.
    final big = resting
        ? Duration(milliseconds: (restLeft.inMilliseconds / 10).ceil() * 10)
        : clock;
    final hundredths = (big.inMilliseconds ~/ 10 % 100).toString().padLeft(
      2,
      '0',
    );
    final firstSet = widget.workout.lastTicked == null;
    final rest = resting
        ? (paused ? 'Rest paused' : 'Rest left')
        : restStatus(widget.workout, widget.restStyle, now);
    const tabular = [FontFeature.tabularFigures()];
    final color = paused
        ? Colors.white54
        : Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          // Shrinks to fit once the clock passes an hour (1:02:03.45).
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  formatClock(big),
                  style: TextStyle(
                    fontSize: 64,
                    height: 1.1,
                    fontFeatures: tabular,
                    color: color,
                  ),
                ),
                Text(
                  '.$hundredths',
                  style: TextStyle(
                    fontSize: 32,
                    fontFeatures: tabular,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (firstSet || rest != null)
            Text.rich(
              // Before the first tick: "Done" in the Done column's green.
              firstSet
                  ? const TextSpan(
                      children: [
                        TextSpan(text: 'Tap '),
                        TextSpan(
                          text: 'Done',
                          style: TextStyle(color: doneColour),
                        ),
                        TextSpan(text: ' when you finish a set'),
                      ],
                    )
                  : TextSpan(text: rest),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontFeatures: tabular,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: paused && clock == Duration.zero
                    ? null
                    : widget.onReset,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset', semanticsLabel: 'Reset clock'),
              ),
              const SizedBox(width: 12),
              Tooltip(
                message: paused ? 'Start clock' : 'Pause clock',
                child: FilledButton.icon(
                  onPressed: widget.onToggle,
                  icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                  label: Text(
                    !paused
                        ? 'Pause'
                        : clock == Duration.zero
                        ? 'Start'
                        : 'Resume',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
