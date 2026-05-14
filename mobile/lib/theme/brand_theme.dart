import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';

/// Provides the active [BrandTheme]. Defaults to [BrandTheme.neutral] until
/// Phase 4 wires real per-brand themes.
final brandThemeProvider = StateProvider<BrandTheme>(
  (_) => BrandTheme.neutral,
);

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

  // ---------------------------------------------------------------------------
  // Placeholder palettes — replaced with brand-accurate tokens in Phase 4.
  // ---------------------------------------------------------------------------

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

  static const BrandTheme peugeot = BrandTheme(
    brand: Brand.peugeot,
    primary: Color(0xFF2D2D2D),
    onPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF2D2D2D),
    background: Color(0xFFF5F5F5),
    logoAsset: 'assets/brands/peugeot.svg',
    displayFont: 'Inter',
  );

  static const BrandTheme citroen = BrandTheme(
    brand: Brand.citroen,
    primary: Color(0xFF8B1A1A),
    onPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1A1A),
    background: Color(0xFFF5F5F5),
    logoAsset: 'assets/brands/citroen.svg',
    displayFont: 'Inter',
  );

  static const BrandTheme ds = BrandTheme(
    brand: Brand.ds,
    primary: Color(0xFF1A1A2E),
    onPrimary: Color(0xFFD4AF37),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1A2E),
    background: Color(0xFFF0EFE9),
    logoAsset: 'assets/brands/ds.svg',
    displayFont: 'Inter',
  );

  static const BrandTheme opel = BrandTheme(
    brand: Brand.opel,
    primary: Color(0xFFFFD700),
    onPrimary: Color(0xFF1A1A1A),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1A1A),
    background: Color(0xFFF5F5F5),
    logoAsset: 'assets/brands/opel.svg',
    displayFont: 'Inter',
  );

  static const BrandTheme vauxhall = BrandTheme(
    brand: Brand.vauxhall,
    primary: Color(0xFFC8102E),
    onPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1A1A),
    background: Color(0xFFF5F5F5),
    logoAsset: 'assets/brands/vauxhall.svg',
    displayFont: 'Inter',
  );

  static const Map<Brand, BrandTheme> perBrand = {
    Brand.citroen: citroen,
    Brand.ds: ds,
    Brand.opel: opel,
    Brand.peugeot: peugeot,
    Brand.vauxhall: vauxhall,
  };
}
