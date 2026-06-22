import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/maintenance/maintenance_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  // No VIN → the maintenance stream yields an empty list without opening Isar.
  testWidgets('renders the maintenance screen with no vehicle selected',
      (tester) async {
    await pumpScreen(tester, const MaintenancePage());
    await tester.pump();

    expect(find.text('Maintenance'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
