import 'package:flutter/material.dart';

import '../theme.dart';

/// A centred grey message: what a screen shows when it is empty or failed
/// to load.
class PlaceholderBody extends StatelessWidget {
  const PlaceholderBody({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge.muted,
        ),
      ),
    );
  }
}
