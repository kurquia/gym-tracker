// The dialog for choosing a rest length.

import 'package:flutter/material.dart';

import '../../shared/format.dart';

/// Rest-length dialog: ±15 s steps and common lengths. Returns null on
/// Cancel, `(rest: null)` for "Default" (follow warm-up / working default).
Future<({Duration? rest})?> showRestPicker(
  BuildContext context,
  Duration initial,
) {
  const step = Duration(seconds: 15);
  const max = Duration(minutes: 10);
  const presets = [30, 60, 90, 120, 150, 180, 240, 300];
  var rest = initial;

  return showDialog<({Duration? rest})>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Rest after this set'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.outlined(
                  tooltip: 'Minus 15 seconds',
                  onPressed: rest <= Duration.zero
                      ? null
                      : () => setState(() => rest -= step),
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    formatClock(rest),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                IconButton.outlined(
                  tooltip: 'Plus 15 seconds',
                  onPressed: rest >= max
                      ? null
                      : () => setState(() => rest += step),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final s in presets)
                  ChoiceChip(
                    label: Text(formatClock(Duration(seconds: s))),
                    selected: rest.inSeconds == s,
                    onSelected: (_) =>
                        setState(() => rest = Duration(seconds: s)),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, (rest: null)),
            child: const Text('Default'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, (rest: rest)),
            child: const Text('OK'),
          ),
        ],
      ),
    ),
  );
}
