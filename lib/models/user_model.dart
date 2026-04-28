import 'allocation_model.dart';

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
  Map<Enum, double> skillAllocations;
  List<AllocationModel> pendingAllocations;

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
    List<AllocationModel>? pendingAllocations,
  }) : pendingAllocations = pendingAllocations ?? [];

  double getSkillPercentage(Enum key) {
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

  void updateSkillAllocations(Map<Enum, double> allocations) {
    skillAllocations = allocations;
  }

  void addPendingAllocations(AllocationModel value) {
    pendingAllocations.add(value);
  }

  void updatePendingAllocations(int index, AllocationModel value) {
    pendingAllocations[index] = value;
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
    "pending_allocations": pendingAllocations.map((e) => e.toJson()).toList(),
    "skill_allocations": skillAllocations.map(
      (key, value) => MapEntry(key.name, value),
    ),
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

    lastActiveDate: json['last_active_date'] ?? 0,
    emergencyAmount: BigInt.parse(json['emergency_amount'] ?? '0'),
    emergencyTotal: BigInt.parse(json['emergency_total'] ?? '0'),

    pendingAllocations:
        (json['pending_allocations'] as List?)
            ?.map((e) => AllocationModel.fromJson(e))
            .toList() ??
        [],

    skillAllocations:
        (json['skill_allocations'] as Map<String, dynamic>?)?.map((key, value) {
          Enum getEnumFromString(String name) {
            for (var element in SectorType.values) {
              if (element.name == name) return element;
            }
            for (var element in SubSectorType.values) {
              if (element.name == name) return element;
            }
            return SectorType.living;
          }

          return MapEntry(getEnumFromString(key), (value as num).toDouble());
        }) ??
        {},
  );
}
