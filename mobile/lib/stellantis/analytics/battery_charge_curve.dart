import 'package:stellantis_mobile/stellantis/analytics/charge.dart';
import 'package:stellantis_mobile/stellantis/models/car_model.dart';

const _defaultKmByKw = 5.3;
const _minAutonomyForGoodResult = 20.0;

/// Raw telemetry sample from a charging session.
///
/// Port of Python `BatteryCurveDto`.
class BatteryCurvePoint {
  const BatteryCurvePoint({
    required this.date,
    required this.level,
    required this.rate,
    required this.autonomy,
  });

  final DateTime date;

  /// State-of-charge at this sample in percent (0–100).
  final double level;

  /// Reported charging rate (km of autonomy gained per hour).
  final double rate;

  /// Reported remaining range in km.
  final double autonomy;
}

/// Resolved charging speed at a given battery level.
///
/// Port of Python `BatteryChargeCurve`.
class BatteryChargeCurve {
  const BatteryChargeCurve({required this.level, required this.speed});

  /// Battery SoC % at this point.
  final double level;

  /// Charging speed in kW at this SoC level.
  final double speed;
}

/// Converts raw [BatteryCurvePoint] samples into a [BatteryChargeCurve] list.
///
/// Port of Python `BatteryChargeCurve.dto_to_battery_curve`.
class BatteryChargeCurveBuilder {
  BatteryChargeCurveBuilder._();

  static List<BatteryChargeCurve> build(
    CarModel car,
    Charge charge,
    List<BatteryCurvePoint> samples,
  ) {
    if (samples.isEmpty) return _fallback(car, charge);

    final last = samples.last;
    if (last.level <= 0 || last.autonomy <= 0) {
      return _fallback(car, charge);
    }

    final capacity = last.level * car.batteryPower / 100;
    final kmByKw = last.autonomy > _minAutonomyForGoodResult
        ? 0.8 * last.autonomy / capacity
        : _defaultKmByKw;

    final curves = <BatteryChargeCurve>[];
    var startIdx = 0;
    final speeds = <double>[];

    for (var i = 1; i < samples.length; i++) {
      _tryAddSpeed(samples[i - 1].rate, kmByKw, speeds);

      final diffLevel = samples[i].level - samples[startIdx].level;
      final diffSec = samples[i]
          .date
          .difference(samples[startIdx].date)
          .inSeconds;

      if (diffSec > 0 && diffLevel > 3) {
        _tryAddSpeed(samples[i].rate, kmByKw, speeds);

        final durationH = diffSec / 3600;
        final chargedKwh = car.batteryPower * diffLevel / 100;
        var speed = chargedKwh / durationH;

        if (speeds.isNotEmpty) {
          final all = [...speeds, speed];
          speed = all.reduce((a, b) => a + b) / all.length;
        }
        speed = (speed * 2).round() / 2;

        curves.add(
          BatteryChargeCurve(level: samples[startIdx].level, speed: speed),
        );
        startIdx = i;
        speeds.clear();
      }
    }
    curves.add(BatteryChargeCurve(level: charge.endLevel ?? 0, speed: 0));
    return curves;
  }

  static void _tryAddSpeed(double rate, double kmByKw, List<double> out) {
    if (rate > 0) out.add(rate / kmByKw);
  }

  static List<BatteryChargeCurve> _fallback(CarModel car, Charge charge) {
    final start = charge.startLevel;
    final end = charge.endLevel;
    final stopAt = charge.stopAt;
    if (start == null || end == null || stopAt == null) return const [];
    final diffSec = stopAt.difference(charge.startAt).inSeconds;
    if (diffSec <= 0) return const [];
    final durationH = diffSec / 3600;
    final chargedKwh = car.batteryPower * (end - start) / 100;
    final speed = chargedKwh / durationH;
    return [
      BatteryChargeCurve(level: start, speed: speed),
      BatteryChargeCurve(level: end, speed: speed),
    ];
  }
}
