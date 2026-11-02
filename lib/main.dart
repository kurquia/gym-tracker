// Where the app starts: registers the licenses of the bundled assets and runs
// the app under Riverpod.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  _registerLicenses();
  runApp(const ProviderScope(child: GymTrackerApp()));
}

/// Adds our bundled assets' licenses to the licenses page in Settings → About.
void _registerLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      ['Atlas icon (game-icons.net)'],
      '"Atlas" by Delapouite, https://game-icons.net/1x1/delapouite/atlas.html\n\n'
      'Licensed under CC BY 3.0: https://creativecommons.org/licenses/by/3.0/\n'
      'Used as the app icon and splash image; rescaled and recolored.',
    );
    yield LicenseEntryWithLineBreaks([
      'TeX Gyre Schola',
    ], await rootBundle.loadString('assets/fonts/GUST-FONT-LICENSE.txt'));
    yield LicenseEntryWithLineBreaks([
      'Z-Anatomy and BodyParts3D (3D body model)',
    ], await rootBundle.loadString('assets/models/BODY-MODEL-LICENSE.txt'));
  });
}
