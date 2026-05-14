import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stellantis_mobile/stellantis/otp/otp_crypto.dart';
import 'package:stellantis_mobile/stellantis/otp/otp_tokenizer.dart';

/// Default inWebo token string embedded in the PSA Android APK (v0.2.11).
const _defaultToken = '0.2.11&&&&&&0&&0&&0&&'
    '9f13ba238fbabba08e85d93638e98ef5e48682a9d3e5bc325c3dd6fac8199a6c'
    'e09e9b4f373aa6a75a905c3d690f6e3335d1e8e5b748ecec3020a794149033f6'
    'ada6896db6d73b8d43b8365bbe15b9ac66f49d4e684a3628f1e9f3deda0c4e24'
    'aba771946e6085b92c5ad312477152acf8db01e6aea4b409d5ac1a05c2fd4e95'
    '&&0&&&&&&&&&&&&0&&0&&0&&0&&0&&0&&0&&&&&&&&0&&0&&0&&0&&0'
    '&&2.0.0&&http://m.inwebo.com/&&';

const _kIwId = 'psa_otp_iwid';
const _kIwTsync = 'psa_otp_iwTsync';
const _kIwK0 = 'psa_otp_iwK0';
const _kIwK1 = 'psa_otp_iwK1';
const _kIwJ = 'psa_otp_iwJ';
const _kIwK = 'psa_otp_iwK';
const _kIwH = 'psa_otp_iwH';
const _kIwSecId = 'psa_otp_iwSecId';
const _kIwSecVal = 'psa_otp_iwSecVal';
const _kKiwKey = 'psa_otp_kiwKey';
const _kKfactKey = 'psa_otp_kfactKey';
const _kDeviceId = 'psa_otp_deviceId';

/// Mutable inWebo state parsed from the default token, mirroring Python IWData.
class IwData {
  IwData._({
    required this.iwid,
    required this.iwalea,
    required this.iwTsync,
    required this.iwK0,
    required this.iwK1,
    required this.iwJ,
    required this.iwK,
    required this.iwH,
    required this.iwSecId,
    required this.iwSecVal,
    required this.kiwKey,
    required this.kfactKey,
    required this.deviceId,
  });

  /// Parses [_defaultToken] and returns a fresh [IwData].
  factory IwData.fromDefaultToken(String deviceId) {
    final tok = OtpTokenizer(_defaultToken);
    tok.nextToken(); // version field
    final iwid = tok.nextToken();
    final iwalea = tok.nextToken();
    tok.nextTokenInt(); // iwblocked
    tok.nextTokenInt(); // iwhasnopin (version ≥ 519)
    final iwTsync = tok.nextTokenInt();
    tok.nextToken(); // kfact (overwritten after activation)
    tok.nextTokenInt(); // iwconnected
    tok.nextToken(); // iwserver
    final iwJ = tok.nextToken();
    final iwK = tok.nextToken();
    final iwK0 = tok.nextToken();
    final iwK1 = tok.nextToken();
    return IwData._(
      iwid: iwid,
      iwalea: iwalea,
      iwTsync: iwTsync,
      iwK0: iwK0,
      iwK1: iwK1,
      iwJ: iwJ,
      iwK: iwK,
      iwH: '',
      iwSecId: '',
      iwSecVal: '',
      kiwKey: '',
      kfactKey: '',
      deviceId: deviceId,
    );
  }

  String iwid;
  String iwalea;
  int iwTsync;
  String iwK0;
  String iwK1;
  String iwJ;
  String iwK;
  String iwH;
  String iwSecId;
  String iwSecVal;

  /// Decrypted inWebo public key modulus (hex), set after activation.
  String kiwKey;

  /// Key factor hex string from ActionSetup response.
  String kfactKey;

  /// Stable device identifier (persisted across sessions).
  String deviceId;

  /// Updates key material from an XML finalize/activate response map.
  void synchro(Map<String, String> xml, String kmaHex) {
    void decryptField(String? hexValue, void Function(String) setter) {
      if (hexValue != null && hexValue.isNotEmpty) {
        setter(aesEcbDecrypt(hexValue, kmaHex));
      }
    }

    final id = xml['id'];
    if (id != null && id.isNotEmpty) iwid = id;

    decryptField(xml['K0'], (v) => iwK0 = v);

    final k1 = xml['K1'];
    final dk1 = xml['dK1'];
    if (k1 != null && k1.isNotEmpty) {
      iwK1 = aesEcbDecrypt(k1, kmaHex);
    } else if (dk1 != null && dk1.isNotEmpty) {
      iwK1 = sha256Hex('$iwK1;$dk1').substring(0, 32);
    }

    final j = xml['J'];
    if (j != null && j.isNotEmpty) iwJ = j;

    final k = xml['K'];
    if (k != null && k.isNotEmpty) iwK = k;

    decryptField(xml['H'], (v) => iwH = v);

    final sId = xml['s_id'];
    if (sId != null && sId.isNotEmpty) iwSecId = sId;

    final tsync = xml['Tsync'];
    if (tsync != null && tsync.isNotEmpty) {
      iwTsync = int.tryParse(tsync) ?? iwTsync;
    }
  }

  Future<void> persist(FlutterSecureStorage storage) async {
    await Future.wait([
      storage.write(key: _kIwId, value: iwid),
      storage.write(key: _kIwTsync, value: iwTsync.toString()),
      storage.write(key: _kIwK0, value: iwK0),
      storage.write(key: _kIwK1, value: iwK1),
      storage.write(key: _kIwJ, value: iwJ),
      storage.write(key: _kIwK, value: iwK),
      storage.write(key: _kIwH, value: iwH),
      storage.write(key: _kIwSecId, value: iwSecId),
      storage.write(key: _kIwSecVal, value: iwSecVal),
      storage.write(key: _kKiwKey, value: kiwKey),
      storage.write(key: _kKfactKey, value: kfactKey),
      storage.write(key: _kDeviceId, value: deviceId),
    ]);
  }

  static Future<IwData?> load(
    FlutterSecureStorage storage,
    String deviceId,
  ) async {
    final values = await Future.wait([
      storage.read(key: _kIwId),
      storage.read(key: _kIwTsync),
      storage.read(key: _kIwK0),
      storage.read(key: _kIwK1),
      storage.read(key: _kIwJ),
      storage.read(key: _kIwK),
      storage.read(key: _kIwH),
      storage.read(key: _kIwSecId),
      storage.read(key: _kIwSecVal),
      storage.read(key: _kKiwKey),
      storage.read(key: _kKfactKey),
      storage.read(key: _kDeviceId),
    ]);

    if (values[0] == null) return null;

    return IwData._(
      iwid: values[0]!,
      iwalea: '',
      iwTsync: int.tryParse(values[1] ?? '0') ?? 0,
      iwK0: values[2] ?? '',
      iwK1: values[3] ?? '',
      iwJ: values[4] ?? '',
      iwK: values[5] ?? '',
      iwH: values[6] ?? '',
      iwSecId: values[7] ?? '',
      iwSecVal: values[8] ?? '',
      kiwKey: values[9] ?? '',
      kfactKey: values[10] ?? '',
      deviceId: values[11] ?? deviceId,
    );
  }

  String toJsonString() => jsonEncode({
        'iwid': iwid,
        'iwalea': iwalea,
        'iwTsync': iwTsync,
        'iwK0': iwK0,
        'iwK1': iwK1,
        'iwJ': iwJ,
        'iwK': iwK,
        'iwH': iwH,
        'iwSecId': iwSecId,
        'iwSecVal': iwSecVal,
        'kiwKey': kiwKey,
        'kfactKey': kfactKey,
        'deviceId': deviceId,
      });
}
