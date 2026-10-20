import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

// ---------------------------------------------------------------------------
// FintaleParseResult — holds parsed header fields + raw payload from a
// .fintale backup file.
// ---------------------------------------------------------------------------

/// Parsed representation of a .fintale file header and its payload.
class FintaleParseResult {
  /// File format version (currently 1).
  final int version;

  /// Encryption mode: 0 = raw (gzip only), 1 = app key, 2 = user key.
  final int mode;

  /// PBKDF2 salt used during key derivation (16 bytes, zeroed when mode == 0).
  final Uint8List salt;

  /// AES-GCM initialisation vector (16 bytes, zeroed when mode == 0).
  final Uint8List iv;

  /// The encrypted (or just compressed, when mode == 0) data payload.
  final Uint8List payload;

  const FintaleParseResult({
    required this.version,
    required this.mode,
    required this.salt,
    required this.iv,
    required this.payload,
  });
}

// ---------------------------------------------------------------------------
// CryptoService — builds, parses, and decrypts .fintale backup files.
//
// File layout (binary):
//   [0..3]   Magic bytes  'FNTL'              (4 bytes)
//   [4]      Version      uint8  (currently 1) (1 byte)
//   [5]      Mode         uint8  0|1|2          (1 byte)
//   [6..21]  Salt         16 bytes (zeroes if mode == 0)
//   [22..37] IV           16 bytes (zeroes if mode == 0)
//   [38..]   Payload      compressed (mode 0) or encrypted blob
// ---------------------------------------------------------------------------

class CryptoService {
  CryptoService._(); // non-instantiable utility class

  // ---- constants ----------------------------------------------------------

  /// Magic bytes identifying a .fintale file.
  static const List<int> _magic = [0x46, 0x4E, 0x54, 0x4C]; // 'FNTL'

  /// Current file-format version.
  static const int _version = 1;

  /// Header size in bytes: magic(4) + version(1) + mode(1) + salt(16) + iv(16).
  static const int _headerSize = 38;

  /// PBKDF2 iteration count – balances security with mobile performance.
  static const int _pbkdf2Iterations = 100000;

  /// AES-GCM authentication tag length in bits.
  static const int _gcmTagBits = 128;

  // ---- obfuscated app key -------------------------------------------------

  /// Returns the application-level encryption passphrase.
  ///
  /// The key is split into fragments so it never appears as a single plaintext
  /// string in the compiled binary.
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

  // ---- public API ---------------------------------------------------------

  /// Builds a complete .fintale file from a JSON string.
  ///
  /// [mode] determines the protection level:
  ///   * `0` – gzip compression only (no encryption).
  ///   * `1` – AES-256-GCM encryption using the built-in app key.
  ///   * `2` – AES-256-GCM encryption using a user-supplied [password].
  ///
  /// Returns the raw bytes ready to be written to a file.
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
      // Raw mode – gzip only, no encryption.
      salt = Uint8List(16); // all zeroes
      iv = Uint8List(16); // all zeroes
      payload = _compress(jsonString);
    } else {
      // Encrypted modes (1 = app key, 2 = user key).
      final secureRandom = _secureRandom();
      salt = secureRandom.nextBytes(16);
      iv = secureRandom.nextBytes(16);

      final passphrase = mode == 1 ? _appKey : password!;
      final key = _deriveKey(passphrase, salt);
      final compressed = _compress(jsonString);
      payload = _aesGcmEncrypt(key, iv, compressed);
    }

    // Assemble header + payload.
    final builder = BytesBuilder(copy: false);
    builder.add(_magic);
    builder.addByte(_version);
    builder.addByte(mode);
    builder.add(salt);
    builder.add(iv);
    builder.add(payload);
    return builder.toBytes();
  }

  /// Parses a .fintale file into its constituent header fields and payload.
  ///
  /// Throws [FormatException] if the magic bytes do not match.
  static FintaleParseResult parseFintaleFile(Uint8List fileBytes) {
    if (fileBytes.length < _headerSize) {
      throw const FormatException(
        'File is too small to be a valid .fintale file.',
      );
    }

    // Validate magic bytes.
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

  /// Decrypts (and decompresses) the payload from a parsed .fintale file.
  ///
  /// For mode 0 the payload is simply gzip-decompressed.
  /// For mode 1 the built-in app key is used.
  /// For mode 2 a user-supplied [password] is required.
  ///
  /// Throws [ArgumentError] when mode 2 is used without a password.
  /// Throws on decryption failure (e.g. wrong password – GCM auth tag check).
  static String decryptPayload({
    required FintaleParseResult parsed,
    String? password,
  }) {
    if (parsed.mode == 0) {
      // No encryption – just decompress.
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

  // ---- private helpers ----------------------------------------------------

  /// Derives a 256-bit AES key from [password] and [salt] using PBKDF2-HMAC-SHA256.
  static Uint8List _deriveKey(String password, Uint8List salt) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, _pbkdf2Iterations, 32));
    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }

  /// Gzip-compresses a UTF-8 string.
  static Uint8List _compress(String data) {
    final raw = utf8.encode(data);
    final compressed = GZipCodec().encode(raw);
    return Uint8List.fromList(compressed);
  }

  /// Gzip-decompresses bytes back to a UTF-8 string.
  static String _decompress(Uint8List data) {
    final decompressed = GZipCodec().decode(data);
    return utf8.decode(decompressed);
  }

  /// Encrypts [plaintext] with AES-256-GCM.
  ///
  /// The returned bytes contain the ciphertext followed by the 16-byte
  /// authentication tag (appended automatically by PointyCastle).
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

  /// Decrypts [ciphertext] (with appended GCM tag) using AES-256-GCM.
  ///
  /// Throws [InvalidCipherTextException] if the authentication tag is invalid
  /// (e.g. wrong key / tampered data).
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

  /// Returns a cryptographically secure random number generator seeded from
  /// [Random.secure].
  static SecureRandom _secureRandom() {
    final seed = Uint8List(32);
    final dartRng = Random.secure();
    for (var i = 0; i < 32; i++) {
      seed[i] = dartRng.nextInt(256);
    }
    return FortunaRandom()..seed(KeyParameter(seed));
  }
}
