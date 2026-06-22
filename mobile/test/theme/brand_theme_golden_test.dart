import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:stellantis_mobile/features/dashboard/widgets/battery_ring.dart';
import 'package:stellantis_mobile/theme/brand_theme.dart';

/// A compact sample that exercises the brand [ThemeData]: an app bar, a
/// battery ring (primary/tertiary), and a filled button. Rendering these per
/// brand catches palette regressions visually. Laid out with a fixed size and
/// `mainAxisSize.min` so it never overflows regardless of grid sizing.
Widget _sample(ThemeData theme, String label) {
  return Theme(
    data: theme,
    child: Material(
      color: theme.scaffoldBackgroundColor,
      child: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 48,
              color: theme.appBarTheme.backgroundColor,
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: theme.appBarTheme.foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: BatteryRing(
                percentage: 72,
                size: 110,
                subtitle: '210 km',
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                onPressed: () {},
                child: const Text('Lock'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _grid(bool dark) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: ColoredBox(
      color: dark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
      child: Wrap(
        children: [
          for (final entry in BrandTheme.perBrand.entries)
            _sample(
              dark ? entry.value.darkTheme : entry.value.lightTheme,
              entry.key.name,
            ),
        ],
      ),
    ),
  );
}

void main() {
  testGoldens('every brand theme — light', (tester) async {
    await tester.pumpWidgetBuilder(
      _grid(false),
      surfaceSize: const Size(900, 1500),
    );
    await screenMatchesGolden(tester, 'brand_themes_light');
  });

  testGoldens('every brand theme — dark', (tester) async {
    await tester.pumpWidgetBuilder(
      _grid(true),
      surfaceSize: const Size(900, 1500),
    );
    await screenMatchesGolden(tester, 'brand_themes_dark');
  });
}
