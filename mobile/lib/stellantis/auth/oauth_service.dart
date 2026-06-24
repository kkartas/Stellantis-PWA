import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:stellantis_mobile/stellantis/auth/auth_storage.dart';
import 'package:stellantis_mobile/stellantis/auth/oauth_token.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_credentials.dart';

/// Scopes requested at authorization time.
///
/// The data scopes (`data:vehicle:devices:pnc`, `data:trip`, `data:position`)
/// are "out of 1st release scope" on the Stellantis IDP and are rejected with
/// `invalid_scope` for current B2C clients. We request only the scopes the
/// provider actually grants — matching the legacy desktop handler's fallback
/// (tools/windows_mymap_handler.py) and docs/STELLANTIS_API.md.
const _scopes = 'openid profile';

/// Minimum PKCE verifier length in characters (spec: 43–128).
const _pkceVerifierLength = 64;

final oauthServiceProvider = Provider<OAuthService>(
  (ref) => OAuthService(ref.watch(authStorageProvider)),
);

/// Thrown when no OAuth client credentials are configured for the selected
/// brand+country. Surfaces a clear message instead of opening the browser to
/// an IDP error page. Populate secrets.dart via tools/extract_secrets.
class MissingBrandCredentialsException implements Exception {
  const MissingBrandCredentialsException(this.cacheKey);

  final String cacheKey;

  @override
  String toString() =>
      'MissingBrandCredentialsException: no OAuth credentials for $cacheKey';
}

/// Thrown when the OAuth provider redirects back with an error instead of an
/// authorization code (e.g. `invalid_scope`, user declined consent). Unlike a
/// bare [StateError], this is an [Exception] so UI `on Exception` handlers can
/// catch it and surface the provider's message instead of crashing silently.
class OAuthException implements Exception {
  const OAuthException(this.error, [this.description]);

  /// The `error` query parameter from the callback (e.g. `invalid_scope`).
  final String error;

  /// The human-readable `error_description`, if the provider supplied one.
  final String? description;

  @override
  String toString() =>
      'OAuthException: $error${description == null ? '' : ' ($description)'}';
}

class OAuthService {
  OAuthService(this._storage);

  final AuthStorage _storage;

  /// Opens the brand login page in the system browser and stores the resulting
  /// tokens. Returns the saved [OAuthToken].
  Future<OAuthToken> login({
    required Brand brand,
    required String countryCode,
  }) async {
    final scheme = BrandConstants.redirectScheme[brand]!;
    final authorizeUrl = BrandConstants.authorizeUrl[brand]!;
    final tokenUrl = BrandConstants.tokenUrl[brand]!;
    final cacheKey = '${brand.name}:${countryCode.toUpperCase()}';
    final clientId = BrandCredentials.clientId(cacheKey) ?? '';
    final clientSecret = BrandCredentials.clientSecret(cacheKey) ?? '';

    if (clientId.isEmpty) {
      throw MissingBrandCredentialsException(cacheKey);
    }

    final redirectUri = '$scheme://oauth2redirect/${countryCode.toLowerCase()}';

    final (verifier, challenge) = _generatePkce();
    final state = _randomBase64Url(16);

    final params = {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': _scopes,
      'state': state,
      'code_challenge': challenge,
      'code_challenge_method': 'S256',
    };

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final fullAuthorizeUrl = '$authorizeUrl?$query';

    final callbackUrl = await FlutterWebAuth2.authenticate(
      url: fullAuthorizeUrl,
      callbackUrlScheme: scheme,
    );

    final code = extractAuthorizationCode(callbackUrl);

    final token = await _exchangeCode(
      tokenUrl: tokenUrl,
      code: code,
      redirectUri: redirectUri,
      verifier: verifier,
      clientId: clientId,
      clientSecret: clientSecret,
    );

    await _storage.save(token);
    return token;
  }

  /// Extracts the authorization code from an OAuth redirect [callbackUrl].
  ///
  /// Throws an [OAuthException] (a catchable [Exception]) when the provider
  /// redirects back with an `error` parameter, carrying the provider's
  /// `error_description` so the UI can show why sign-in failed.
  static String extractAuthorizationCode(String callbackUrl) {
    final uri = Uri.parse(callbackUrl);
    final code = uri.queryParameters['code'];
    if (code != null && code.isNotEmpty) {
      return code;
    }

    final error = uri.queryParameters['error'];
    if (error != null && error.isNotEmpty) {
      throw OAuthException(error, uri.queryParameters['error_description']);
    }

    // No code and no error: a malformed callback. Still surface a catchable
    // Exception so the UI never fails silently.
    throw const OAuthException(
      'invalid_response',
      'No authorization code in callback.',
    );
  }

  Future<OAuthToken> _exchangeCode({
    required String tokenUrl,
    required String code,
    required String redirectUri,
    required String verifier,
    required String clientId,
    required String clientSecret,
  }) async {
    final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

    final response = await Dio().post<Map<String, dynamic>>(
      tokenUrl,
      data: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'code_verifier': verifier,
      },
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
        headers: {'Authorization': 'Basic $credentials'},
        responseType: ResponseType.json,
      ),
    );

    return _parseTokenResponse(response.data!);
  }

  OAuthToken _parseTokenResponse(Map<String, dynamic> data) {
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;
    final expiresIn = data['expires_in'];

    if (accessToken == null || refreshToken == null) {
      throw FormatException('Missing tokens in response: $data');
    }

    final ttl = expiresIn is num ? expiresIn.toInt() : 3600;
    final expiresAt = DateTime.now().toUtc().add(Duration(seconds: ttl));

    return OAuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  /// Generates a PKCE (verifier, challenge) pair using SHA-256.
  static (String verifier, String challenge) _generatePkce() {
    final verifier = _randomBase64Url(_pkceVerifierLength);
    final digest = sha256.convert(utf8.encode(verifier));
    final challenge = base64Url
        .encode(Uint8List.fromList(digest.bytes))
        .replaceAll('=', '');
    return (verifier, challenge);
  }

  static String _randomBase64Url(int length) {
    final rng = Random.secure();
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = rng.nextInt(256);
    }
    return base64Url.encode(bytes).replaceAll('=', '').substring(0, length);
  }
}
