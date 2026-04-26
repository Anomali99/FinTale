import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/assets_model.dart';
import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';

class AssetsDict {
  static const CategoryModel lowRisk = CategoryModel(
    terminology: TermModel(normal: 'Low Risk', rpg: 'Tanker'),
    color: Color(0xFF81C784),
    description:
        'Stable and secure assets designed to protect your capital. While the returns are modest, these investments act as the ultimate shield against market volatility, ensuring steady, long-term growth.',
    icons: IconModel(
      normal: FontAwesomeIcons.vault,
      rpg: FontAwesomeIcons.shieldHalved,
    ),
  );

  static const CategoryModel mediumRisk = CategoryModel(
    terminology: TermModel(normal: 'Medium Risk', rpg: 'Fighter'),
    color: Color(0xFFFFB74D),
    description:
        'The vanguard of your portfolio. These assets offer a balanced mix of risk and reward, aiming for substantial capital appreciation and potential dividends to consistently build your wealth.',
    icons: IconModel(
      normal: FontAwesomeIcons.chartLine,
      rpg: FontAwesomeIcons.handFist,
    ),
  );

  static const CategoryModel highRisk = CategoryModel(
    terminology: TermModel(normal: 'High Risk', rpg: 'Assassin'),
    color: Color(0xFFF06292),
    description:
        'Highly volatile assets capable of delivering massive, rapid gains—or severe losses. Perfect for aggressive growth strategies, but requires precise timing and a high tolerance for danger.',
    icons: IconModel(
      normal: FontAwesomeIcons.rocket,
      rpg: FontAwesomeIcons.userNinja,
    ),
  );

  static CategoryModel getByEnum(RiskType type) {
    switch (type) {
      case RiskType.low:
        return lowRisk;
      case RiskType.medium:
        return mediumRisk;
      case RiskType.high:
        return highRisk;
    }
  }
}
