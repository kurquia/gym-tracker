// The "Note for today" sheet of an exercise in the open workout.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';

/// Today's note on one exercise of the open workout, saved as it is typed.
Future<void> showTodayNote(BuildContext context, WorkoutExercise item) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  item.exercise.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  initialValue: item.entry.note,
                  autofocus: true,
                  minLines: 2,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Note for today',
                    helperText: 'Add a note for today',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (t) => ref
                      .read(databaseProvider)
                      .exercisesDao
                      .setEntryNote(item.entry.id, t),
                ),
              ),
            ],
          ),
        ),
      ),
    );
