import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';

class ProfileDict {
  static const TermModel missions = TermModel(
    normal: 'Daily Missions',
    rpg: 'Guild Tasks',
  );

  static const TermModel stats = TermModel(
    normal: 'Allocation Stats',
    rpg: 'Combat Stats',
  );

  static const TermModel allocationTree = TermModel(
    normal: 'Allocation Tree',
    rpg: 'Skill Tree',
  );

  static const CategoryModel baseDaily = CategoryModel(
    terminology: TermModel(normal: 'Base Daily Limit', rpg: 'Base Daily Mana'),
    icons: IconModel(
      normal: FontAwesomeIcons.bolt,
      rpg: FontAwesomeIcons.flask,
    ),
  );
}
