// Adding and removing sets in the open workout, asking first before ticked
// sets go.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';
import '../../shared/widgets/confirm.dart';

/// Adds a set to each exercise: one set on a normal page, a round on a
/// superset page.
Future<void> addSets(WidgetRef ref, List<WorkoutExercise> exercises) async {
  final db = ref.read(databaseProvider);
  for (final e in exercises) {
    await db.workoutsDao.addSet(e.entry.id);
  }
}

/// Removes the last set of each exercise (a round on a superset page). If one
/// of them is ticked, asks first. [named] puts the exercise's name in that
/// question (several exercises, or one of a superset).
Future<void> removeLastSets(
  BuildContext context,
  WidgetRef ref,
  List<WorkoutExercise> exercises, {
  required bool named,
}) async {
  final last = [
    for (final e in exercises)
      if (e.sets.lastOrNull case final s?) (e, s),
  ];
  final db = ref.read(databaseProvider);
  final unit = ref.read(weightUnitProvider);
  final ticked = [
    for (final (e, s) in last)
      if (s.completedAt != null)
        describeSet(
          s,
          setLabels(e.sets).last,
          e.exercise,
          unit,
          name: named ? e.exercise.name : null,
        ),
  ];
  if (ticked.isNotEmpty && !await confirmRemoveDone(context, ticked)) return;
  await db.workoutsDao.deleteSets([for (final (_, s) in last) s.id]);
}

/// "Set 2 (70×8)", "Pullups set 2 (BW×8)", "Warm-up (40×10)", "Drop set
/// (50×6)".
String describeSet(
  WorkoutSet s,
  String label,
  Exercise exercise,
  WeightUnit unit, {
  String? name,
}) {
  final which = switch (s.kind) {
    SetKind.normal || SetKind.failure => 'set $label',
    SetKind.warmup => 'warm-up',
    SetKind.drop => 'drop set',
  };
  final what = name == null ? sentenceCase(which) : '$name $which';
  return '$what (${formatSet(s, unit, markKind: false, typedAs: exercise)})';
}

/// Asks before removing ticked sets ([sets] as from [describeSet]); true =
/// remove.
Future<bool> confirmRemoveDone(BuildContext context, List<String> sets) =>
    confirm(
      context,
      title: sets.length == 1 ? 'Remove a done set?' : 'Remove done sets?',
      message:
          '${sets.join(' and ')} ${sets.length == 1 ? 'is' : 'are'} ticked.',
      action: 'Remove',
      destructive: true,
    );
