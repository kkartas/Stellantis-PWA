import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/stellantis/analytics/charge.dart';
import 'package:stellantis_mobile/stellantis/analytics/charging_parser.dart';
import 'package:stellantis_mobile/stellantis/models/car_model.dart';

final _date0 = DateTime.utc(2021, 3, 1, 11);
final _date1 = DateTime.utc(2021, 3, 1, 11, 20);

const _car = CarModel(
  name: 'e-208',
  batteryPower: 46,
  fuelCapacity: 0,
);

void main() {
  group('ChargingParser.isChargeEnded', () {
    test('null charge is considered ended', () {
      expect(ChargingParser.isChargeEnded(null), isTrue);
    });

    test('charge with stopAt is ended', () {
      expect(
        ChargingParser.isChargeEnded(
          Charge(startAt: _date0, stopAt: _date1),
        ),
        isTrue,
      );
    });

    test('charge without stopAt is not ended', () {
      expect(
        ChargingParser.isChargeEnded(Charge(startAt: _date0)),
        isFalse,
      );
    });
  });

  group('ChargingParser.recordChargeEvent', () {
    test('InProgress with null current creates new charge', () {
      final result = ChargingParser.recordChargeEvent(
        current: null,
        chargingStatus: 'InProgress',
        date: _date0,
        level: 40,
        mileage: 1000,
        vin: 'VR3UHZKX',
        mode: ChargeMode.ac,
      );
      expect(result, isNotNull);
      expect(result!.startLevel, 40.0);
      expect(result.stopAt, isNull);
      expect(result.chargingMode, ChargeMode.ac);
    });

    test('InProgress with open charge returns same object', () {
      final open = Charge(startAt: _date0, startLevel: 40);
      final result = ChargingParser.recordChargeEvent(
        current: open,
        chargingStatus: 'InProgress',
        date: _date1,
        level: 60,
        mileage: null,
        vin: null,
        mode: ChargeMode.ac,
      );
      expect(identical(result, open), isTrue);
    });

    test('Stopped with open charge closes it', () {
      final open = Charge(startAt: _date0, startLevel: 40);
      final result = ChargingParser.recordChargeEvent(
        current: open,
        chargingStatus: 'Stopped',
        date: _date1,
        level: 80,
        mileage: 1100,
        vin: 'VR3UHZKX',
        mode: ChargeMode.ac,
      );
      expect(result, isNotNull);
      expect(result!.stopAt, isNotNull);
      expect(result.endLevel, 80.0);
    });

    test('Stopped with null current returns null', () {
      final result = ChargingParser.recordChargeEvent(
        current: null,
        chargingStatus: 'Stopped',
        date: _date1,
        level: 80,
        mileage: null,
        vin: null,
        mode: ChargeMode.unknown,
      );
      expect(result, isNull);
    });
  });

  group('ChargingParser.computeEnergyKwh', () {
    test('46 kWh car from 40% to 85% delivers 20.7 kWh', () {
      // Mirrors Python kw=20.7 fixture from test_unit.py
      final energy = ChargingParser.computeEnergyKwh(
        car: _car,
        startLevel: 40,
        endLevel: 85,
      );
      expect(energy, closeTo(20.7, 0.01));
    });

    test('returns null when startLevel is null', () {
      expect(
        ChargingParser.computeEnergyKwh(
          car: _car,
          startLevel: null,
          endLevel: 80,
        ),
        isNull,
      );
    });

    test('returns null when endLevel is null', () {
      expect(
        ChargingParser.computeEnergyKwh(
          car: _car,
          startLevel: 40,
          endLevel: null,
        ),
        isNull,
      );
    });
  });
}
