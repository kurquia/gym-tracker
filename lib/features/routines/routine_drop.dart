// What a drag in the routine editor does to the list: move, join a superset or
// leave one. Pure functions, no widgets, so the rules are unit-tested.
//
// A routine is a flat list of exercises plus `superset[i]` = "exercise i is in
// a superset with the one before" (as stored in routine_exercises). Groups
// (a superset block, or a lone exercise) come from `groupSupersets`.

import '../../data/database.dart' show groupSupersets;

/// What is being dragged.
sealed class DragSource {
  const DragSource();
}

/// One exercise, by its index in the list. A superset member dragged out of
/// its block leaves the superset.
class DragExercise extends DragSource {
  const DragExercise(this.index);
  final int index;
}

/// A whole superset block, by the index of its first exercise.
class DragBlock extends DragSource {
  const DragBlock(this.start);
  final int start;
}

/// Where it is dropped.
sealed class DropTarget {
  const DropTarget();
}

/// Between rows: in front of exercise [gap] (the list's length = at the end).
/// Inside a block (between two of its members) the dragged exercise joins the
/// block there; anywhere else it is a plain move and stands alone.
class DropBetween extends DropTarget {
  const DropBetween(this.gap);
  final int gap;

  @override
  bool operator ==(Object other) => other is DropBetween && other.gap == gap;
  @override
  int get hashCode => gap.hashCode;
}

/// Onto exercise [index]: a superset with it, placed right after it (in its
/// block if it has one).
class DropOnto extends DropTarget {
  const DropOnto(this.index);
  final int index;

  @override
  bool operator ==(Object other) => other is DropOnto && other.index == index;
  @override
  int get hashCode => Object.hash(DropOnto, index);
}

/// Onto a block's header, by the index of its first exercise: joins the
/// superset at its end.
class DropOntoBlock extends DropTarget {
  const DropOntoBlock(this.start);
  final int start;

  @override
  bool operator ==(Object other) =>
      other is DropOntoBlock && other.start == start;
  @override
  int get hashCode => Object.hash(DropOntoBlock, start);
}

/// The list after a drop: [order] holds the old indices in their new order,
/// [superset] the new flags.
typedef DropResult = ({List<int> order, List<bool> superset});

/// Groups of indices, as the list shows them.
List<List<int>> supersetGroups(List<bool> superset) => groupSupersets([
  for (var i = 0; i < superset.length; i++) i,
], (i) => superset[i]);

/// Is [gap] between two members of the same block?
bool insideBlock(List<bool> superset, int gap) =>
    gap > 0 && gap < superset.length && superset[gap];

/// Applies a drop. Returns null when it changes nothing (dropped where it
/// already is, or onto itself), so the editor shows no target there.
DropResult? applyDrop(
  List<bool> superset,
  DragSource source,
  DropTarget target,
) {
  final n = superset.length;
  final groups = supersetGroups(superset);
  int groupOf(int i) => groups.indexWhere((g) => g.contains(i));

  final moving = switch (source) {
    DragExercise(:final index) => [index],
    DragBlock(:final start) => groups[groupOf(start)],
  };

  // Where it goes, as (group, position in it) or a new group at a group
  // position, worked out on the list without the dragged exercises.
  List<int>? joinGroup; // the group it joins
  int? joinAfter; // … right after this exercise (null = at the start)
  var appendToGroup = false; // … or at its end
  int? newGroupBefore; // or alone, in front of this exercise's group
  switch (target) {
    case DropOnto(:final index):
      if (moving.contains(index)) return null;
      joinGroup = groups[groupOf(index)];
      joinAfter = index;
    case DropOntoBlock(:final start):
      if (moving.contains(start)) return null;
      joinGroup = groups[groupOf(start)];
      appendToGroup = true;
    case DropBetween(:final gap):
      if (insideBlock(superset, gap)) {
        final g = groups[groupOf(gap)];
        // A block can't go inside itself.
        if (source is DragBlock && g.contains(moving.first)) return null;
        joinGroup = g;
        // Right after the member before the gap; if that is the dragged
        // exercise itself, after the member before it.
        final before = moving.contains(gap - 1) ? gap - 2 : gap - 1;
        joinAfter = g.contains(before) ? before : null;
      } else {
        // Alone, in front of the first exercise at or after the gap that
        // isn't being dragged (null = at the end). The gap is at a group
        // boundary, so that exercise leads its group once the dragged ones
        // are out.
        for (var i = gap; i < n; i++) {
          if (!moving.contains(i)) {
            newGroupBefore = i;
            break;
          }
        }
      }
  }

  // Take the dragged exercises out.
  final rest = [
    for (final g in groups)
      [
        for (final i in g)
          if (!moving.contains(i)) i,
      ],
  ]..removeWhere((g) => g.isEmpty);

  if (joinGroup != null) {
    final g = rest.firstWhere((r) => r.any(joinGroup!.contains));
    final at = appendToGroup
        ? g.length
        : joinAfter == null
        ? 0
        : g.indexOf(joinAfter) + 1;
    g.insertAll(at, moving);
  } else {
    final at = newGroupBefore == null
        ? rest.length
        : rest.indexWhere((g) => g.contains(newGroupBefore));
    rest.insert(at, moving);
  }

  final order = [for (final g in rest) ...g];
  final flags = [
    for (final g in rest)
      for (var k = 0; k < g.length; k++) k > 0,
  ];
  final unchanged =
      order.indexed.every((e) => e.$1 == e.$2) &&
      flags.indexed.every((e) => e.$2 == superset[e.$1]);
  return unchanged ? null : (order: order, superset: flags);
}
