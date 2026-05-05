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

  Future<void> processRecordTransaction() async {
    MissionResult? firstResult = progress.processFirstTransaction();
    MissionResult? result = progress.processRecordTransaction();
    if (result.xpGranted) {
      currentUser?.addXp(result.xpReward);
      if (firstResult.xpGranted) {
        currentUser?.addXp(firstResult.xpReward);
      }
      await saveUser();
    }
  }

  Future<void> evaluateAndResetDaily() async {
    if (currentUser == null) return;

    DateTime now = DateTime.now();
    int todayInt = now.year * 10000 + now.month * 100 + now.day;

    bool isNewDay =
        (budget.lastActiveDate != 0) && (todayInt > budget.lastActiveDate);

    if (isNewDay) {
      bool wasBudgetSafe = budget.todayUsage <= budget.currentDailyLimit;

      if (wasBudgetSafe) {
        MissionResult dailyResult = progress.processDailyBudgetCap(true);
        if (dailyResult.xpGranted) {
          currentUser!.addXp(dailyResult.xpReward);
        }

        MissionResult weeklyResult = progress.processConsistentBudgeting();
        if (weeklyResult.progressUpdated && weeklyResult.xpGranted) {
          currentUser!.addXp(weeklyResult.xpReward);
        }
      } else {
        progress.updatWeeklyBudget(0, false);
      }
    }

    bool isResetProgress = progress.checkAndReset();
    bool isResetBudget = budget.checkAndResetDaily();

    if (isResetProgress || isResetBudget) {
      await processDailyCheckIn();
      await saveUser();
    }
  }

  Future<void> processDailyCheckIn() async {
    MissionResult result = progress.processWeeklyCheckIn();

    if (result.progressUpdated) {
      if (result.xpGranted) {
        currentUser?.addXp(result.xpReward);
      }
    }
  }

  Future<bool> claimDailyBudgetMission() async {
    bool isBudgetSafe = budget.todayUsage <= budget.currentDailyLimit;
    MissionResult result = progress.processDailyBudgetCap(isBudgetSafe);

    if (result.xpGranted) {
      currentUser?.addXp(result.xpReward);
      await saveUser();
      return true;
    }
    return false;
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

  Future<void> loadData() async {
    try {
      currentUser = _prefService.getUser();
    } catch (e) {
      debugPrint("[USER] An error occurred while loading profile: $e");
    } finally {
      notifyListeners();
    }
  }
}
