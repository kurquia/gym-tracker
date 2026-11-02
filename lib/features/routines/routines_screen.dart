import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';
import '../../shared/widgets/placeholder_body.dart';

/// Says [deleted] is gone and offers Undo, which restores it and then runs
/// [onUndone].
void showRoutineDeleted(
  ScaffoldMessengerState messenger,
  AppDatabase db,
  DeletedRoutine deleted, {
  VoidCallback? onUndone,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('Deleted "${deleted.routine.name}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await db.routinesDao.restoreRoutine(deleted);
            onUndone?.call();
          },
        ),
      ),
    );
}

/// The Routines tab: the list of routines; swipe to delete, tap to edit.
class RoutinesScreen extends ConsumerStatefulWidget {
  const RoutinesScreen({super.key});

  @override
  ConsumerState<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends ConsumerState<RoutinesScreen> {
  /// Swiped-away routines, hidden until the database stream catches up.
  final _deleting = <int>{};

  Future<void> _delete(int id) async {
    setState(() => _deleting.add(id));
    final db = ref.read(databaseProvider);
    final deleted = await db.routinesDao.deleteRoutine(id);
    if (!mounted) return;
    showRoutineDeleted(
      ScaffoldMessenger.of(context),
      db,
      deleted,
      onUndone: () {
        if (mounted) setState(() => _deleting.remove(id));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final routines = ref.watch(routinesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Routines')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New routine',
        onPressed: () => context.push('/routines/new'),
        child: const Icon(Icons.add),
      ),
      body: routines.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => PlaceholderBody(text: 'Could not load routines.\n$e'),
        data: (all) {
          final visible = [
            for (final r in all)
              if (!_deleting.contains(r.routine.id)) r,
          ];
          if (visible.isEmpty) {
            return const PlaceholderBody(
              text: 'No routines yet.\nTap + to create one.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            itemCount: visible.length,
            itemBuilder: (context, i) {
              final r = visible[i];
              return Dismissible(
                key: ValueKey(r.routine.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete_outline),
                ),
                onDismissed: (_) => _delete(r.routine.id),
                child: Card(
                  child: ListTile(
                    title: Text(r.routine.name),
                    subtitle: Text(countOf(r.exerciseCount, 'exercise')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/routines/${r.routine.id}'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
