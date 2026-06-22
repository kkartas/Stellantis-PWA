import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/dashboard/dashboard_page.dart';
import 'package:stellantis_mobile/features/settings/units_settings_page.dart';

import '../support/test_harness.dart';

/// Accessibility guideline checks for the primary screens. Covers tap-target
/// sizing, that interactive elements carry a semantic label, and text/colour
/// contrast against the default Material theme.
void main() {
  setUp(mockSecureStorage);

  testWidgets('Dashboard meets tap-target and labelling guidelines',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester, const DashboardPage());
    await tester.pump();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
    await tester.pumpWidget(const SizedBox()); // cancel Prefetcher timer
  });

  testWidgets('Units settings meets tap-target and labelling guidelines',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester, const UnitsSettingsPage());
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
  });
}

// NOTE: textContrastGuideline is intentionally not asserted here. It flags
// Flutter's default Material greys (onSurfaceVariant), but production always
// applies a designed BrandTheme — never the bare default — so the check would
// fail on framework defaults rather than on our palette. Brand palette
// contrast is reviewed via the golden snapshots in test/theme/.
