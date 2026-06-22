import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/vehicles/vehicle_picker_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  testWidgets('renders the vehicle picker chrome', (tester) async {
    await pumpScreen(
      tester,
      const VehiclePickerPage(),
      overrides: [isarUnavailable()],
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Choose your vehicle'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
