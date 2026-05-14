import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/stellantis/analytics/battery_charge_curve.dart';
import 'package:stellantis_mobile/stellantis/analytics/charge.dart';
import 'package:stellantis_mobile/stellantis/analytics/electricity_price_config.dart';

void main() {
  group('ElectricityPriceConfig', () {
    test('isEnabled is false when dayPrice is zero', () {
      const config = ElectricityPriceConfig(dayPrice: 0);
      expect(config.isEnabled, isFalse);
    });

    test('AC day-rate: 10 kWh at 1.0/kWh with 100% efficiency = 10.0', () {
      const config = ElectricityPriceConfig(
        dayPrice: 1,
        chargerEfficiency: 1,
      );
      final start = DateTime.utc(2021, 3, 1, 10);
      final stop = DateTime.utc(2021, 3, 1, 11);
      final charge = Charge(
        startAt: start,
        stopAt: stop,
        kw: 10,
        chargingMode: ChargeMode.ac,
      );
      final price = config.getPrice(charge, []);
      expect(price, closeTo(10, 0.01));
    });

    test('AC night-tariff applies within the night window', () {
      const config = ElectricityPriceConfig(
        dayPrice: 0.20,
        nightPrice: 0.10,
        nightHourStart: HourMinute(22, 0),
        nightHourEnd: HourMinute(6, 0),
        chargerEfficiency: 1,
      );
      // Local time 22:00–23:00 — both 30-min samples are night rate
      final start = DateTime(2021, 3, 1, 22);
      final stop = DateTime(2021, 3, 1, 23);
      final charge = Charge(
        startAt: start,
        stopAt: stop,
        kw: 10,
        chargingMode: ChargeMode.ac,
      );
      // avg=0.10 → price = 10 * 0.10 / 1.0 = 1.0
      expect(config.getPrice(charge, []), closeTo(1, 0.01));
    });

    test('DC pricing uses dcChargePrice × kWh', () {
      const config = ElectricityPriceConfig(
        dcChargePrice: 0.35,
        chargerEfficiency: 1,
      );
      final start = DateTime.utc(2021, 3, 1, 10);
      final stop = DateTime.utc(2021, 3, 1, 10, 30);
      final charge = Charge(
        startAt: start,
        stopAt: stop,
        kw: 20,
        chargingMode: ChargeMode.dc,
      );
      const curve = BatteryChargeCurve(level: 50, speed: 40);
      // 0.35 * 20 = 7.0
      expect(config.getPrice(charge, [curve]), closeTo(7, 0.01));
    });

    test('DC high-speed pricing applies when maxSpeed > threshold', () {
      const config = ElectricityPriceConfig(
        dcChargePrice: 0.35,
        highSpeedDcChargePrice: 0.50,
        highSpeedDcChargeThreshold: 50,
        chargerEfficiency: 1,
      );
      final start = DateTime.utc(2021, 3, 1, 10);
      final stop = DateTime.utc(2021, 3, 1, 10, 30);
      final charge = Charge(
        startAt: start,
        stopAt: stop,
        kw: 10,
        chargingMode: ChargeMode.dc,
      );
      // speed=75 > threshold=50 → highSpeedDcChargePrice * 10 = 5.0
      const curve = BatteryChargeCurve(level: 50, speed: 75);
      expect(config.getPrice(charge, [curve]), closeTo(5, 0.01));
    });

    test('AC getPrice returns null when kw is null', () {
      const config = ElectricityPriceConfig();
      final start = DateTime.utc(2021, 3, 1, 10);
      final stop = DateTime.utc(2021, 3, 1, 11);
      final charge = Charge(
        startAt: start,
        stopAt: stop,
        chargingMode: ChargeMode.ac,
      );
      expect(config.getPrice(charge, []), isNull);
    });
  });

  group('HourMinute.isAfterOrAt', () {
    test('returns true when dt is at the boundary', () {
      const hm = HourMinute(22, 0);
      final dt = DateTime(2021, 3, 1, 22);
      expect(hm.isAfterOrAt(dt), isTrue);
    });

    test('returns false when dt is before the boundary', () {
      const hm = HourMinute(22, 0);
      final dt = DateTime(2021, 3, 1, 21, 59);
      expect(hm.isAfterOrAt(dt), isFalse);
    });
  });
}
