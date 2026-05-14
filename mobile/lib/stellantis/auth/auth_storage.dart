import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stellantis_mobile/stellantis/auth/oauth_token.dart';

const _kAccessToken = 'psa_access_token';
const _kRefreshToken = 'psa_refresh_token';
const _kExpiresAt = 'psa_expires_at';

final authStorageProvider = Provider<AuthStorage>((_) => const AuthStorage());

class AuthStorage {
  const AuthStorage(
      {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> save(OAuthToken token) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: token.accessToken),
      _storage.write(key: _kRefreshToken, value: token.refreshToken),
      _storage.write(
        key: _kExpiresAt,
        value: token.expiresAt.toIso8601String(),
      ),
    ]);
  }

  Future<OAuthToken?> load() async {
    final values = await Future.wait([
      _storage.read(key: _kAccessToken),
      _storage.read(key: _kRefreshToken),
      _storage.read(key: _kExpiresAt),
    ]);

    final accessToken = values[0];
    final refreshToken = values[1];
    final expiresAtRaw = values[2];

    if (accessToken == null || refreshToken == null || expiresAtRaw == null) {
      return null;
    }

    final expiresAt = DateTime.tryParse(expiresAtRaw);
    if (expiresAt == null) return null;

    return OAuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
      _storage.delete(key: _kExpiresAt),
    ]);
  }
}
