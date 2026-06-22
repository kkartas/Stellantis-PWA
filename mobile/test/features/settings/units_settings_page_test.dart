import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/settings/data/units_preferences.dart';
import 'package:stellantis_mobile/features/settings/units_settings_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  testWidgets('renders the three unit sections with defaults', (tester) async {
    await pumpScreen(tester, const UnitsSettingsPage());
    await tester.pumpAndSettle();

    expect(find.text('Units'), findsOneWidget);
    expect(find.text('DISTANCE'), findsOneWidget);
    expect(find.text('TEMPERATURE'), findsOneWidget);
    expect(find.text('CURRENCY'), findsOneWidget);
    expect(find.text('Kilometres (km)'), findsOneWidget);
    expect(find.text('Fahrenheit (°F)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selecting miles updates without error', (tester) async {
    await pumpScreen(tester, const UnitsSettingsPage());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Miles (mi)'));
    await tester.pumpAndSettle();

    final tile = tester.widget<RadioListTile<DistanceUnit>>(
      find.widgetWithText(RadioListTile<DistanceUnit>, 'Miles (mi)'),
    );
    expect(tile.value, DistanceUnit.miles);
    expect(tester.takeException(), isNull);
  });
}
