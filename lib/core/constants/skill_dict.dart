import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/allocation_model.dart';
import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';
import 'assets_dict.dart';
import 'shared_dict.dart';

class SkillDict {
  static const CategoryModel income = SharedDict.income;

  static const CategoryModel dailyParent = CategoryModel(
    terminology: TermModel(normal: 'Living Expenses', rpg: 'Stamina'),
    description:
        'The core energy required to keep your character alive and functioning in the game world.',
    icons: IconModel(
      normal: FontAwesomeIcons.wallet,
      rpg: FontAwesomeIcons.heartPulse,
    ),
    color: Color(0xFF4FC3F7),
  );

  static const CategoryModel dailyRoutine = CategoryModel(
    terminology: TermModel(normal: 'Essentials', rpg: 'Rations'),
    description:
        'Consumables and fixed costs like food, utilities, and shelter. Unavoidable upkeep for survival.',
    icons: IconModel(
      normal: FontAwesomeIcons.basketShopping,
      rpg: FontAwesomeIcons.drumstickBite,
    ),
    color: Color(0xFF81D4FA),
  );

  static const CategoryModel dreamFund = CategoryModel(
    terminology: TermModel(normal: 'Dream Fund', rpg: 'Quest Chest'),
    description:
        'Resources gathered for specific future goals or items. Accumulate mana here to unlock big rewards later.',
    icons: IconModel(normal: FontAwesomeIcons.star, rpg: FontAwesomeIcons.gem),
    color: Color(0xFFCE93D8),
  );

  static const CategoryModel debt = CategoryModel(
    terminology: TermModel(normal: 'Pay Debt', rpg: 'Attack Boss'),
    description:
        'A lingering debuff that drains your loot over time. Clear this condition to restore your full earning potential.',
    icons: IconModel(
      normal: FontAwesomeIcons.fileInvoiceDollar,
      rpg: FontAwesomeIcons.dragon,
    ),
    color: Color(0xFFE57373),
  );

  static const CategoryModel emergency = CategoryModel(
    terminology: TermModel(normal: 'Emergency Fund', rpg: 'Shield Wall'),
    description:
        'Your primary defense against random critical hits from life. Absorbs unexpected damage so your main quest is not interrupted.',
    icons: IconModel(
      normal: FontAwesomeIcons.briefcaseMedical,
      rpg: FontAwesomeIcons.shieldCat,
    ),
    color: Color(0xFF4DB6AC),
  );

  static const CategoryModel investment = CategoryModel(
    terminology: TermModel(normal: 'Investment', rpg: 'Armory'),
    description:
        'Allocated skill points to multiply your wealth passively. The true path to late-game dominance.',
    icons: IconModel(
      normal: FontAwesomeIcons.seedling,
      rpg: FontAwesomeIcons.userNinja,
    ),
    color: Color(0xFFFFB300),
  );

  static const CategoryModel lowRisk = AssetsDict.lowRisk;
  static const CategoryModel mediumRisk = AssetsDict.mediumRisk;
  static const CategoryModel highRisk = AssetsDict.highRisk;

  static CategoryModel getByEnum(Enum item) {
    switch (item) {
      case SectorType.living:
        return dailyParent;
      case SectorType.payDebt:
        return debt;
      case SectorType.emergency:
        return emergency;
      case SectorType.investment:
        return investment;
      case SubSectorType.essentials:
        return dailyRoutine;
      case SubSectorType.dreamFund:
        return dreamFund;
      case SubSectorType.lowRisk:
        return lowRisk;
      case SubSectorType.highRisk:
        return highRisk;
      case SubSectorType.mediumRisk:
        return mediumRisk;
      default:
        return dailyParent;
    }
  }
}
