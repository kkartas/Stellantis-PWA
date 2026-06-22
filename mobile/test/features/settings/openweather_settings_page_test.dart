import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/settings/openweather_settings_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  testWidgets('renders the api key field and save button', (tester) async {
    await pumpScreen(tester, const OpenWeatherSettingsPage());
    await tester.pumpAndSettle();

    expect(find.text('OpenWeather'), findsOneWidget);
    expect(find.text('API key'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('entering a key and saving confirms via snackbar',
      (tester) async {
    await pumpScreen(tester, const OpenWeatherSettingsPage());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'abc123');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    await tester.pump();

    expect(find.text('OpenWeather key saved'), findsOneWidget);
  });
}
