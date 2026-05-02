import 'package:flutter/material.dart';

import '../core/utils/leveling_extension.dart';
import '../core/utils/mission_extension.dart';
import '../data/local/pref_service.dart';
import '../models/allocation_model.dart';
import '../models/user_allocation_model.dart';
import '../models/user_budget_model.dart';
import '../models/user_model.dart';
import '../models/user_progress_model.dart';

class UserController with ChangeNotifier {
  final PrefService _prefService;
  UserModel? currentUser;

  UserController(this._prefService);

  bool get isRpgMode => _prefService.isRpgMode;
  bool get isHideBalance => _prefService.isHideBalance;

  String get userName => currentUser?.name ?? 'Adventurer';
  TitleType get userTitle => currentUser?.title ?? TitleType.noviceSaver;
  int get userLevel => currentUser?.level ?? 1;
  double get xpPercentage => currentUser?.progressPercentage ?? 0.0;

  UserBudgetModel get budget => currentUser?.budget ?? UserBudgetModel();
  BigInt get baseDailyLimit => budget.baseDailyLimit;
  BigInt get currentDailyLimit => budget.currentDailyLimit;
  BigInt get todayUsage => budget.todayUsage;
  BigInt get emergencyAmount => budget.emergencyAmount;
  BigInt get emergencyTotal => budget.emergencyTotal;
  bool get isEmergencyMax => budget.isEmergencyMax;
  bool get isFreeDebt => budget.isFreeDebt;

  UserAllocationModel get allocation =>
      currentUser?.allocation ?? UserAllocationModel(skills: {});
  Map<Enum, double?> get userAllocations => allocation.skills;
  List<AllocationModel> get pendingAllocations => allocation.pending;

  UserProgressModel get progress =>
      currentUser?.progress ?? UserProgressModel();

  void updateName(String name) {
    if (currentUser != null) {
      currentUser!.updateName(name);
    }
  }

  void resetSkillAlocaton() {
    if (currentUser != null) {
      currentUser!.resetSkillAlocaton();
    }
  }

  void updateEmergencyAmount(BigInt amount) =>
      budget.updateEmergencyAmount(amount);
  void updateBaseDailyLimit(BigInt amount) =>
      budget.updateBaseDailyLimit(amount);

  double? getAllocation(Enum type) => allocation.getSkillPercentage(type);
  void updateSkillByKey(Enum key, double skills) =>
      allocation.updateSkillByKey(key, skills);

  void updatePending(int index, AllocationModel value) =>
      allocation.updatePending(index, value);

  void addPending(AllocationModel value) => allocation.addPending(value);

  Future<void> clearAll() => _prefService.clearAll();

  Future<void> processCreateWallet() async {
    MissionResult? result = progress.processCreateWallet();
    if (result.xpGranted) {
      currentUser?.addXp(result.xpReward);
      await saveUser();
    }
  }

  Future<void> processSetAllocation() async {
    MissionResult? result = progress.processSetAllocation();
    if (result.xpGranted) {
      currentUser?.addXp(result.xpReward);
      await saveUser();
    }
  }

  Future<void> loadData() async {
    try {
      currentUser = _prefService.getUser();
    } catch (e) {
      debugPrint("[USER] An error occurred while loading profile: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> saveUser({UserModel? newUser}) async {
    try {
      if (currentUser != null || newUser != null) {
        await _prefService.saveUser(newUser ?? currentUser!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("[USER] An error occurred while saving profile: $e");
    }
  }
}
