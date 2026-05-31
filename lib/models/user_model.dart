import '../core/utils/enum_types.dart';

class UserModel {
  final String uid;
  final String? email;
  String name;
  TitleType title;
  int level;
  int xp;
  UserBudgetModel budget;
  UserAllocationModel allocation;
  UserProgressModel progress;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.title,
    required this.level,
    required this.xp,
    required this.budget,
    required this.allocation,
    required this.progress,
  });

  void updateName(String name) {
    this.name = name;
  }

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "name": name,
    "email": email,
    "title": title.name,
    "level": level,
    "xp": xp,
    "budget": budget.toJson(),
    "allocation": allocation.toJson(),
    "progress": progress.toJson(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json['uid'],
    name: json['name'],
    email: json['email'],
    title: TitleType.values.firstWhere(
      (e) => e.name == json['title'],
      orElse: () => TitleType.noviceSaver,
    ),
    level: json['level'],
    xp: json['xp'],
    budget: UserBudgetModel.fromJson(json['budget'] ?? {}),
    allocation: UserAllocationModel.fromJson(json['allocation'] ?? {}),
    progress: UserProgressModel.fromJson(json['progress'] ?? {}),
  );
}

class UserBudgetModel {
  BigInt baseDailyLimit;
  BigInt dailyPenalty;
  BigInt currentPenalty;
  BigInt todayUsage;
  BigInt emergencyAmount;
  BigInt emergencyTotal;
  bool isFreeDebt;
  int lastActiveDate;

  UserBudgetModel({
    this.isFreeDebt = true,
    this.lastActiveDate = 0,
    BigInt? baseDailyLimit,
    BigInt? dailyPenalty,
    BigInt? currentPenalty,
    BigInt? todayUsage,
    BigInt? emergencyAmount,
    BigInt? emergencyTotal,
  }) : baseDailyLimit = baseDailyLimit ?? BigInt.zero,
       dailyPenalty = dailyPenalty ?? BigInt.zero,
       currentPenalty = currentPenalty ?? BigInt.zero,
       todayUsage = todayUsage ?? BigInt.zero,
       emergencyAmount = emergencyAmount ?? BigInt.zero,
       emergencyTotal = emergencyTotal ?? BigInt.zero;

  Map<String, dynamic> toJson() => {
    "base_daily_limit": baseDailyLimit.toString(),
    "daily_penalty": dailyPenalty.toString(),
    "current_penalty": currentPenalty.toString(),
    "today_usage": todayUsage.toString(),
    "emergency_amount": emergencyAmount.toString(),
    "emergency_total": emergencyTotal.toString(),
    "last_active_date": lastActiveDate,
    "is_free_debt": isFreeDebt,
  };

  factory UserBudgetModel.fromJson(Map<String, dynamic> json) =>
      UserBudgetModel(
        baseDailyLimit: BigInt.parse(json['base_daily_limit'] ?? '0'),
        dailyPenalty: BigInt.parse(json['daily_penalty'] ?? '0'),
        currentPenalty: BigInt.parse(json['current_penalty'] ?? '0'),
        todayUsage: BigInt.parse(json['today_usage'] ?? '0'),
        emergencyAmount: BigInt.parse(json['emergency_amount'] ?? '0'),
        emergencyTotal: BigInt.parse(json['emergency_total'] ?? '0'),
        lastActiveDate: json['last_active_date'] ?? 0,
        isFreeDebt: json['is_free_debt'] ?? false,
      );
}

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
        isMonthlyDebtClaimed: json['is_monthly_debt_claimed'],
        isMonthlyReviewClaimed: json['is_monthly_review_claimed'],
        isFirstTransactionClaimed: json['is_first_transaction_claimed'],
        walletCreatedCount: json['wallet_created_count'],
        isAllocationSetClaimed: json['is_allocationSet_claimed'],
      );
}

class AllocationModel {
  final int walletId;
  final SectorType sector;
  final SubSectorType? subSector;
  BigInt amount;

  AllocationModel({
    required this.walletId,
    required this.amount,
    required this.sector,
    this.subSector,
  });

  void addAmount(BigInt amount, {bool isIncome = true}) {
    if (isIncome) {
      this.amount += amount;
    } else {
      this.amount -= amount;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "wallet_id": walletId,
      "amount": amount.toString(),
      "sector": sector.name,
      "sub_sector": subSector?.name,
    };
  }

  factory AllocationModel.fromJson(Map<String, dynamic> json) {
    return AllocationModel(
      walletId: json['wallet_id'],
      amount: BigInt.parse(json['amount']),
      sector: SectorType.values.firstWhere(
        (e) => e.name == json['sector'],
        orElse: () => SectorType.living,
      ),

      subSector: json['sub_sector'] != null
          ? SubSectorType.values.firstWhere(
              (e) => e.name == json['sub_sector'],
              orElse: () => SubSectorType.essentials,
            )
          : null,
    );
  }
}

class UserAllocationModel {
  Map<Enum, double?> skills;
  List<AllocationModel> pending;

  UserAllocationModel({required this.skills, List<AllocationModel>? pending})
    : pending = pending ?? [];

  Map<String, dynamic> toJson() => {
    "skills": skills.map((key, value) => MapEntry(key.name, value)),
    "pending": pending.map((e) => e.toJson()).toList(),
  };

  factory UserAllocationModel.fromJson(Map<String, dynamic> json) =>
      UserAllocationModel(
        skills:
            (json['skills'] as Map<String, dynamic>?)?.map((key, value) {
              Enum getEnumFromString(String name) {
                for (var element in SectorType.values) {
                  if (element.name == name) return element;
                }
                for (var element in SubSectorType.values) {
                  if (element.name == name) return element;
                }
                return SectorType.living;
              }

              return MapEntry(getEnumFromString(key), value);
            }) ??
            {},
        pending:
            (json['pending'] as List?)
                ?.map((e) => AllocationModel.fromJson(e))
                .toList() ??
            [],
      );
}

extension UserAllocationExtension on UserAllocationModel {
  double? getSkillPercentage(Enum key) => skills[key];

  void updateSkill(Map<Enum, double?> skills) {
    this.skills = skills;
  }

  void updateSkillByKey(Enum key, double? skills) {
    this.skills[key] = skills;
  }

  void addPending(AllocationModel value) {
    pending.add(value);
  }

  void updatePending(int index, AllocationModel value) {
    pending[index] = value;
  }

  void removePending(int index) {
    pending.removeAt(index);
  }
}

extension UserBudgetExtension on UserBudgetModel {
  BigInt get currentDailyLimit {
    BigInt calculatedLimit = baseDailyLimit - dailyPenalty;
    return calculatedLimit < BigInt.zero ? BigInt.zero : calculatedLimit;
  }

  BigInt get remainingLimitToday {
    BigInt remaining = currentDailyLimit - todayUsage;
    return remaining < BigInt.zero ? BigInt.zero : remaining;
  }

  bool get isEmergencyMax =>
      BigInt.zero < emergencyAmount && emergencyTotal >= emergencyAmount;

  void updateBaseDailyLimit(BigInt limit) {
    baseDailyLimit = limit;
  }

  void updateEmergencyAmount(BigInt amount) {
    emergencyAmount = amount;
  }

  void addEmergencyTotal(BigInt amount, {bool isIncome = true}) {
    if (isIncome) {
      emergencyTotal += amount;
    } else {
      emergencyTotal -= amount;
    }
  }

  void updateFreeDebt(bool value) {
    isFreeDebt = value;
  }

  void useDaily(BigInt amount) {
    BigInt remaining = remainingLimitToday;
    if (amount <= remaining) {
      todayUsage += amount;
    } else {
      todayUsage += remaining;
      BigInt excess = amount - remaining;
      currentPenalty += excess;
    }
  }

  bool checkAndResetDaily() {
    DateTime now = DateTime.now();
    int todayInt = now.year * 10000 + now.month * 100 + now.day;

    if (lastActiveDate == 0) {
      lastActiveDate = todayInt;
      return true;
    }

    if (todayInt > lastActiveDate) {
      todayUsage = BigInt.zero;
      dailyPenalty = currentPenalty;
      currentPenalty = BigInt.zero;
      lastActiveDate = todayInt;
      return true;
    }

    return false;
  }
}
