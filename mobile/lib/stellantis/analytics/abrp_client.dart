import 'package:dio/dio.dart';

const _abrpApiKey = '1e28ad14-df16-49f0-97da-364c9154b44a';
const _abrpUrl = 'https://api.iternio.com/1/tlm/send';
const _timeoutSeconds = 10;

/// Telemetry payload sent to A Better Route Planner.
///
/// All fields mirror the ABRP TLM API spec.
/// See: https://documenter.getpostman.com/view/7396339/SWTK5a8w
class AbrpTelemetry {
  const AbrpTelemetry({
    required this.utc,
    required this.soc,
    this.speed,
    this.carModel,
    this.current,
    this.isCharging,
    this.lat,
    this.lon,
    this.power,
    this.extTemp,
  });

  /// Unix timestamp of the telemetry sample.
  final int utc;

  /// State of charge in percent (0–100).
  final double soc;

  /// Vehicle speed in km/h, null if unavailable.
  final double? speed;

  /// ABRP car model string (e.g. `"peugeot:e208:20:50"`).
  final String? carModel;

  /// Battery current in amperes, null if unavailable.
  final double? current;

  /// True when the vehicle is actively charging.
  final bool? isCharging;

  final double? lat;
  final double? lon;

  /// Power draw in kW (positive = consuming, negative = regen).
  final double? power;

  /// External / ambient temperature in °C.
  final double? extTemp;

  Map<String, Object?> toMap() => {
        'utc': utc,
        'soc': soc,
        if (speed != null) 'speed': speed,
        if (carModel != null) 'car_model': carModel,
        if (current != null) 'current': current,
        if (isCharging != null) 'is_charging': isCharging,
        if (lat != null) 'lat': lat,
        if (lon != null) 'lon': lon,
        if (power != null) 'power': power,
        if (extTemp != null) 'ext_temp': extTemp,
      };
}

/// Sends live telemetry to A Better Route Planner.
///
/// Port of Python `Abrp` (psacc/application/abrp.py).
/// Only VINs added via [enableAbrp] will transmit data.
class AbrpClient {
  AbrpClient({
    required this.dio,
    required this.token,
  });

  final Dio dio;

  /// ABRP user token. Telemetry is silently dropped when empty.
  final String token;

  final _enabledVins = <String>{};

  /// Enables or disables telemetry forwarding for [vin].
  void enableAbrp(String vin, {required bool enable}) {
    if (enable) {
      _enabledVins.add(vin);
    } else {
      _enabledVins.remove(vin);
    }
  }

  bool isEnabled(String vin) => _enabledVins.contains(vin);

  /// Sends [telemetry] for [vin] to the ABRP API.
  ///
  /// Returns true when the API responds with `{"status": "ok"}`.
  /// Returns false silently when the token is empty, the VIN is not
  /// enabled, or the request fails.
  Future<bool> send(String vin, AbrpTelemetry telemetry) async {
    if (token.isEmpty || !_enabledVins.contains(vin)) return false;
    try {
      final resp = await dio.post<Map<String, dynamic>>(
        _abrpUrl,
        queryParameters: {
          'tlm': _encodeMap(telemetry.toMap()),
          'token': token,
          'api_key': _abrpApiKey,
        },
        options: Options(
          sendTimeout: const Duration(seconds: _timeoutSeconds),
          receiveTimeout: const Duration(seconds: _timeoutSeconds),
        ),
      );
      final status = resp.data?['status'];
      return status is String && status == 'ok';
    } on DioException {
      return false;
    }
  }

  static String _encodeMap(Map<String, Object?> map) {
    final buf = StringBuffer('{');
    var first = true;
    map.forEach((k, v) {
      if (!first) buf.write(',');
      first = false;
      buf.write('"$k":');
      if (v is String) {
        buf.write('"$v"');
      } else {
        buf.write(v);
      }
    });
    buf.write('}');
    return buf.toString();
  }
}
