import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';

class BillsDict {
  static const TermModel bills = TermModel(
    normal: 'Current Bills',
    rpg: 'Active Quests',
  );

  static const TermModel template = TermModel(
    normal: 'Template Bills',
    rpg: 'Master Quests',
  );

  static const TermModel debts = TermModel(normal: 'Debts', rpg: 'Boss Raids');

  static const TermModel remaining = TermModel(
    normal: 'Remaining Debt',
    rpg: 'HP Remaining',
  );

  static const CategoryModel pay = CategoryModel(
    terminology: TermModel(normal: 'Pay', rpg: 'Attack'),
    icons: IconModel(
      normal: FontAwesomeIcons.check,
      rpg: FontAwesomeIcons.wandMagicSparkles,
    ),
  );

  static const IconModel addIcon = IconModel(
    normal: FontAwesomeIcons.receipt,
    rpg: FontAwesomeIcons.dragon,
  );

  static const CategoryModel addTemplate = CategoryModel(
    terminology: TermModel(
      normal: 'Add Template Bill',
      rpg: 'Add Master Quest',
    ),
    description: 'Create a new recurring payment template',
    icons: IconModel(
      normal: FontAwesomeIcons.receipt,
      rpg: FontAwesomeIcons.scroll,
    ),
  );

  static const CategoryModel addDebt = CategoryModel(
    terminology: TermModel(normal: 'Add Debt', rpg: 'Add Boss Raid'),
    description: 'Record a new loan or major debt',
    icons: IconModel(
      normal: FontAwesomeIcons.buildingColumns,
      rpg: FontAwesomeIcons.dragon,
    ),
  );
}
