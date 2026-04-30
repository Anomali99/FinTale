class UserBudgetModel {
  BigInt baseDailyLimit;
  BigInt dailyPenalty;
  BigInt todayUsage;
  BigInt emergencyAmount;
  BigInt emergencyTotal;
  int lastActiveDate;

  UserBudgetModel({
    this.lastActiveDate = 0,
    BigInt? baseDailyLimit,
    BigInt? dailyPenalty,
    BigInt? todayUsage,
    BigInt? emergencyAmount,
    BigInt? emergencyTotal,
  }) : baseDailyLimit = baseDailyLimit ?? BigInt.zero,
       dailyPenalty = dailyPenalty ?? BigInt.zero,
       todayUsage = todayUsage ?? BigInt.zero,
       emergencyAmount = emergencyAmount ?? BigInt.zero,
       emergencyTotal = emergencyTotal ?? BigInt.zero;

  BigInt get currentDailyLimit {
    BigInt calculatedLimit = baseDailyLimit - dailyPenalty;
    return calculatedLimit < BigInt.zero ? BigInt.zero : calculatedLimit;
  }

  BigInt get remainingLimitToday {
    BigInt remaining = currentDailyLimit - todayUsage;
    return remaining < BigInt.zero ? BigInt.zero : remaining;
  }

  void updateBaseDailyLimit(BigInt limit) {
    baseDailyLimit = limit;
  }

  void updateEmergencyAmount(BigInt amount) {
    emergencyAmount = amount;
  }

  void addEmergencyAmount(BigInt amount) {
    emergencyAmount += amount;
  }

  Map<String, dynamic> toJson() => {
    "base_daily_limit": baseDailyLimit.toString(),
    "daily_penalty": dailyPenalty.toString(),
    "today_usage": todayUsage.toString(),
    "emergency_amount": emergencyAmount.toString(),
    "emergency_total": emergencyTotal.toString(),
    "last_active_date": lastActiveDate,
  };

  factory UserBudgetModel.fromJson(Map<String, dynamic> json) =>
      UserBudgetModel(
        baseDailyLimit: BigInt.parse(json['base_daily_limit'] ?? '0'),
        dailyPenalty: BigInt.parse(json['daily_penalty'] ?? '0'),
        todayUsage: BigInt.parse(json['today_usage'] ?? '0'),
        emergencyAmount: BigInt.parse(json['emergency_amount'] ?? '0'),
        emergencyTotal: BigInt.parse(json['emergency_total'] ?? '0'),
        lastActiveDate: json['last_active_date'] ?? 0,
      );
}
