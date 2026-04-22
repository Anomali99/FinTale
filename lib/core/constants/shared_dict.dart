import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';

class SharedDict {
  static const CategoryModel income = CategoryModel(
    terminology: TermModel(normal: 'Income', rpg: 'Loot'),
    icons: IconModel(
      normal: FontAwesomeIcons.arrowTurnDown,
      rpg: FontAwesomeIcons.sackDollar,
    ),
  );

  static const CategoryModel expense = CategoryModel(
    terminology: TermModel(normal: 'Expense', rpg: 'Damage Taken'),
    icons: IconModel(
      normal: FontAwesomeIcons.arrowTrendDown,
      rpg: FontAwesomeIcons.heartCrack,
    ),
  );

  static const CategoryModel transfer = CategoryModel(
    terminology: TermModel(normal: 'Transfer', rpg: 'Distribute'),
    icons: IconModel(
      normal: FontAwesomeIcons.moneyBillTransfer,
      rpg: FontAwesomeIcons.dolly,
    ),
  );

  static const CategoryModel filter = CategoryModel(
    terminology: TermModel(normal: 'Filter', rpg: 'Sort Magic'),
    icons: IconModel(
      normal: FontAwesomeIcons.filter,
      rpg: FontAwesomeIcons.wandMagicSparkles,
    ),
  );

  static const TermModel invest = TermModel(normal: 'Invest', rpg: 'Armory');

  static const TermModel unallocated = TermModel(
    normal: 'Unallocated (Idle)',
    rpg: 'Idle Mana',
  );
}
