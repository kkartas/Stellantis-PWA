import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/stellantis/models/car_model.dart';
import 'package:yaml/yaml.dart';

const _defaultBatteryPower = 46.0;
const _defaultFuelCapacity = 0.0;

final carModelRepositoryProvider =
    FutureProvider<CarModelRepository>((ref) async {
  return CarModelRepository._load();
});

/// Loads car_models.yml from assets and resolves VIN → [CarModel].
///
/// Port of Python `CarModelRepository`.
class CarModelRepository {
  CarModelRepository._(this._models);

  final List<CarModel> _models;

  static Future<CarModelRepository> _load() async {
    final raw = await rootBundle.loadString('assets/data/car_models.yml');
    return CarModelRepository._(_parseYaml(raw));
  }

  /// Returns the first model whose VIN prefix matches [vin], or the fallback.
  CarModel findByVin(String vin) {
    if (vin.isNotEmpty && vin != 'vin') {
      for (final model in _models) {
        if (model.matchesVin(vin)) return model;
      }
    }
    return _fallback;
  }

  /// Returns the first model whose name equals [name], or null.
  CarModel? findByName(String name) {
    for (final model in _models) {
      if (model.name == name) return model;
    }
    return null;
  }

  static CarModel get _fallback => const CarModel(
        name: 'unknown',
        batteryPower: _defaultBatteryPower,
        fuelCapacity: _defaultFuelCapacity,
      );

  static List<CarModel> _parseYaml(String raw) {
    // Strip Python ruamel.yaml type tags before parsing —
    // !ElecModel / !CarModel are valid YAML local tags but
    // carry no additional semantics beyond what the fields express.
    final cleaned =
        raw.replaceAll(RegExp('!(?:Elec|Car)Model'), '');
    final doc = loadYaml(cleaned);
    if (doc is! YamlList) return const [];
    return [
      for (final item in doc)
        if (item is YamlMap) _parseModel(item),
    ];
  }

  static CarModel _parseModel(YamlMap map) {
    final fuelRaw =
        (map['max_fuel_consumption'] ?? map['max_fuel_consumptipn']) as num?;
    return CarModel(
      name: (map['name'] as String? ?? 'unknown').replaceAll("'", ''),
      batteryPower: (map['battery_power'] as num? ?? 0).toDouble(),
      fuelCapacity: (map['fuel_capacity'] as num? ?? 0).toDouble(),
      abrpName: _nonEmpty(map['abrp_name'] as String?),
      reg: _nonEmpty(map['reg'] as String?),
      maxElecConsumption:
          (map['max_elec_consumption'] as num? ?? 70).toDouble(),
      maxFuelConsumption: (fuelRaw ?? 30).toDouble(),
    );
  }

  static String? _nonEmpty(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    return s.trim();
  }
}
