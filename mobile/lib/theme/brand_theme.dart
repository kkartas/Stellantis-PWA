import 'package:flutter/material.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';

/// Immutable set of design tokens for one Stellantis brand.
/// Populated per-brand in Phase 4. Until then, every brand
/// returns a neutral light-grey placeholder palette.
@immutable
class BrandTheme {
  const BrandTheme({
    required this.brand,
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.onSurface,
    required this.background,
    required this.logoAsset,
    required this.displayFont,
  });

  final Brand brand;
  final Color primary;
  final Color onPrimary;
  final Color surface;
  final Color onSurface;
  final Color background;

  /// Path inside assets/brands/.
  final String logoAsset;

  /// Google Fonts family name.
  final String displayFont;

  ThemeData toMaterialTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        secondary: primary,
        onSecondary: onPrimary,
        error: const Color(0xFFB00020),
        onError: const Color(0xFFFFFFFF),
        surface: surface,
        onSurface: onSurface,
      ),
      scaffoldBackgroundColor: background,
    );
  }

  static const BrandTheme neutral = BrandTheme(
    brand: Brand.peugeot,
    primary: Color(0xFF1A1A2E),
    onPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1A2E),
    background: Color(0xFFF5F5F5),
    logoAsset: 'assets/brands/stellantis.svg',
    displayFont: 'Inter',
  );
}
