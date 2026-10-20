import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class HashHelper {
  static String hashPin(String pin, {String? customSalt}) {
    final String salt;
    if (customSalt != null) {
      salt = customSalt;
    } else {
      final random = Random.secure();
      final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
      salt = saltBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    }

    final bytes = utf8.encode('$salt:$pin');
    // Multiple rounds to strengthen against brute-force attacks
    Digest digest = sha256.convert(bytes);
    for (int i = 0; i < 1000; i++) {
      digest = sha256.convert(digest.bytes + bytes);
    }

    return '$salt:${digest.toString()}';
  }

  static bool verifyPin(String plainPin, String hashedPin) {
    // Backward compatibility with legacy unsalted SHA-256
    if (!hashedPin.contains(':')) {
      final legacyHash = sha256.convert(utf8.encode(plainPin)).toString();
      return _constantTimeEquals(legacyHash, hashedPin);
    }

    final parts = hashedPin.split(':');
    if (parts.length != 2) return false;
    final salt = parts[0];
    final expectedHash = parts[1];

    final bytes = utf8.encode('$salt:$plainPin');
    Digest digest = sha256.convert(bytes);
    for (int i = 0; i < 1000; i++) {
      digest = sha256.convert(digest.bytes + bytes);
    }

    return _constantTimeEquals(digest.toString(), expectedHash);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
