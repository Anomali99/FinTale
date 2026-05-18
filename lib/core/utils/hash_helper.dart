import 'dart:convert';

import 'package:crypto/crypto.dart';

class HashHelper {
  static String hashPin(String pin) {
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPin(String plainPin, String hashedPin) {
    String inputHash = hashPin(plainPin);

    return inputHash == hashedPin;
  }
}
