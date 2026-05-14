import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stellantis_mobile/core/logging/logger.dart';
import 'package:stellantis_mobile/stellantis/otp/iw_data.dart';
import 'package:stellantis_mobile/stellantis/otp/otp_crypto.dart';
import 'package:xml/xml.dart';

const _log = AppLogger('OtpService');

const _iwwsUrl = 'https://otp.mpsa.com/iwws/MAC';
const _iwwsVersion = 'Generator-1.0/0.2.11';
const _macId = 'bb8e981582b0f31353108fb020bead1c';
const _userAgent =
    'Dalvik/2.1.0 (Linux; U; Android 8.0.0; Android SDK built for x86_64 '
    'Build/OSR1.180418.004)';

const _otpOk = 0;
const _otpNok = -1;
const _otpTwice = 10;

final otpServiceProvider = Provider<OtpService>(
  (ref) => OtpService(const FlutterSecureStorage()),
);

/// Port of the Python inWebo OTP service.
///
/// - [activate]: initial device activation using an SMS code and PIN.
/// - [getOtpCode]: generates a fresh OTP for remote-access requests.
class OtpService {
  OtpService(this._storage);

  final FlutterSecureStorage _storage;

  IwData? _data;
  late String _iwalea;
  late String _deviceId;
  String _challenge = '';
  String _action = '';
  String? _smsCode;
  String? _codePin;
  String _defi = '';
  bool _initialized = false;

  final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Connection': 'Keep-Alive',
        'Host': 'otp.mpsa.com',
        'User-Agent': _userAgent,
      },
    ),
  );

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Activates the OTP device. Must be called once before [getOtpCode].
  Future<bool> activate(String smsCode, String codePin) async {
    _smsCode = smsCode;
    _codePin = codePin;

    final stored = await IwData.load(_storage, _newDeviceId());
    _data = stored ?? IwData.fromDefaultToken(_newDeviceId());
    _deviceId = _data!.deviceId;
    _iwalea = _randomHex(16);
    _initialized = false;

    try {
      if (!await _activationStart(activate: true)) return false;
      final result = await _activationFinalize(activate: true);
      if (result == _otpNok) return false;
      await _data!.persist(_storage);
      _initialized = true;
      return true;
    } catch (e, st) {
      _log.e('OTP activation failed', e, st);
      return false;
    }
  }

  /// Returns a fresh OTP code.
  Future<String?> getOtpCode() async {
    if (!_initialized) {
      final stored = await IwData.load(_storage, '');
      if (stored == null) {
        _log.e('OTP not activated — call activate() first');
        return null;
      }
      _data = stored;
      _deviceId = stored.deviceId;
      _iwalea = _randomHex(16);
      _initialized = true;
    }

    try {
      if (!await _activationStart(activate: false)) return null;
      var result = await _activationFinalize(activate: false);
      if (result == _otpNok) return null;
      if (result == _otpTwice) {
        if (!await _activationStart(activate: false)) return null;
        result = await _activationFinalize(activate: false);
        if (result != _otpOk) return null;
      }
      final code = _computeOtpCode();
      _log.d('OTP code generated');
      await _data!.persist(_storage);
      return code;
    } catch (e, st) {
      _log.e('OTP getOtpCode failed', e, st);
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Internal protocol
  // ---------------------------------------------------------------------------

  Future<bool> _activationStart({required bool activate}) async {
    final data = _data!;
    final mode = activate ? 'activate' : 'otp';

    final params = <String, String>{
      'action': 'ActionSetup',
      'mode': mode,
      'id': data.iwid,
      'lastsync': data.iwTsync.toString(),
      'version': _iwwsVersion,
      'macid': _macId,
      if (activate) 'code': _smsCode! else 'sid': data.iwSecId,
    };

    final xml = await _request(params, setup: true);
    if (xml['err'] != 'OK') {
      _log.e('ActionSetup failed: $xml');
      return false;
    }

    if (activate) {
      final kiwHex = xml['Kiw']!;
      final kfact = xml['Kfact']!;
      data.kfactKey = kfact;
      data.kiwKey = rsaOaepDecodeWithPublicKey(kiwHex, kfact);
    } else {
      _challenge = xml['challenge'] ?? '';
    }
    return true;
  }

  Future<int> _activationFinalize({
    required bool activate,
    Uint8List? randomBytes,
  }) async {
    final data = _data!;
    final mode = activate ? 'activate' : 'otp';
    final r = _computeR();

    final params = <String, String>{
      'action': 'ActionFinalize',
      'mode': mode,
      'id': data.iwid,
      'lastsync': data.iwTsync.toString(),
      'version': _iwwsVersion,
      'lang': 'fr',
      'ack': '',
      'macid': _macId,
      ...r,
    };

    if (activate) {
      final kmaHex = _generateKmaHex();
      final kmaBytes = hexToBytes(kmaHex);
      final kmaCrypt = rsaOaepEncrypt(kmaBytes, data.kiwKey);
      final pinCrypt = rsaOaepEncrypt(
        Uint8List.fromList(_codePin!.codeUnits),
        data.kiwKey,
      );
      params
        ..['serial'] = _getSerial()
        ..['code'] = _smsCode!
        ..['Kma'] = bytesToHex(kmaCrypt)
        ..['pin'] = bytesToHex(pinCrypt)
        ..['name'] = 'Android SDK built for x86_64 / UNKNOWN';
    } else {
      params
        ..['keytype'] = '0'
        ..['sid'] = data.iwSecId;
    }

    final xml = await _request(params, setup: false);
    if (xml['err'] != 'OK') {
      _log.e('ActionFinalize failed: $xml');
      return _otpNok;
    }

    data.synchro(xml, _generateKmaHex());

    if (!activate) {
      _defi = xml['defi'] ?? '';
      if (xml.containsKey('J')) return _otpTwice;
      return _otpOk;
    }

    final msN = xml['ms_n'];
    if (msN == null || msN == '0') return _otpOk;
    if (int.tryParse(msN) != 1) throw UnimplementedError('ms_n > 1');

    _challenge = xml['challenge'] ?? '';
    _action = 'synchro';

    final msKey = xml['ms_key']!;
    final tempModHex = rsaOaepDecodeWithPublicKey(msKey, data.kfactKey);
    final rb = randomBytes ?? _randomBytes(16);
    final kpubEncode = rsaOaepEncrypt(rb, tempModHex);
    final kmaHex = _generateKmaHex();
    data.iwSecVal = bytesToHex(aesEcbEncryptBytes(rb, kmaHex));
    data.iwSecId = xml['s_id'] ?? '';

    final msParams = <String, String>{
      'action': 'ActionFinalize',
      'mode': 'ms',
      'ms_id0': xml['ms_id'] ?? '',
      'ms_val0': bytesToHex(kpubEncode),
      'macid': _macId,
      'id': data.iwid,
      'lastsync': data.iwTsync.toString(),
      'ms_n': '1',
      ..._computeR(),
    };
    final xml2 = await _request(msParams, setup: false);
    data.synchro(xml2, kmaHex);
    return _otpOk;
  }

  Future<Map<String, String>> _request(
    Map<String, String> params, {
    required bool setup,
  }) async {
    final response = await _dio.get<String>(
      _iwwsUrl,
      queryParameters: params,
      options: Options(responseType: ResponseType.plain),
    );
    var body = response.data ?? '';
    final start = body.indexOf('?>');
    if (start >= 0) body = body.substring(start + 2);
    return _parseXml(body, setup: setup);
  }

  Map<String, String> _parseXml(String xmlStr, {required bool setup}) {
    final doc = XmlDocument.parse('<r>$xmlStr</r>');
    final root = setup
        ? doc.findAllElements('ActionSetup').firstOrNull
        : doc.findAllElements('ActionFinalize').firstOrNull;
    if (root == null) throw StateError('Bad OTP response: $xmlStr');
    final result = <String, String>{};
    for (final child in root.children.whereType<XmlElement>()) {
      result[child.name.local] = child.innerText;
    }
    for (final attr in root.attributes) {
      result[attr.name.local] = attr.value;
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Crypto helpers
  // ---------------------------------------------------------------------------

  String _getSerial() => '$_deviceId/_/$_iwalea';

  String _generateKmaHex() =>
      sha256Hex('$_codePin;${_getSerial()}').substring(0, 32);

  Map<String, String> _computeR() {
    final data = _data!;
    final iw = data.iwK0;
    final r2Base = '$_challenge;$iw;';
    return {
      'R0': sha256Hex('$r2Base${_getSerial()}'),
      'R1': sha256Hex('$r2Base${data.iwK1}'),
      'R2': sha256Hex(
        _action == 'synchro' ? '$r2Base$_codePin' : r2Base,
      ),
    };
  }

  String _computeOtpCode() {
    final data = _data!;
    final hashHex = sha256Hex('${data.iwK1}:$_defi:${data.iwSecVal}');
    final hashBytes = hexToBytes(hashHex.substring(0, 16));
    final nb = (_bytesToInt(hashBytes.sublist(0, 4)) & 0xfffffff) * 1024 +
        (_bytesToInt(hashBytes.sublist(4, 8)) & 1023);
    return _toBase36(nb);
  }

  // ---------------------------------------------------------------------------
  // Utilities
  // ---------------------------------------------------------------------------

  static const _base36 = 'abcdefghijklmnopqrstuvwxyz0123456789';

  static String _toBase36(int n) {
    if (n == 0) return '0';
    final buf = StringBuffer();
    var v = n;
    while (v > 0) {
      buf.write(_base36[v % 36]);
      v ~/= 36;
    }
    return buf.toString();
  }

  static String _newDeviceId() => _randomHex(8);

  static String _randomHex(int byteCount) {
    final rng = Random.secure();
    return List.generate(
      byteCount,
      (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  static Uint8List _randomBytes(int length) => Uint8List.fromList(
        List.generate(length, (_) => Random.secure().nextInt(256)),
      );

  static int _bytesToInt(Uint8List bytes) {
    var result = 0;
    for (final b in bytes) {
      result = (result << 8) | b;
    }
    return result;
  }
}
