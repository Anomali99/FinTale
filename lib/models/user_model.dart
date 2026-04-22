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

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.title,
    required this.level,
    required this.xp,
  });
}
