import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/vehicle_detail/vehicle_detail_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  // No VIN selected → no live or cached status → empty state, no Isar.
  testWidgets('renders the empty state with no vehicle selected',
      (tester) async {
    await pumpScreen(tester, const VehicleDetailPage());
    await tester.pump();

    expect(find.text('Vehicle'), findsOneWidget);
    expect(find.textContaining('No live state yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
