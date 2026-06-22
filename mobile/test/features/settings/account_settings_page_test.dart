import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/settings/account_settings_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  testWidgets('renders the account screen with no session', (tester) async {
    await pumpScreen(
      tester,
      const AccountSettingsPage(),
      overrides: [isarUnavailable()],
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Not signed in'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
