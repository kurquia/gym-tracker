// Choosing how many working sets a routine gives an exercise, and its warm-ups.

import 'package:flutter/material.dart';

/// What a routine says about one exercise's sets: how many working sets
/// (null = as last time) and whether to start with warm-ups.
typedef SetsChoice = ({int? sets, bool warmup});

/// Number-of-sets picker for a routine: one tap on a number in a bottom
/// sheet; W (warm-up) toggles without closing. Applies to each exercise of a
/// superset. Returns null when nothing changed.
Future<SetsChoice?> showSetsPicker(
  BuildContext context, {
  required SetsChoice initial,
}) async {
  var warmup = initial.warmup;
  final picked = await showModalBottomSheet<SetsChoice>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sets', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Each exercise in the superset',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              SetsSelector(
                value: (sets: initial.sets, warmup: warmup),
                onWarmup: (w) => setState(() => warmup = w),
                onSets: (n) => Navigator.pop(context, (
                  sets: n,
                  warmup: n != null && warmup,
                )),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  // Closed after only toggling W: keep the number, save the W.
  if (picked == null && initial.sets != null && warmup != initial.warmup) {
    return (sets: initial.sets, warmup: warmup);
  }
  return picked;
}

/// W, 1 … 6 and As last time. [onWarmup] gets W's new state, [onSets] the
/// tapped number (null = As last time, which goes without a W).
class SetsSelector extends StatelessWidget {
  const SetsSelector({
    super.key,
    required this.value,
    required this.onWarmup,
    required this.onSets,
  });

  final SetsChoice value;
  final ValueChanged<bool> onWarmup;
  final ValueChanged<int?> onSets;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Select the number of sets. Press W to start with a warm-up set.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Square(
            label: 'W',
            tooltip: 'Start with a warm-up',
            selected: value.warmup,
            onTap: () => onWarmup(!value.warmup),
          ),
          for (var n = 1; n <= 6; n++)
            _Square(
              label: '$n',
              selected: value.sets == n,
              onTap: () => onSets(n),
            ),
        ],
      ),
      const SizedBox(height: 8),
      _Square(
        label: 'As last time',
        wide: true,
        selected: value.sets == null,
        onTap: () => onSets(null),
      ),
    ],
  );
}

/// W, 1 … 6 or [wide] "As last time": outlined, filled when selected.
class _Square extends StatelessWidget {
  const _Square({
    required this.label,
    required this.selected,
    required this.onTap,
    this.tooltip,
    this.wide = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final size = wide ? const Size(0, 44) : const Size.square(44);
    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(size),
      maximumSize: wide ? null : WidgetStatePropertyAll(size),
      padding: WidgetStatePropertyAll(
        wide ? const EdgeInsets.symmetric(horizontal: 16) : EdgeInsets.zero,
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    final button = selected
        ? FilledButton(onPressed: onTap, style: style, child: Text(label))
        : OutlinedButton(onPressed: onTap, style: style, child: Text(label));
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
