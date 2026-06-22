import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/charging/charging_detail_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  testWidgets('renders the charge detail chrome', (tester) async {
    await pumpScreen(
      tester,
      const ChargingDetailPage(chargeId: 1),
      overrides: [isarUnavailable()],
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Charge'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
