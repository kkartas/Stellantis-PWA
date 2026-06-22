import 'dart:async';

import 'package:golden_toolkit/golden_toolkit.dart';

/// Applies to every test under `test/`. Loads real app fonts so golden
/// snapshots render text deterministically instead of with the boxy test
/// fallback font.
///
/// Golden PNGs are inherently host-sensitive (font hinting differs across
/// OSes). Regenerate them on the same platform CI runs goldens on
/// (`flutter test --update-goldens`) if you see sub-pixel drift.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return GoldenToolkit.runWithConfiguration(
    () async {
      await loadAppFonts();
      await testMain();
    },
    config: GoldenToolkitConfiguration(
      // Skip goldens unless explicitly requested? No — run them everywhere,
      // but keep the default device so snapshots stay reproducible.
      enableRealShadows: true,
    ),
  );
}
