import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';
import '../../shared/theme.dart';
import 'set_actions.dart';

/// Width of the Previous column, shared with the header in the exercise card.
const previousColumnWidth = 64.0;

/// Width of the Rest column, shared with the header in the exercise card.
const restColumnWidth = 56.0;

/// One editable set: label (tap = set type), last time's set at the same
/// position (tap to copy it), weight, reps, done tick. The weight carries the
/// load: blank = bodyweight ("BW"), negative = assisted, and on a bodyweight
/// exercise a positive number is added weight ("+10"). Its rest sits before
/// the tick (a RestCell).
/// Swipe left to delete (a ticked set asks first). Every edit is saved
/// immediately.
class SetRow extends ConsumerStatefulWidget {
  const SetRow({
    super.key,
    required this.set,
    required this.label,
    required this.exercise,
    required this.unit,
    required this.previous,
    this.rest,
  });

  /// Its rest, before the tick; empty when it has none (mid-round in a
  /// superset, straight on).
  final Widget? rest;

  final WorkoutSet set;
  final String label;

  /// Last time's set at the same position, if there was one.
  final WorkoutSet? previous;

  /// Its weight options; on a bodyweight exercise a blank weight means
  /// bodyweight and a positive one is added weight.
  final Exercise exercise;

  bool get bodyweightExercise => exercise.equipment == 'body only';

  /// Unit the weight is shown and typed in; stored as kg.
  final WeightUnit unit;

  @override
  ConsumerState<SetRow> createState() => _SetRowState();
}

class _SetRowState extends ConsumerState<SetRow> {
  late final _kg = TextEditingController(text: _kgText(widget.set));
  late final _reps = TextEditingController(text: widget.set.reps?.toString());
  final _kgFocus = FocusNode();
  final _repsFocus = FocusNode();

  String _kgText(WorkoutSet s) {
    if (s.weightKg == null || s.loadType == LoadType.bodyweight) return '';
    final kg = formatWeight(
      s.loadType == LoadType.weight
          ? widget.exercise.typedFromKg(s.weightKg!)
          : s.weightKg!,
      widget.unit,
    );
    return switch (s.loadType) {
      LoadType.weighted => '+$kg',
      LoadType.assisted => '-$kg',
      _ => kg,
    };
  }

  /// The typed weight as a load type and a magnitude in kg.
  (LoadType, double?) _loadOf(String text) {
    final t = text.trim().replaceAll('−', '-');
    final v = parseWeight(t, widget.unit);
    final bodyweight = widget.bodyweightExercise;
    return switch (v) {
      null || 0 when bodyweight => (LoadType.bodyweight, null),
      null => (LoadType.weight, null),
      < 0 => (LoadType.assisted, -v),
      _ when bodyweight || t.startsWith('+') => (LoadType.weighted, v),
      _ => (LoadType.weight, widget.exercise.kgFromTyped(v)),
    };
  }

  @override
  void didUpdateWidget(SetRow old) {
    super.didUpdateWidget(old);
    // Take outside changes (e.g. after undo) without fighting the user's typing.
    final s = widget.set;
    if (old.unit != widget.unit ||
        old.exercise != widget.exercise ||
        (!_kgFocus.hasFocus && _loadOf(_kg.text) != (s.loadType, s.weightKg))) {
      _kg.text = _kgText(s);
    }
    if (!_repsFocus.hasFocus && int.tryParse(_reps.text) != widget.set.reps) {
      _reps.text = widget.set.reps?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _kg.dispose();
    _reps.dispose();
    _kgFocus.dispose();
    _repsFocus.dispose();
    super.dispose();
  }

  Future<void> _save(SetsCompanion changes) =>
      ref.read(databaseProvider).workoutsDao.updateSet(widget.set.id, changes);

  @override
  Widget build(BuildContext context) {
    final s = widget.set;
    final done = s.completedAt != null;

    return Dismissible(
      key: ValueKey('dismiss-${s.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete_outline),
      ),
      // A ticked set is asked about first.
      confirmDismiss: (_) async =>
          !done ||
          await confirmRemoveDone(context, [
            describeSet(s, widget.label, widget.exercise, widget.unit),
          ]),
      onDismissed: (_) =>
          ref.read(databaseProvider).workoutsDao.deleteSets([s.id]),
      child: Padding(
        // Half the gap between rows on each side.
        padding: const EdgeInsets.only(right: 8, top: 3, bottom: 3),
        // A ticked set is covered by a light band, so done sets stand out.
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: done ? Colors.white.withValues(alpha: 0.24) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: _KindButton(
                    set: s,
                    label: widget.label,
                    onPicked: (kind) => _save(SetsCompanion(kind: Value(kind))),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: previousColumnWidth,
                  child: switch (widget.previous) {
                    null => const Text(
                      '—',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38),
                    ),
                    final p => TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: previousColour,
                      ),
                      onPressed: () => _save(
                        SetsCompanion(
                          loadType: Value(p.loadType),
                          weightKg: Value(p.weightKg),
                          reps: Value(p.reps),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formatSet(
                            p,
                            widget.unit,
                            markKind: false,
                            typedAs: widget.exercise,
                          ),
                          semanticsLabel:
                              'Last time ${formatSet(p, widget.unit, typedAs: widget.exercise)}, tap to copy',
                        ),
                      ),
                    ),
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _kg,
                    focusNode: _kgFocus,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    decoration: _decoration(
                      widget.bodyweightExercise ? 'BW' : widget.unit.name,
                    ),
                    onChanged: (t) {
                      final (load, kg) = _loadOf(t);
                      _save(
                        SetsCompanion(
                          loadType: Value(load),
                          weightKg: Value(kg),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _reps,
                    focusNode: _repsFocus,
                    keyboardType: TextInputType.number,
                    decoration: _decoration('reps'),
                    onChanged: (t) => _save(
                      SetsCompanion(reps: Value(int.tryParse(t.trim()))),
                    ),
                  ),
                ),
                SizedBox(width: restColumnWidth, child: widget.rest),
                SizedBox(
                  width: 48,
                  child: Checkbox(
                    value: done,
                    activeColor: doneColour,
                    checkColor: Colors.black,
                    semanticLabel: 'Set done',
                    onChanged: s.reps == null
                        ? null
                        : (v) {
                            // A short buzz: ticked without looking.
                            if (v!) HapticFeedback.mediumImpact();
                            ref
                                .read(databaseProvider)
                                .workoutsDao
                                .tickSet(s.id, done: v);
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    isDense: true,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  );
}

/// The set's label; tap to pick its type (normal, warm-up, drop, failure).
class _KindButton extends StatelessWidget {
  const _KindButton({
    required this.set,
    required this.label,
    required this.onPicked,
  });

  final WorkoutSet set;
  final String label;
  final ValueChanged<SetKind> onPicked;

  static const _names = {
    SetKind.normal: 'Normal set',
    SetKind.warmup: 'Warm-up',
    SetKind.drop: 'Drop set',
    SetKind.failure: 'To failure',
  };

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    Color colour(SetKind kind) => setKindColour(kind, onSurface);
    return PopupMenuButton<SetKind>(
      initialValue: set.kind,
      onSelected: (kind) {
        if (kind != set.kind) onPicked(kind);
      },
      tooltip: '',
      itemBuilder: (context) => [
        for (final kind in SetKind.values)
          PopupMenuItem(
            value: kind,
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    kindLetter(kind) ?? '1',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colour(kind),
                    ),
                  ),
                ),
                Text(_names[kind]!),
              ],
            ),
          ),
      ],
      child: SizedBox(
        height: 40,
        child: Center(
          child: Text(
            label,
            semanticsLabel: '${_names[set.kind]} $label, tap to change type',
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: colour(set.kind)),
          ),
        ),
      ),
    );
  }
}
