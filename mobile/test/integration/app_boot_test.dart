import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/app/app.dart';

import '../support/test_harness.dart';

/// Headless counterpart to `integration_test/app_boot_test.dart`. Drives the
/// real [StellantisApp] (router + theme + localization) through the first-run
/// boot flow so it can be verified under `flutter test` without a device.
///
/// With an empty secure store there is no saved session, so the splash
/// bootstrap routes to the brand picker — the genuine first-launch happy path.
void main() {
  setUp(mockSecureStorage);

  testWidgets('first launch boots through splash to the brand picker',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: StellantisApp()));

    // Splash holds for a minimum dwell, then the bootstrap decides the route.
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Choose your brand'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
