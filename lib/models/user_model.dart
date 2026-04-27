enum TitleType {
  noviceSaver,
  smartBudgeter,
  wiseInvestor,
  wealthBuilder,
  financialMaster,
}

class UserModel {
  final String uid;
  final String name;
  final String? email;
  final TitleType title;
  final int level;
  final int xp;
  BigInt emergencyAmount;
  BigInt emergencyTotal;
  BigInt baseDailyLimit;
  BigInt dailyPenalty;
  BigInt todayUsage;
  int lastActiveDate;
  Map<String, double> skillAllocations;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.title,
    required this.level,
    required this.xp,
    required this.emergencyAmount,
    required this.emergencyTotal,
    required this.skillAllocations,
    required this.baseDailyLimit,
    required this.dailyPenalty,
    required this.todayUsage,
    required this.lastActiveDate,
  });

  double getSkillPercentage(String key) {
    return skillAllocations[key] ?? 0.0;
  }

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

  void updateSkillAllocations(Map<String, double> allocations) {
    skillAllocations = allocations;
  }

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "name": name,
    "email": email,
    "title": title.name,
    "level": level,
    "xp": xp,
    "base_daily_limit": baseDailyLimit.toString(),
    "daily_penalty": dailyPenalty.toString(),
    "today_usage": todayUsage.toString(),
    "last_active_date": lastActiveDate,
    "emergency_amount": emergencyAmount.toString(),
    "emergency_total": emergencyTotal.toString(),
    "skill_allocations": skillAllocations,
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
    baseDailyLimit: BigInt.parse(json['base_daily_limit'] ?? '0'),
    dailyPenalty: BigInt.parse(json['daily_penalty'] ?? '0'),
    todayUsage: BigInt.parse(json['today_usage'] ?? '0'),
    lastActiveDate: json['last_active_date'] ?? '',
    emergencyAmount: BigInt.parse(json['emergency_amount'] ?? '0'),
    emergencyTotal: BigInt.parse(json['emergency_total'] ?? '0'),
    skillAllocations: Map<String, double>.from(json['skill_allocations'] ?? {}),
  );
}
