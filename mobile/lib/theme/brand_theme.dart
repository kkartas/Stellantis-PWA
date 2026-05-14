import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';

/// Provides the active [BrandTheme]. Callers can override to force a brand.
final brandThemeProvider = StateProvider<BrandTheme>(
  (_) => BrandTheme.neutral,
);

/// Immutable set of design tokens for one Stellantis brand.
///
/// Pass to toMaterialTheme or toCupertinoThemeData
/// to obtain a platform-ready theme object.
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
    // Accent palette (optional — falls back to primary if omitted)
    this.secondary,
    this.onSecondary,
    this.tertiary,
    this.onTertiary,
    // Dark-mode overrides (null = derive from light values)
    this.darkPrimary,
    this.darkOnPrimary,
    this.darkSurface,
    this.darkOnSurface,
    this.darkBackground,
    // Asset paths
    this.heroAsset,
    // Typography
    this.bodyFont,
    // Motion
    this.fastCurve = Curves.easeOut,
    this.slowCurve = Curves.easeInOut,
    this.fastDuration = const Duration(milliseconds: 200),
    this.slowDuration = const Duration(milliseconds: 350),
  });

  final Brand brand;

  // --- Light palette ---
  final Color primary;
  final Color onPrimary;
  final Color surface;
  final Color onSurface;
  final Color background;
  final Color? secondary;
  final Color? onSecondary;
  final Color? tertiary;
  final Color? onTertiary;

  // --- Dark-mode palette ---
  final Color? darkPrimary;
  final Color? darkOnPrimary;
  final Color? darkSurface;
  final Color? darkOnSurface;
  final Color? darkBackground;

  // --- Assets ---
  final String logoAsset;
  final String? heroAsset;

  // --- Typography ---
  final String displayFont;
  final String? bodyFont;

  // --- Motion ---
  final Curve fastCurve;
  final Curve slowCurve;
  final Duration fastDuration;
  final Duration slowDuration;

  // Derived fallbacks
  Color get _secondary => secondary ?? primary;
  Color get _onSecondary => onSecondary ?? onPrimary;
  Color get _tertiary => tertiary ?? _secondary;
  Color get _onTertiary => onTertiary ?? _onSecondary;

  /// Light Material 3 ThemeData.
  ThemeData get lightTheme => toMaterialTheme();

  /// Dark Material 3 ThemeData.
  ThemeData get darkTheme =>
      toMaterialTheme(brightness: Brightness.dark);

  ThemeData toMaterialTheme({
    Brightness brightness = Brightness.light,
  }) {
    final isDark = brightness == Brightness.dark;
    final p = isDark ? (darkPrimary ?? primary) : primary;
    final op = isDark ? (darkOnPrimary ?? onPrimary) : onPrimary;
    final sf = isDark
        ? (darkSurface ?? const Color(0xFF1E1E1E))
        : surface;
    final osf = isDark
        ? (darkOnSurface ?? const Color(0xFFE8E8E8))
        : onSurface;
    final bg = isDark
        ? (darkBackground ?? const Color(0xFF121218))
        : background;

    final scheme = ColorScheme.fromSeed(
      seedColor: p,
      brightness: brightness,
    ).copyWith(
      primary: p,
      onPrimary: op,
      secondary: _secondary,
      onSecondary: _onSecondary,
      tertiary: _tertiary,
      onTertiary: _onTertiary,
      surface: sf,
      onSurface: osf,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: displayFont),
        displayMedium: TextStyle(fontFamily: displayFont),
        displaySmall: TextStyle(fontFamily: displayFont),
        headlineLarge: TextStyle(fontFamily: displayFont),
        headlineMedium: TextStyle(fontFamily: displayFont),
        headlineSmall: TextStyle(fontFamily: displayFont),
        bodyLarge: TextStyle(fontFamily: bodyFont ?? displayFont),
        bodyMedium: TextStyle(fontFamily: bodyFont ?? displayFont),
        bodySmall: TextStyle(fontFamily: bodyFont ?? displayFont),
        labelLarge: TextStyle(fontFamily: bodyFont ?? displayFont),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p,
        foregroundColor: op,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: sf,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p,
          foregroundColor: op,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Brand palette registry — one entry per brand.
  // Updated per-brand in steps 4.3-4.15.
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
