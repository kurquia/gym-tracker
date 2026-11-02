import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/placeholder_body.dart';
import '../exercises/exercise_browser.dart';
import 'time_chart.dart';

/// The charts of Statistics → Exercises, one at a time.
enum ProgressPlot {
  oneRepMax('1RM'),
  volume('Volume'),
  sets('Sets per week');

  const ProgressPlot(this.label);
  final String label;
}

/// Statistics → Exercises: one exercise's progress over time.
class ExerciseProgressView extends ConsumerWidget {
  const ExerciseProgressView({
    super.key,
    required this.exerciseId,
    required this.onPick,
    required this.range,
    required this.onRange,
    required this.plot,
    required this.onPlot,
  });

  /// Null = the most often done exercise.
  final int? exerciseId;
  final void Function(int exerciseId) onPick;
  final ChartRange range;
  final void Function(ChartRange range) onRange;
  final ProgressPlot plot;
  final void Function(ProgressPlot plot) onPlot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logged = ref.watch(loggedExercisesProvider).value;
    if (logged == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (logged.isEmpty) {
      return const PlaceholderBody(
        text: 'Finish a workout to see your progress here.',
      );
    }
    final chosen = logged.firstWhere(
      (l) => l.exercise.id == exerciseId,
      orElse: () => logged.first,
    );
    final history =
        ref.watch(exerciseHistoryProvider(chosen.exercise.id)).value ?? [];
    final points = strengthHistory(history);
    final volume = volumeHistory(history);
    // Bodyweight exercises have no kg × reps: their volume is reps.
    final byReps = mostlyBodyweight(history);
    final unit = ref.watch(weightUnitProvider);
    final firstWeekday = ref.watch(firstWeekdayProvider);
    final today = DateTime.now();
    final start =
        range.start(today) ?? (history.isEmpty ? today : history.first.date);
    final from = DateTime(start.year, start.month, start.day);
    final bucket = Bucket.forSpan(today.difference(from));
    bool inRange(DateTime d) => !d.isBefore(from);
    final strength = bestPer(
      [
        for (final p in points)
          if (inRange(p.date)) p,
      ],
      bucket,
      firstWeekday: firstWeekday,
    );
    final shownVolume = [
      for (final p in volume)
        if (inRange(p.date)) p,
    ];
    final load = sumPer(shownVolume, bucket, firstWeekday: firstWeekday);
    // Sets are counted per week at least.
    final setsBucket = bucket == Bucket.month ? Bucket.month : Bucket.week;
    final sets = sumPer(shownVolume, setsBucket, firstWeekday: firstWeekday);
    // Weeks before the first workout don't count against the rate.
    final perWeek = workoutsPerWeek(
      shownVolume.length,
      volume.isNotEmpty && volume.first.date.isAfter(from)
          ? volume.first.date
          : from,
      today,
    );
    final lastDone = volume.isEmpty ? null : volume.last.date;
    double periodDays(Bucket b) => switch (b) {
      Bucket.workout => 0,
      Bucket.week => 7,
      Bucket.month => 30,
    };
    String weightSum(VolumePoint p) =>
        '${unit.fromKg(p.kg).round()} ${unit.name}';
    final perDumbbell = chosen.exercise.counting == WeightCounting.perDumbbell;
    final textTheme = Theme.of(context).textTheme;
    final grey = context.greyText;

    String heading(DateTime d, Bucket b) => switch (b) {
      Bucket.workout => formatDay(d),
      // "Week 43", with the year when it isn't this one.
      Bucket.week => [
        'Week ${weekNumber(d, firstWeekday)}',
        if (weekYear(d, firstWeekday) != today.year)
          '${weekYear(d, firstWeekday)}',
      ].join(', '),
      Bucket.month => formatMonth(d),
    };
    Widget empty(String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(child: Text(text, style: grey)),
    );
    Widget chart(TimeChart c) =>
        Padding(padding: const EdgeInsets.only(right: 8), child: c);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _pick(context, logged, chosen.exercise.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chosen.exercise.name, style: textTheme.titleLarge),
                      Text(
                        history.isEmpty
                            ? countOf(chosen.sessions, 'workout')
                            : '${countOf(chosen.sessions, 'workout')} since '
                                  '${formatMonth(history.first.date)}',
                        style: grey,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.expand_more),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: SegmentedButton<ChartRange>(
            showSelectedIcon: false,
            segments: [
              for (final r in ChartRange.values)
                ButtonSegment(value: r, label: Text(r.label)),
            ],
            selected: {range},
            onSelectionChanged: (r) => onRange(r.single),
          ),
        ),
        if (lastDone != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Text.rich(
                TextSpan(
                  style: grey,
                  children: [
                    TextSpan(
                      text: '${perWeek.toStringAsFixed(1)} times a week',
                      style: const TextStyle(color: previousColour),
                    ),
                    const TextSpan(text: ' · last done '),
                    TextSpan(
                      text: daysAgo(lastDone, today),
                      style: const TextStyle(color: previousColour),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        const Divider(height: 32),
        Row(
          children: [
            PopupMenuButton<ProgressPlot>(
              tooltip: 'Choose a chart',
              initialValue: plot,
              onSelected: onPlot,
              itemBuilder: (_) => [
                for (final p in ProgressPlot.values)
                  PopupMenuItem(value: p, child: Text(p.label)),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(plot.label, style: textTheme.titleMedium),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            const Spacer(),
            if (plot == ProgressPlot.oneRepMax)
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'How is this calculated?',
                onPressed: () => _explain(context),
              )
            else
              const SizedBox(height: 48),
          ],
        ),
        if (plot == ProgressPlot.oneRepMax) ...[
          if (points.isEmpty)
            empty(
              'No weighted working sets of up to $maxRepsForEstimate reps yet.',
            )
          else ...[
            _Headline(points: points, unit: unit),
            const SizedBox(height: 16),
            if (strength.isEmpty)
              empty('No workouts in this time.')
            else
              chart(
                TimeChart(
                  dates: [for (final p in strength) p.date],
                  values: [for (final p in strength) unit.fromKg(p.oneRepMax)],
                  from: from,
                  to: today,
                  // 2 kg of room above and below, never under 0.
                  minY: math.max(
                    0,
                    unit.fromKg(
                          strength.map((p) => p.oneRepMax).reduce(math.min),
                        ) -
                        unit.fromKg(2),
                  ),
                  maxY:
                      unit.fromKg(
                        strength.map((p) => p.oneRepMax).reduce(math.max),
                      ) +
                      unit.fromKg(2),
                  yLabel: perDumbbell
                      ? '1RM per dumbbell (${unit.name})'
                      : '1RM (${unit.name})',
                  formatY: (v) => formatWeight(unit.toKg(v), unit),
                  tooltip: (i) => (
                    formatDay(strength[i].date),
                    '${unit.fromKg(strength[i].oneRepMax).round()} ${unit.name}'
                        '  (${formatSet(strength[i].best, unit)})',
                  ),
                ),
              ),
          ],
        ],
        if (plot != ProgressPlot.oneRepMax) const SizedBox(height: 8),
        if (plot != ProgressPlot.oneRepMax && load.isEmpty)
          empty('No working sets in this time.'),
        if (plot == ProgressPlot.volume && load.isNotEmpty)
          chart(
            TimeChart(
              dates: [for (final p in load) p.date],
              values: [
                for (final p in load)
                  byReps ? p.reps.toDouble() : unit.fromKg(p.kg),
              ],
              from: from,
              to: today,
              minY: 0,
              maxY:
                  (byReps
                      ? load.map((p) => p.reps).reduce(math.max).toDouble()
                      : unit.fromKg(load.map((p) => p.kg).reduce(math.max))) *
                  1.1,
              yLabel: byReps
                  ? 'Reps'
                  : perDumbbell
                  ? '${unit.name} × reps per dumbbell'
                  : '${unit.name} × reps',
              periodDays: periodDays(bucket),
              formatY: (v) => v.round().toString(),
              tooltip: (i) => (
                heading(load[i].date, bucket),
                '${byReps ? countOf(load[i].reps, 'rep') : weightSum(load[i])}'
                    ' · ${countOf(load[i].sets, 'set')}',
              ),
            ),
          ),
        if (plot == ProgressPlot.sets && load.isNotEmpty)
          chart(
            TimeChart(
              dates: [for (final p in sets) p.date],
              values: [for (final p in sets) p.sets.toDouble()],
              from: from,
              to: today,
              minY: 0,
              maxY: sets.map((p) => p.sets).reduce(math.max) * 1.1 + 1,
              yLabel: setsBucket == Bucket.week
                  ? 'Working sets per week'
                  : 'Working sets per month',
              periodDays: periodDays(setsBucket),
              formatY: (v) => v.round().toString(),
              tooltip: (i) => (
                heading(sets[i].date, setsBucket),
                countOf(sets[i].sets, 'working set'),
              ),
            ),
          ),
      ],
    );
  }

  void _explain(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showDialog<void>(
      context: context,
      // Not an AlertDialog: it measures intrinsic sizes, which Math can't give.
      builder: (dialog) => Dialog(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How is this calculated?', style: textTheme.headlineSmall),
              const SizedBox(height: 16),
              const Text(
                'Each dot is your estimated one-rep max (1RM): the most you '
                'could lift once. We use the formula',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Math.tex(
                    r'\mathrm{1RM} = \frac{w}{1.026}\,e^{0.031\,r},',
                    textStyle: TextStyle(
                      fontSize: textTheme.titleMedium?.fontSize,
                    ),
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'where '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Math.tex('w'),
                    ),
                    const TextSpan(text: ' is the weight used and '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Math.tex('r'),
                    ),
                    const TextSpan(
                      text:
                          ' the number of repetitions performed with it, to '
                          'failure.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mitter B, Csapo R, Bauer P, Tschan H (2022). Reproducibility '
                'of strength performance and strength-endurance profiles: a '
                'test-retest study. PLOS ONE 17(5): e0268074.',
                style: textTheme.labelSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(dialog),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pick(
    BuildContext context,
    List<({Exercise exercise, int sessions})> logged,
    int current,
  ) {
    final sessions = {for (final l in logged) l.exercise.id: l.sessions};
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheet).bottom),
        child: SizedBox(
          height: MediaQuery.sizeOf(sheet).height * 0.85,
          child: ExerciseBrowser(
            only: [for (final l in logged) l.exercise.id],
            tileBuilder: (context, e, details) => ListTile(
              title: Text(e.name),
              subtitle: Text(countOf(sessions[e.id] ?? 0, 'workout')),
              selected: e.id == current,
              onTap: () {
                Navigator.pop(sheet);
                onPick(e.id);
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Record and last time, side by side.
class _Headline extends StatelessWidget {
  const _Headline({required this.points, required this.unit});
  final List<StrengthPoint> points;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final record = points.lastWhere((p) => p.isRecord);
    return Row(
      children: [
        Expanded(child: _stat(context, 'Record', record)),
        Expanded(child: _stat(context, 'Last time', points.last)),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, StrengthPoint p) {
    final textTheme = Theme.of(context).textTheme;
    final grey = context.greyText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: grey),
        Text(
          '${unit.fromKg(p.oneRepMax).round()} ${unit.name}',
          style: textTheme.headlineSmall,
        ),
        Text('${formatSet(p.best, unit)} · ${formatDay(p.date)}', style: grey),
      ],
    );
  }
}
