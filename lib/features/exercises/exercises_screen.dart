import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import 'exercise_browser.dart';

/// The exercise library: search, filter by muscle, open details, add custom.
class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> create([String name = '']) async {
      final created = await context.push<Exercise>(
        '/exercises/new',
        extra: name,
      );
      if (created != null && context.mounted) {
        context.push('/exercises/${created.id}');
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New custom exercise',
        onPressed: create,
        child: const Icon(Icons.add),
      ),
      body: ExerciseBrowser(
        onCreate: create,
        tileBuilder: (context, e, details) => ListTile(
          title: Text(e.name),
          subtitle: Text(details),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/exercises/${e.id}'),
        ),
      ),
    );
  }
}
