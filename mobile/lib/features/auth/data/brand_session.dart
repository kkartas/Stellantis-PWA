import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';

const _kBrandKey = 'session_brand';
const _kCountryKey = 'session_country';

/// Identifies the brand + country a user has chosen for their PSA account.
/// Persists across launches so the splash can skip the brand picker once set.
class BrandSession {
  const BrandSession({required this.brand, required this.countryCode});

  final Brand brand;
  final String countryCode;

  String get cacheKey => '${brand.name}:${countryCode.toUpperCase()}';
}

final brandSessionStoreProvider = Provider<BrandSessionStore>(
  (_) => const BrandSessionStore(),
);

class BrandSessionStore {
  const BrandSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<BrandSession?> load() async {
    final brandName = await _storage.read(key: _kBrandKey);
    final country = await _storage.read(key: _kCountryKey);
    if (brandName == null || country == null) return null;
    final brand = Brand.values.firstWhere(
      (b) => b.name == brandName,
      orElse: () => Brand.peugeot,
    );
    return BrandSession(brand: brand, countryCode: country);
  }

  Future<void> save(BrandSession session) async {
    await _storage.write(key: _kBrandKey, value: session.brand.name);
    await _storage.write(
      key: _kCountryKey,
      value: session.countryCode.toUpperCase(),
    );
  }

  Future<void> clear() async {
    await _storage.delete(key: _kBrandKey);
    await _storage.delete(key: _kCountryKey);
  }
}

/// In-memory selection during the brand-picker flow.
final selectedBrandSessionProvider = StateProvider<BrandSession?>((_) => null);
