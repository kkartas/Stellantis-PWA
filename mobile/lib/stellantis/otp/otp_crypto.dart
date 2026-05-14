import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/ecb.dart';
import 'package:pointycastle/pointycastle.dart';

/// RSA public exponent used by the inWebo OTP system (0x11 = 17).
final _e = BigInt.from(0x11);

/// Block size for RSA operations in this protocol.
const _rsaBlockSize = 128;

/// SHA-256 output length in bytes.
const _hLen = 32;

// ---------------------------------------------------------------------------
// Low-level RSA + OAEP
// ---------------------------------------------------------------------------

/// Converts a [Uint8List] to a non-negative [BigInt] (big-endian).
BigInt _bytesToBigInt(Uint8List bytes) {
  var result = BigInt.zero;
  for (final b in bytes) {
    result = (result << 8) | BigInt.from(b);
  }
  return result;
}

/// Converts [value] to a big-endian [Uint8List] of exactly [length] bytes.
Uint8List _bigIntToBytes(BigInt value, int length) {
  final bytes = Uint8List(length);
  var v = value;
  for (var i = length - 1; i >= 0; i--) {
    bytes[i] = (v & BigInt.from(0xFF)).toInt();
    v >>= 8;
  }
  return bytes;
}

Uint8List _xor(Uint8List a, Uint8List b) {
  final out = Uint8List(a.length);
  for (var i = 0; i < a.length; i++) {
    out[i] = a[i] ^ b[i];
  }
  return out;
}

/// MGF1 mask-generation function with SHA-256.
Uint8List _mgf1(Uint8List seed, int maskLen) {
  final t = BytesBuilder();
  final rounds = (maskLen / _hLen).ceil();
  for (var i = 0; i < rounds; i++) {
    final counter = Uint8List(4)
      ..[0] = (i >> 24) & 0xFF
      ..[1] = (i >> 16) & 0xFF
      ..[2] = (i >> 8) & 0xFF
      ..[3] = i & 0xFF;
    t.add(sha256.convert([...seed, ...counter]).bytes);
  }
  return Uint8List.fromList(t.toBytes().sublist(0, maskLen));
}

/// OAEP-SHA256 pad [message] to [k] bytes.
/// RFC 3447 §7.1.1, label = ''.
Uint8List _oaepPad(Uint8List message, int k) {
  final lHash = Uint8List.fromList(sha256.convert(const <int>[]).bytes);
  final mLen = message.length;
  if (mLen > k - 2 * _hLen - 2) {
    throw ArgumentError('OAEP: message too long');
  }
  final psLen = k - mLen - 2 * _hLen - 2;
  final db = Uint8List(k - _hLen - 1)
    ..setRange(0, _hLen, lHash)
    ..setRange(_hLen + psLen, _hLen + psLen + 1, [0x01])
    ..setRange(_hLen + psLen + 1, k - _hLen - 1, message);

  final rng = Random.secure();
  final seed = Uint8List.fromList(
    List.generate(_hLen, (_) => rng.nextInt(256)),
  );
  final dbMask = _mgf1(seed, k - _hLen - 1);
  final maskedDb = _xor(db, dbMask);
  final seedMask = _mgf1(maskedDb, _hLen);
  final maskedSeed = _xor(seed, seedMask);

  return Uint8List(k)
    ..[0] = 0x00
    ..setRange(1, 1 + _hLen, maskedSeed)
    ..setRange(1 + _hLen, k, maskedDb);
}

/// OAEP-SHA256 unpad [em] (k bytes), returning the embedded message.
Uint8List _oaepUnpad(Uint8List em) {
  final k = em.length;
  final maskedSeed = em.sublist(1, _hLen + 1);
  final maskedDb = em.sublist(_hLen + 1);
  final seedMask = _mgf1(maskedDb, _hLen);
  final seed = _xor(maskedSeed, seedMask);
  final dbMask = _mgf1(seed, k - _hLen - 1);
  final db = _xor(maskedDb, dbMask);
  final onePos = db.sublist(_hLen).indexOf(0x01);
  if (onePos < 0) throw ArgumentError('OAEP unpad: no 0x01 separator');
  return db.sublist(_hLen + onePos + 1);
}

// ---------------------------------------------------------------------------
// Public cryptographic helpers
// ---------------------------------------------------------------------------

/// Decrypts [encHex] (hex) using RSA public key [modulusHex].
///
/// The inWebo server signs key material with its private key; clients recover
/// it by applying `c^e mod n` (public exponent) then OAEP-SHA256 unpadding.
/// Processes [encHex] in [_rsaBlockSize]-byte chunks.
String rsaOaepDecodeWithPublicKey(String encHex, String modulusHex) {
  final modulus = BigInt.parse(modulusHex, radix: 16);
  final encBytes = hexToBytes(encHex);
  final buf = StringBuffer();
  final blockCount = (encBytes.length / _rsaBlockSize).ceil();
  for (var x = 0; x < blockCount; x++) {
    final mini = x * _rsaBlockSize;
    final maxi = (x == blockCount - 1) ? encBytes.length : mini + _rsaBlockSize;
    final block = encBytes.sublist(mini, maxi);
    final ct = _bytesToBigInt(block);
    final pt = ct.modPow(_e, modulus);
    final ptBytes = _bigIntToBytes(pt, _rsaBlockSize);
    buf.write(bytesToHex(_oaepUnpad(ptBytes)));
  }
  return buf.toString();
}

/// Encrypts [plaintext] using RSA public key [modulusHex] with OAEP-SHA256.
/// Uses `m^e mod n` (standard public-key encryption, RFC 3447 §7.1.1).
Uint8List rsaOaepEncrypt(Uint8List plaintext, String modulusHex) {
  final modulus = BigInt.parse(modulusHex, radix: 16);
  const k = _rsaBlockSize;
  final padded = _oaepPad(plaintext, k);
  final pt = _bytesToBigInt(padded);
  final ct = pt.modPow(_e, modulus);
  return _bigIntToBytes(ct, k);
}

/// AES-128 ECB decrypt of [cipherHex] using [keyHex], returned as hex.
String aesEcbDecrypt(String cipherHex, String keyHex) {
  final cipher = ECBBlockCipher(AESEngine())
    ..init(false, KeyParameter(hexToBytes(keyHex)));
  final input = hexToBytes(cipherHex);
  final output = Uint8List(input.length);
  for (var i = 0; i < input.length; i += 16) {
    cipher.processBlock(input, i, output, i);
  }
  return bytesToHex(output);
}

/// AES-128 ECB encrypt of [plaintext] bytes using [keyHex].
Uint8List aesEcbEncryptBytes(Uint8List plaintext, String keyHex) {
  final cipher = ECBBlockCipher(AESEngine())
    ..init(true, KeyParameter(hexToBytes(keyHex)));
  final output = Uint8List(plaintext.length);
  for (var i = 0; i < plaintext.length; i += 16) {
    cipher.processBlock(plaintext, i, output, i);
  }
  return output;
}

/// SHA-256 of a UTF-8 [input], returned as a lowercase hex string.
String sha256Hex(String input) =>
    sha256.convert(utf8.encode(input)).bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

Uint8List hexToBytes(String hex) {
  final out = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return out;
}

String bytesToHex(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
