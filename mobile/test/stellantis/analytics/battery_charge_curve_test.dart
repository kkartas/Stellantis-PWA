import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/stellantis/analytics/battery_charge_curve.dart';
import 'package:stellantis_mobile/stellantis/analytics/charge.dart';
import 'package:stellantis_mobile/stellantis/models/car_model.dart';

// 20-minute intervals; mirrors test_BatteryChargeCurve.py fixtures.
final _date0 = DateTime.utc(2021, 3, 1, 11);
final _date1 = DateTime.utc(2021, 3, 1, 11, 20);
final _date2 = DateTime.utc(2021, 3, 1, 11, 40);

const _car = CarModel(
  name: 'e-208',
  batteryPower: 46,
  fuelCapacity: 0,
);

void main() {
  group('BatteryChargeCurveBuilder', () {
    test('normal 3-sample curve matches Python fixture [32.5, 14.5, 0]', () {
      final samples = [
        BatteryCurvePoint(
          date: _date0,
          level: 0,
          rate: 20,
          autonomy: 60,
        ),
        BatteryCurvePoint(
          date: _date1,
          level: 60,
          rate: 20,
          autonomy: 100,
        ),
        BatteryCurvePoint(
          date: _date2,
          level: 80,
          rate: 20,
          autonomy: 120,
        ),
      ];
      final charge = Charge(
        startAt: _date0,
        stopAt: _date2,
        startLevel: 0,
        endLevel: 80,
      );
      final result =
          BatteryChargeCurveBuilder.build(_car, charge, samples);
      expect(result.map((c) => c.speed).toList(), [32.5, 14.5, 0.0]);
    });

    test('zero autonomy falls back to straight-line curve', () {
      final samples = [
        BatteryCurvePoint(
          date: _date0,
          level: 0,
          rate: 20,
          autonomy: 0,
        ),
      ];
      final charge = Charge(
        startAt: _date0,
        stopAt: _date2,
        startLevel: 0,
        endLevel: 80,
      );
      final result =
          BatteryChargeCurveBuilder.build(_car, charge, samples);
      expect(result, hasLength(2));
      expect(result[0].level, 0.0);
      expect(result[1].level, 80.0);
      // 46 kWh * 80% / (40 min / 60) h ≈ 55.2 kW
      expect(result[1].speed, closeTo(55.2, 0.1));
    });

    test('empty samples returns straight-line fallback', () {
      final charge = Charge(
        startAt: _date0,
        stopAt: _date2,
        startLevel: 20,
        endLevel: 60,
      );
      final result = BatteryChargeCurveBuilder.build(_car, charge, []);
      expect(result, hasLength(2));
      expect(result[0].level, 20.0);
      expect(result[1].level, 60.0);
    });

    test('missing startLevel returns empty list', () {
      final charge = Charge(startAt: _date0, stopAt: _date2);
      final result = BatteryChargeCurveBuilder.build(_car, charge, []);
      expect(result, isEmpty);
    });
  });
}
