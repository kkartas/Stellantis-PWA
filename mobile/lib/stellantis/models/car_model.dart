const _defaultMaxElecConsumption = 70.0;
const _defaultMaxFuelConsumption = 30.0;

/// Resolved car model with powertrain specs, used for analytics and ABRP.
///
/// Port of Python `CarModel` / `ElecModel`.
class CarModel {
  const CarModel({
    required this.name,
    required this.batteryPower,
    required this.fuelCapacity,
    this.abrpName,
    this.reg,
    this.maxElecConsumption = _defaultMaxElecConsumption,
    this.maxFuelConsumption = _defaultMaxFuelConsumption,
  });

  /// Human-readable model name.
  final String name;

  /// Usable battery capacity in kWh (0 for thermal vehicles).
  final double batteryPower;

  /// Fuel tank capacity in litres (0 for pure electric).
  final double fuelCapacity;

  /// ABRP vehicle identifier string, null if unknown.
  final String? abrpName;

  /// VIN prefix used for model lookup; may contain trailing `.*` suffix.
  final String? reg;

  /// Rated consumption in kWh/100 km.
  final double maxElecConsumption;

  /// Rated consumption in L/100 km.
  final double maxFuelConsumption;

  bool get isElectric => fuelCapacity == 0 && batteryPower > 0;
  bool get isThermal => fuelCapacity > 0 && batteryPower == 0;
  bool get isHybrid => fuelCapacity > 0 && batteryPower > 0;
  bool get hasBattery => batteryPower > 0;
  bool get hasFuel => fuelCapacity > 0;

  /// Returns true if [vin] matches the [reg] prefix for this model.
  bool matchesVin(String vin) {
    final prefix = reg?.replaceAll('.*', '').trimRight();
    if (prefix == null || prefix.isEmpty) return false;
    return vin.startsWith(prefix);
  }

  @override
  String toString() => 'CarModel($name, '
      'battery=${batteryPower}kWh, fuel=${fuelCapacity}L)';
}
