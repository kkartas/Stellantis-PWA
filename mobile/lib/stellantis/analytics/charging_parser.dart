import 'package:stellantis_mobile/stellantis/analytics/battery_charge_curve.dart';
import 'package:stellantis_mobile/stellantis/analytics/charge.dart';
import 'package:stellantis_mobile/stellantis/analytics/electricity_price_config.dart';
import 'package:stellantis_mobile/stellantis/models/car_model.dart';

/// Static helpers for detecting and pricing charge sessions.
///
/// Port of Python Charging (psacc/application/charging.py) without DB.
class ChargingParser {
  ChargingParser._();

  /// A charge session is ended when it is null or already has a stop time.
  static bool isChargeEnded(Charge? charge) =>
      charge == null || charge.stopAt != null;

  /// Handles a charging-status tick and returns an updated [Charge].
  ///
  /// Pass the current in-progress charge (or null on first tick).
  /// Returns a new or updated [Charge], or null when nothing changed.
  static Charge? recordChargeEvent({
    required Charge? current,
    required String chargingStatus,
    required DateTime date,
    required double level,
    required double? mileage,
    required String? vin,
    required ChargeMode mode,
  }) {
    final at = date.copyWith(microsecond: 0);
    if (chargingStatus == 'InProgress') {
      if (isChargeEnded(current)) {
        return Charge(
          startAt: at,
          startLevel: level,
          vin: vin,
          chargingMode: mode,
          mileage: mileage,
        );
      }
      return current;
    } else {
      final last = current;
      if (last != null && last.stopAt == null) {
        last.stopAt = at;
        last.endLevel = level;
        last.mileage = mileage;
      }
      return last;
    }
  }

  /// Computes price and attaches it to [charge].
  ///
  /// [curves] must come from [BatteryChargeCurveBuilder.build].
  static void applyPrice(
    Charge charge,
    List<BatteryChargeCurve> curves,
    ElectricityPriceConfig config,
  ) {
    charge.price = config.getPrice(charge, curves);
  }

  /// Computes the energy delivered (kWh) from level deltas + car specs.
  static double? computeEnergyKwh({
    required CarModel car,
    required double? startLevel,
    required double? endLevel,
  }) {
    if (startLevel == null || endLevel == null) return null;
    return car.batteryPower * (endLevel - startLevel) / 100;
  }

  /// Adds computed duration and price to each item in [charges] in-place.
  static void applyCalculatedFields(
    List<Map<String, Object?>> charges,
  ) {
    for (final c in charges) {
      final start = c['start_at'] as DateTime?;
      final stop = c['stop_at'] as DateTime?;
      if (start != null && stop != null) {
        final secs = stop.difference(start).inSeconds;
        c['duration_min'] = secs / 60.0;
        c['duration_str'] = stop.difference(start).toString();
      }
    }
  }
}

extension DateTimeExtensions on DateTime {
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) =>
      DateTime(
        year ?? this.year,
        month ?? this.month,
        day ?? this.day,
        hour ?? this.hour,
        minute ?? this.minute,
        second ?? this.second,
        millisecond ?? this.millisecond,
        microsecond ?? this.microsecond,
      );
}
