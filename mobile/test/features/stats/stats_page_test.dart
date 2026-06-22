import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/stats/stats_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  // No VIN → the SOH/trip/charge stat streams all yield empty without Isar.
  testWidgets('renders the stats hub with no vehicle selected',
      (tester) async {
    await pumpScreen(tester, const StatsPage());
    await tester.pump();

    expect(find.text('Stats'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
