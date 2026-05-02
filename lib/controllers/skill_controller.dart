import 'package:fintale/models/allocation_model.dart';
import 'package:flutter/material.dart';

import '../core/utils/leveling_extension.dart';
import 'user_controller.dart';

class SkillController with ChangeNotifier {
  final UserController _userController;
  Map<Enum, double?> baseAllocation = {};
  Map<Enum, double?> baseLimitAllocation = {};
  double extraFreeAllocation = 0;
  double freeAllocation = 0;
  Map<SectorType, double> extraFreeAllocationLv1 = {
    SectorType.living: 0.0,
    SectorType.payDebt: 0.0,
    SectorType.emergency: 0.0,
    SectorType.investment: 0.0,
  };
  Map<SectorType, double> freeAllocationLv1 = {
    SectorType.living: 0.0,
    SectorType.payDebt: 0.0,
    SectorType.emergency: 0.0,
    SectorType.investment: 0.0,
  };
  Enum? selectedNode;
  bool isLoading = true;

  SkillController(this._userController) {
    loadData();
  }

  bool get isRpg => _userController.isRpgMode;

  Map<Enum, double?> get skillAllocations => _userController.userAllocations;

  double? get currentPercentage {
    if (selectedNode == null) return null;
    return skillAllocations[selectedNode];
  }

  void changeNode(Enum? node) {
    if (selectedNode != node) {
      selectedNode = node;
      notifyListeners();
    }
  }

  Future<void> loadData() async {
    isLoading = true;
    Future.microtask(() => notifyListeners());
    try {
      baseAllocation = AllocationMap.getAllocationByLevel(
        _userController.userLevel,
        maxEmergency: _userController.isEmergencyMax,
        noDebt: _userController.isFreeDebt,
      );
      baseLimitAllocation = AllocationMap.getAllocationLimitByLevel(
        _userController.userLevel,
      );

      extraFreeAllocation = 0.0;
      freeAllocation = 0.0;
      extraFreeAllocationLv1.clear();

      for (SectorType sector in SectorType.values) {
        if (skillAllocations[sector] == null) {
          extraFreeAllocation += baseAllocation[sector] ?? 0.0;
        }
      }

      _calculateSectorPool(SectorType.living);
      _calculateSectorPool(SectorType.payDebt);
      _calculateSectorPool(SectorType.emergency);
      _calculateSectorPool(SectorType.investment);

      if (freeAllocation < 0) {
        extraFreeAllocation += freeAllocation;
        freeAllocation = 0.0;
      }

      _setupChildCake(SectorType.living, [
        SubSectorType.essentials,
        SubSectorType.dreamFund,
      ]);
      _setupChildCake(SectorType.investment, [
        SubSectorType.mediumRisk,
        SubSectorType.highRisk,
      ]);
      _setupLowRiskCake();
    } catch (e) {
      debugPrint("[SKILL] An error occurred while loading profile: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _calculateSectorPool(SectorType sector) {
    double? allocated = skillAllocations[sector];
    if (allocated == null) return;

    double basePoint = baseAllocation[sector] ?? 0.0;
    double limitPoint = baseLimitAllocation[sector] ?? 0.0;

    if (allocated < basePoint) {
      freeAllocation += (basePoint - allocated);
    } else if (allocated > basePoint) {
      double diff = allocated - basePoint;

      double maxRegularLimit = (limitPoint == 0.0) ? diff : limitPoint;

      if (diff <= maxRegularLimit) {
        freeAllocation -= diff;
      } else {
        freeAllocation -= maxRegularLimit;
        extraFreeAllocation -= (diff - maxRegularLimit);
      }
    }

    extraFreeAllocationLv1[sector] = allocated;
  }

  void _setupChildCake(SectorType parent, List<SubSectorType> children) {
    double parentTotal = extraFreeAllocationLv1[parent] ?? 0.0;
    double usedByChildren = 0.0;

    for (var child in children) {
      usedByChildren += skillAllocations[child] ?? 0.0;
    }

    extraFreeAllocationLv1[parent] = parentTotal - usedByChildren;
  }

  void _setupLowRiskCake() {
    double lowRiskAllocated = skillAllocations[SubSectorType.lowRisk] ?? 0.0;
    double emergencyCake = extraFreeAllocationLv1[SectorType.emergency] ?? 0.0;
    double investmentCake =
        extraFreeAllocationLv1[SectorType.investment] ?? 0.0;

    if (lowRiskAllocated <= emergencyCake) {
      extraFreeAllocationLv1[SectorType.emergency] =
          emergencyCake - lowRiskAllocated;
    } else {
      double remainingNeed = lowRiskAllocated - emergencyCake;
      extraFreeAllocationLv1[SectorType.emergency] = 0.0;
      extraFreeAllocationLv1[SectorType.investment] =
          investmentCake - remainingNeed;
    }
  }

  void _squeezeChildren(SectorType sector) {
    double leftoverCake = extraFreeAllocationLv1[sector] ?? 0.0;
    if (leftoverCake > 0) return;

    if (sector == SectorType.living) {
      double dream = skillAllocations[SubSectorType.dreamFund] ?? 0.0;
      double ess = skillAllocations[SubSectorType.essentials] ?? 0.0;

      if (dream > 0) {
        _userController.updateSkillByKey(SubSectorType.dreamFund, dream - 1);
      } else if (ess > 0) {
        _userController.updateSkillByKey(SubSectorType.essentials, ess - 1);
      }
    } else if (sector == SectorType.emergency) {
      double invCake = extraFreeAllocationLv1[SectorType.investment] ?? 0.0;

      if (invCake <= 0) {
        double low = skillAllocations[SubSectorType.lowRisk] ?? 0.0;
        if (low > 0) {
          _userController.updateSkillByKey(SubSectorType.lowRisk, low - 1);
        }
      }
    } else if (sector == SectorType.investment) {
      double high = skillAllocations[SubSectorType.highRisk] ?? 0.0;
      double med = skillAllocations[SubSectorType.mediumRisk] ?? 0.0;
      double low = skillAllocations[SubSectorType.lowRisk] ?? 0.0;

      if (high > 0) {
        _userController.updateSkillByKey(SubSectorType.highRisk, high - 1);
      } else if (med > 0) {
        _userController.updateSkillByKey(SubSectorType.mediumRisk, med - 1);
      } else if (low > 0) {
        _userController.updateSkillByKey(SubSectorType.lowRisk, low - 1);
      }
    }
  }

  Future<void> increaseAllocation() async {
    if (selectedNode == null) return;

    double current = currentPercentage ?? 0.0;
    bool isSector = selectedNode is SectorType;

    if (isSector) {
      SectorType sector = selectedNode as SectorType;
      double basePoint = baseAllocation[sector] ?? 0.0;
      double limitPoint = baseLimitAllocation[sector] ?? 0.0;

      double maxRegularAllowed = (limitPoint == 0.0)
          ? 100.0
          : basePoint + limitPoint;

      if (current < maxRegularAllowed && freeAllocation > 0) {
        freeAllocation -= 1;
      } else if (extraFreeAllocation > 0) {
        extraFreeAllocation -= 1;
      } else {
        return;
      }
    } else {
      SubSectorType subSector = selectedNode as SubSectorType;
      double basePoint = baseAllocation[subSector] ?? 0.0;
      double limitPoint = baseLimitAllocation[subSector] ?? 0.0;
      double maxRegularAllowed = (limitPoint == 0.0)
          ? 100.0
          : basePoint + limitPoint;

      SectorType? parent = _getParent(subSector);
      bool parentUsingExtra = false;
      if (parent != null) {
        double pBase = baseAllocation[parent] ?? 0.0;
        double pLimit = baseLimitAllocation[parent] ?? 0.0;
        double pMax = (pLimit == 0.0) ? 100.0 : pBase + pLimit;
        double pAllocated = skillAllocations[parent] ?? 0.0;
        if (pAllocated > pMax) parentUsingExtra = true;
      }

      if (current >= maxRegularAllowed &&
          !parentUsingExtra &&
          limitPoint != 0.0) {
        return;
      }

      if (parent != null) {
        if (subSector == SubSectorType.lowRisk) {
          if ((extraFreeAllocationLv1[SectorType.emergency] ?? 0) > 0) {
            extraFreeAllocationLv1[SectorType.emergency] =
                (extraFreeAllocationLv1[SectorType.emergency]!) - 1;
          } else if ((extraFreeAllocationLv1[SectorType.investment] ?? 0) > 0) {
            extraFreeAllocationLv1[SectorType.investment] =
                (extraFreeAllocationLv1[SectorType.investment]!) - 1;
          } else {
            return;
          }
        } else {
          if ((extraFreeAllocationLv1[parent] ?? 0) > 0) {
            extraFreeAllocationLv1[parent] =
                (extraFreeAllocationLv1[parent]!) - 1;
          } else if ((freeAllocationLv1[parent] ?? 0) > 0) {
            freeAllocationLv1[parent] = (freeAllocationLv1[parent]!) - 1;
          } else {
            return;
          }
        }
      }
    }

    if (current < 100) {
      _userController.updateSkillByKey(selectedNode!, current + 1);
      await _userController.saveUser();
      await loadData();
      notifyListeners();
    }
  }

  Future<void> decreaseAllocation() async {
    if (selectedNode == null) return;

    double current = currentPercentage ?? 0.0;
    bool isSector = selectedNode is SectorType;

    if (isSector) {
      SectorType sector = selectedNode as SectorType;
      double basePoint = baseAllocation[sector] ?? 0.0;
      double limitPoint = baseLimitAllocation[sector] ?? 0.0;

      double minAllowed = (limitPoint == 0.0) ? 0.0 : basePoint - limitPoint;

      if (current <= minAllowed || current <= 0.0) return;
      _squeezeChildren(sector);
    } else {
      SubSectorType subSector = selectedNode as SubSectorType;
      double basePoint = baseAllocation[subSector] ?? 0.0;
      double limitPoint = baseLimitAllocation[subSector] ?? 0.0;

      double minAllowed = (limitPoint == 0.0) ? 0.0 : basePoint - limitPoint;

      if (current <= minAllowed || current <= 0.0) return;
    }

    if (current > 0) {
      _userController.updateSkillByKey(selectedNode!, current - 1);
      await _userController.saveUser();
      await loadData();
      notifyListeners();
    }
  }

  Future<void> resetAllocation() async {
    _userController.updateSkill(baseAllocation);
    await _userController.saveUser();
    await loadData();
    notifyListeners();
  }

  SectorType? _getParent(SubSectorType child) {
    if (child == SubSectorType.essentials || child == SubSectorType.dreamFund)
      return SectorType.living;
    if (child == SubSectorType.mediumRisk || child == SubSectorType.highRisk)
      return SectorType.investment;
    return null;
  }
}
