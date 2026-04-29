import 'package:flutter/material.dart';

import '../data/local/pref_service.dart';
import '../models/allocation_model.dart';
import '../models/user_model.dart';

class SkillController with ChangeNotifier {
  final PrefService _prefService;

  SkillController(this._prefService) {
    loadData();
  }

  Enum? selectedNode;
  UserModel? currentUser;
  bool isLoading = true;
  List<Enum> lockedSkills = [];

  bool get isRpg => _prefService.isRpgMode;

  void changeNode(Enum? node) {
    if (selectedNode != node) {
      selectedNode = node;
      notifyListeners();
    }
  }

  double get currentPercentage {
    if (selectedNode == null || currentUser == null) return 0.0;
    return currentUser!.skillAllocations[selectedNode!] ?? 0.0;
  }

  Future<void> loadData() async {
    isLoading = true;
    Future.microtask(() => notifyListeners());
    try {
      currentUser = _prefService.getUser();
      lockedSkills = [
        SectorType.investment,
        SubSectorType.mediumRisk,
        SubSectorType.highRisk,
      ];
    } catch (e) {
      debugPrint("An error occurred while loading profile: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> increaseAllocation() async {
    if (selectedNode == null || currentUser == null) return;

    double current = currentPercentage;
    if (current < 100) {
      currentUser!.updateSkillAllocation(selectedNode!, current + 1);
      await _prefService.saveUser(currentUser!);
      await loadData();
      notifyListeners();
    }
  }

  Future<void> decreaseAllocation() async {
    if (selectedNode == null || currentUser == null) return;

    double current = currentPercentage;
    if (current > 0) {
      currentUser!.updateSkillAllocation(selectedNode!, current - 1);
      await _prefService.saveUser(currentUser!);
      await loadData();
      notifyListeners();
    }
  }
}
