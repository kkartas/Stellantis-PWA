import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:stellantis_mobile/core/logging/logger.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';
import 'package:stellantis_mobile/stellantis/mqtt/mqtt_request.dart';
import 'package:stellantis_mobile/stellantis/mqtt/remote_credentials.dart';
import 'package:stellantis_mobile/stellantis/network/psa_http_client.dart';
import 'package:stellantis_mobile/stellantis/otp/otp_service.dart';

const _log = AppLogger('MqttClientService');

const _mqttRespTopic = 'psa/RemoteServices/to/cid/';
const _mqttEventTopic = 'psa/RemoteServices/events/MPHRTServices/';
const _remoteTokenPath = '/virtualkey/remoteaccess/token';
const _otpSmsUrl =
    'https://api.groupe-psa.com/applications/cvs/v4/mobile/smsCode';

/// Default preconditioning schedule (all programs off) — mirrors Python const.
const _defaultPrecondPrograms = <String, Object>{
  'program1': <String, Object>{
    'day': <int>[0, 0, 0, 0, 0, 0, 0],
    'hour': 34,
    'minute': 7,
    'on': 0,
  },
  'program2': <String, Object>{
    'day': <int>[0, 0, 0, 0, 0, 0, 0],
    'hour': 34,
    'minute': 7,
    'on': 0,
  },
  'program3': <String, Object>{
    'day': <int>[0, 0, 0, 0, 0, 0, 0],
    'hour': 34,
    'minute': 7,
    'on': 0,
  },
  'program4': <String, Object>{
    'day': <int>[0, 0, 0, 0, 0, 0, 0],
    'hour': 34,
    'minute': 7,
    'on': 0,
  },
};

final mqttClientServiceProvider = Provider<MqttClientService>((ref) {
  return MqttClientService(
    otpService: ref.watch(otpServiceProvider),
    storage: const FlutterSecureStorage(),
    dio: ref.watch(psaHttpClientProvider),
  );
});

/// Port of Python `RemoteClient` — manages MQTT connection and remote commands.
class MqttClientService {
  MqttClientService({
    required OtpService otpService,
    required FlutterSecureStorage storage,
    required Dio dio,
  })  : _otpService = otpService,
        _storage = storage,
        _dio = dio;

  final OtpService _otpService;
  final FlutterSecureStorage _storage;
  final Dio _dio;

  MqttServerClient? _client;
  RemoteCredentials? _credentials;
  MqttRequest? _lastRequest;
  String _mqttCustomerId = '';
  String _clientId = '';
  String _realm = '';
  final Map<String, Map<String, Object>> _precondPrograms = {};

  String? lastErrorCode;
  String? lastError;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Connects to the PSA MQTT broker and subscribes to response/event topics.
  Future<bool> connect({
    required String clientId,
    required String realm,
    required String customerId,
    required List<String> vins,
  }) async {
    _clientId = clientId;
    _realm = realm;
    _mqttCustomerId = _getMqttCustomerId(customerId);
    _credentials = await RemoteCredentials.load(_storage);
    lastErrorCode = null;
    lastError = null;

    if (!await _refreshRemoteToken()) return false;

    final mqttClientId =
        'flutter-${DateTime.now().millisecondsSinceEpoch}';
    final mqttClient = MqttServerClient.withPort(
      BrandConstants.mqttHost,
      mqttClientId,
      BrandConstants.mqttPort,
    );
    mqttClient.secure = true;
    mqttClient.keepAlivePeriod = 60;
    mqttClient.autoReconnect = false;
    mqttClient.onDisconnected = _onDisconnected;

    final connMsg = MqttConnectMessage()
        .withClientIdentifier(mqttClientId)
        .startClean();
    mqttClient.connectionMessage = connMsg;

    try {
      await mqttClient.connect(
        'IMA_OAUTH_ACCESS_TOKEN',
        _credentials!.accessToken,
      );
    } on Exception catch (e, st) {
      _log.e('MQTT connect threw', e, st);
      _setError('mqtt_connect', 'MQTT connection failed: $e');
      return false;
    }

    final status = mqttClient.connectionStatus;
    if (status?.state != MqttConnectionState.connected) {
      final code = status?.returnCode;
      if (code == MqttConnectReturnCode.notAuthorized) {
        _setError(
          'mqtt_forbidden',
          'Remote broker refused connection (not authorized). '
          'Please redo OTP setup.',
        );
      } else {
        _setError('mqtt_connect', 'MQTT connect failed: $code');
      }
      return false;
    }

    mqttClient.subscribe(
      '$_mqttRespTopic$_mqttCustomerId/#',
      MqttQos.atMostOnce,
    );
    for (final vin in vins) {
      mqttClient.subscribe(
        '$_mqttEventTopic$vin',
        MqttQos.atMostOnce,
      );
    }
    mqttClient.updates!.listen(_onMessages);
    _client = mqttClient;
    return true;
  }

  /// Disconnects from the MQTT broker.
  void disconnect() {
    _client?.onDisconnected = null;
    _client?.disconnect();
    _client = null;
  }

  /// Publishes [request] to the MQTT broker after refreshing the remote token.
  Future<void> publish(MqttRequest request, {bool store = true}) async {
    await _refreshRemoteToken();
    final token = _credentials?.accessToken;
    if (token == null || _client == null) return;
    final payload = request.toJson(token);
    final builder = MqttClientPayloadBuilder()..addString(payload);
    _client!.publishMessage(
      request.topic,
      MqttQos.exactlyOnce,
      builder.payload!,
    );
    if (store) _lastRequest = request;
  }

  /// Triggers an SMS OTP for the current [_clientId].
  Future<bool> requestOtpSms() async {
    try {
      await _dio.post<void>(
        _otpSmsUrl,
        queryParameters: {'client_id': _clientId},
        options: Options(
          headers: {'x-introspect-realm': _realm},
        ),
      );
      return true;
    } on DioException catch (e, st) {
      _log.e('SMS OTP request failed', e, st);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Remote commands
  // ---------------------------------------------------------------------------

  Future<void> horn(String vin) => publish(
        _buildRequest(vin, {'nb_horn': 1, 'action': 'activate'}, '/Horn'),
      );

  Future<void> lights(String vin) => publish(
        _buildRequest(
          vin,
          {'action': 'activate', 'duration': 10},
          '/Lights',
        ),
      );

  Future<void> wakeup(String vin) => publish(
        _buildRequest(vin, {'action': 'state'}, '/VehCharge/state'),
      );

  Future<void> lockDoor(String vin, {required bool lock}) => publish(
        _buildRequest(
          vin,
          {'action': lock ? 'lock' : 'unlock'},
          '/Doors',
        ),
      );

  Future<void> preconditioning(String vin, {required bool activate}) =>
      publish(
        _buildRequest(
          vin,
          {
            'asap': activate ? 'activate' : 'deactivate',
            'programs': _precondPrograms[vin] ?? _defaultPrecondPrograms,
          },
          '/ThermalPrecond',
        ),
      );

  Future<void> vehChargeRequest(
    String vin, {
    required int hour,
    required int minute,
    required String chargeType,
  }) =>
      publish(
        _buildRequest(
          vin,
          {
            'program': <String, Object>{'hour': hour, 'minute': minute},
            'type': chargeType,
          },
          '/VehCharge',
        ),
      );

  Future<void> chargeNow(String vin, {required bool now}) =>
      vehChargeRequest(
        vin,
        hour: 0,
        minute: 0,
        chargeType: now ? 'immediate' : 'delayed',
      );

  Future<void> changeChargeHour(
    String vin, {
    required int hour,
    required int minute,
  }) =>
      vehChargeRequest(
        vin,
        hour: hour,
        minute: minute,
        chargeType: 'delayed',
      );

  // ---------------------------------------------------------------------------
  // Internal MQTT callbacks
  // ---------------------------------------------------------------------------

  void _onDisconnected() {
    _log.w('MQTT disconnected');
  }

  void _onMessages(List<MqttReceivedMessage<MqttMessage?>> messages) {
    for (final msg in messages) {
      final pub = msg.payload;
      if (pub is! MqttPublishMessage) continue;
      final payload = MqttPublishPayload.bytesToStringAsString(
        pub.payload.message,
      );
      _handleMessage(msg.topic, payload);
    }
  }

  void _handleMessage(String topic, String payload) {
    _log.d('MQTT: $topic');
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (topic.startsWith(_mqttRespTopic)) {
        _handleResponseMessage(data);
      } else if (topic.startsWith(_mqttEventTopic)) {
        _handleEventMessage(data);
      }
    } on FormatException catch (e) {
      _log.e('Failed to parse MQTT payload', e);
    }
  }

  void _handleResponseMessage(Map<String, dynamic> data) {
    final returnCode = data['return_code'] as String?;
    if (returnCode == null) return;
    if (returnCode == '400') {
      _refreshRemoteToken(force: true).then((_) {
        final last = _lastRequest;
        if (last != null && !last.isExpired) {
          _lastRequest = null;
          publish(last, store: false);
        }
      });
    } else if (returnCode != '0') {
      final reason = data['reason'] as String? ?? 'unknown';
      _log.e('MQTT command failed ($returnCode): $reason');
    }
  }

  void _handleEventMessage(Map<String, dynamic> data) {
    final vin = data['vin'] as String?;
    final precondState =
        data['precond_state'] as Map<String, dynamic>?;
    final programs = precondState?['programs'] as Map<String, dynamic>?;
    if (vin != null && programs != null) {
      _precondPrograms[vin] = programs.cast<String, Object>();
    }
  }

  // ---------------------------------------------------------------------------
  // Remote token management
  // ---------------------------------------------------------------------------

  Future<bool> _refreshRemoteToken({bool force = false}) async {
    final creds = _credentials;
    if (creds == null) return false;

    if (!force && creds.accessToken != null) {
      final age =
          DateTime.now().difference(creds.lastUpdate).inSeconds;
      if (age < BrandConstants.mqttTokenTtlSeconds) return true;
    }

    try {
      if (creds.refreshToken != null) {
        if (await _tryRefreshGrant(creds)) return true;
      }
      final otp = await _otpService.getOtpCode();
      if (otp == null) {
        _setError('otp_missing', 'OTP not configured; redo OTP setup.');
        return false;
      }
      return _tryPasswordGrant(creds, otp);
    } on DioException catch (e, st) {
      _log.e('Remote token refresh failed', e, st);
      _setError('network', 'Network error refreshing remote token.');
      return false;
    }
  }

  Future<bool> _tryRefreshGrant(RemoteCredentials creds) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _remoteTokenPath,
      queryParameters: {'client_id': _clientId},
      data: {
        'grant_type': 'refresh_token',
        'refresh_token': creds.refreshToken,
      },
      options: Options(
        headers: {'x-introspect-realm': _realm},
      ),
    );
    final data = response.data;
    if (data == null) return false;
    final at = data['access_token'] as String?;
    if (at == null) return false;
    creds.accessToken = at;
    final rt = data['refresh_token'] as String?;
    if (rt != null) creds.refreshToken = rt;
    creds.markUpdated();
    await creds.persist(_storage);
    return true;
  }

  Future<bool> _tryPasswordGrant(
    RemoteCredentials creds,
    String otpCode,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _remoteTokenPath,
      queryParameters: {'client_id': _clientId},
      data: {'grant_type': 'password', 'password': otpCode},
      options: Options(
        headers: {'x-introspect-realm': _realm},
      ),
    );
    final data = response.data;
    if (data == null) {
      _setError('remote_token', 'Empty response from remote token endpoint.');
      return false;
    }
    final at = data['access_token'] as String?;
    if (at == null) {
      final error = data['error'] as String?;
      if (error == 'invalid_grant') {
        _setError(
          'otp_expired',
          'Remote session expired. Please redo OTP setup.',
        );
      } else {
        _setError('remote_token', 'Remote token grant failed.');
      }
      return false;
    }
    creds.accessToken = at;
    creds.refreshToken = data['refresh_token'] as String?;
    creds.markUpdated();
    await creds.persist(_storage);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  MqttRequest _buildRequest(
    String vin,
    Map<String, Object> params,
    String commandPath,
  ) =>
      MqttRequest(
        commandPath: commandPath,
        vin: vin,
        reqParameters: params,
        customerId: _mqttCustomerId,
      );

  void _setError(String code, String message) {
    lastErrorCode = code;
    lastError = message;
    _log.e('$code: $message');
  }

  /// Maps raw customer ID prefix to MQTT broker partition prefix.
  static String _getMqttCustomerId(String customerId) {
    if (customerId.length < 2) return customerId;
    const mapping = <String, String>{
      'AP': 'AP',
      'AC': 'AC',
      'DS': 'AC',
      'VX': 'OV',
      'OP': 'OV',
    };
    final code = customerId.substring(0, 2);
    return '${mapping[code] ?? code}${customerId.substring(2)}';
  }
}
