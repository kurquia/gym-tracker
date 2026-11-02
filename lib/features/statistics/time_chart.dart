import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../shared/format.dart';

/// Values over time as a line with dots, on a date axis from [from] to [to].
class TimeChart extends StatelessWidget {
  const TimeChart({
    super.key,
    required this.dates,
    required this.values,
    required this.from,
    required this.to,
    required this.minY,
    required this.maxY,
    required this.yLabel,
    this.periodDays = 0,
    required this.formatY,
    required this.tooltip,
  });

  /// At least one, oldest first, all within [from]..[to]; one value each.
  final List<DateTime> dates;
  final List<double> values;
  final DateTime from;
  final DateTime to;
  final double minY;
  final double maxY;
  final String yLabel;

  /// For sums dated at their week's or month's start: its length in days, so
  /// the dot stands in its middle.
  final double periodDays;
  final String Function(double y) formatY;

  /// Point i's tooltip: a small heading and the value line.
  final (String, String) Function(int i) tooltip;

  double _x(DateTime d) => d.difference(from).inHours / Duration.hoursPerDay;

  DateTime _day(double x) =>
      DateTime(from.year, from.month, from.day + x.round());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final faint = theme.colorScheme.onSurface.withValues(alpha: 0.3);
    final small = theme.textTheme.bodySmall!.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final step = _niceStep((maxY - minY) / 4);
    final days = _x(to);
    final monthStep = math.max(1, (_monthsBetween(from, to) / 4).ceil());
    String? dateLabel(DateTime day) {
      if (days <= 45) {
        // Weekly ticks from the first day.
        return day.difference(from).inDays % 7 == 0
            ? '${day.day} ${monthName(day).substring(0, 3)}'
            : null;
      }
      if (day.day != 1 ||
          _monthsBetween(DateTime(from.year, from.month), day) % monthStep !=
              0) {
        return null;
      }
      return day.month == 1 ? '${day.year}' : monthName(day).substring(0, 3);
    }

    return AspectRatio(
      aspectRatio: 1.4,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: math.max(1, days),
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (final (i, d) in dates.indexed)
                  FlSpot(_x(d) + periodDays / 2, values[i]),
              ],
              color: Theme.of(context).colorScheme.onSurface,
              barWidth: 2,
              dotData: FlDotData(
                getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                  radius: 3.5,
                  color: Theme.of(context).colorScheme.onSurface,
                  strokeWidth: 0,
                ),
              ),
            ),
          ],
          borderData: FlBorderData(
            border: Border(
              left: BorderSide(color: faint),
              bottom: BorderSide(color: faint),
            ),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: step,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Colors.white12, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              axisNameWidget: Text(yLabel, style: small),
              axisNameSize: 20,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: step,
                minIncluded: minY == 0,
                maxIncluded: false,
                getTitlesWidget: (v, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(formatY(v), style: small),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (v, meta) {
                  final label = dateLabel(_day(v));
                  return label == null
                      ? const SizedBox.shrink()
                      : SideTitleWidget(
                          meta: meta,
                          child: Text(label, style: small),
                        );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => theme.colorScheme.surfaceContainerHigh,
              getTooltipItems: (touched) => [
                for (final s in touched)
                  if (tooltip(s.spotIndex) case (final heading, final value))
                    LineTooltipItem(
                      '$heading\n',
                      theme.textTheme.bodySmall!,
                      children: [
                        TextSpan(
                          text: value,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static int _monthsBetween(DateTime a, DateTime b) =>
      (b.year - a.year) * 12 + b.month - a.month;

  /// 1, 2, 2.5 or 5 times a power of ten, at least [raw].
  static double _niceStep(double raw) {
    if (raw <= 0) return 1;
    final p = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    return [1, 2, 2.5, 5, 10].map((m) => m * p).firstWhere((s) => s >= raw);
  }
}
