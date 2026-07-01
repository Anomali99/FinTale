import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class PrefService {
  final SharedPreferences _prefs;
  PrefService(this._prefs);

  static const String _keyUserProfile = 'user_profile';
  static const String _keyHideBalance = 'is_hide_balance';
  static const String _keyAppLock = 'is_app_lock';
  static const String _keyBiometric = 'is_biometric';
  static const String _keyRpgMode = 'is_rpg_mode';
  static const String _keyNotification = 'is_notification';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyPinHash = 'pin_hash';

  Future<void> saveUser(UserModel user) async {
    String jsonString = jsonEncode(user.toJson());
    await _prefs.setString(_keyUserProfile, jsonString);
  }

  Future<void> saveRawUser(Map<String, dynamic> user) async {
    String jsonString = jsonEncode(user);
    await _prefs.setString(_keyUserProfile, jsonString);
  }

  UserModel? get user {
    String? jsonString = _prefs.getString(_keyUserProfile);
    if (jsonString == null) return null;

    return UserModel.fromJson(jsonDecode(jsonString));
  }

  Map<String, dynamic>? get rawUser {
    String? jsonString = _prefs.getString(_keyUserProfile);
    if (jsonString == null) return null;

    return jsonDecode(jsonString);
  }

  bool get isHideBalance => _prefs.getBool(_keyHideBalance) ?? false;

  Future<void> setHideBalance(bool value) async =>
      await _prefs.setBool(_keyHideBalance, value);

  bool get isAppLock => _prefs.getBool(_keyAppLock) ?? false;

  Future<void> setAppLock(bool value) async =>
      await _prefs.setBool(_keyAppLock, value);

  bool get isBiometric => _prefs.getBool(_keyBiometric) ?? false;

  Future<void> setBiometric(bool value) async =>
      await _prefs.setBool(_keyBiometric, value);

  bool get isRpgMode => _prefs.getBool(_keyRpgMode) ?? false;

  Future<void> setRpgMode(bool value) async =>
      await _prefs.setBool(_keyRpgMode, value);

  bool get isNotification => _prefs.getBool(_keyNotification) ?? false;

  Future<void> setNotification(bool value) async =>
      await _prefs.setBool(_keyNotification, value);

  ThemeMode get themeMode {
    final String? themeString = _prefs.getString(_keyThemeMode);

    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String themeString = 'system';

    if (mode == ThemeMode.light) {
      themeString = 'light';
    } else if (mode == ThemeMode.dark) {
      themeString = 'dark';
    }

    await _prefs.setString(_keyThemeMode, themeString);
  }

  String? get pinHash => _prefs.getString(_keyPinHash);

  Future<void> setPinHash(String? value) async => value == null
      ? await _prefs.remove(_keyPinHash)
      : await _prefs.setString(_keyPinHash, value);

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
