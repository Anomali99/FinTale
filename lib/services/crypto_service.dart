import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

class FintaleParseResult {
  final int version;

  final int mode;

  final Uint8List salt;

  final Uint8List iv;

  final Uint8List payload;

  const FintaleParseResult({
    required this.version,
    required this.mode,
    required this.salt,
    required this.iv,
    required this.payload,
  });
}

class CryptoService {
  CryptoService._();

  static const List<int> _magic = [0x46, 0x4E, 0x54, 0x4C];

  static const int _version = 1;

  static const int _headerSize = 38;

  static const int _pbkdf2Iterations = 100000;

  static const int _gcmTagBits = 128;

  static String get _appKey {
    final parts = <String>[
      'FnT',
      '4l3',
      '_S3',
      'cR3',
      't_K',
      '3y_',
      '2o2',
      '6',
    ];
    return parts.join();
  }

  static Uint8List buildFintaleFile({
    required String jsonString,
    required int mode,
    String? password,
  }) {
    assert(mode >= 0 && mode <= 2, 'mode must be 0, 1, or 2');
    if (mode == 2 && (password == null || password.isEmpty)) {
      throw ArgumentError('A password is required for mode 2 (user key).');
    }

    final Uint8List salt;
    final Uint8List iv;
    final Uint8List payload;

    if (mode == 0) {
      salt = Uint8List(16);
      iv = Uint8List(16);
      payload = _compress(jsonString);
    } else {
      final secureRandom = _secureRandom();
      salt = secureRandom.nextBytes(16);
      iv = secureRandom.nextBytes(16);

      final passphrase = mode == 1 ? _appKey : password!;
      final key = _deriveKey(passphrase, salt);
      final compressed = _compress(jsonString);
      payload = _aesGcmEncrypt(key, iv, compressed);
    }

    final builder = BytesBuilder(copy: false);
    builder.add(_magic);
    builder.addByte(_version);
    builder.addByte(mode);
    builder.add(salt);
    builder.add(iv);
    builder.add(payload);
    return builder.toBytes();
  }

  static FintaleParseResult parseFintaleFile(Uint8List fileBytes) {
    if (fileBytes.length < _headerSize) {
      throw const FormatException(
        'File is too small to be a valid .fintale file.',
      );
    }

    for (var i = 0; i < _magic.length; i++) {
      if (fileBytes[i] != _magic[i]) {
        throw const FormatException(
          'Invalid .fintale file: magic bytes do not match.',
        );
      }
    }

    final version = fileBytes[4];
    final mode = fileBytes[5];
    final salt = Uint8List.fromList(fileBytes.sublist(6, 22));
    final iv = Uint8List.fromList(fileBytes.sublist(22, 38));
    final payload = Uint8List.fromList(fileBytes.sublist(38));

    return FintaleParseResult(
      version: version,
      mode: mode,
      salt: salt,
      iv: iv,
      payload: payload,
    );
  }

  static String decryptPayload({
    required FintaleParseResult parsed,
    String? password,
  }) {
    if (parsed.mode == 0) {
      return _decompress(parsed.payload);
    }

    if (parsed.mode == 2 && (password == null || password.isEmpty)) {
      throw ArgumentError('A password is required to decrypt a mode-2 file.');
    }

    final passphrase = parsed.mode == 1 ? _appKey : password!;
    final key = _deriveKey(passphrase, parsed.salt);
    final decrypted = _aesGcmDecrypt(key, parsed.iv, parsed.payload);
    return _decompress(decrypted);
  }

  static Uint8List _deriveKey(String password, Uint8List salt) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, _pbkdf2Iterations, 32));
    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }

  static Uint8List _compress(String data) {
    final raw = utf8.encode(data);
    final compressed = GZipCodec().encode(raw);
    return Uint8List.fromList(compressed);
  }

  static String _decompress(Uint8List data) {
    final decompressed = GZipCodec().decode(data);
    return utf8.decode(decompressed);
  }

  static Uint8List _aesGcmEncrypt(
    Uint8List key,
    Uint8List iv,
    Uint8List plaintext,
  ) {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(KeyParameter(key), _gcmTagBits, iv, Uint8List(0)),
      );
    return cipher.process(plaintext);
  }

  static Uint8List _aesGcmDecrypt(
    Uint8List key,
    Uint8List iv,
    Uint8List ciphertext,
  ) {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(KeyParameter(key), _gcmTagBits, iv, Uint8List(0)),
      );
    return cipher.process(ciphertext);
  }

  static SecureRandom _secureRandom() {
    final seed = Uint8List(32);
    final dartRng = Random.secure();
    for (var i = 0; i < 32; i++) {
      seed[i] = dartRng.nextInt(256);
    }
    return FortunaRandom()..seed(KeyParameter(seed));
  }
}
