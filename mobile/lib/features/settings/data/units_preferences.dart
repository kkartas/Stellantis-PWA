import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kDistance = 'units_distance';
const _kTemperature = 'units_temperature';
const _kCurrency = 'units_currency';

enum DistanceUnit { kilometers, miles }

enum TemperatureUnit { celsius, fahrenheit }

class UnitsPreferences {
  const UnitsPreferences({
    this.distance = DistanceUnit.kilometers,
    this.temperature = TemperatureUnit.celsius,
    this.currency = 'EUR',
  });

  final DistanceUnit distance;
  final TemperatureUnit temperature;
  final String currency;

  UnitsPreferences copyWith({
    DistanceUnit? distance,
    TemperatureUnit? temperature,
    String? currency,
  }) {
    return UnitsPreferences(
      distance: distance ?? this.distance,
      temperature: temperature ?? this.temperature,
      currency: currency ?? this.currency,
    );
  }
}

final unitsControllerProvider =
    AsyncNotifierProvider<UnitsController, UnitsPreferences>(
  UnitsController.new,
);

class UnitsController extends AsyncNotifier<UnitsPreferences> {
  static const _storage = FlutterSecureStorage();

  @override
  Future<UnitsPreferences> build() async {
    final values = await Future.wait([
      _storage.read(key: _kDistance),
      _storage.read(key: _kTemperature),
      _storage.read(key: _kCurrency),
    ]);
    return UnitsPreferences(
      distance: values[0] == 'miles'
          ? DistanceUnit.miles
          : DistanceUnit.kilometers,
      temperature: values[1] == 'fahrenheit'
          ? TemperatureUnit.fahrenheit
          : TemperatureUnit.celsius,
      currency: values[2] ?? 'EUR',
    );
  }

  Future<void> setDistance(DistanceUnit unit) async {
    await _storage.write(key: _kDistance, value: unit.name);
    state = AsyncData((state.valueOrNull ?? const UnitsPreferences())
        .copyWith(distance: unit));
  }

  Future<void> setTemperature(TemperatureUnit unit) async {
    await _storage.write(key: _kTemperature, value: unit.name);
    state = AsyncData((state.valueOrNull ?? const UnitsPreferences())
        .copyWith(temperature: unit));
  }

  Future<void> setCurrency(String code) async {
    await _storage.write(key: _kCurrency, value: code);
    state = AsyncData((state.valueOrNull ?? const UnitsPreferences())
        .copyWith(currency: code));
  }
}
