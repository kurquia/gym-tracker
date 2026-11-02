import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';
import '../../shared/theme.dart';
import '../exercises/exercise_options_sheet.dart';
import 'rest_cell.dart';
import 'set_actions.dart';
import 'set_row.dart';
import 'today_note_sheet.dart';

/// One exercise in a workout: name and menu, last time, and its set rows.
class ExerciseCard extends ConsumerWidget {
  const ExerciseCard({
    super.key,
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.workout,
  });

  final WorkoutExercise item;

  /// Its page is the first / last: moving it stops there.
  final bool isFirst;
  final bool isLast;
  final ActiveWorkout workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(weightUnitProvider);
    final labels = setLabels(item.sets);
    final resting = workout.lastTicked?.id;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            item: item,
            isFirst: isFirst,
            isLast: isLast,
            canSupersetWithNext: !isLast,
          ),
          _ColumnHeader(
            weight: item.exercise.counting == WeightCounting.total
                ? 'Weight'
                : weightCountingLabel(item.exercise, item.exercise.counting),
          ),
          for (final (i, s) in item.sets.indexed)
            SetRow(
              key: ValueKey(s.id),
              set: s,
              previous: item.previous?.sets.elementAtOrNull(i),
              label: labels[i],
              exercise: item.exercise,
              unit: unit,
              rest: RestCell(
                set: s,
                // Straight on into a drop set.
                nextInRound:
                    item.sets.elementAtOrNull(i + 1)?.kind == SetKind.drop
                    ? 'drop set'
                    : null,
                active: s.id == resting,
                session: workout.session,
              ),
            ),
        ],
      ),
    );
  }
}

/// A superset on one page, in the order it is done: round 1 is the first set
/// of each exercise (A1, B1), and so on; the rest comes after each round.
class SupersetCard extends ConsumerWidget {
  const SupersetCard({
    super.key,
    required this.group,
    required this.isFirst,
    required this.isLast,
    required this.workout,
  });

  final List<WorkoutExercise> group;
  final bool isFirst;
  final bool isLast;
  final ActiveWorkout workout;

  static String letter(int k) => String.fromCharCode(0x41 + k); // A, B, …

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(weightUnitProvider);
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Colors.white70);
    final rounds = group.fold(
      0,
      (n, e) => e.working.length > n ? e.working.length : n,
    );
    final resting = workout.lastTicked?.id;

    Widget row(
      WorkoutExercise e,
      WorkoutSet s,
      String label,
      WorkoutSet? previous, {
      Widget? rest,
    }) => SetRow(
      key: ValueKey(s.id),
      set: s,
      previous: previous,
      label: label,
      exercise: e.exercise,
      unit: unit,
      rest: rest,
    );

    Widget rest(WorkoutSet s, {String? nextInRound}) => RestCell(
      set: s,
      nextInRound: nextInRound,
      active: s.id == resting,
      session: workout.session,
    );

    // "Warm-up", "Round 2" above the rows.
    Widget roundLabel(String text) => Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 2),
      child: Text(text, style: muted),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (k, e) in group.indexed)
            _Header(
              item: e,
              letter: letter(k),
              isFirst: isFirst,
              isLast: isLast,
              canSupersetWithNext: !isLast && k == group.length - 1,
            ),
          const _ColumnHeader(weight: 'Weight'),
          // Warm-ups first, each with its own rest: not part of a round.
          if (group.any((e) => e.warmups.isNotEmpty)) roundLabel('Warm-up'),
          for (final (k, e) in group.indexed)
            for (final (w, s) in e.warmups.indexed)
              row(
                e,
                s,
                '${letter(k)}W',
                e.previous?.sets.where((p) => p.isWarmup).elementAtOrNull(w),
                rest: rest(s),
              ),
          for (var r = 0; r < rounds; r++) ...[
            roundLabel('Round ${r + 1}'),
            for (final (k, e) in group.indexed)
              if (e.working.elementAtOrNull(r) case final s?)
                row(
                  e,
                  s,
                  '${letter(k)}${r + 1}',
                  e.previous?.sets.where((p) => !p.isWarmup).elementAtOrNull(r),
                  // The round's rest after its last set; mid-round only a
                  // rest of its own shows (by default it's straight on).
                  rest: _lastInRound(r, k)
                      ? rest(s)
                      : s.restSeconds != null
                      ? rest(s, nextInRound: group[k + 1].exercise.name)
                      : null,
                ),
          ],
        ],
      ),
    );
  }

  /// No later exercise of the superset has a working set in round [r].
  bool _lastInRound(int r, int k) =>
      group.skip(k + 1).every((e) => e.working.length <= r);
}

/// An exercise's name, last time's date and menu, then today's note. In a
/// superset the name gets its letter (A, B, …).
class _Header extends ConsumerWidget {
  const _Header({
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.canSupersetWithNext,
    this.letter,
  });

  final WorkoutExercise item;
  final String? letter;
  final bool isFirst;
  final bool isLast;
  final bool canSupersetWithNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final textTheme = Theme.of(context).textTheme;
    final muted = textTheme.bodySmall?.copyWith(color: Colors.white70);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (letter != null)
              SizedBox(
                width: 24,
                child: Text(
                  letter!,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Expanded(
              child: Text(item.exercise.name, style: textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: switch (item.previous) {
                null => Text('First time', style: muted),
                // The sets themselves are in the Previous column.
                final p => Tooltip(
                  message: 'Last time: ${formatDay(p.date)}',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 16,
                        color: previousColour,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${p.date.day} ${monthName(p.date).substring(0, 3)}',
                        style: muted?.copyWith(color: previousColour),
                      ),
                    ],
                  ),
                ),
              },
            ),
            PopupMenuButton<void>(
              tooltip: 'Exercise options',
              // `_`: the handlers open sheets from this header's context.
              itemBuilder: (_) => [
                PopupMenuItem(
                  onTap: () => showTodayNote(context, item),
                  child: const Text('Note for today'),
                ),
                PopupMenuItem(
                  onTap: () => showExerciseOptions(context, item.exercise.id),
                  child: const Text('Exercise options'),
                ),
                // The page's buttons add and remove rounds; these make a
                // superset uneven (2 + 3 sets).
                if (letter != null) ...[
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    onTap: () => addSets(ref, [item]),
                    child: const Text('Add set'),
                  ),
                  PopupMenuItem(
                    onTap: () =>
                        removeLastSets(context, ref, [item], named: true),
                    enabled: item.sets.isNotEmpty,
                    child: const Text('Remove last set'),
                  ),
                ],
                const PopupMenuDivider(),
                if (canSupersetWithNext)
                  PopupMenuItem(
                    onTap: () => db.workoutsDao.supersetWithNext(item.entry.id),
                    child: const Text('Superset with next'),
                  ),
                if (letter != null)
                  PopupMenuItem(
                    onTap: () => db.workoutsDao.leaveSuperset(item.entry.id),
                    child: const Text('Leave superset'),
                  ),
                if (!isFirst)
                  PopupMenuItem(
                    onTap: () => db.workoutsDao.moveExercise(item.entry.id, -1),
                    child: const Text('Move earlier'),
                  ),
                if (!isLast)
                  PopupMenuItem(
                    onTap: () => db.workoutsDao.moveExercise(item.entry.id, 1),
                    child: const Text('Move later'),
                  ),
                PopupMenuItem(
                  onTap: () => db.workoutsDao.removeExercise(item.entry.id),
                  child: const Text('Remove from workout'),
                ),
              ],
            ),
          ],
        ),
        // Lined up under the name, past a superset's letter. The exercise's
        // own options (weight counting, setup, note) are under ⋮ only, to
        // keep the page short (user's pick, 2026-10-25).
        if (item.entry.note case final note?)
          Padding(
            padding: EdgeInsets.only(left: letter == null ? 0 : 24),
            child: InkWell(
              onTap: () => showTodayNote(context, item),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8, right: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.edit_note,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Today: $note',
                        style: muted?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Set · Previous · Weight · Reps · Rest · Done, lined up with the set rows.
class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({required this.weight});

  final String weight;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Colors.white70);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('Set', style: muted, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: previousColumnWidth,
            child: Text(
              'Previous',
              style: muted?.copyWith(color: previousColour),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: Text(weight, style: muted)),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: Text('Reps', style: muted)),
          SizedBox(
            width: restColumnWidth,
            child: Text('Rest', style: muted, textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 48,
            child: Text(
              'Done',
              style: muted?.copyWith(color: doneColour),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
