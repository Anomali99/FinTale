import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'user_controller.dart';

class ProfileController with ChangeNotifier {
  final UserController _userController;
  bool isLoading = true;

  ProfileController(this._userController);

  Future<bool> saveName(String name) async {
    try {
      _userController.updateName(name);
      await _userController.saveUser();
      return true;
    } catch (e) {
      debugPrint("[PROFILE] Failed to save name: $e");
      return false;
    }
  }

  Future<bool> saveBaseDailyLimit(Decimal amount) async {
    try {
      _userController.updateBaseDailyLimit(amount);
      await _userController.saveUser();
      return true;
    } catch (e) {
      debugPrint("[PROFILE] Failed to save base daily limit: $e");
      return false;
    }
  }

  Future<bool> saveEmergencyAmount(Decimal amount) async {
    try {
      _userController.updateEmergencyAmount(amount);
      await _userController.saveUser();
      return true;
    } catch (e) {
      debugPrint("[PROFILE] Failed to save emergency amount: $e");
      return false;
    }
  }
}
