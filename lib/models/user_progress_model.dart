class UserProgressModel {
  int? lastLoginDate;
  int? currentWeekId;
  int? currentMonthId;
  int dailyTransactionCount;
  bool isDailyBudgetClaimed;
  int weeklyLoginDays;
  int weeklyBudgetDays;
  bool isWeeklyCheckInClaimed;
  bool isWeeklyBudgetClaimed;
  bool isMonthlySavingsClaimed;
  bool isMonthlyDebtClaimed;
  bool isMonthlyReviewClaimed;
  bool isFirstTransactionClaimed;
  int walletCreatedCount;
  bool isAllocationSetClaimed;

  UserProgressModel({
    this.lastLoginDate,
    this.currentWeekId,
    this.currentMonthId,
    this.dailyTransactionCount = 0,
    this.isDailyBudgetClaimed = false,
    this.weeklyLoginDays = 0,
    this.weeklyBudgetDays = 0,
    this.isWeeklyCheckInClaimed = false,
    this.isWeeklyBudgetClaimed = false,
    this.isMonthlySavingsClaimed = false,
    this.isMonthlyDebtClaimed = false,
    this.isMonthlyReviewClaimed = false,
    this.isFirstTransactionClaimed = false,
    this.walletCreatedCount = 0,
    this.isAllocationSetClaimed = false,
  });

  Map<String, dynamic> toJson() => {
    "last_login_date": lastLoginDate,
    "current_week_id": currentWeekId,
    "current_month_id": currentMonthId,
    "daily_transaction_count": dailyTransactionCount,
    "is_daily_budget_claimed": isDailyBudgetClaimed,
    "weekly_login_days": weeklyLoginDays,
    "weekly_budget_days": weeklyBudgetDays,
    "is_weekly_checkIn_claimed": isWeeklyCheckInClaimed,
    "is_weekly_budget_claimed": isWeeklyBudgetClaimed,
    "is_monthly_savings_claimed": isMonthlySavingsClaimed,
    "is_monthly_debt_claimed": isMonthlyDebtClaimed,
    "is_monthly_review_claimed": isMonthlyReviewClaimed,
    "is_first_transaction_claimed": isFirstTransactionClaimed,
    "wallet_created_count": walletCreatedCount,
    "is_allocationSet_claimed": isAllocationSetClaimed,
  };

  factory UserProgressModel.fromJson(Map<String, dynamic> json) =>
      UserProgressModel(
        lastLoginDate: json['last_login_date'],
        currentWeekId: json['current_week_id'],
        currentMonthId: json['current_month_id'],
        dailyTransactionCount: json['daily_transaction_count'],
        isDailyBudgetClaimed: json['is_daily_budget_claimed'],
        weeklyLoginDays: json['weekly_login_days'],
        weeklyBudgetDays: json['weekly_budget_days'],
        isWeeklyCheckInClaimed: json['is_weekly_checkIn_claimed'],
        isWeeklyBudgetClaimed: json['is_weekly_budget_claimed'],
        isMonthlySavingsClaimed: json['is_monthly_savings_claimed'],
        isMonthlyDebtClaimed: json['is_monthly_debt_claimed'],
        isMonthlyReviewClaimed: json['is_monthly_review_claimed'],
        isFirstTransactionClaimed: json['is_first_transaction_claimed'],
        walletCreatedCount: json['wallet_created_count'],
        isAllocationSetClaimed: json['is_allocationSet_claimed'],
      );
}
