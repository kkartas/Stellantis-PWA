import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/settings/theme_settings_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  testWidgets('renders appearance modes and the auto-brand option',
      (tester) async {
    await pumpScreen(tester, const ThemeSettingsPage());
    await tester.pumpAndSettle();

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Match system'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Auto (match vehicle brand)'), findsOneWidget);
    // Per-brand rows live further down the scrollable list; assert one is
    // reachable by scrolling to it.
    await tester.scrollUntilVisible(find.text('Peugeot'), 200);
    expect(find.text('Peugeot'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a theme mode does not throw', (tester) async {
    await pumpScreen(tester, const ThemeSettingsPage());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
