import 'package:flutter/material.dart';

import '../data/local/pref_service.dart';
import '../services/auth_service.dart';

class SettingsController with ChangeNotifier {
  final AuthService _authService;
  final PrefService _prefService;

  SettingsController(this._authService, this._prefService);

  bool get isHideBalance => _prefService.isHideBalance;
  bool get isAppLock => _prefService.isAppLock;
  bool get isRpgMode => _prefService.isRpgMode;
  bool get isNotification => _prefService.isNotification;
  String get themeMode => _prefService.themeMode;

  Future<void> changeHideBalance(bool value) async {
    await _prefService.setHideBalance(value);
    notifyListeners();
  }

  Future<void> changeAppLock(bool value) async {
    await _prefService.setAppLock(value);
    notifyListeners();
  }

  Future<void> changeRpgMode(bool value) async {
    await _prefService.setRpgMode(value);
    notifyListeners();
  }

  Future<void> changeNotification(bool value) async {
    await _prefService.setNotification(value);
    notifyListeners();
  }

  Future<void> changeThemeMode(String? value) async {
    if (value != null) {
      await _prefService.setThemeMode(value);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> handleSignOut() async {
    try {
      await _authService.signOut();
      return {"success": true};
    } catch (e) {
      return {"success": false, "error": e};
    }
  }
}
