// The options sheet of an exercise: how its weight is counted, its setup
// fields and its note; opened from a routine, also its sets there.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';
import '../routines/sets_picker.dart';

/// "Total", "Per side", "Per dumbbell" / "Per kettlebell"; also the weight
/// column's header in Record (with "Weight" for total).
String weightCountingLabel(Exercise e, WeightCounting c) => switch (c) {
  WeightCounting.total => 'Total',
  WeightCounting.perSide => 'Per side',
  WeightCounting.perDumbbell =>
    e.equipment == 'kettlebells' ? 'Per kettlebell' : 'Per dumbbell',
};

/// What per side adds: "bar", or "base" on a machine.
String barLabel(Exercise e) => e.equipment == 'machine' ? 'base' : 'bar';

/// "Per side · bar 20 kg", "Total".
String weightCountingSummary(Exercise e, WeightUnit unit) =>
    e.counting == WeightCounting.perSide
    ? 'Per side · ${barLabel(e)} ${formatWeight(e.bar, unit)} ${unit.name}'
    : weightCountingLabel(e, e.counting);

String _hint(Exercise e, WeightCounting c) => switch (c) {
  WeightCounting.total =>
    e.equipment == 'machine'
        ? 'The stack or the whole load'
        : 'The whole weight',
  WeightCounting.perSide =>
    'The plates on one side; the ${barLabel(e)} is added',
  WeightCounting.perDumbbell =>
    e.equipment == 'kettlebells' ? 'One kettlebell' : 'One dumbbell',
};

/// Why an exercise has only one way to count its weight.
String _onlyWay(Exercise e) => switch (e.equipment) {
  'body only' =>
    'Bodyweight: leave the weight blank, type +10 for added weight '
        'or −20 for assistance.',
  'dumbbell' => 'One dumbbell: dumbbell exercises are logged per dumbbell.',
  'kettlebells' =>
    'One kettlebell: kettlebell exercises are logged per kettlebell.',
  _ => 'The whole weight.',
};

/// The exercise's options (how its weight is typed, setup fields, note),
/// saved as they change.
/// Opened from the routine editor and the exercise page. From the routine
/// editor it starts with that routine's [routineSets], which go to
/// [onRoutineSets] as they change.
Future<void> showExerciseOptions(
  BuildContext context,
  int exerciseId, {
  SetsChoice? routineSets,
  ValueChanged<SetsChoice>? onRoutineSets,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => _ExerciseOptions(exerciseId, routineSets, onRoutineSets),
);

class _ExerciseOptions extends ConsumerStatefulWidget {
  const _ExerciseOptions(this.exerciseId, this.routineSets, this.onRoutineSets);

  final int exerciseId;
  final SetsChoice? routineSets;
  final ValueChanged<SetsChoice>? onRoutineSets;

  @override
  ConsumerState<_ExerciseOptions> createState() => _ExerciseOptionsState();
}

class _ExerciseOptionsState extends ConsumerState<_ExerciseOptions> {
  final _bar = TextEditingController();
  final _note = TextEditingController();
  var _loaded = false;
  late SetsChoice? _sets = widget.routineSets;

  void _setSets(SetsChoice sets) {
    setState(() => _sets = sets);
    widget.onRoutineSets?.call(sets);
  }

  /// One per setup field, keyed by field id; filled once from the database.
  final _values = <int, TextEditingController>{};

  @override
  void dispose() {
    _bar.dispose();
    _note.dispose();
    for (final c in _values.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _addCustomField(AppDatabase db, int exerciseId) async {
    final picked = await showDialog<(String, String?)>(
      context: context,
      builder: (_) => const _CustomFieldDialog(),
    );
    if (picked case (final name, final unit)) {
      await db.exercisesDao.addSetupField(exerciseId, name, unit: unit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final unit = ref.watch(weightUnitProvider);
    final detail = ref.watch(exerciseDetailProvider(widget.exerciseId)).value;
    if (detail == null) return const SizedBox(height: 200);
    final e = detail.exercise;
    final presets = setupPresets(e);
    final choicesOf = {for (final p in presets) p.name: p.choices};
    if (!_loaded) {
      _loaded = true;
      _bar.text = formatWeight(e.bar, unit);
      _note.text = e.note ?? '';
      // The exercise's own setting is always there, ready for a value.
      final names = {for (final f in detail.setupFields) f.name};
      for (final p in presets) {
        if (!names.contains(p.name)) {
          db.exercisesDao.addSetupField(e.id, p.name, unit: p.unit);
        }
      }
    }
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      // Stays above the keyboard while something is typed.
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(e.name, style: textTheme.titleLarge),
            ),
            if (_sets case final sets?) ...[
              ListTile(
                title: Text(
                  'Sets in this routine',
                  style: textTheme.titleSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SetsSelector(
                  value: sets,
                  onWarmup: (w) => _setSets((sets: sets.sets, warmup: w)),
                  onSets: (n) =>
                      _setSets((sets: n, warmup: n != null && sets.warmup)),
                ),
              ),
              const Divider(),
            ],
            ListTile(
              title: Text('Weight counted as', style: textTheme.titleSmall),
              subtitle: Text(
                e.countingChoices.length == 1
                    ? _onlyWay(e)
                    : 'What you type in Record. The equipment '
                          '(${e.equipment}) decides the choices.',
              ),
            ),
            if (e.countingChoices.length > 1)
              RadioGroup<WeightCounting>(
                groupValue: e.counting,
                onChanged: (c) =>
                    db.exercisesDao.setWeightCounting(e.id, c!, barKg: e.barKg),
                child: Column(
                  children: [
                    for (final counting in e.countingChoices)
                      RadioListTile(
                        value: counting,
                        title: Text(weightCountingLabel(e, counting)),
                        subtitle: Text(_hint(e, counting)),
                      ),
                  ],
                ),
              ),
            if (e.counting == WeightCounting.perSide)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  controller: _bar,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: e.equipment == 'machine'
                        ? 'Base weight (sled, empty machine)'
                        : 'Bar weight',
                    suffixText: unit.name,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (t) {
                    final kg = parseWeight(t, unit);
                    if (kg != null && kg >= 0) {
                      db.exercisesDao.setWeightCounting(
                        e.id,
                        e.counting,
                        barKg: kg,
                      );
                    }
                  },
                ),
              ),
            const SizedBox(height: 8),
            const Divider(),
            ListTile(
              title: Text('Setup', style: textTheme.titleSmall),
              subtitle: const Text('Shown in Record; each workout keeps it.'),
            ),
            for (final f in detail.setupFields)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 4, 8),
                child: Row(
                  children: [
                    Expanded(child: Text(f.name)),
                    if (choicesOf[f.name] case final choices?)
                      // A fixed set of answers: a dropdown instead of a box.
                      DropdownButton<String?>(
                        value: f.value,
                        hint: const Text('—'),
                        onChanged: (v) =>
                            db.exercisesDao.setSetupFieldValue(f.id, v ?? ''),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('—')),
                          for (final c in choices)
                            DropdownMenuItem(value: c, child: Text(c)),
                        ],
                      )
                    else ...[
                      SizedBox(
                        width: 96,
                        child: TextField(
                          controller: _values.putIfAbsent(
                            f.id,
                            () => TextEditingController(text: f.value),
                          ),
                          keyboardType: f.unit == '°'
                              ? const TextInputType.numberWithOptions(
                                  signed: true,
                                  decimal: true,
                                )
                              : TextInputType.text,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (t) =>
                              db.exercisesDao.setSetupFieldValue(f.id, t),
                        ),
                      ),
                      // The unit right after the box, also while it's empty.
                      SizedBox(
                        width: 40,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(f.unit ?? ''),
                        ),
                      ),
                    ],
                    // The exercise's own setting stays; added ones can go.
                    if (choicesOf.containsKey(f.name))
                      const SizedBox(width: 48)
                    else
                      IconButton(
                        tooltip: 'Remove ${f.name}',
                        icon: const Icon(Icons.close),
                        onPressed: () => db.exercisesDao.removeSetupField(f.id),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('Other…'),
                onPressed: () => _addCustomField(db, e.id),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _note,
                minLines: 2,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  helperText: 'Shown every time in Record.',
                  border: OutlineInputBorder(),
                ),
                onChanged: (t) => db.exercisesDao.setExerciseNote(e.id, t),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Name and optional unit of a setup field of the user's own.
class _CustomFieldDialog extends StatefulWidget {
  const _CustomFieldDialog();

  @override
  State<_CustomFieldDialog> createState() => _CustomFieldDialogState();
}

class _CustomFieldDialogState extends State<_CustomFieldDialog> {
  final _name = TextEditingController();
  final _unit = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New setup field'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Name'),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            controller: _unit,
            decoration: const InputDecoration(
              labelText: 'Unit (optional)',
              hintText: '°, cm, holes …',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _name.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, (
                  _name.text.trim(),
                  _unit.text.trim().isEmpty ? null : _unit.text.trim(),
                )),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
