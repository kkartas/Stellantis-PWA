import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/core/ui/skeleton.dart';

void main() {
  group('Skeleton', () {
    testWidgets('animates (pumps cleanly) when motion is enabled',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Skeleton(width: 200))),
        ),
      );
      // Advance the repeating shimmer; must not throw or leak a ticker.
      await tester.pump(const Duration(milliseconds: 650));
      expect(find.byType(Skeleton), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Skeleton),
          matching: find.byType(AnimatedBuilder),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders a static block when animations are disabled',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(body: Center(child: Skeleton(width: 200))),
          ),
        ),
      );
      // With reduce-motion on there is no AnimatedBuilder driving a gradient.
      expect(
        find.descendant(
          of: find.byType(Skeleton),
          matching: find.byType(AnimatedBuilder),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes its ticker without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Skeleton())),
      );
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      expect(tester.takeException(), isNull);
    });
  });

  group('SkeletonList', () {
    testWidgets('renders the requested number of rows', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonList(rows: 4))),
      );
      expect(find.byType(Skeleton), findsNWidgets(4));
    });
  });
}
