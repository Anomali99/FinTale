import '../../models/user_progress_model.dart';

class MissionResult {
  final bool progressUpdated;
  final bool xpGranted;
  final int xpReward;

  MissionResult({
    this.progressUpdated = false,
    this.xpGranted = false,
    this.xpReward = 0,
  });
}

extension MissionExtension on UserProgressModel {
  bool checkAndReset() {
    DateTime now = DateTime.now();
    bool isChanged = false;

    int todayId = int.parse(
      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
    );

    int monthId = int.parse(
      '${now.year}${now.month.toString().padLeft(2, '0')}',
    );

    int dayOfYear = int.parse(
      now.difference(DateTime(now.year, 1, 1)).inDays.toString(),
    );
    int weekId = int.parse(
      '${now.year}${(dayOfYear / 7).floor().toString().padLeft(2, '0')}',
    );

    if (lastLoginDate != todayId) {
      dailyTransactionCount = 0;
      isDailyBudgetClaimed = false;
      lastLoginDate = todayId;
      isChanged = true;
    }

    if (currentWeekId != weekId) {
      weeklyLoginDays = 0;
      weeklyBudgetDays = 0;
      isWeeklyCheckInClaimed = false;
      isWeeklyBudgetClaimed = false;
      currentWeekId = weekId;
      isChanged = true;
    }

    if (currentMonthId != monthId) {
      isMonthlySavingsClaimed = false;
      isMonthlyDebtClaimed = false;
      isMonthlyReviewClaimed = false;
      currentMonthId = monthId;
      isChanged = true;
    }

    return isChanged;
  }

  MissionResult processRecordTransaction() {
    if (dailyTransactionCount >= 3) {
      return MissionResult();
    }

    dailyTransactionCount++;
    return MissionResult(progressUpdated: true, xpGranted: true, xpReward: 10);
  }

  MissionResult processDailyBudgetCap(bool isBudgetSafe) {
    if (!isBudgetSafe || isDailyBudgetClaimed) {
      return MissionResult();
    }

    isDailyBudgetClaimed = true;
    return MissionResult(progressUpdated: true, xpGranted: true, xpReward: 25);
  }

  MissionResult processWeeklyCheckIn() {
    if (isWeeklyCheckInClaimed) return MissionResult();

    weeklyLoginDays++;

    if (weeklyLoginDays >= 5) {
      isWeeklyCheckInClaimed = true;
      return MissionResult(
        progressUpdated: true,
        xpGranted: true,
        xpReward: 100,
      );
    }

    return MissionResult(progressUpdated: true);
  }

  MissionResult processConsistentBudgeting() {
    if (isWeeklyBudgetClaimed) return MissionResult();

    weeklyBudgetDays++;

    if (weeklyBudgetDays >= 5) {
      isWeeklyBudgetClaimed = true;
      return MissionResult(
        progressUpdated: true,
        xpGranted: true,
        xpReward: 150,
      );
    }

    return MissionResult(progressUpdated: true);
  }

  MissionResult processMonthlySavings(bool isTargetMet) {
    if (!isTargetMet || isMonthlySavingsClaimed) return MissionResult();

    isMonthlySavingsClaimed = true;
    return MissionResult(progressUpdated: true, xpGranted: true, xpReward: 500);
  }

  MissionResult processDebtPayment() {
    if (isMonthlyDebtClaimed) return MissionResult();

    isMonthlyDebtClaimed = true;
    return MissionResult(progressUpdated: true, xpGranted: true, xpReward: 300);
  }

  MissionResult processMonthlyReview() {
    if (isMonthlyReviewClaimed) return MissionResult();

    isMonthlyReviewClaimed = true;
    return MissionResult(progressUpdated: true, xpGranted: true, xpReward: 200);
  }

  MissionResult processFirstTransaction() {
    if (isFirstTransactionClaimed) return MissionResult();

    isFirstTransactionClaimed = true;
    return MissionResult(progressUpdated: true, xpGranted: true, xpReward: 100);
  }

  MissionResult processCreateWallet() {
    if (walletCreatedCount >= 3) return MissionResult();

    walletCreatedCount++;
    return MissionResult(progressUpdated: true, xpGranted: true, xpReward: 50);
  }

  MissionResult processSetAllocation() {
    if (isAllocationSetClaimed) return MissionResult();

    isAllocationSetClaimed = true;
    return MissionResult(progressUpdated: true, xpGranted: true, xpReward: 200);
  }
}
