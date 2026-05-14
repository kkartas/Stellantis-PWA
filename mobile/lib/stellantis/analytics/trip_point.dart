/// A single telemetry sample from the vehicle position/status stream.
///
/// Column order mirrors the Python DB schema:
/// Timestamp, VIN, longitude, latitude, mileage, level, moving,
/// temperature, level_fuel, altitude.
class TripPoint {
  const TripPoint({
    required this.timestamp,
    this.level,
    this.levelFuel,
    this.mileage,
    this.latitude,
    this.longitude,
    this.altitude,
    this.temperature,
    this.moving,
  });

  final DateTime timestamp;

  /// Battery state-of-charge in percent (0–100), null if not available.
  final double? level;

  /// Fuel level in percent (0–100), null for pure-electric vehicles.
  final double? levelFuel;

  final double? mileage;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final double? temperature;
  final bool? moving;
}
