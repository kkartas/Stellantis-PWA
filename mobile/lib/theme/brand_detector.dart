import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';
import 'package:stellantis_mobile/stellantis/storage/repositories.dart';
import 'package:stellantis_mobile/theme/brand_theme.dart';

/// Maps a free-form brand string (API realm, customer-ID prefix, or
/// human-readable name) to a [Brand] enum value. Returns null if no
/// known brand matches.
class BrandDetector {
  const BrandDetector._();

  static Brand? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    final lower = value.toLowerCase();
    if (lower.contains('peugeot') || lower == 'ap') return Brand.peugeot;
    if (lower.contains('citro')) return Brand.citroen;
    if (lower == 'ac') return Brand.citroen;
    if (lower.contains('vauxhall') || lower == 'vx') return Brand.vauxhall;
    if (lower.contains('opel') || lower == 'op') return Brand.opel;
    if (lower.contains('ds')) return Brand.ds;
    if (lower.contains('alfa') || lower.contains('romeo')) {
      return Brand.alfaRomeo;
    }
    if (lower.contains('lancia')) return Brand.lancia;
    if (lower.contains('maserati')) return Brand.maserati;
    if (lower.contains('chrysler')) return Brand.chrysler;
    if (lower.contains('dodge')) return Brand.dodge;
    if (lower.contains('jeep')) return Brand.jeep;
    if (lower.contains('fiat')) return Brand.fiat;
    if (lower == 'ram' || lower.contains('ram ')) return Brand.ram;
    return null;
  }
}

/// User-supplied brand override. When non-null, [activeBrandThemeProvider]
/// uses this regardless of what the API reports.
final brandOverrideProvider = StateProvider<Brand?>((_) => null);

/// Resolves the active [BrandTheme] from (1) explicit user override, or
/// (2) the brand string on the most recently seen VehicleRecord, falling
/// back to [BrandTheme.neutral] if neither yields a known brand.
final activeBrandThemeProvider = FutureProvider<BrandTheme>((ref) async {
  final override = ref.watch(brandOverrideProvider);
  if (override != null) {
    return BrandTheme.perBrand[override] ?? BrandTheme.neutral;
  }
  final repo = await ref.watch(vehicleRepoProvider.future);
  final vehicles = await repo.watchAll().first;
  if (vehicles.isEmpty) return BrandTheme.neutral;
  final detected = BrandDetector.fromString(vehicles.first.brand);
  if (detected == null) return BrandTheme.neutral;
  return BrandTheme.perBrand[detected] ?? BrandTheme.neutral;
});
