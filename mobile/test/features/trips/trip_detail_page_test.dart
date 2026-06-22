import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/trips/trip_detail_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  // With Isar unavailable the trip lookup resolves to an error state; the page
  // must still render its chrome without throwing.
  testWidgets('renders the trip detail chrome', (tester) async {
    await pumpScreen(
      tester,
      const TripDetailPage(tripId: 1),
      overrides: [isarUnavailable()],
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Trip'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
