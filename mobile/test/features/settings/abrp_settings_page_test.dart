import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/settings/abrp_settings_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  testWidgets('renders the toggle and token field', (tester) async {
    await pumpScreen(tester, const AbrpSettingsPage());
    await tester.pumpAndSettle();

    expect(find.text('A Better Route Planner'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('token field is disabled until forwarding is enabled',
      (tester) async {
    await pumpScreen(tester, const AbrpSettingsPage());
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
  });

  testWidgets('saving shows a confirmation snackbar', (tester) async {
    await pumpScreen(tester, const AbrpSettingsPage());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    await tester.pump();

    expect(find.text('ABRP settings saved'), findsOneWidget);
  });
}
