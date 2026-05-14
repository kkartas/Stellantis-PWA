import 'package:stellantis_mobile/stellantis/analytics/battery_charge_curve.dart';
import 'package:stellantis_mobile/stellantis/analytics/charge.dart';

/// A wall-clock hour:minute pair used for night-tariff boundaries.
class HourMinute {
  const HourMinute(this.hour, this.minute);

  final int hour;
  final int minute;

  bool isAfterOrAt(DateTime dt) {
    if (dt.hour < hour) return false;
    if (dt.hour == hour && dt.minute < minute) return false;
    return true;
  }
}

/// Electricity tariff configuration and price calculator.
///
/// Port of Python `ElectricityPriceConfig`.
class ElectricityPriceConfig {
  const ElectricityPriceConfig({
    this.dayPrice = 0.15,
    this.nightPrice,
    this.nightHourStart,
    this.nightHourEnd,
    this.dcChargePrice,
    this.highSpeedDcChargePrice,
    this.highSpeedDcChargeThreshold,
    this.chargerEfficiency = 0.8942,
  });

  /// Day-time price per kWh in local currency.
  final double dayPrice;

  /// Night-time price per kWh (null = no night tariff).
  final double? nightPrice;

  final HourMinute? nightHourStart;
  final HourMinute? nightHourEnd;

  /// Flat price per kWh for DC (fast) charging.
  final double? dcChargePrice;

  /// Price per kWh for high-power DC charging.
  final double? highSpeedDcChargePrice;

  /// kW threshold above which [highSpeedDcChargePrice] applies.
  final double? highSpeedDcChargeThreshold;

  /// AC charger wall-to-battery efficiency (default ≈ 89%).
  final double chargerEfficiency;

  bool get isEnabled => dayPrice > 0;

  /// Returns the applicable tariff for [utcDate] (converted to local time).
  double getInstantPrice(DateTime utcDate) {
    final local = utcDate.toLocal();
    final np = nightPrice;
    final start = nightHourStart;
    final end = nightHourEnd;
    if (np == null || start == null || end == null) return dayPrice;
    if (start.isAfterOrAt(local) || !end.isAfterOrAt(local)) return np;
    return dayPrice;
  }

  /// Computes electricity cost for [charge] given measured [curves].
  ///
  /// Returns null when the required fields are missing.
  double? getPrice(Charge charge, List<BatteryChargeCurve> curves) {
    final dcPrice = dcChargePrice;
    if (charge.chargingMode == ChargeMode.dc && dcPrice != null) {
      return _getDcPrice(charge, curves, dcPrice);
    }
    return _getAcPrice(charge.startAt, charge.stopAt, charge.kw);
  }

  double? _getDcPrice(
    Charge charge,
    List<BatteryChargeCurve> curves,
    double dcPrice,
  ) {
    final maxSpeed = curves.fold<double>(0, (s, c) => s + c.speed);
    final total = charge.kw ?? 0;
    final threshold = highSpeedDcChargeThreshold;
    final highPrice = highSpeedDcChargePrice;
    if (threshold != null && highPrice != null && maxSpeed > threshold) {
      return highPrice * total;
    }
    return dcPrice * total;
  }

  double? _getAcPrice(DateTime? start, DateTime? stop, double? kw) {
    if (start == null || stop == null || kw == null) return null;
    final prices = <double>[];
    var date = start;
    while (date.isBefore(stop)) {
      prices.add(getInstantPrice(date));
      date = date.add(const Duration(minutes: 30));
    }
    if (prices.isEmpty) return null;
    final avg = prices.reduce((a, b) => a + b) / prices.length;
    return (kw * avg / chargerEfficiency * 100).round() / 100;
  }
}
