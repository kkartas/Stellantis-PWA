import 'package:stellantis_mobile/stellantis/models/car_model.dart';

/// A resolved driving trip with computed consumption figures.
///
/// Port of Python `Trip` (psacc/model/trip.py).
class Trip {
  Trip({
    required this.car,
    required this.startAt,
    required this.endAt,
    required this.distance,
    required this.duration,
    required this.mileage,
    this.speedAverage,
    this.altitudeDiff,
    this.id,
    List<({double lat, double lon})>? positions,
    List<double>? temperatures,
  })  : positions = positions ?? [],
        temperatures = temperatures ?? [],
        consumption = 0,
        consumptionKm = 0,
        consumptionFuel = 0,
        consumptionFuelKm = 0;

  final CarModel car;
  final DateTime startAt;
  final DateTime endAt;

  /// Distance travelled in km.
  final double distance;

  /// Trip duration in hours.
  final double duration;

  /// Odometer reading at trip end in km.
  final double mileage;

  final double? speedAverage;
  final double? altitudeDiff;
  final int? id;
  final List<({double lat, double lon})> positions;
  final List<double> temperatures;

  /// Electric energy consumed in kWh.
  double consumption;

  /// Consumption in kWh/100 km.
  double consumptionKm;

  /// Fuel consumed in litres.
  double consumptionFuel;

  /// Consumption in L/100 km.
  double consumptionFuelKm;

  double? get averageTemperature {
    if (temperatures.isEmpty) return null;
    return temperatures.reduce((a, b) => a + b) / temperatures.length;
  }

  /// Computes [consumption] and [consumptionKm] from a battery level delta.
  ///
  /// [diffLevelPercent]: positive = consumed, clamped to zero when negative.
  void setConsumption(double diffLevelPercent) {
    final delta = diffLevelPercent < 0 ? 0.0 : diffLevelPercent;
    consumption = delta * car.batteryPower / 100;
    consumptionKm =
        distance > 0 ? 100 * consumption / distance : 0;
  }

  /// Computes [consumptionFuel] and [consumptionFuelKm] from a fuel delta.
  void setFuelConsumption(double diffLevelPercent) {
    consumptionFuel = _round2(diffLevelPercent * car.fuelCapacity / 100);
    consumptionFuelKm =
        distance > 0 ? _round2(100 * consumptionFuel / distance) : 0;
  }

  static double _round2(double v) => (v * 100).round() / 100;

  Map<String, Object?> toJson() => {
        'id': id,
        'start_at': startAt.toIso8601String(),
        'end_at': endAt.toIso8601String(),
        'distance': distance,
        'duration': duration * 60,
        'mileage': mileage,
        'speed_average': speedAverage,
        'altitude_diff': altitudeDiff,
        'consumption': consumption,
        'consumption_km': consumptionKm,
        if (car.hasFuel) 'consumption_fuel': consumptionFuel,
        if (car.hasFuel) 'consumption_fuel_km': consumptionFuelKm,
        'consumption_by_temp': averageTemperature,
        'positions': {
          'lat': positions.map((p) => p.lat).toList(),
          'long': positions.map((p) => p.lon).toList(),
        },
      };
}
