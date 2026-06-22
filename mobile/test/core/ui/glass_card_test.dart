import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/core/ui/glass_card.dart';

void main() {
  group('GlassCard', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassCard(child: Text('42%')),
            ),
          ),
        ),
      );
      expect(find.text('42%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('applies the requested padding', (tester) async {
      const padding = EdgeInsets.all(24);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              padding: padding,
              child: SizedBox(width: 10, height: 10),
            ),
          ),
        ),
      );
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GlassCard),
          matching: find.byType(Container),
        ),
      );
      expect(container.padding, padding);
    });
  });
}
