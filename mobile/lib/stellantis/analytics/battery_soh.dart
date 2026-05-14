/// A single battery state-of-health measurement.
class BatterySohReading {
  const BatterySohReading({required this.date, required this.resistance});

  /// Timestamp of the measurement.
  final DateTime date;

  /// Battery internal resistance (Ω), as reported by the PSA API
  /// via `energy.battery.health.resistance`. Higher = more degraded.
  final double resistance;
}

/// Time-series of battery SOH readings for one vehicle.
///
/// Port of Python `BatterySoh` (psacc/model/battery_soh.py) with
/// added analytics helpers.
class BatterySoh {
  BatterySoh({required this.vin, List<BatterySohReading>? readings})
      : readings = readings ?? [];

  final String vin;
  final List<BatterySohReading> readings;

  bool get isEmpty => readings.isEmpty;

  double? get latestResistance =>
      readings.isEmpty ? null : readings.last.resistance;

  /// Appends a new reading and keeps the list sorted by date.
  void record(DateTime date, double resistance) {
    readings.add(BatterySohReading(date: date, resistance: resistance));
    readings.sort((a, b) => a.date.compareTo(b.date));
  }

  /// Returns the resistance trend over the last [n] readings.
  ///
  /// Positive → resistance increasing (degradation), negative → improving.
  double? trendOverLast(int n) {
    if (readings.length < 2) return null;
    final slice = readings.length >= n
        ? readings.sublist(readings.length - n)
        : readings;
    if (slice.length < 2) return null;
    return slice.last.resistance - slice.first.resistance;
  }

  /// Lists (date, resistance) pairs as parallel lists for charting.
  Map<String, List<Object>> toChartData() => {
        'dates': readings.map((r) => r.date.toIso8601String()).toList(),
        'levels': readings.map((r) => r.resistance).toList(),
      };
}
