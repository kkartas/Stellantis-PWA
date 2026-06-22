import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/settings/about_settings_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  testWidgets('renders the about and diagnostics screen', (tester) async {
    await pumpScreen(
      tester,
      const AboutSettingsPage(),
      overrides: [isarUnavailable()],
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('About & diagnostics'), findsOneWidget);
    expect(find.text('Stellantis Mobile'), findsOneWidget);
    expect(find.textContaining('Version'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
