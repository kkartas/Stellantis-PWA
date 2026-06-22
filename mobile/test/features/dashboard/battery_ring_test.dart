import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/dashboard/widgets/battery_ring.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: child))),
  );
}

void main() {
  group('BatteryRing', () {
    testWidgets('renders the rounded percentage', (tester) async {
      await _pump(tester, const BatteryRing(percentage: 73.6));
      expect(find.text('74'), findsOneWidget);
    });

    testWidgets('shows an em-dash when percentage is null', (tester) async {
      await _pump(tester, const BatteryRing(percentage: null));
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('clamps values above 100 without throwing', (tester) async {
      await _pump(tester, const BatteryRing(percentage: 140));
      expect(tester.takeException(), isNull);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('clamps negative values to zero', (tester) async {
      await _pump(tester, const BatteryRing(percentage: -10));
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('shows the bolt icon only while charging', (tester) async {
      await _pump(tester, const BatteryRing(percentage: 50));
      expect(find.byIcon(Icons.bolt), findsNothing);

      await _pump(tester, const BatteryRing(percentage: 50, isCharging: true));
      expect(find.byIcon(Icons.bolt), findsOneWidget);
    });

    testWidgets('renders the subtitle when provided', (tester) async {
      await _pump(
        tester,
        const BatteryRing(percentage: 50, subtitle: '210 km'),
      );
      expect(find.text('210 km'), findsOneWidget);
    });

    testWidgets('honours the label override', (tester) async {
      await _pump(tester, const BatteryRing(percentage: 50, label: 'SOC'));
      expect(find.text('SOC'), findsOneWidget);
    });
  });
}
