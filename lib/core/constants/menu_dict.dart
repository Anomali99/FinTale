import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';

class MenuDict {
  static const CategoryModel home = CategoryModel(
    terminology: TermModel(normal: 'Home', rpg: 'Guild Hall'),
    icons: IconModel(
      normal: FontAwesomeIcons.house,
      rpg: FontAwesomeIcons.chessRook,
    ),
  );

  static const CategoryModel bills = CategoryModel(
    terminology: TermModel(normal: 'Bills', rpg: 'Quest Board'),
    icons: IconModel(
      normal: FontAwesomeIcons.receipt,
      rpg: FontAwesomeIcons.scroll,
    ),
  );

  static const CategoryModel invest = CategoryModel(
    terminology: TermModel(normal: 'Invest', rpg: 'Armory'),
    icons: IconModel(
      normal: FontAwesomeIcons.chartLine,
      rpg: FontAwesomeIcons.shieldHalved,
    ),
  );

  static const CategoryModel history = CategoryModel(
    terminology: TermModel(normal: 'History', rpg: 'Battle Log'),
    icons: IconModel(
      normal: FontAwesomeIcons.clockRotateLeft,
      rpg: FontAwesomeIcons.bookJournalWhills,
    ),
  );

  static const CategoryModel analytics = CategoryModel(
    terminology: TermModel(normal: 'Analytics', rpg: 'Guild Report'),
    icons: IconModel(
      normal: FontAwesomeIcons.chartPie,
      rpg: FontAwesomeIcons.eye,
    ),
  );

  static const CategoryModel pay = CategoryModel(
    terminology: TermModel(normal: 'Pay Debt', rpg: 'Attack Attack Boss'),
    decription: 'Record a debt installment',
    icons: IconModel(
      normal: FontAwesomeIcons.buildingColumns,
      rpg: FontAwesomeIcons.khanda,
    ),
  );

  static const CategoryModel daily = CategoryModel(
    terminology: TermModel(normal: 'Daily Expense', rpg: 'Use Mana'),
    decription: 'Record food, transport, etc.',
    icons: IconModel(
      normal: FontAwesomeIcons.wallet,
      rpg: FontAwesomeIcons.flask,
    ),
  );
}
