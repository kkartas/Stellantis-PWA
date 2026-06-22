import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/settings/charging_settings_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  testWidgets('renders the charging configuration sections', (tester) async {
    await pumpScreen(tester, const ChargingSettingsPage());
    await tester.pumpAndSettle();

    expect(find.text('Charging'), findsOneWidget);
    expect(find.text('Target state of charge'), findsOneWidget);
    expect(find.text('Scheduled charging window'), findsOneWidget);
    expect(find.text('Price per kWh'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editing the target SoC reveals the Save action', (tester) async {
    await pumpScreen(tester, const ChargingSettingsPage());
    await tester.pumpAndSettle();

    // No draft yet → no Save button in the app bar.
    expect(find.widgetWithText(TextButton, 'Save'), findsNothing);

    await tester.drag(find.byType(Slider), const Offset(40, 0));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextButton, 'Save'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
