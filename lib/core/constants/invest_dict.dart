import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';

class InvestDict {
  static const TermModel total = TermModel(
    normal: 'Total Portfolio',
    rpg: 'Total Troop Strength',
  );

  static const TermModel invested = TermModel(
    normal: 'Invested Capital',
    rpg: 'Deployed Gold',
  );

  static const TermModel value = TermModel(
    normal: 'Current Value',
    rpg: 'Current Power',
  );

  static const TermModel empty = TermModel(
    normal: 'No assets here yet.\nAdd one now!',
    rpg: 'No troops in this division.\nRecruit now!',
  );

  static const CategoryModel add = CategoryModel(
    terminology: TermModel(normal: 'Add Asset', rpg: 'Recruit Troops'),
    icons: IconModel(
      normal: FontAwesomeIcons.folderPlus,
      rpg: FontAwesomeIcons.flag,
    ),
  );
}
