import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/trips/trips_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  // No VIN → the trips stream yields an empty list without opening Isar.
  testWidgets('renders the trips screen with an empty list', (tester) async {
    await pumpScreen(tester, const TripsPage());
    await tester.pump();

    expect(find.text('Trips'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
