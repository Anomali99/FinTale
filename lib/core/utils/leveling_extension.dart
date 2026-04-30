import '../../models/allocation_model.dart';
import '../../models/user_model.dart';

extension LevelingExtension on UserModel {
  static const int maxCoreLevel = 50;

  int get requiredXp {
    return 500 + (level * 150);
  }

  double get progressPercentage {
    return (xp / requiredXp).clamp(0.0, 1.0);
  }

  void addXp(int xp) {
    int totalXp = this.xp + xp;
    int initialLevel = level;

    while (totalXp >= requiredXp) {
      totalXp -= requiredXp;
      level++;
    }

    this.xp = totalXp;

    if (level > initialLevel) {
      title = getTitleForLevel(level);
      if ([11, 21, 31, 41].contains(level)) {
        allocation.updateSkill(
          AllocationMap.getAllocationByLevel(
            level,
            maxEmergency: budget.emergencyTotal >= budget.emergencyAmount,
          ),
        );
      }
    }
  }

  TitleType getTitleForLevel(int level) {
    if (level <= 10) return TitleType.noviceSaver;
    if (level <= 20) return TitleType.smartBudgeter;
    if (level <= 30) return TitleType.wiseInvestor;
    if (level < 50) return TitleType.wealthBuilder;

    return TitleType.financialMaster;
  }
}

class AllocationMap {
  static Map<Enum, double?> getAllocationByLevel(
    int level, {
    bool noDebt = false,
    bool maxEmergency = false,
  }) {
    if (level <= 10) {
      return {
        SectorType.living: 55.0,
        SectorType.payDebt: noDebt ? null : 25.0,
        SectorType.emergency: maxEmergency ? null : 20.0,
        SectorType.investment: maxEmergency ? 0.0 : null,
        SubSectorType.essentials: 55.0,
        SubSectorType.dreamFund: 0.0,
        SubSectorType.lowRisk: maxEmergency ? 0.0 : 20.0,
        SubSectorType.mediumRisk: null,
        SubSectorType.highRisk: null,
      };
    }
    if (level <= 20) {
      return {
        SectorType.living: 50.0,
        SectorType.payDebt: noDebt ? null : 20.0,
        SectorType.emergency: maxEmergency ? null : 20.0,
        SectorType.investment: 10.0,
        SubSectorType.essentials: 50.0,
        SubSectorType.dreamFund: 0.0,
        SubSectorType.lowRisk: maxEmergency ? 0.0 : 20.0,
        SubSectorType.mediumRisk: 10.0,
        SubSectorType.highRisk: null,
      };
    }
    if (level <= 30) {
      return {
        SectorType.living: 45.0,
        SectorType.payDebt: noDebt ? null : 15.0,
        SectorType.emergency: maxEmergency ? null : 20.0,
        SectorType.investment: 20.0,
        SubSectorType.essentials: 45.0,
        SubSectorType.dreamFund: 0.0,
        SubSectorType.lowRisk: maxEmergency ? 0.0 : 20.0,
        SubSectorType.mediumRisk: 15.0,
        SubSectorType.highRisk: 5.0,
      };
    }
    if (level <= 40) {
      return {
        SectorType.living: 40.0,
        SectorType.payDebt: noDebt ? null : 10.0,
        SectorType.emergency: maxEmergency ? null : 25.0,
        SectorType.investment: 25.0,
        SubSectorType.essentials: 40.0,
        SubSectorType.dreamFund: 0.0,
        SubSectorType.lowRisk: maxEmergency ? 0.0 : 25.0,
        SubSectorType.mediumRisk: 15.0,
        SubSectorType.highRisk: 10.0,
      };
    }

    return {
      SectorType.living: 35.0,
      SectorType.payDebt: noDebt ? null : 5.0,
      SectorType.emergency: maxEmergency ? null : 30.0,
      SectorType.investment: 30.0,
      SubSectorType.essentials: 35.0,
      SubSectorType.dreamFund: 0.0,
      SubSectorType.lowRisk: maxEmergency ? 0.0 : 30.0,
      SubSectorType.mediumRisk: 15.0,
      SubSectorType.highRisk: 15.0,
    };
  }

  static Map<Enum, double?> getAllocationLimitByLevel(
    int level, {
    bool noDebt = false,
    bool maxEmergency = false,
  }) {
    if (level <= 10) {
      return {
        SectorType.living: 5.0,
        SectorType.payDebt: 3.0,
        SectorType.emergency: 3.0,
        SectorType.investment: null,
        SubSectorType.essentials: 5.0,
        SubSectorType.dreamFund: 0.0,
        SubSectorType.lowRisk: 3.0,
        SubSectorType.mediumRisk: null,
        SubSectorType.highRisk: null,
      };
    }
    if (level <= 20) {
      return {
        SectorType.living: 5.0,
        SectorType.payDebt: 3.0,
        SectorType.emergency: 4.0,
        SectorType.investment: 2.0,
        SubSectorType.essentials: 5.0,
        SubSectorType.dreamFund: 0.0,
        SubSectorType.lowRisk: 4.0,
        SubSectorType.mediumRisk: 2.0,
        SubSectorType.highRisk: null,
      };
    }
    if (level <= 30) {
      return {
        SectorType.living: 7.0,
        SectorType.payDebt: 5.0,
        SectorType.emergency: 4.0,
        SectorType.investment: 7.0,
        SubSectorType.essentials: 7.0,
        SubSectorType.dreamFund: 0.0,
        SubSectorType.lowRisk: 4.0,
        SubSectorType.mediumRisk: 5.0,
        SubSectorType.highRisk: 2.0,
      };
    }
    if (level <= 40) {
      return {
        SectorType.living: 7.0,
        SectorType.payDebt: 5.0,
        SectorType.emergency: 5.0,
        SectorType.investment: 10.0,
        SubSectorType.essentials: 7.0,
        SubSectorType.dreamFund: 0.0,
        SubSectorType.lowRisk: 5.0,
        SubSectorType.mediumRisk: 5.0,
        SubSectorType.highRisk: 5.0,
      };
    }
    if (level < 50) {
      return {
        SectorType.living: 10.0,
        SectorType.payDebt: 5.0,
        SectorType.emergency: 10.0,
        SectorType.investment: 10.0,
        SubSectorType.essentials: 10.0,
        SubSectorType.dreamFund: 0.0,
        SubSectorType.lowRisk: 10.0,
        SubSectorType.mediumRisk: 5.0,
        SubSectorType.highRisk: 5.0,
      };
    }
    return {
      SectorType.living: null,
      SectorType.payDebt: null,
      SectorType.emergency: null,
      SectorType.investment: null,
      SubSectorType.essentials: null,
      SubSectorType.dreamFund: null,
      SubSectorType.lowRisk: null,
      SubSectorType.mediumRisk: null,
      SubSectorType.highRisk: null,
    };
  }
}
