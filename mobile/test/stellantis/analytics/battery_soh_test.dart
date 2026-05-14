import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/stellantis/analytics/battery_soh.dart';

void main() {
  group('BatterySoh', () {
    test('isEmpty and latestResistance are null when no readings', () {
      final soh = BatterySoh(vin: 'VR3UHZKX');
      expect(soh.isEmpty, isTrue);
      expect(soh.latestResistance, isNull);
    });

    test('record keeps readings sorted ascending by date', () {
      final soh = BatterySoh(vin: 'VR3UHZKX');
      final d1 = DateTime.utc(2024);
      final d2 = DateTime.utc(2024, 1, 2);
      final d3 = DateTime.utc(2024, 1, 3);
      soh
        ..record(d3, 0.30)
        ..record(d1, 0.10)
        ..record(d2, 0.20);
      expect(
        soh.readings.map((r) => r.resistance).toList(),
        [0.10, 0.20, 0.30],
      );
    });

    test('latestResistance returns the most recent value', () {
      final soh = BatterySoh(vin: 'VR3UHZKX');
      soh
        ..record(DateTime.utc(2024), 0.10)
        ..record(DateTime.utc(2024, 1, 2), 0.20);
      expect(soh.latestResistance, 0.20);
    });

    test('trendOverLast is positive when resistance is increasing', () {
      final soh = BatterySoh(vin: 'VR3UHZKX');
      soh
        ..record(DateTime.utc(2024), 0.10)
        ..record(DateTime.utc(2024, 1, 2), 0.15)
        ..record(DateTime.utc(2024, 1, 3), 0.20);
      expect(soh.trendOverLast(3), closeTo(0.10, 0.001));
    });

    test('trendOverLast returns null with fewer than 2 readings', () {
      final soh = BatterySoh(vin: 'VR3UHZKX');
      soh.record(DateTime.utc(2024), 0.10);
      expect(soh.trendOverLast(5), isNull);
    });

    test('trendOverLast clamps to last n readings', () {
      final soh = BatterySoh(vin: 'VR3UHZKX');
      soh
        ..record(DateTime.utc(2024), 0.10)
        ..record(DateTime.utc(2024, 1, 2), 0.20)
        ..record(DateTime.utc(2024, 1, 3), 0.25)
        ..record(DateTime.utc(2024, 1, 4), 0.30);
      // last 2: 0.25 → 0.30, diff = 0.05
      expect(soh.trendOverLast(2), closeTo(0.05, 0.001));
    });

    test('toChartData returns parallel dates and levels', () {
      final soh = BatterySoh(vin: 'VR3UHZKX');
      final d1 = DateTime.utc(2024);
      final d2 = DateTime.utc(2024, 1, 2);
      soh
        ..record(d1, 0.10)
        ..record(d2, 0.20);
      final data = soh.toChartData();
      expect(data['dates'], hasLength(2));
      expect(data['levels'], [0.10, 0.20]);
    });
  });
}
