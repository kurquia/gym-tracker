import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/placeholder_body.dart';
import 'body_model/muscle_map.dart';

/// Letters and digits only, lower case, so "Pull-Up", "pull up" and "Pullups"
/// all match each other.
String _squash(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), '');

/// Whether every word of [query] occurs in [name].
bool nameMatches(String name, String query) {
  final squashed = _squash(name);
  return query
      .split(RegExp(r'\s+'))
      .map(_squash)
      .where((w) => w.isNotEmpty)
      .every(squashed.contains);
}

/// What an exercise can be filtered by.
enum Facet {
  muscle('Muscle'),
  equipment('Equipment'),
  kind('Kind');

  const Facet(this.label);
  final String label;

  /// The entry's values for this facet: its target muscles' coarse groups,
  /// its equipment, its free-exercise-db category ("strength", "stretching").
  Set<String> valuesOf(CatalogEntry c) => switch (this) {
    muscle => {for (final id in c.targetMuscleIds) ?coarseGroupOf(id)},
    equipment => {?c.exercise.equipment},
    kind => {?c.exercise.category},
  };
}

/// The search text and the chosen options per facet. Options of one facet
/// are OR-ed ("barbell or dumbbell"), facets AND-ed ("chest and barbell").
class ExerciseFilter {
  const ExerciseFilter({this.query = '', this.chosen = const {}});

  final String query;
  final Map<Facet, Set<String>> chosen;

  Set<String> of(Facet f) => chosen[f] ?? const {};

  int get count => chosen.values.fold(0, (n, s) => n + s.length);

  ExerciseFilter withQuery(String q) =>
      ExerciseFilter(query: q, chosen: chosen);

  /// [option] of [facet] switched on or off.
  ExerciseFilter toggle(Facet facet, String option) {
    final options = {...of(facet)};
    if (!options.remove(option)) options.add(option);
    return ExerciseFilter(query: query, chosen: {...chosen, facet: options});
  }

  /// No options chosen in [facet], or in any facet when null; the search
  /// text stays.
  ExerciseFilter clear([Facet? facet]) => ExerciseFilter(
    query: query,
    chosen: facet == null ? const {} : {...chosen, facet: const {}},
  );

  /// Whether [c] passes, leaving out [except] (to count that facet's options).
  bool matches(CatalogEntry c, {Facet? except}) =>
      nameMatches(c.exercise.name, query) &&
      Facet.values.every(
        (f) =>
            f == except || of(f).isEmpty || f.valuesOf(c).any(of(f).contains),
      );

  /// For each option of [facet], how many of [entries] would show with it
  /// chosen (on top of the other facets); options sorted by name.
  Map<String, int> counts(Facet facet, List<CatalogEntry> entries) {
    final counts = <String, int>{};
    for (final c in entries) {
      final hit = matches(c, except: facet);
      for (final v in facet.valuesOf(c)) {
        counts[v] = (counts[v] ?? 0) + (hit ? 1 : 0);
      }
    }
    return Map.fromEntries(
      counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }
}

/// Search field, filter buttons (muscle, equipment, kind) and the filtered
/// exercise library.
class ExerciseBrowser extends ConsumerStatefulWidget {
  const ExerciseBrowser({
    super.key,
    required this.tileBuilder,
    this.onCreate,
    this.only,
  });

  /// Builds one row; [details] is "target muscles · equipment".
  final Widget Function(BuildContext context, Exercise e, String details)
  tileBuilder;

  /// Called by the "Create …" row on top of the results while searching,
  /// with the search text; no such row when null.
  final void Function(String query)? onCreate;

  /// Only these exercises, in this order; the whole library A–Z when null.
  final List<int>? only;

  @override
  ConsumerState<ExerciseBrowser> createState() => _ExerciseBrowserState();
}

class _ExerciseBrowserState extends ConsumerState<ExerciseBrowser> {
  final _filter = ValueNotifier(const ExerciseFilter());

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  List<CatalogEntry> _entries(List<CatalogEntry> all) {
    final only = widget.only;
    if (only == null) return all;
    final byId = {for (final c in all) c.exercise.id: c};
    return [for (final id in only) ?byId[id]];
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(exerciseCatalogProvider);
    final muscles = ref.watch(musclesProvider).value ?? const <Muscle>[];
    final muscleNames = {for (final m in muscles) m.id: m.name};

    return ValueListenableBuilder(
      valueListenable: _filter,
      builder: (context, filter, _) {
        final entries = _entries(catalog.value ?? const []);
        final shown = entries.where(filter.matches).toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search exercises',
                ),
                onChanged: (q) => _filter.value = filter.withQuery(q),
              ),
            ),
            _FilterBar(
              filter: _filter,
              entries: entries,
              name: (f, o) => f == Facet.muscle
                  ? muscleNames[o] ?? muscleName(o)
                  : sentenceCase(o),
              shown: shown.length,
            ),
            Expanded(
              child: catalog.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    PlaceholderBody(text: 'Could not load exercises.\n$e'),
                data: (_) => _results(context, filter, shown, muscleNames),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _results(
    BuildContext context,
    ExerciseFilter filter,
    List<CatalogEntry> shown,
    Map<String, String> muscleNames,
  ) {
    final query = filter.query.trim();
    final createTile = query.isNotEmpty && widget.onCreate != null
        ? ListTile(
            leading: const Icon(Icons.add),
            title: Text('Create “$query”'),
            subtitle: const Text('New custom exercise'),
            onTap: () => widget.onCreate!(query),
          )
        : null;
    if (shown.isEmpty && createTile == null) {
      return Column(
        children: [
          const SizedBox(height: 48),
          const Text('No matching exercises.'),
          if (filter.count > 0)
            TextButton(
              onPressed: () => _filter.value = filter.clear(),
              child: const Text('Clear filters'),
            ),
        ],
      );
    }
    final offset = createTile == null ? 0 : 1;
    return ListView.builder(
      // Room for a floating action button below the last row.
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: shown.length + offset,
      itemBuilder: (context, i) {
        if (i < offset) return createTile!;
        final c = shown[i - offset];
        final details = [
          ...groupNames(c.targetMuscleIds, muscleNames),
          ?c.exercise.equipment,
          if (c.exercise.isCustom) 'custom',
        ].join(' · ');
        return widget.tileBuilder(context, c.exercise, details);
      },
    );
  }
}

typedef _Namer = String Function(Facet facet, String option);

/// A button per facet ("Muscle ▾", or "Chest +1" once chosen), each opening
/// its options in a sheet; then the number of exercises shown and Clear.
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filter,
    required this.entries,
    required this.name,
    required this.shown,
  });

  final ValueNotifier<ExerciseFilter> filter;
  final List<CatalogEntry> entries;
  final _Namer name;
  final int shown;

  @override
  Widget build(BuildContext context) {
    final f = filter.value;
    Widget button(Facet facet) {
      final chosen = f.of(facet).toList()..sort();
      final label = switch (chosen) {
        [] => facet.label,
        [final one] => name(facet, one),
        [final first, ...] => '${name(facet, first)} +${chosen.length - 1}',
      };
      Future<void> open() => _openSheet(
        context,
        facet: facet,
        filter: filter,
        entries: entries,
        name: name,
      );
      final content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(label), const Icon(Icons.arrow_drop_down, size: 20)],
      );
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: chosen.isEmpty
            ? OutlinedButton(onPressed: open, child: content)
            : FilledButton.tonal(onPressed: open, child: content),
      );
    }

    final grey = context.greyText;
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
          child: Row(
            children: [for (final facet in Facet.values) button(facet)],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
          child: Row(
            children: [
              Text(countOf(shown, 'exercise'), style: grey),
              const Spacer(),
              if (f.count > 0)
                TextButton(
                  onPressed: () => filter.value = f.clear(),
                  child: const Text('Clear'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// [facet]'s options as chips with counts, in a sheet updated live, with a
/// "Show N exercises" button. Options that would show nothing are greyed out
/// unless chosen.
Future<void> _openSheet(
  BuildContext context, {
  required Facet facet,
  required ValueNotifier<ExerciseFilter> filter,
  required List<CatalogEntry> entries,
  required _Namer name,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (sheet) => ValueListenableBuilder(
    valueListenable: filter,
    builder: (context, f, _) {
      final shown = entries.where(f.matches).length;
      final chosen = f.of(facet);
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facet.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final MapEntry(key: option, value: n)
                            in f.counts(facet, entries).entries)
                          FilterChip(
                            label: Text('${name(facet, option)}  $n'),
                            selected: chosen.contains(option),
                            onSelected: n == 0 && !chosen.contains(option)
                                ? null
                                : (_) => filter.value = filter.value.toggle(
                                    facet,
                                    option,
                                  ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => filter.value = f.clear(facet),
                    child: const Text('Clear'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.pop(sheet),
                    child: Text('Show ${countOf(shown, 'exercise')}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  ),
);
