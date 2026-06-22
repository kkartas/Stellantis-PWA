import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/vehicle_detail/location_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  // With no position the page shows the empty state rather than the map, so
  // no OSM tiles are requested during the test.
  testWidgets('renders the no-location empty state', (tester) async {
    await pumpScreen(tester, const VehicleLocationPage());
    await tester.pump();

    expect(find.text('Location'), findsOneWidget);
    expect(find.textContaining('No location reported yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
