import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/confirm.dart';
import '../../shared/widgets/placeholder_body.dart';
import 'body_model/body_view.dart';
import 'body_model/muscle_map.dart';
import 'exercise_options_sheet.dart';

/// One exercise: equipment, muscles by role and last time's sets.
/// Custom exercises can be edited and deleted here.
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final int exerciseId;

  static String _roleLabel(MuscleRole role) => switch (role) {
    MuscleRole.target => 'Target',
    MuscleRole.synergist => 'Synergists',
    MuscleRole.stabilizer => 'Fixators',
  };

  /// "Main: chest" (targets) and "Secondary: shoulders, triceps"
  /// (synergists), as groups; groups already under Main aren't repeated.
  /// Stabilizers are only in the full list.
  static List<(String, String)> _summary(
    Map<MuscleRole, List<Muscle>> muscles,
    Map<String, String> names,
  ) {
    List<String> groups(MuscleRole role) => groupNames([
      for (final m in muscles[role] ?? const <Muscle>[]) m.id,
    ], names);
    final main = groups(MuscleRole.target);
    final secondary = [
      for (final g in groups(MuscleRole.synergist))
        if (!main.contains(g)) g,
    ];
    String text(List<String> l) => l.join(', ').toLowerCase();
    return [
      if (main.isNotEmpty) ('Main', text(main)),
      if (secondary.isNotEmpty) ('Secondary', text(secondary)),
    ];
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await confirm(
      context,
      title: 'Delete exercise?',
      action: 'Delete',
      destructive: true,
    );
    if (!ok) return;
    final deleted = await ref
        .read(databaseProvider)
        .exercisesDao
        .deleteCustomExercise(exerciseId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? 'Exercise deleted.'
              : 'A routine or workout uses this exercise, so it stays.',
        ),
      ),
    );
    if (deleted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(exerciseDetailProvider(exerciseId));
    final textTheme = Theme.of(context).textTheme;
    final muted = textTheme.bodyMedium.muted;

    final unit = ref.watch(weightUnitProvider);
    final names = {
      for (final m in ref.watch(musclesProvider).value ?? const <Muscle>[])
        m.id: m.name,
    };
    return detail.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: PlaceholderBody(text: 'Could not load the exercise.\n$e'),
      ),
      data: (d) {
        if (d == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const PlaceholderBody(text: 'Exercise not found.'),
          );
        }
        final e = d.exercise;
        final highlight = BodyHighlight.ofExercise(d.muscles);
        // Each row opens the options sheet.
        Widget option(String title, String value) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title),
          subtitle: Text(value),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showExerciseOptions(context, e.id),
        );
        return Scaffold(
          appBar: AppBar(
            title: Text(e.name),
            actions: [
              if (e.isCustom) ...[
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push('/exercises/${e.id}/edit'),
                ),
                PopupMenuButton<void>(
                  tooltip: 'Exercise options',
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => _delete(context, ref),
                      child: const Text('Delete exercise'),
                    ),
                  ],
                ),
              ],
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Text(
                [
                  sentenceCase(e.equipment ?? 'no equipment'),
                  if (e.isCustom) 'custom exercise',
                ].join(' · '),
                style: muted,
              ),
              const SizedBox(height: 24),
              Text('Muscles', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final (label, groups) in _summary(d.muscles, names))
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '$label: ', style: muted),
                        TextSpan(text: groups),
                      ],
                    ),
                  ),
                ),
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  expandedAlignment: Alignment.centerLeft,
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  title: const Text('More information'),
                  children: [
                    for (final role in MuscleRole.values)
                      if (d.muscles[role] case final list?) ...[
                        Text(_roleLabel(role), style: muted),
                        for (final m in list) Text('•  ${m.name}'),
                        const SizedBox(height: 8),
                      ],
                    if (!e.isCustom && !e.musclesVerified)
                      Text(
                        'Approximate (free-exercise-db), not checked yet.',
                        style: textTheme.bodySmall.faint,
                      ),
                  ],
                ),
              ),
              if (highlight.onModel) ...[
                const SizedBox(height: 16),
                BodyKeyFilter(
                  highlight: highlight,
                  hint: 'Tap to turn and zoom in 3D',
                  builder: (context, shown, legend) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 360,
                        child: BodyFigures(
                          highlight: shown,
                          route: '/exercises/${e.id}/3d',
                        ),
                      ),
                      const SizedBox(height: 8),
                      legend,
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text('Options', style: textTheme.titleMedium),
              option('Weight counted as', weightCountingSummary(e, unit)),
              option('Setup', switch (setupSummary([
                for (final f in d.setupFields) (field: f, value: f.value),
              ])) {
                '' => 'None',
                final setup => setup,
              }),
              option('Note', e.note ?? 'None'),
              const SizedBox(height: 16),
              Text('Last time', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              switch (d.lastTime) {
                null => Text('Not done yet.', style: muted),
                final p => Text(
                  '${formatDay(p.date)}: '
                  '${p.sets.map((s) => formatSet(s, unit)).join(' · ')}',
                ),
              },
            ],
          ),
        );
      },
    );
  }
}
