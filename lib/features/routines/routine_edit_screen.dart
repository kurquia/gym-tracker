import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';
import '../exercises/exercise_options_sheet.dart';
import 'routine_drop.dart';
import 'routines_screen.dart';
import 'sets_picker.dart';

/// Creates a routine ([routineId] null) or edits an existing one.
class RoutineEditScreen extends ConsumerStatefulWidget {
  const RoutineEditScreen({super.key, this.routineId});

  final int? routineId;

  @override
  ConsumerState<RoutineEditScreen> createState() => _RoutineEditScreenState();
}

class _RoutineEditScreenState extends ConsumerState<RoutineEditScreen> {
  final _name = TextEditingController();
  String _defaultName = '';
  List<_Row> _rows = [];
  bool _loading = true;

  /// Per row: in a superset with the exercise before.
  List<bool> get _superset => [for (final r in _rows) r.superset];

  // Dragging: what, where it would land, and where the pointer is.
  DragSource? _dragging;
  final _hover = ValueNotifier<DropTarget?>(null);
  Offset? _pointer;
  Timer? _autoScroll;
  final _scroll = ScrollController();
  final _viewport = GlobalKey();

  /// Rows by exercise id and block headers by ('header', first id), to find
  /// what the pointer is over.
  final _keys = <Object, GlobalKey>{};
  GlobalKey _key(Object tag) => _keys.putIfAbsent(tag, GlobalKey.new);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final id = widget.routineId;
    if (id == null) {
      _defaultName = await db.routinesDao.nextRoutineName();
    } else {
      final routine = await db.routinesDao.routine(id);
      _name.text = routine.name;
      _defaultName = routine.name;
      final entries = await db.routinesDao.routineEntries(id);
      _rows = [
        for (final e in entries)
          _Row(
            e.exercise,
            superset: e.superset,
            sets: e.sets,
            warmup: e.warmup,
          ),
      ];
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _autoScroll?.cancel();
    _hover.dispose();
    _scroll.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _addExercises() async {
    final picked = await context.push<List<Exercise>>(
      '/exercises/pick',
      extra: {for (final r in _rows) r.exercise.id},
    );
    if (picked != null) {
      setState(() => _rows.addAll([for (final e in picked) _Row(e)]));
    }
  }

  /// Replaces the exercise at [i] with whatever is picked, in its place.
  Future<void> _swap(int i) async {
    final current = _rows[i].exercise;
    final picked = await context.push<List<Exercise>>(
      '/exercises/pick',
      extra: {
        for (final r in _rows)
          if (r.exercise.id != current.id) r.exercise.id,
      },
    );
    if (picked != null) {
      setState(() {
        // The first pick takes the old place in a superset, and its sets.
        _rows[i].exercise = picked.first;
        _rows.insertAll(i + 1, [for (final e in picked.skip(1)) _Row(e)]);
      });
    }
  }

  Future<void> _save() async {
    if (_rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise.')),
      );
      return;
    }
    final name = _name.text.trim();
    await ref
        .read(databaseProvider)
        .routinesDao
        .saveRoutine(
          id: widget.routineId,
          name: name.isEmpty ? _defaultName : name,
          exerciseIds: [for (final r in _rows) r.exercise.id],
          superset: _superset,
          sets: [for (final r in _rows) r.sets],
          warmup: [for (final r in _rows) r.warmup],
        );
    if (mounted) context.pop();
  }

  /// Takes the exercise at [i] out of the list. The one after it stays in
  /// a superset only if this one was in it too (with the one before).
  void _takeOut(int i) {
    final removed = _rows.removeAt(i);
    if (i < _rows.length && _rows[i].superset) {
      _rows[i].superset = removed.superset;
    }
  }

  /// In a superset with a neighbour.
  bool _inSuperset(int i) =>
      _rows[i].superset || (i + 1 < _rows.length && _rows[i + 1].superset);

  /// Deletes right away; the list's snackbar offers Undo, as for a swipe.
  Future<void> _delete() async {
    final db = ref.read(databaseProvider);
    final messenger = ScaffoldMessenger.of(context);
    final deleted = await db.routinesDao.deleteRoutine(widget.routineId!);
    if (mounted) context.pop();
    showRoutineDeleted(messenger, db, deleted);
  }

  // ---- Drag and drop ----------------------------------------------------

  List<List<int>> get _groups => supersetGroups(_superset);

  Rect? _rect(Object tag) {
    final box = _keys[tag]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// What the pointer at height [y] is over: the middle of a row = onto it,
  /// its top or bottom quarter = between rows, a block's header = onto the
  /// block (its top edge = above the block).
  DropTarget _targetAt(double y) {
    for (final g in _groups) {
      if (g.length > 1) {
        final r = _rect(('header', _rows[g.first].exercise.id));
        if (r != null && y < r.bottom) {
          return y < r.top + r.height * 0.35
              ? DropBetween(g.first)
              : DropOntoBlock(g.first);
        }
      }
      for (final i in g) {
        final r = _rect(_rows[i].exercise.id);
        if (r == null || y >= r.bottom) continue;
        final frac = (y - r.top) / r.height;
        if (frac < 0.25) return DropBetween(i);
        if (frac > 0.75) return DropBetween(i + 1);
        return DropOnto(i);
      }
    }
    return DropBetween(_rows.length);
  }

  void _updateHover() {
    final p = _pointer;
    final source = _dragging;
    DropTarget? target;
    if (p != null && source != null) {
      target = _targetAt(p.dy);
      // No target where a drop changes nothing.
      if (applyDrop(_superset, source, target) == null) target = null;
    }
    if (target != _hover.value) setState(() => _hover.value = target);
  }

  void _startDrag(DragSource source) => setState(() => _dragging = source);

  void _endDrag() {
    _autoScroll?.cancel();
    _autoScroll = null;
    _pointer = null;
    _hover.value = null;
    if (mounted) setState(() => _dragging = null);
  }

  void _drop(DragSource source, Offset pointer) {
    final result = applyDrop(_superset, source, _targetAt(pointer.dy));
    if (result == null) return;
    setState(() {
      _rows = [
        for (final (k, i) in result.order.indexed)
          _rows[i]..superset = result.superset[k],
      ];
    });
  }

  /// Sets the number of sets of every member of the superset at [rows].
  Future<void> _pickSets(List<int> rows) async {
    final current = {
      for (final i in rows) (sets: _rows[i].sets, warmup: _rows[i].warmup),
    };
    final picked = await showSetsPicker(
      context,
      initial: current.length == 1
          ? current.single
          : (sets: null, warmup: false),
    );
    if (picked == null) return;
    setState(() {
      for (final i in rows) {
        _rows[i]
          ..sets = picked.sets
          ..warmup = picked.warmup;
      }
    });
  }

  /// "barbell · W + 3 sets".
  String? _subtitle(int i) {
    final row = _rows[i];
    final sets = row.sets;
    final parts = [
      ?row.exercise.equipment,
      if (sets != null) '${row.warmup ? 'W + ' : ''}${countOf(sets, 'set')}',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// Scrolls while the pointer is near the top or bottom of the list.
  void _scrollNearEdges() {
    void stop() {
      _autoScroll?.cancel();
      _autoScroll = null;
    }

    _autoScroll ??= Timer.periodic(const Duration(milliseconds: 16), (_) {
      final p = _pointer;
      final box = _viewport.currentContext?.findRenderObject() as RenderBox?;
      if (p == null || box == null || !_scroll.hasClients) return stop();
      const edge = 56.0, fastest = 12.0;
      final top = box.localToGlobal(Offset.zero).dy;
      final bottom = top + box.size.height;
      final speed = p.dy < top + edge
          ? -fastest * ((top + edge - p.dy) / edge).clamp(0.0, 1.0)
          : p.dy > bottom - edge
          ? fastest * ((p.dy - bottom + edge) / edge).clamp(0.0, 1.0)
          : 0.0;
      final pos = _scroll.position;
      final to = (pos.pixels + speed).clamp(
        pos.minScrollExtent,
        pos.maxScrollExtent,
      );
      if (to == pos.pixels) return stop();
      _scroll.jumpTo(to);
      _updateHover();
    });
  }

  /// What letting go does, shown on the card under the finger.
  String? _action(DropTarget? target) {
    final source = _dragging;
    if (target == null || source == null) return null;
    final from = switch (source) {
      DragExercise(:final index) => index,
      DragBlock(:final start) => start,
    };
    final groups = _groups;
    List<int> groupOf(int i) => groups.firstWhere((g) => g.contains(i));
    // Already in that superset: only the order changes.
    bool own(int i) => groupOf(i).length > 1 && groupOf(i).contains(from);
    return switch (target) {
      DropOnto(:final index) when own(index) => 'Move here',
      DropOnto(:final index) => 'Superset with ${_rows[index].exercise.name}',
      DropOntoBlock(:final start) when own(start) => 'Move to the end',
      DropOntoBlock() => 'Join the superset',
      DropBetween(:final gap) when insideBlock(_superset, gap) && !own(gap) =>
        'Join the superset',
      DropBetween() => 'Move here',
    };
  }

  /// Keeps the dragged card at a fixed left edge, whatever the finger's x,
  /// so it stays on screen; vertically it follows the finger. The drop
  /// position the target gets then has the pointer's y.
  static Offset _cardAnchor(Draggable<Object> _, BuildContext _, Offset at) =>
      Offset(at.dx - 40, 0);

  /// Makes [child] start a drag of [source]: right away for a handle, after
  /// a long press for a whole row.
  Widget _draggable({
    required DragSource source,
    required String title,
    required String? subtitle,
    required Widget child,
    bool longPress = false,
  }) {
    final feedback = Transform.translate(
      // A little below the finger, so the target stays visible.
      offset: const Offset(0, 16),
      child: ValueListenableBuilder(
        valueListenable: _hover,
        builder: (context, target, _) => Material(
          color: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white38),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 280,
            child: ListTile(
              leading: const Icon(Icons.drag_handle),
              title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: switch (_action(target) ?? subtitle) {
                null => null,
                final text => Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              },
            ),
          ),
        ),
      ),
    );
    return longPress
        ? LongPressDraggable<DragSource>(
            data: source,
            dragAnchorStrategy: _cardAnchor,
            feedback: feedback,
            onDragStarted: () => _startDrag(source),
            onDragEnd: (_) => _endDrag(),
            child: child,
          )
        : Draggable<DragSource>(
            data: source,
            dragAnchorStrategy: _cardAnchor,
            feedback: feedback,
            onDragStarted: () => _startDrag(source),
            onDragEnd: (_) => _endDrag(),
            child: child,
          );
  }

  bool _isDragged(int i) => switch (_dragging) {
    DragExercise(:final index) => index == i,
    DragBlock(:final start) => _groups.any(
      (g) => g.first == start && g.contains(i),
    ),
    null => false,
  };

  /// Hovering between rows: where the dragged exercise would land. Takes no
  /// height, so nothing jumps.
  Widget _insertionLine() => SizedBox(
    height: 0,
    child: OverflowBox(
      maxHeight: 12,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 2,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 2,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // ---- Rows -------------------------------------------------------------

  /// One exercise; [letter] (A, B, …) when it is in a superset block.
  Widget _exerciseRow(int i, {String? letter}) {
    final e = _rows[i].exercise;
    final last = i == _rows.length - 1;
    final hovered = _hover.value == DropOnto(i);
    final tile = ListTile(
      contentPadding: const EdgeInsets.only(left: 8, right: 4),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _draggable(
            source: DragExercise(i),
            title: e.name,
            subtitle: e.equipment,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Icon(
                Icons.drag_handle,
                color: letter != null ? Colors.white70 : null,
              ),
            ),
          ),
          if (letter != null) ...[
            const SizedBox(width: 12),
            Text(letter, style: Theme.of(context).textTheme.titleMedium),
          ],
        ],
      ),
      title: Text(e.name),
      subtitle: switch (_subtitle(i)) {
        null => null,
        final text => Text(text),
      },
      trailing: PopupMenuButton<void>(
        tooltip: 'Exercise options',
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: () => showExerciseOptions(
              context,
              e.id,
              routineSets: (sets: _rows[i].sets, warmup: _rows[i].warmup),
              onRoutineSets: (choice) => setState(
                () => _rows[i]
                  ..sets = choice.sets
                  ..warmup = choice.warmup,
              ),
            ),
            child: const Text('Edit'),
          ),
          PopupMenuItem(
            onTap: () => _swap(i),
            child: const Text('Change exercise'),
          ),
          if (!last && !_rows[i + 1].superset)
            PopupMenuItem(
              onTap: () => setState(() => _rows[i + 1].superset = true),
              child: const Text('Superset with next'),
            ),
          if (_inSuperset(i))
            PopupMenuItem(
              onTap: () => setState(() {
                _rows[i].superset = false;
                if (!last) _rows[i + 1].superset = false;
              }),
              child: const Text('Leave superset'),
            ),
          PopupMenuItem(
            onTap: () => setState(() => _takeOut(i)),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    final row = Container(
      key: _key(e.id),
      // Hovering onto it: letting go makes a superset with it.
      decoration: hovered
          ? BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: _draggable(
        source: DragExercise(i),
        title: e.name,
        subtitle: e.equipment,
        longPress: true,
        child: tile,
      ),
    );
    return _isDragged(i) ? Opacity(opacity: 0.25, child: row) : row;
  }

  /// A superset: one outlined block; the handle in its header moves all of it.
  Widget _block(List<int> group) {
    final hover = _hover.value;
    final hovered = hover == DropOntoBlock(group.first);
    final title = [for (final i in group) _rows[i].exercise.name].join(' + ');
    final header = Padding(
      key: _key(('header', _rows[group.first].exercise.id)),
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 0),
      child: _draggable(
        source: DragBlock(group.first),
        title: title,
        subtitle: 'Superset',
        longPress: true,
        child: Row(
          children: [
            _draggable(
              source: DragBlock(group.first),
              title: title,
              subtitle: 'Superset',
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Icon(Icons.drag_handle),
              ),
            ),
            const SizedBox(width: 12),
            Text('Superset', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            PopupMenuButton<void>(
              tooltip: 'Superset options',
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () => _pickSets(group),
                  child: const Text('Sets'),
                ),
                PopupMenuItem(
                  onTap: () => setState(() {
                    for (final i in group) {
                      _rows[i].superset = false;
                    }
                  }),
                  child: const Text('Ungroup'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        // Hovering onto the header: letting go joins this superset.
        color: hovered ? Colors.white.withValues(alpha: 0.14) : null,
        border: hovered
            ? Border.all(
                color: Theme.of(context).colorScheme.onSurface,
                width: 2,
              )
            : Border.all(color: Colors.white54),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          header,
          for (final (k, i) in group.indexed) ...[
            if (k > 0 && hover == DropBetween(i)) _insertionLine(),
            _exerciseRow(i, letter: String.fromCharCode(0x41 + k)),
          ],
        ],
      ),
    );
  }

  Widget _list() {
    final hover = _hover.value;
    final superset = _superset;
    // The line between groups; one inside a block is drawn by the block.
    bool lineAt(int gap) =>
        hover == DropBetween(gap) && !insideBlock(superset, gap);
    return Column(
      children: [
        for (final g in _groups) ...[
          if (lineAt(g.first)) _insertionLine(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: g.length == 1 ? _exerciseRow(g.single) : _block(g),
          ),
        ],
        if (lineAt(_rows.length)) _insertionLine(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routineId == null ? 'New routine' : 'Edit routine'),
        actions: [
          if (widget.routineId != null)
            IconButton(
              tooltip: 'Delete routine',
              color: Theme.of(context).colorScheme.error,
              icon: const Icon(Icons.delete_outline),
              onPressed: _loading ? null : _delete,
            ),
          TextButton(
            onPressed: _loading ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _name,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: _defaultName,
                    ),
                  ),
                ),
                Expanded(
                  child: DragTarget<DragSource>(
                    key: _viewport,
                    onMove: (details) {
                      _pointer = details.offset;
                      _updateHover();
                      _scrollNearEdges();
                    },
                    onLeave: (_) {
                      _pointer = null;
                      _updateHover();
                    },
                    onAcceptWithDetails: (details) =>
                        _drop(details.data, details.offset),
                    builder: (context, _, _) => SingleChildScrollView(
                      controller: _scroll,
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          _list(),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: OutlinedButton.icon(
                              onPressed: _addExercises,
                              icon: const Icon(Icons.add),
                              label: const Text('Add exercises'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// One exercise in the routine being edited.
class _Row {
  _Row(this.exercise, {this.superset = false, this.sets, this.warmup = false});

  Exercise exercise;

  /// In a superset with the exercise before.
  bool superset;

  /// Number of working sets, null = as last time.
  int? sets;

  /// With a number of sets, start with warm-ups.
  bool warmup;
}
