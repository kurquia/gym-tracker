import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';
import 'body_model/muscle_map.dart';

/// Creates a custom exercise ([exerciseId] null) or edits one.
/// Pops with the saved [Exercise].
class ExerciseEditScreen extends ConsumerStatefulWidget {
  const ExerciseEditScreen({super.key, this.exerciseId, this.initialName = ''});

  final int? exerciseId;
  final String initialName;

  @override
  ConsumerState<ExerciseEditScreen> createState() => _ExerciseEditScreenState();
}

class _ExerciseEditScreenState extends ConsumerState<ExerciseEditScreen> {
  final _name = TextEditingController();
  String? _equipment;
  final _targets = <String>{};
  final _synergists = <String>{};
  String? _nameError;
  bool _musclesMissing = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _name.text = widget.initialName;
    _load();
  }

  Future<void> _load() async {
    final id = widget.exerciseId;
    if (id != null) {
      final detail = await ref
          .read(databaseProvider)
          .exercisesDao
          .exerciseDetail(id);
      if (detail != null) {
        _name.text = detail.exercise.name;
        _equipment = detail.exercise.equipment;
        for (final (role, ids) in [
          (MuscleRole.target, _targets),
          (MuscleRole.synergist, _synergists),
        ]) {
          ids.addAll([for (final m in detail.muscles[role] ?? []) m.id]);
        }
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    final name = _name.text.trim();
    final nameError = name.isEmpty
        ? 'Give the exercise a name.'
        : await db.exercisesDao.exerciseNameTaken(
            name,
            exceptId: widget.exerciseId,
          )
        ? 'An exercise with this name already exists.'
        : null;
    setState(() {
      _nameError = nameError;
      _musclesMissing = _targets.isEmpty;
    });
    if (nameError != null || _targets.isEmpty) return;

    final id = await db.exercisesDao.saveCustomExercise(
      id: widget.exerciseId,
      name: name,
      equipment: _equipment,
      targetMuscleIds: _targets.toList(),
      synergistMuscleIds: _synergists.toList(),
    );
    final saved = await db.exercisesDao.exercise(id);
    if (mounted) context.pop(saved);
  }

  /// Picking a muscle in one group removes it from the other.
  void _toggle(Set<String> group, Set<String> other, String id) => setState(() {
    if (!group.remove(id)) {
      group.add(id);
      other.remove(id);
    }
    _musclesMissing = false;
  });

  @override
  Widget build(BuildContext context) {
    final muscles = ref.watch(musclesProvider).value ?? const <Muscle>[];
    final equipment = ref.watch(equipmentNamesProvider).value ?? const [];
    final heading = Theme.of(context).textTheme.titleSmall;

    Widget muscleChips(Set<String> group, Set<String> other) => Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final m in muscles.where((m) => !isFineMuscle(m.id)))
          FilterChip(
            label: Text(m.name),
            selected: group.contains(m.id),
            onSelected: (_) => _toggle(group, other, m.id),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.exerciseId == null ? 'New exercise' : 'Edit exercise',
        ),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                TextField(
                  controller: _name,
                  autofocus: widget.exerciseId == null && _name.text.isEmpty,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: _nameError,
                  ),
                  onChanged: (_) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                ),
                const SizedBox(height: 24),
                Text('Equipment', style: heading),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final e in [null, ...equipment])
                      ChoiceChip(
                        label: Text(e == null ? 'None' : sentenceCase(e)),
                        selected: _equipment == e,
                        onSelected: (_) => setState(() => _equipment = e),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Target muscles', style: heading),
                if (_musclesMissing)
                  Text(
                    'Pick at least one target muscle.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 8),
                muscleChips(_targets, _synergists),
                const SizedBox(height: 24),
                Text('Secondary muscles', style: heading),
                const SizedBox(height: 8),
                muscleChips(_synergists, _targets),
              ],
            ),
    );
  }
}
