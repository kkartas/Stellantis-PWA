import 'dart:convert';
import 'dart:math';

const _mqttReqTopic = 'psa/RemoteServices/from/cid/';
const _expirationSeconds = 30;

/// Builds and serialises an MQTT command payload for the PSA remote service.
///
/// Port of Python `mqtt_request.py` / `MQTTRequest`.
class MqttRequest {
  MqttRequest({
    required String commandPath,
    required this.vin,
    required this.reqParameters,
    required this.customerId,
  })  : topic = '$_mqttReqTopic$customerId$commandPath',
        _createdAt = DateTime.now();

  final String topic;
  final String vin;
  final Map<String, Object> reqParameters;
  final String customerId;
  final DateTime _createdAt;

  bool get isExpired =>
      DateTime.now().difference(_createdAt).inSeconds > _expirationSeconds;

  String toJson(String accessToken) =>
      jsonEncode(_buildMessage(accessToken));

  Map<String, Object> _buildMessage(String accessToken) {
    final now = DateTime.now().toUtc();
    return {
      'access_token': accessToken,
      'customer_id': customerId,
      'correlation_id': _genCorrelationId(now),
      'req_date': _formatPsaDate(now),
      'vin': vin,
      'req_parameters': reqParameters,
    };
  }

  static String _formatPsaDate(DateTime dt) =>
      '${_p4(dt.year)}-${_p2(dt.month)}-${_p2(dt.day)}'
      'T${_p2(dt.hour)}:${_p2(dt.minute)}:${_p2(dt.second)}Z';

  static String _genCorrelationId(DateTime dt) {
    final ms = dt.millisecond.toString().padLeft(3, '0');
    final dateStr =
        '${_p4(dt.year)}${_p2(dt.month)}${_p2(dt.day)}'
        '${_p2(dt.hour)}${_p2(dt.minute)}${_p2(dt.second)}$ms';
    return '${_randomUuidNoDashes()}$dateStr';
  }

  static String _randomUuidNoDashes() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static String _p2(int v) => v.toString().padLeft(2, '0');
  static String _p4(int v) => v.toString().padLeft(4, '0');

  @override
  String toString() => 'topic: $topic params: $reqParameters';
}
