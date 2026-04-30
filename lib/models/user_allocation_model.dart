import 'allocation_model.dart';

class UserAllocationModel {
  Map<Enum, double?> skills;
  List<AllocationModel> pending;

  UserAllocationModel({required this.skills, List<AllocationModel>? pending})
    : pending = pending ?? [];

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
