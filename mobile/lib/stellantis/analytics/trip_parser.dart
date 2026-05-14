import 'package:stellantis_mobile/stellantis/analytics/trip.dart';
import 'package:stellantis_mobile/stellantis/analytics/trip_point.dart';
import 'package:stellantis_mobile/stellantis/models/car_model.dart';

/// Maximum plausible speed in km/h; trips exceeding this are discarded.
const maxTripSpeed = 150.0;

enum _Drivetrain { electric, thermal, hybrid }

/// Consumption deltas computed from two [TripPoint]s.
class TripConsumption {
  const TripConsumption({
    required this.elecDeltaPercent,
    required this.fuelDeltaPercent,
  });

  final double elecDeltaPercent;
  final double fuelDeltaPercent;
}

/// Port of Python `TripParser` (psacc/application/trip_parser.py).
///
/// Determines energy consumption and event detection (refuel / recharge /
/// low-speed stop) from a sequence of [TripPoint]s.
class TripParser {
  TripParser(this.car) : _drivetrain = _getDrivetrain(car);

  final CarModel car;
  final _Drivetrain _drivetrain;

  // ---------------------------------------------------------------------------
  // Consumption computation
  // ---------------------------------------------------------------------------

  TripConsumption getLevelConsumption(TripPoint start, TripPoint end) {
    switch (_drivetrain) {
      case _Drivetrain.electric:
        return TripConsumption(
          elecDeltaPercent: (start.level ?? 0) - (end.level ?? 0),
          fuelDeltaPercent: 0,
        );
      case _Drivetrain.thermal:
        return TripConsumption(
          elecDeltaPercent: 0,
          fuelDeltaPercent:
              (start.levelFuel ?? 0) - (end.levelFuel ?? 0),
        );
      case _Drivetrain.hybrid:
        return TripConsumption(
          elecDeltaPercent: (start.level ?? 0) - (end.level ?? 0),
          fuelDeltaPercent:
              (start.levelFuel ?? 0) - (end.levelFuel ?? 0),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Event detection
  // ---------------------------------------------------------------------------

  bool isRefuel(TripPoint start, TripPoint end, double distance) {
    final cons = getLevelConsumption(start, end);
    switch (_drivetrain) {
      case _Drivetrain.electric:
        return isRecharging(cons.elecDeltaPercent, distance);
      case _Drivetrain.thermal:
        return cons.fuelDeltaPercent < 0;
      case _Drivetrain.hybrid:
        return cons.fuelDeltaPercent < 0 ||
            isRecharging(cons.elecDeltaPercent, distance);
    }
  }

  /// Battery level increased by more than 2% with negligible distance →
  /// recharging event detected.
  ///
  /// A margin of 2% is tolerated for regeneration / temperature changes.
  /// If distance > 0 but discharge > 5%, a missing data point is assumed.
  static bool isRecharging(double decharge, double distance) =>
      decharge < -2 && (distance == 0 || decharge < -5);

  /// Speed < 0.2 km/h for duration > 0.05 h (~3 min) → low-speed stop.
  static bool isLowSpeed(double speedAverage, double duration) =>
      speedAverage < 0.2 && duration > 0.05;

  // ---------------------------------------------------------------------------
  // Trip builder
  // ---------------------------------------------------------------------------

  /// Parses [points] into a list of [Trip]s.
  ///
  /// Mirrors the loop in Python `Trips.get_trips`.
  List<Trip> parsePoints(List<TripPoint> points) {
    if (points.length < 2) return const [];

    final trips = <Trip>[];
    var tripId = 1;
    var start = points[0];
    var end = points[1];
    final waypoints = <({double lat, double lon})>[];
    final temps = <double>[];

    for (var x = 0; x < points.length - 2; x++) {
      final nextPoint = points[x + 2];

      final distance = _mileageDiff(end, start);
      final duration = _durationHours(start, end);
      final speedAverage = _speed(distance, duration);

      if (isLowSpeed(speedAverage, duration) ||
          isRefuel(start, end, distance)) {
        start = end;
        waypoints.clear();
        temps.clear();
      } else {
        final nextDistance = _mileageDiff(nextPoint, end);
        final nextDuration = _durationHours(end, nextPoint);
        final nextSpeed = _speed(nextDistance, nextDuration);

        final endTrip = isRefuel(end, nextPoint, nextDistance) ||
            isLowSpeed(nextSpeed, nextDuration) ||
            nextDuration > 2 ||
            x == points.length - 3;

        if (endTrip) {
          final tripDist = _mileageDiff(end, start);
          if (tripDist > 0) {
            final tripDuration = _durationHours(start, end);
            final tripSpeed = _speed(tripDist, tripDuration);
            final cons = getLevelConsumption(start, end);
            final trip = Trip(
              car: car,
              startAt: start.timestamp,
              endAt: end.timestamp,
              distance: tripDist,
              duration: tripDuration,
              mileage: end.mileage ?? 0,
              speedAverage: tripSpeed,
              altitudeDiff: _altDiff(start, end),
              id: tripId,
              positions: List.of(waypoints),
              temperatures: List.of(temps),
            );
            if (cons.elecDeltaPercent != 0) {
              trip.setConsumption(cons.elecDeltaPercent);
            }
            if (cons.fuelDeltaPercent != 0) {
              trip.setFuelConsumption(cons.fuelDeltaPercent);
            }
            if (_isValidTrip(trip)) {
              trips.add(trip);
              tripId++;
            }
          }
          start = nextPoint;
          waypoints.clear();
          temps.clear();
        } else {
          final lat = end.latitude;
          final lon = end.longitude;
          if (lat != null && lon != null) {
            waypoints.add((lat: lat, lon: lon));
          }
          final temp = end.temperature;
          if (temp != null) temps.add(temp);
        }
      }
      end = nextPoint;
    }
    return trips;
  }

  bool _isValidTrip(Trip trip) =>
      trip.consumptionKm <= car.maxElecConsumption &&
      trip.consumptionFuelKm <= car.maxFuelConsumption &&
      (trip.speedAverage ?? 0) < maxTripSpeed;

  static double _mileageDiff(TripPoint a, TripPoint b) {
    final am = a.mileage;
    final bm = b.mileage;
    if (am == null || bm == null) return 0;
    return am - bm;
  }

  static double _durationHours(TripPoint from, TripPoint to) {
    final ms = to.timestamp.difference(from.timestamp).inMilliseconds;
    return ms / 3600000;
  }

  static double _speed(double distance, double duration) =>
      duration > 0 ? distance / duration : 0;

  static double? _altDiff(TripPoint start, TripPoint end) {
    final sa = start.altitude;
    final ea = end.altitude;
    if (sa == null || ea == null) return null;
    return ea - sa;
  }

  static _Drivetrain _getDrivetrain(CarModel car) {
    if (car.isElectric) return _Drivetrain.electric;
    if (car.isThermal) return _Drivetrain.thermal;
    return _Drivetrain.hybrid;
  }
}
