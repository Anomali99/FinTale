import 'package:flutter/material.dart';

import '../core/utils/enum_types.dart';
import '../core/utils/leveling_extension.dart';
import '../core/utils/mission_extension.dart';
import '../data/pref_service.dart';
import '../models/user_model.dart';

class UserController with ChangeNotifier {
  final PrefService _prefService;
  UserModel? currentUser;

  UserController(this._prefService) {
    debugPrint("[DEBUG-RESET] UserController Constructor Dipanggil");
    evaluateAndResetDaily();
  }

  bool get isHideBalance => _prefService.isHideBalance;
  bool get isNotification => _prefService.isNotification;

  String get userName => currentUser?.name ?? 'Adventurer';
  TitleType get userTitle => currentUser?.title ?? TitleType.noviceSaver;
  int get userLevel => currentUser?.level ?? 1;
  double get xpPercentage => currentUser?.progressPercentage ?? 0.0;

  UserBudgetModel get budget => currentUser?.budget ?? UserBudgetModel();
  BigInt get baseDailyLimit => budget.baseDailyLimit;
  BigInt get dailyPenalty => budget.dailyPenalty;
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

  void addEmergencyTotal(BigInt amount, {required bool isIncome}) =>
      currentUser?.addEmergencyTotal(amount, isIncome: isIncome);
  void updateEmergencyAmount(BigInt amount) =>
      currentUser?.updateEmergencyAmount(amount);
  void updateFreeDebt(bool value) => currentUser?.updateFreeDebt(value);

  void updateBaseDailyLimit(BigInt amount) =>
      budget.updateBaseDailyLimit(amount);
  void useDaily(BigInt amount) => budget.useDaily(amount);

  double? getAllocation(Enum type) => allocation.getSkillPercentage(type);
  void updateSkillByKey(Enum key, double skills) =>
      allocation.updateSkillByKey(key, skills);

  void updatePending(int index, AllocationModel value) =>
      allocation.updatePending(index, value);

  void removePending(int index) => allocation.removePending(index);

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

  Future<void> processDebtPayment() async {
    MissionResult? result = progress.processDebtPayment();
    if (result.xpGranted) {
      currentUser?.addXp(result.xpReward);
      await saveUser();
    }
  }

  Future<void> processMonthlyReview() async {
    MissionResult? result = progress.processMonthlyReview();
    if (result.xpGranted) {
      currentUser?.addXp(result.xpReward);
      await saveUser();
    }
  }

  Future<void> evaluateAndResetDaily() async {
    try {
      await loadData();

      if (currentUser == null) {
        return;
      }

      DateTime now = DateTime.now();
      int todayInt = now.year * 10000 + now.month * 100 + now.day;

      if (budget.lastActiveDate == 0 || budget.lastActiveDate > 99991231) {
        budget.checkAndResetDaily();
        progress.checkAndReset();
        await saveUser();
        return;
      }

      bool isNewDay = todayInt > budget.lastActiveDate;

      if (isNewDay) {
        bool wasBudgetSafe = budget.todayUsage <= budget.currentDailyLimit;

        progress.checkAndReset();
        budget.checkAndResetDaily();

        MissionResult result = progress.processWeeklyCheckIn();

        if (wasBudgetSafe) {
          MissionResult dailyResult = progress.processDailyBudgetCap(true);
          MissionResult weeklyResult = progress.processConsistentBudgeting();
          result = MissionResult(
            progressUpdated:
                dailyResult.progressUpdated ||
                weeklyResult.progressUpdated ||
                result.progressUpdated,
            xpGranted:
                dailyResult.xpGranted ||
                weeklyResult.xpGranted ||
                result.xpGranted,
            xpReward:
                dailyResult.xpReward + weeklyResult.xpReward + result.xpReward,
          );
        } else {
          progress.updatWeeklyBudget(0, false);
        }

        if (result.xpGranted) {
          currentUser!.addXp(result.xpReward);
        }

        await saveUser();
      }
    } catch (e) {
      debugPrint("[USER] An error occurred while loading evaluate daily: $e");
    } finally {
      notifyListeners();
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
        await loadData();
      }
    } catch (e) {
      debugPrint("[USER] An error occurred while saving profile: $e");
    }
  }

  Future<void> saveRawUser(Map<String, dynamic> user) async {
    try {
      await _prefService.saveRawUser(user);
    } catch (e) {
      debugPrint("[USER] An error occurred while saving profile: $e");
    }
  }

  Future<void> loadData() async {
    try {
      currentUser = _prefService.user;
    } catch (e) {
      debugPrint("[USER] An error occurred while loading profile: $e");
    } finally {
      notifyListeners();
    }
  }
}
