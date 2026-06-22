import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/auth/brand_picker_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  testWidgets('lists the authenticatable brands and a country selector',
      (tester) async {
    await pumpScreen(tester, const BrandPickerPage());
    await tester.pumpAndSettle();

    expect(find.text('Choose your brand'), findsOneWidget);
    // Top-row brands are laid out; later tiles are lazily built off-screen.
    expect(find.text('Peugeot'), findsOneWidget);
    expect(find.text('Citroën'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Continue is disabled until a brand is picked', (tester) async {
    await pumpScreen(tester, const BrandPickerPage());
    await tester.pumpAndSettle();

    FilledButton continueButton() => tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Continue'),
        );
    expect(continueButton().onPressed, isNull);

    await tester.tap(find.text('Peugeot'));
    await tester.pumpAndSettle();

    expect(continueButton().onPressed, isNotNull);
  });
}
