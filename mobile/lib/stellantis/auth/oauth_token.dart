import 'package:flutter/foundation.dart';

@immutable
class OAuthToken {
  const OAuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;

  /// UTC instant after which [accessToken] must be refreshed.
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);

  /// True when the token expires within the given [window].
  bool expiresWithin(Duration window) =>
      DateTime.now().toUtc().isAfter(expiresAt.subtract(window));

  OAuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) =>
      OAuthToken(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        expiresAt: expiresAt ?? this.expiresAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuthToken &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode => Object.hash(accessToken, refreshToken, expiresAt);
}
