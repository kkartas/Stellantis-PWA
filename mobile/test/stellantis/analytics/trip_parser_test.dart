import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/stellantis/analytics/trip_parser.dart';
import 'package:stellantis_mobile/stellantis/analytics/trip_point.dart';
import 'package:stellantis_mobile/stellantis/models/car_model.dart';

// date3 = 2021-03-01 12:00 UTC; others relative to it.
final _date3 = DateTime.utc(2021, 3, 1, 12);
final _date0 = _date3.subtract(const Duration(minutes: 60));
final _date1 = _date3.subtract(const Duration(minutes: 40));
final _date2 = _date3.subtract(const Duration(minutes: 20));

const _electricCar = CarModel(
  name: 'e-208',
  batteryPower: 46,
  fuelCapacity: 0,
);

const _thermalCar = CarModel(
  name: '3008',
  batteryPower: 0,
  fuelCapacity: 53,
);

void main() {
  group('TripParser static helpers', () {
    test('isRecharging detects negative SoC gain > 2%', () {
      expect(TripParser.isRecharging(-3, 0), isTrue);
      expect(TripParser.isRecharging(-6, 10), isTrue);
      expect(TripParser.isRecharging(-1, 0), isFalse);
      expect(TripParser.isRecharging(3, 5), isFalse);
    });

    test('isLowSpeed detects near-zero speed over sufficient time', () {
      expect(TripParser.isLowSpeed(0.1, 0.1), isTrue);
      expect(TripParser.isLowSpeed(10, 0.1), isFalse);
      expect(TripParser.isLowSpeed(0.1, 0.01), isFalse);
    });
  });

  group('TripParser.parsePoints (electric)', () {
    // Mirrors Python test_record_position_charging fixture:
    // 4 positions → 1 trip, distance=19km, consumption=4.6kWh
    test('parses 4-point electric trip from Python fixture', () {
      final points = [
        TripPoint(
          timestamp: _date0,
          mileage: 11,
          level: 40,
          latitude: 47.2183,
          longitude: -1.60,
        ),
        TripPoint(
          timestamp: _date1,
          mileage: 20,
          level: 35,
          latitude: 47.2183,
          longitude: -1.55,
        ),
        TripPoint(
          timestamp: _date2,
          mileage: 30,
          level: 30,
          latitude: 47.2183,
          longitude: -1.55,
        ),
        // 4th point: same timestamp as _date2, no mileage
        TripPoint(
          timestamp: _date2,
          level: 30,
          latitude: 47.2183,
          longitude: -1.55,
        ),
      ];

      final trips = TripParser(_electricCar).parsePoints(points);

      expect(trips, hasLength(1));
      final trip = trips[0];
      expect(trip.distance, closeTo(19, 0.01));
      expect(trip.consumption, closeTo(4.6, 0.01));
      expect(trip.consumptionKm, closeTo(24.21, 0.1));
      expect(trip.speedAverage, closeTo(28.5, 0.1));
      expect(trip.mileage, 30.0);
    });

    test('fewer than 2 points returns empty list', () {
      final trips = TripParser(_electricCar).parsePoints([
        TripPoint(
          timestamp: _date0,
          mileage: 10,
          level: 50,
        ),
      ]);
      expect(trips, isEmpty);
    });
  });

  group('TripParser.parsePoints (thermal)', () {
    test('parses fuel consumption for thermal car', () {
      final points = [
        TripPoint(
          timestamp: _date0,
          mileage: 11,
          levelFuel: 80,
          latitude: 47.22,
          longitude: -1.60,
        ),
        TripPoint(
          timestamp: _date1,
          mileage: 20,
          levelFuel: 77,
          latitude: 47.22,
          longitude: -1.55,
        ),
        TripPoint(
          timestamp: _date2,
          mileage: 30,
          levelFuel: 74,
          latitude: 47.22,
          longitude: -1.55,
        ),
        TripPoint(
          timestamp: _date2,
          levelFuel: 74,
        ),
      ];

      final trips = TripParser(_thermalCar).parsePoints(points);
      expect(trips, hasLength(1));
      final trip = trips[0];
      expect(trip.distance, closeTo(19, 0.01));
      // fuel: 53L * (80-74)% / 100 = 3.18L consumed
      expect(trip.consumptionFuel, closeTo(3.18, 0.01));
    });
  });

  group('TripParser.getLevelConsumption', () {
    test('electric: uses battery SoC delta', () {
      final parser = TripParser(_electricCar);
      final p0 = TripPoint(timestamp: _date0, level: 60, levelFuel: 0);
      final p1 = TripPoint(timestamp: _date1, level: 50, levelFuel: 0);
      final cons = parser.getLevelConsumption(p0, p1);
      expect(cons.elecDeltaPercent, 10.0);
      expect(cons.fuelDeltaPercent, 0.0);
    });

    test('thermal: uses fuel level delta', () {
      final parser = TripParser(_thermalCar);
      final p0 = TripPoint(timestamp: _date0, levelFuel: 80);
      final p1 = TripPoint(timestamp: _date1, levelFuel: 75);
      final cons = parser.getLevelConsumption(p0, p1);
      expect(cons.elecDeltaPercent, 0.0);
      expect(cons.fuelDeltaPercent, 5.0);
    });
  });
}
