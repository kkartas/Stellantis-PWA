import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kRemoteAccessToken = 'psa_remote_access_token';
const _kRemoteRefreshToken = 'psa_remote_refresh_token';

/// Holds the PSA remote-access token pair (separate from the main OAuth token).
///
/// Port of Python `RemoteCredentials`.
class RemoteCredentials {
  RemoteCredentials({this.refreshToken})
      : lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  String? accessToken;
  String? refreshToken;
  DateTime lastUpdate;

  void markUpdated() => lastUpdate = DateTime.now();

  Future<void> persist(FlutterSecureStorage storage) async {
    final writes = <Future<void>>[];
    final at = accessToken;
    final rt = refreshToken;
    if (at != null) {
      writes.add(storage.write(key: _kRemoteAccessToken, value: at));
    }
    if (rt != null) {
      writes.add(storage.write(key: _kRemoteRefreshToken, value: rt));
    }
    await Future.wait(writes);
  }

  static Future<RemoteCredentials> load(
    FlutterSecureStorage storage,
  ) async {
    final values = await Future.wait([
      storage.read(key: _kRemoteAccessToken),
      storage.read(key: _kRemoteRefreshToken),
    ]);
    return RemoteCredentials(refreshToken: values[1])
      ..accessToken = values[0];
  }
}
