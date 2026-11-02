// The "are you sure?" dialog used across the app.

import 'package:flutter/material.dart';

/// Asks before doing something: Cancel or [action], true for [action]. A
/// [destructive] action (it deletes or replaces data) is red.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  String? message,
  required String action,
  bool destructive = false,
}) async {
  final colors = Theme.of(context).colorScheme;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                )
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(action),
        ),
      ],
    ),
  );
  return ok ?? false;
}
