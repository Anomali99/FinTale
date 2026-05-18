import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  static final _auth = LocalAuthentication();
  static bool isAuthenticatingOS = false;

  static Future<bool> isBiometricSupported() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics && isSupported;
    } on PlatformException catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    isAuthenticatingOS = true;
    try {
      return await _auth.authenticate(
        localizedReason: 'Gunakan Sidik Jari atau PIN untuk konfirmasi',
        biometricOnly: false,
      );
    } on PlatformException catch (_) {
      return false;
    } finally {
      isAuthenticatingOS = false;
    }
  }

  static Future<bool> authenticateBiometricOnly() async {
    isAuthenticatingOS = true;
    try {
      return await _auth.authenticate(
        localizedReason: 'Gunakan Sidik Jari atau PIN untuk konfirmasi',
        biometricOnly: true,
      );
    } on PlatformException catch (_) {
      return false;
    } finally {
      isAuthenticatingOS = false;
    }
  }
}
