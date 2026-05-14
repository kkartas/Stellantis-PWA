/// Charging mode (AC = slow, DC = fast charge).
///
/// Port of Python `ChargingMode` (psacc/model/charge.py).
enum ChargeMode {
  ac('slow'),
  dc('fast'),
  unknown('unknown');

  const ChargeMode(this.apiValue);

  /// API string value returned by the PSA Connected Car API.
  final String apiValue;

  static ChargeMode fromApi(String? value) => ChargeMode.values.firstWhere(
        (m) => m.apiValue == value,
        orElse: () => ChargeMode.unknown,
      );
}

/// One recorded charge session.
///
/// Port of Python `Charge` (psacc/model/charge.py).
class Charge {
  Charge({
    required this.startAt,
    this.stopAt,
    this.vin,
    this.startLevel,
    this.endLevel,
    this.co2,
    this.kw,
    this.price,
    this.chargingMode = ChargeMode.unknown,
    this.mileage,
  });

  final DateTime startAt;
  DateTime? stopAt;
  final String? vin;

  /// Battery state-of-charge at charge start (0–100 %).
  double? startLevel;

  /// Battery state-of-charge at charge end (0–100 %).
  double? endLevel;

  /// CO₂ intensity during the charge in gCO₂/kWh, null if unavailable.
  double? co2;

  /// Energy delivered during the charge in kWh.
  double? kw;

  /// Electricity cost in local currency, null until computed.
  double? price;

  ChargeMode chargingMode;

  /// Odometer reading at charge end in km.
  double? mileage;

  Duration? get duration {
    final stop = stopAt;
    if (stop == null) return null;
    return stop.difference(startAt);
  }

  double? get durationMinutes {
    final d = duration;
    if (d == null) return null;
    return d.inSeconds / 60.0;
  }
}
