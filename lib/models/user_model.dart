import 'user_allocation_model.dart';
import 'user_budget_model.dart';
import 'user_progress_model.dart';

enum TitleType {
  noviceSaver,
  smartBudgeter,
  wiseInvestor,
  wealthBuilder,
  financialMaster,
}

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
