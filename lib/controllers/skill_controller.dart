import 'package:flutter/material.dart';

import 'user_controller.dart';

class SkillController with ChangeNotifier {
  final UserController _userController;
  Enum? selectedNode;
  bool isLoading = true;

  SkillController(this._userController) {
    loadData();
  }

  bool get isRpg => _userController.isRpgMode;

  Map<Enum, double?> get skillAllocations => _userController.userAllocations;

  double? get currentPercentage {
    if (selectedNode == null) return null;
    return _userController.getAllocation(selectedNode!);
  }

  void changeNode(Enum? node) {
    if (selectedNode != node) {
      selectedNode = node;
      notifyListeners();
    }
  }

  Future<void> loadData() async {
    isLoading = true;
    Future.microtask(() => notifyListeners());
    try {
      await _userController.loadData();
    } catch (e) {
      debugPrint("[SKILL] An error occurred while loading profile: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> increaseAllocation() async {
    if (selectedNode == null) return;

    double current = currentPercentage ?? 0.0;
    if (current < 100) {
      _userController.updateSkillByKey(selectedNode!, current + 1);
      await _userController.saveUser();
      await loadData();
      notifyListeners();
    }
  }

  Future<void> decreaseAllocation() async {
    if (selectedNode == null) return;

    double current = currentPercentage ?? 0.0;
    if (current > 0) {
      _userController.updateSkillByKey(selectedNode!, current - 1);
      await _userController.saveUser();
      await loadData();
      notifyListeners();
    }
  }
}
