import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/dashboard/dashboard_page.dart';
import 'package:stellantis_mobile/features/dashboard/widgets/battery_ring.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  // With no VIN selected the status/vehicle streams short-circuit to null,
  // so the dashboard renders its empty state without touching Isar.
  testWidgets('renders the empty/no-data dashboard state', (tester) async {
    await pumpScreen(tester, const DashboardPage());
    await tester.pump();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('No data yet'), findsOneWidget);
    expect(find.byType(BatteryRing), findsOneWidget);
    // Quick actions row is present with its first action visible.
    expect(find.text('Lock'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Dispose to cancel the Prefetcher's warm-up timer before teardown.
    await tester.pumpWidget(const SizedBox());
  });
}
