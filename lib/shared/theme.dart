// The app's look: the soft dark palette, the Record colours, the Material 3
// theme and the muted text styles.

import 'package:flutter/material.dart';

import '../data/tables.dart' show SetKind;

/// Softer on the eyes (Material's dark-theme advice): dark grey, slightly
/// lighter cards and bars, off-white text. The app's look since 2026-10-20.
const softPalette = (
  background: Color(0xFF121212),
  surface: Color(0xFF1E1E1E),
  text: Color(0xFFE3E3E3),
  outline: Colors.white12,
);

/// Last time in Record: the date by each exercise, the Previous column.
/// Material Amber 500.
const previousColour = Color(0xFFFFC107);

/// Done in Record: the column header and the ticked boxes. Apple's
/// systemGreen in dark mode, the user's pick 2026-10-25.
const doneColour = Color(0xFF30D158);

/// The lamp on the Record tab while a workout is open, like a camera's REC
/// light: the one red that isn't a destructive action or an error. Apple's
/// systemRed.
const recordingColour = Color(0xFFFF3B30);

/// Set labels in Record (and the set-type menu), the user's pick 2026-10-25:
/// normal Material Blue 300, D (drop) Material Purple A200 (magenta), F
/// (failure) Apple systemOrange in dark mode. W stays dimmed text.
const normalSetColour = Color(0xFF64B5F6);
const dropSetColour = Color(0xFFE040FB);
const failureSetColour = Color(0xFFFF9F0A);

/// A set label's colour by type, in Record and the workout log.
Color setKindColour(SetKind kind, Color onSurface) => switch (kind) {
  SetKind.warmup => onSurface.withValues(alpha: 0.54),
  SetKind.drop => dropSetColour,
  SetKind.failure => failureSetColour,
  SetKind.normal => normalSetColour,
};

/// Secondary text, in two strengths.
extension MutedText on TextStyle? {
  TextStyle? get muted => this?.copyWith(color: Colors.white70);
  TextStyle? get faint => this?.copyWith(color: Colors.white54);
}

/// Grey text in the theme's outline colour.
extension GreyText on BuildContext {
  TextStyle get greyText =>
      TextStyle(color: Theme.of(this).colorScheme.outline);
}

/// Monochrome dark theme: dark background, light text, greys for structure.
ThemeData buildTheme() {
  const p = softPalette;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: Colors.white,
        brightness: Brightness.dark,
        dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
      ).copyWith(
        primary: p.text,
        onPrimary: p.background,
        surface: p.background,
        onSurface: p.text,
        // Destructive actions (delete) and errors.
        error: Colors.redAccent,
        onError: Colors.black,
      );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: p.background,
    fontFamily: 'TeXGyreSchola',
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.text,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      indicatorColor: p.text,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? p.background
              : Colors.white70,
        ),
      ),
    ),
    dividerTheme: DividerThemeData(color: p.outline),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.text,
      foregroundColor: p.background,
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: p.outline),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}
