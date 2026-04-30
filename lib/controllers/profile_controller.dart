import 'package:flutter/material.dart';

import 'user_controller.dart';

class ProfileController with ChangeNotifier {
  final UserController _userController;
  bool isLoading = true;

  ProfileController(this._userController);

  Future<void> saveName(String name) async {
    try {
      _userController.updateName(name);
      await _userController.saveUser();
    } catch (e) {
      debugPrint("[PROFILE] Failed to save name: $e");
    }
  }

  Future<void> saveBaseDailyLimit(BigInt amount) async {
    try {
      _userController.updateBaseDailyLimit(amount);
      await _userController.saveUser();
    } catch (e) {
      debugPrint("[PROFILE] Failed to save base daily limit: $e");
    }
  }

  Future<void> saveEmergencyAmount(BigInt amount) async {
    try {
      _userController.updateEmergencyAmount(amount);
      await _userController.saveUser();
    } catch (e) {
      debugPrint("[PROFILE] Failed to save emergency amount: $e");
    }
  }
}
