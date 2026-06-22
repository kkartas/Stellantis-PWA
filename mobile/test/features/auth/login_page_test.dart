import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/auth/data/brand_session.dart';
import 'package:stellantis_mobile/features/auth/login_page.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  testWidgets('renders the sign-in prompt for the selected brand',
      (tester) async {
    await pumpScreen(
      tester,
      const LoginPage(),
      overrides: [
        selectedBrandSessionProvider.overrideWith(
          (ref) => const BrandSession(brand: Brand.peugeot, countryCode: 'FR'),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Sign in to your Peugeot account'),
        findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Use a different brand'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
