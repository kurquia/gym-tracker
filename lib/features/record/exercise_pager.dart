import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../shared/format.dart';
import 'exercise_card.dart';
import 'set_actions.dart';

/// The workout one page at a time: swipe, or use the previous / next buttons
/// at the top (the last page offers "Add exercise" instead); "2 / 7" between
/// them opens an overview to jump anywhere. "Remove set" and "Add set" sit at
/// the bottom ("… round" on a superset page).
/// Each page is one exercise, or one superset.
class ExercisePager extends ConsumerStatefulWidget {
  const ExercisePager({
    super.key,
    required this.workout,
    required this.onAddExercises,
  });

  final ActiveWorkout workout;
  final VoidCallback onAddExercises;

  @override
  ConsumerState<ExercisePager> createState() => _ExercisePagerState();
}

bool _isDone(List<WorkoutExercise> group) => group.every(
  (e) => e.sets.isNotEmpty && e.sets.every((s) => s.completedAt != null),
);

String _nameOf(List<WorkoutExercise> group) =>
    group.map((e) => e.exercise.name).join(' + ');

class _ExercisePagerState extends ConsumerState<ExercisePager> {
  late final PageController _controller;
  late int _page;

  /// First exercise on the current page, so the page follows it when
  /// exercises are moved, removed or added.
  int? _entryId;

  List<List<WorkoutExercise>> get _groups => groupSupersets(
    widget.workout.exercises,
    (e) => e.entry.supersetWithPrevious,
  );

  @override
  void initState() {
    super.initState();
    // Resuming a workout: open at the first exercise that isn't finished.
    final groups = _groups;
    final firstOpen = groups.indexWhere((g) => !_isDone(g));
    _page = firstOpen == -1 ? 0 : firstOpen;
    _entryId = groups.isEmpty ? null : groups[_page].first.entry.id;
    _controller = PageController(initialPage: _page);
  }

  @override
  void didUpdateWidget(ExercisePager old) {
    super.didUpdateWidget(old);
    final groups = _groups;
    if (groups.isEmpty) return;
    final oldIds = {for (final e in old.workout.exercises) e.entry.id};
    final added = groups.indexWhere(
      (g) => g.any((e) => !oldIds.contains(e.entry.id)),
    );
    final current = groups.indexWhere(
      (g) => g.any((e) => e.entry.id == _entryId),
    );
    final target = added != -1
        ? added // just added: show it
        : current != -1
        ? current // moved: follow it
        : _page.clamp(0, groups.length - 1); // removed: stay put
    _entryId = groups[target].first.entry.id;
    if (target != _page) {
      _page = target;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) _controller.jumpToPage(target);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int page) => _controller.animateToPage(
    page,
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
  );

  Future<void> _overview() async {
    final groups = _groups;
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          for (final (i, g) in groups.indexed)
            ListTile(
              selected: i == _page,
              leading: Text('${i + 1}'),
              title: Text(_nameOf(g)),
              subtitle: Text(_progress(g)),
              trailing: _isDone(g) ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, i),
            ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add exercise'),
            onTap: () {
              Navigator.pop(context);
              widget.onAddExercises();
            },
          ),
        ],
      ),
    );
    if (picked != null) _go(picked);
  }

  static String _progress(List<WorkoutExercise> group) {
    final sets = [for (final e in group) ...e.sets];
    final ticked = sets.where((s) => s.completedAt != null).length;
    return '$ticked of ${countOf(sets.length, 'set')} done';
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups;
    if (groups.isEmpty) {
      return Center(
        child: OutlinedButton.icon(
          onPressed: widget.onAddExercises,
          icon: const Icon(Icons.add),
          label: const Text('Add exercise'),
        ),
      );
    }
    return PageView.builder(
      controller: _controller,
      itemCount: groups.length,
      onPageChanged: (i) {
        _page = i;
        _entryId = groups[i].first.entry.id;
      },
      itemBuilder: (_, i) => _buildPage(groups, i),
    );
  }

  Widget _buildPage(List<List<WorkoutExercise>> groups, int i) {
    final group = groups[i];
    final previous = i > 0 ? groups[i - 1] : null;
    final next = i < groups.length - 1 ? groups[i + 1] : null;

    final Widget nextButton;
    if (next == null) {
      nextButton = TextButton.icon(
        onPressed: widget.onAddExercises,
        icon: const Icon(Icons.add),
        label: const Text('Add exercise'),
      );
    } else {
      final label = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              _nameOf(next),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      );
      const padding = EdgeInsets.only(left: 12, right: 4);
      // Stands out once every set on this page is ticked.
      nextButton = _isDone(group)
          ? FilledButton(
              style: FilledButton.styleFrom(padding: padding),
              onPressed: () => _go(i + 1),
              child: label,
            )
          : TextButton(
              style: TextButton.styleFrom(padding: padding),
              onPressed: () => _go(i + 1),
              child: label,
            );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
          child: Row(
            children: [
              Expanded(
                child: previous == null
                    ? const SizedBox.shrink()
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => _go(i - 1),
                          icon: const Icon(Icons.chevron_left),
                          label: Text(
                            _nameOf(previous),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
              ),
              TextButton(
                onPressed: _overview,
                child: Text(
                  '${i + 1} / ${groups.length}',
                  semanticsLabel:
                      'Exercise ${i + 1} of ${groups.length}, '
                      'tap for an overview',
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: nextButton,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              if (group.length > 1)
                SupersetCard(
                  group: group,
                  isFirst: i == 0,
                  isLast: i == groups.length - 1,
                  workout: widget.workout,
                )
              else
                ExerciseCard(
                  item: group.single,
                  isFirst: i == 0,
                  isLast: i == groups.length - 1,
                  workout: widget.workout,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: _bottomRow(group),
        ),
      ],
    );
  }

  /// [− Remove set] [+ Add set]; a superset page removes / adds a round
  /// (the last set of each exercise / one set each).
  Widget _bottomRow(List<WorkoutExercise> group) {
    final noun = group.length > 1 ? 'round' : 'set';
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: group.any((e) => e.sets.isNotEmpty)
                ? () => removeLastSets(
                    context,
                    ref,
                    group,
                    named: group.length > 1,
                  )
                : null,
            icon: const Icon(Icons.remove),
            label: Text('Remove $noun'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => addSets(ref, group),
            icon: const Icon(Icons.add),
            label: Text('Add $noun'),
          ),
        ),
      ],
    );
  }
}
