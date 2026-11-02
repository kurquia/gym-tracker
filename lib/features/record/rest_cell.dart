import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';
import 'rest_picker.dart';

/// The rest after a set, in the Rest column of its row: "3:00" (tap to
/// change), "→" straight on (into a drop set, or to the superset's next
/// exercise). In the most recently ticked set's row it shows the rest in
/// progress: "→17:03" on the workout clock, or "…" while the big number at
/// the top counts the rest down.
class RestCell extends ConsumerStatefulWidget {
  const RestCell({
    super.key,
    required this.set,
    required this.active,
    required this.session,
    this.nextInRound,
  });

  final WorkoutSet set;

  /// The workout, for its clock: the rest runs on it.
  final Session session;

  /// This set's rest is the one in progress (it was ticked last).
  final bool active;

  /// Within a superset round: the exercise that comes next ("drop set"
  /// before one). Without a rest of its own, the cell shows "→" instead.
  final String? nextInRound;

  @override
  ConsumerState<RestCell> createState() => _RestCellState();
}

class _RestCellState extends ConsumerState<RestCell> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Rebuilds once a second while a countdown runs, to notice its end.
  void _keepTicking(bool ticking) {
    if (ticking) {
      _timer ??= Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() {}),
      );
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.set;
    final style =
        ref.watch(settingsProvider).value?.restStyle ?? RestStyle.clock;
    final clock = widget.session.clockAt(DateTime.now());
    final midRound = widget.nextInRound != null;
    final straightOn = midRound && s.restSeconds == null;
    final rest = s.restFor(midRound: midRound);
    final end = widget.active && !straightOn
        ? s.restEndOn(clock, midRound: midRound)
        : null;
    final counting =
        end != null &&
        style == RestStyle.countdown &&
        end - clock > Duration.zero;
    final (String label, String spoken) = switch (end) {
      null when straightOn => ('→', 'Then ${widget.nextInRound}'),
      null => (formatClock(rest), 'Rest ${formatClock(rest)}'),
      final e when style == RestStyle.clock => (
        '→${formatClock(e)}',
        'Next set at ${formatClock(e)}',
      ),
      // The countdown itself is the big number at the top.
      _ when counting => ('…', 'Resting'),
      _ => ('over', 'Rest over'),
    };
    // Only a running clock can end the rest.
    _keepTicking(counting && widget.session.clockRunningSince != null);

    // Dimmest while the rest is still the warm-up / working default.
    final color = end != null || (straightOn && widget.active)
        ? Theme.of(context).colorScheme.onSurface
        : s.restSeconds == null
        ? Colors.white38
        : Colors.white70;
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: color,
        visualDensity: VisualDensity.compact,
        minimumSize: const Size(0, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        // From the theme, so it keeps the app font.
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 13,
          fontWeight: end != null ? FontWeight.bold : null,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      onPressed: () async {
        final picked = await showRestPicker(context, rest);
        if (picked != null) {
          await ref
              .read(databaseProvider)
              .workoutsDao
              .updateSet(
                s.id,
                SetsCompanion(restSeconds: Value(picked.rest?.inSeconds)),
              );
        }
      },
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, semanticsLabel: '$spoken, tap to change the rest'),
      ),
    );
  }
}
