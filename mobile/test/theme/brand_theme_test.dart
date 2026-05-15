import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';
import 'package:stellantis_mobile/theme/brand_theme.dart';

Future<void> _pumpWithTheme(WidgetTester tester, ThemeData theme) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Stellantis')),
            body: const Center(
              child: Card(
                child: SizedBox(
                  width: 240,
                  height: 120,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Sample'),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

void main() {
  group('BrandTheme registry', () {
    test('all 13 Stellantis brands are registered in perBrand', () {
      expect(BrandTheme.perBrand, hasLength(Brand.values.length));
      for (final brand in Brand.values) {
        expect(
          BrandTheme.perBrand[brand],
          isNotNull,
          reason: 'Missing BrandTheme entry for $brand',
        );
      }
    });

    test('every brand has a non-empty logo asset path', () {
      for (final theme in BrandTheme.perBrand.values) {
        expect(theme.logoAsset, startsWith('assets/brands/'));
        expect(theme.logoAsset, endsWith('.svg'));
      }
    });
  });

  group('BrandTheme.lightTheme — every brand', () {
    for (final entry in BrandTheme.perBrand.entries) {
      final brandName = entry.key.name;
      final theme = entry.value;

      testWidgets('$brandName renders without errors (light)', (tester) async {
        await _pumpWithTheme(tester, theme.lightTheme);
        expect(tester.takeException(), isNull);
      });

      test('$brandName ColorScheme.primary matches token', () {
        final scheme = theme.lightTheme.colorScheme;
        expect(scheme.primary, theme.primary);
        expect(scheme.onPrimary, theme.onPrimary);
      });

      test('$brandName ColorScheme.secondary matches token', () {
        final scheme = theme.lightTheme.colorScheme;
        expect(scheme.secondary, theme.secondary ?? theme.primary);
      });

      test('$brandName uses Material 3', () {
        expect(theme.lightTheme.useMaterial3, isTrue);
      });
    }
  });

  group('BrandTheme.darkTheme — every brand', () {
    for (final entry in BrandTheme.perBrand.entries) {
      final brandName = entry.key.name;
      final theme = entry.value;

      testWidgets('$brandName renders without errors (dark)', (tester) async {
        await _pumpWithTheme(tester, theme.darkTheme);
        expect(tester.takeException(), isNull);
      });

      test('$brandName dark scheme has Brightness.dark', () {
        expect(theme.darkTheme.brightness, Brightness.dark);
      });
    }
  });

  group('BrandTheme.neutral', () {
    testWidgets('renders light without errors', (tester) async {
      await _pumpWithTheme(tester, BrandTheme.neutral.lightTheme);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders dark without errors', (tester) async {
      await _pumpWithTheme(tester, BrandTheme.neutral.darkTheme);
      expect(tester.takeException(), isNull);
    });
  });

}
