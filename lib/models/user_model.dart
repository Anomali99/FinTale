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
  final String email;
  final TitleType title;
  final int level;
  final int xp;
  final BigInt dailyLimit;
  final BigInt emergencyAmount;
  final BigInt emergencyTotal;
  final Map<String, double> skillAllocations;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.title,
    required this.level,
    required this.xp,
    required this.dailyLimit,
    required this.emergencyAmount,
    required this.emergencyTotal,
    required this.skillAllocations,
  });

  double getSkillPercentage(String key) {
    return skillAllocations[key] ?? 0.0;
  }
}
