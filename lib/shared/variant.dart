// The switch for comparing layout variants at build time.

/// Layout variant for design reviews, set at build time:
/// `tool/variants.sh` passes `--dart-define=VARIANT=<name>` to the screenshot
/// test (also works with `flutter run`). Empty in normal builds, so the app
/// always shows the default. Compare variants in the one widget under review
/// (`if (designVariant == 'b') …`) and delete the switch once one is picked.
const designVariant = String.fromEnvironment('VARIANT');
