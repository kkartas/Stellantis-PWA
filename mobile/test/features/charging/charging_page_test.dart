import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/charging/charging_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  // No VIN → the charges stream yields an empty list without opening Isar.
  testWidgets('renders the charging screen with an empty list',
      (tester) async {
    await pumpScreen(tester, const ChargingPage());
    await tester.pump();

    expect(find.text('Charging'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
