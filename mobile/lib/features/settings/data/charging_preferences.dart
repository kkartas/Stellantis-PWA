import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kTargetSoc = 'charging_target_soc';
const _kScheduledStart = 'charging_sched_start';
const _kScheduledStop = 'charging_sched_stop';
const _kPricePerKwh = 'charging_kwh_price';
const _kPeakStart = 'charging_peak_start';
const _kPeakStop = 'charging_peak_stop';
const _kPeakPrice = 'charging_peak_price';

class ChargingPreferences {
  const ChargingPreferences({
    this.targetSoc = 80,
    this.scheduledStartHour = 22,
    this.scheduledStopHour = 6,
    this.pricePerKwh = 0.20,
    this.peakStartHour = 17,
    this.peakStopHour = 21,
    this.peakPricePerKwh = 0.30,
  });

  final int targetSoc;
  final int scheduledStartHour;
  final int scheduledStopHour;
  final double pricePerKwh;
  final int peakStartHour;
  final int peakStopHour;
  final double peakPricePerKwh;

  ChargingPreferences copyWith({
    int? targetSoc,
    int? scheduledStartHour,
    int? scheduledStopHour,
    double? pricePerKwh,
    int? peakStartHour,
    int? peakStopHour,
    double? peakPricePerKwh,
  }) {
    return ChargingPreferences(
      targetSoc: targetSoc ?? this.targetSoc,
      scheduledStartHour: scheduledStartHour ?? this.scheduledStartHour,
      scheduledStopHour: scheduledStopHour ?? this.scheduledStopHour,
      pricePerKwh: pricePerKwh ?? this.pricePerKwh,
      peakStartHour: peakStartHour ?? this.peakStartHour,
      peakStopHour: peakStopHour ?? this.peakStopHour,
      peakPricePerKwh: peakPricePerKwh ?? this.peakPricePerKwh,
    );
  }
}

final chargingPrefsControllerProvider = AsyncNotifierProvider<
    ChargingPrefsController, ChargingPreferences>(
  ChargingPrefsController.new,
);

class ChargingPrefsController extends AsyncNotifier<ChargingPreferences> {
  static const _storage = FlutterSecureStorage();

  @override
  Future<ChargingPreferences> build() async {
    final values = await Future.wait([
      _storage.read(key: _kTargetSoc),
      _storage.read(key: _kScheduledStart),
      _storage.read(key: _kScheduledStop),
      _storage.read(key: _kPricePerKwh),
      _storage.read(key: _kPeakStart),
      _storage.read(key: _kPeakStop),
      _storage.read(key: _kPeakPrice),
    ]);
    return ChargingPreferences(
      targetSoc: int.tryParse(values[0] ?? '') ?? 80,
      scheduledStartHour: int.tryParse(values[1] ?? '') ?? 22,
      scheduledStopHour: int.tryParse(values[2] ?? '') ?? 6,
      pricePerKwh: double.tryParse(values[3] ?? '') ?? 0.20,
      peakStartHour: int.tryParse(values[4] ?? '') ?? 17,
      peakStopHour: int.tryParse(values[5] ?? '') ?? 21,
      peakPricePerKwh: double.tryParse(values[6] ?? '') ?? 0.30,
    );
  }

  Future<void> save(ChargingPreferences prefs) async {
    await Future.wait([
      _storage.write(key: _kTargetSoc, value: prefs.targetSoc.toString()),
      _storage.write(
          key: _kScheduledStart, value: prefs.scheduledStartHour.toString()),
      _storage.write(
          key: _kScheduledStop, value: prefs.scheduledStopHour.toString()),
      _storage.write(key: _kPricePerKwh, value: prefs.pricePerKwh.toString()),
      _storage.write(key: _kPeakStart, value: prefs.peakStartHour.toString()),
      _storage.write(key: _kPeakStop, value: prefs.peakStopHour.toString()),
      _storage.write(
          key: _kPeakPrice, value: prefs.peakPricePerKwh.toString()),
    ]);
    state = AsyncData(prefs);
  }
}
