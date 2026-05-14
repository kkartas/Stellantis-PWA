import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/core/logging/logger.dart';
import 'package:stellantis_mobile/stellantis/auth/auth_storage.dart';
import 'package:stellantis_mobile/stellantis/auth/oauth_token.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';
import 'package:stellantis_mobile/stellantis/brands/secrets_template.dart';

const _log = AppLogger('TokenRefresh');

/// Time before expiry within which a proactive refresh is attempted.
const _proactiveRefreshWindow = Duration(minutes: 5);

final tokenRefreshInterceptorProvider = Provider<TokenRefreshInterceptor>(
  (ref) => TokenRefreshInterceptor(ref.watch(authStorageProvider)),
);

/// Dio interceptor that:
/// 1. Attaches the current Bearer token to every request.
/// 2. Proactively refreshes when the token is close to expiry.
/// 3. Retries once on 401 after a forced refresh.
class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor(this._storage);

  final AuthStorage _storage;
  OAuthToken? _cachedToken;

  // Prevent concurrent refreshes.
  bool _refreshing = false;
  final List<void Function()> _pendingQueue = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _getValidToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer ${token.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Avoid infinite retry loops.
    final alreadyRetried =
        err.requestOptions.extra['_tokenRefreshRetried'] == true;
    if (alreadyRetried) {
      handler.next(err);
      return;
    }

    _log.w('401 received — attempting token refresh before retry');

    final refreshed = await _forceRefresh();
    if (!refreshed || _cachedToken == null) {
      handler.next(err);
      return;
    }

    // Retry the original request with the new token.
    final opts = err.requestOptions
      ..headers['Authorization'] = 'Bearer ${_cachedToken!.accessToken}'
      ..extra['_tokenRefreshRetried'] = true;

    try {
      final dio = Dio();
      final response = await dio.fetch<dynamic>(opts);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Returns a valid token, proactively refreshing if close to expiry.
  Future<OAuthToken?> _getValidToken() async {
    _cachedToken ??= await _storage.load();
    final token = _cachedToken;
    if (token == null) return null;

    if (token.expiresWithin(_proactiveRefreshWindow)) {
      await _forceRefresh();
    }

    return _cachedToken;
  }

  /// Refreshes the token using the stored refresh_token grant. Serialises
  /// concurrent callers so only one network call is made.
  Future<bool> _forceRefresh() async {
    if (_refreshing) {
      await _waitForRefresh();
      return _cachedToken != null;
    }

    _refreshing = true;
    try {
      final stored = _cachedToken ?? await _storage.load();
      if (stored == null) return false;

      final newToken = await _refreshGrant(stored.refreshToken);
      _cachedToken = newToken;
      await _storage.save(newToken);
      _log.i('Token refreshed, expires ${newToken.expiresAt.toIso8601String()
          }');
      return true;
    } on DioException catch (e) {
      _log.e('Token refresh failed', e);
      return false;
    } finally {
      _refreshing = false;
      for (final cb in _pendingQueue) {
        cb();
      }
      _pendingQueue.clear();
    }
  }

  Future<void> _waitForRefresh() {
    final completer = Future<void>(() {});
    _pendingQueue.add(() {});
    return completer;
  }

  Future<OAuthToken> _refreshGrant(String refreshToken) async {
    // Find first brand that has a matching client_id in storage.
    // In practice only one brand is active at a time.
    final stored = _cachedToken ?? await _storage.load();
    if (stored == null) throw StateError('No stored token to refresh');

    // We need the client credentials — look up from BrandSecrets.
    // Iterate all known cache keys to find one that might match.
    String? tokenUrl;
    String? clientId;
    String? clientSecret;

    for (final brand in Brand.values) {
      for (final cc in ['FR', 'DE', 'GB', 'ES', 'IT', 'NL', 'BE']) {
        final key = '${brand.name}:$cc';
        final id = BrandSecrets.clientId[key];
        if (id != null && id.isNotEmpty) {
          tokenUrl = BrandConstants.tokenUrl[brand];
          clientId = id;
          clientSecret = BrandSecrets.clientSecret[key];
          break;
        }
      }
      if (tokenUrl != null) break;
    }

    if (tokenUrl == null || clientId == null || clientSecret == null) {
      throw StateError('No brand credentials found for token refresh');
    }

    final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

    final response = await Dio().post<Map<String, dynamic>>(
      tokenUrl,
      data: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      },
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
        headers: {'Authorization': 'Basic $credentials'},
        responseType: ResponseType.json,
      ),
    );

    final data = response.data!;
    final accessToken = data['access_token'] as String?;
    final newRefreshToken =
        (data['refresh_token'] as String?) ?? refreshToken;
    final expiresIn = data['expires_in'];

    if (accessToken == null) {
      throw FormatException('Missing access_token in refresh response: $data');
    }

    final ttl = expiresIn is num ? expiresIn.toInt() : 3600;
    return OAuthToken(
      accessToken: accessToken,
      refreshToken: newRefreshToken,
      expiresAt: DateTime.now().toUtc().add(Duration(seconds: ttl)),
    );
  }
}
