import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';

class PrefService {
  final SharedPreferences _prefs;
  PrefService(this._prefs);

  static const String _keyUserProfile = 'user_profile';
  static const String _keyHideBalance = 'is_hide_balance';
  static const String _keyAppLock = 'is_app_lock';
  static const String _keyRpgMode = 'is_rpg_mode';
  static const String _keyNotification = 'is_notification';
  static const String _keyThemeMode = 'theme_mode';

  Future<void> saveUser(UserModel user) async {
    String jsonString = jsonEncode(user.toJson());
    await _prefs.setString(_keyUserProfile, jsonString);
  }

  UserModel? getUser() {
    String? jsonString = _prefs.getString(_keyUserProfile);
    if (jsonString == null) return null;

    return UserModel.fromJson(jsonDecode(jsonString));
  }

  bool get isHideBalance => _prefs.getBool(_keyHideBalance) ?? false;

  Future<void> setHideBalance(bool value) async =>
      await _prefs.setBool(_keyHideBalance, value);

  bool get isAppLock => _prefs.getBool(_keyAppLock) ?? false;

  Future<void> setAppLock(bool value) async =>
      await _prefs.setBool(_keyAppLock, value);

  bool get isRpgMode => _prefs.getBool(_keyRpgMode) ?? false;

  Future<void> setRpgMode(bool value) async =>
      await _prefs.setBool(_keyRpgMode, value);

  bool get isNotification => _prefs.getBool(_keyNotification) ?? false;

  Future<void> setNotification(bool value) async =>
      await _prefs.setBool(_keyNotification, value);

  String get themeMode => _prefs.getString(_keyThemeMode) ?? "dark";

  Future<void> setThemeMode(String value) async =>
      await _prefs.setString(_keyThemeMode, value);

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
