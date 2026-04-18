import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModeProvider with ChangeNotifier {
  bool _isRpgMode = true;

  static const String _prefKey = 'is_rpg_mode';

  bool get isRpgMode => _isRpgMode;

  ModeProvider() {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isRpgMode = prefs.getBool(_prefKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleMode() async {
    _isRpgMode = !_isRpgMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, _isRpgMode);

    notifyListeners();
  }
}
