import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import 'exercise_browser.dart';

/// Multi-select exercise search. Pops with the newly picked exercises in the
/// order they were ticked; [alreadyAdded] ones are shown ticked and locked.
/// Custom exercises created from here are picked right away.
class ExercisePickerScreen extends StatefulWidget {
  const ExercisePickerScreen({super.key, required this.alreadyAdded});

  final Set<int> alreadyAdded;

  @override
  State<ExercisePickerScreen> createState() => _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends State<ExercisePickerScreen> {
  final _picked = <Exercise>[];

  void _toggle(Exercise e) => setState(() {
    final i = _picked.indexWhere((p) => p.id == e.id);
    i >= 0 ? _picked.removeAt(i) : _picked.add(e);
  });

  Future<void> _create([String name = '']) async {
    final created = await context.push<Exercise>('/exercises/new', extra: name);
    if (created != null && mounted) setState(() => _picked.add(created));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add exercises'),
        actions: [
          TextButton(
            onPressed: _picked.isEmpty ? null : () => context.pop(_picked),
            child: Text(_picked.isEmpty ? 'Add' : 'Add (${_picked.length})'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New custom exercise',
        onPressed: _create,
        child: const Icon(Icons.add),
      ),
      body: ExerciseBrowser(
        onCreate: _create,
        tileBuilder: (context, e, details) {
          final locked = widget.alreadyAdded.contains(e.id);
          return CheckboxListTile(
            value: locked || _picked.any((p) => p.id == e.id),
            onChanged: locked ? null : (_) => _toggle(e),
            title: Text(e.name),
            subtitle: Text(locked ? 'Already added' : details),
            controlAffinity: ListTileControlAffinity.leading,
          );
        },
      ),
    );
  }
}
