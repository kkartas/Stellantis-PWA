import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kAbrpEnabled = 'abrp_enabled';
const _kAbrpToken = 'abrp_token';
const _kOpenWeatherKey = 'openweather_api_key';

class IntegrationPreferences {
  const IntegrationPreferences({
    this.abrpEnabled = false,
    this.abrpToken = '',
    this.openWeatherApiKey = '',
  });

  final bool abrpEnabled;
  final String abrpToken;
  final String openWeatherApiKey;

  IntegrationPreferences copyWith({
    bool? abrpEnabled,
    String? abrpToken,
    String? openWeatherApiKey,
  }) {
    return IntegrationPreferences(
      abrpEnabled: abrpEnabled ?? this.abrpEnabled,
      abrpToken: abrpToken ?? this.abrpToken,
      openWeatherApiKey: openWeatherApiKey ?? this.openWeatherApiKey,
    );
  }
}

final integrationPrefsControllerProvider = AsyncNotifierProvider<
    IntegrationPrefsController, IntegrationPreferences>(
  IntegrationPrefsController.new,
);

class IntegrationPrefsController
    extends AsyncNotifier<IntegrationPreferences> {
  static const _storage = FlutterSecureStorage();

  @override
  Future<IntegrationPreferences> build() async {
    final values = await Future.wait([
      _storage.read(key: _kAbrpEnabled),
      _storage.read(key: _kAbrpToken),
      _storage.read(key: _kOpenWeatherKey),
    ]);
    return IntegrationPreferences(
      abrpEnabled: values[0] == 'true',
      abrpToken: values[1] ?? '',
      openWeatherApiKey: values[2] ?? '',
    );
  }

  Future<void> setAbrp({required bool enabled, required String token}) async {
    await Future.wait([
      _storage.write(key: _kAbrpEnabled, value: enabled.toString()),
      _storage.write(key: _kAbrpToken, value: token),
    ]);
    state = AsyncData(
      (state.valueOrNull ?? const IntegrationPreferences())
          .copyWith(abrpEnabled: enabled, abrpToken: token),
    );
  }

  Future<void> setOpenWeatherKey(String key) async {
    await _storage.write(key: _kOpenWeatherKey, value: key);
    state = AsyncData(
      (state.valueOrNull ?? const IntegrationPreferences())
          .copyWith(openWeatherApiKey: key),
    );
  }
}
