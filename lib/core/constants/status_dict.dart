import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';
import 'app_colors.dart';

class StatusDict {
  static const CategoryModel pending = CategoryModel(
    terminology: TermModel(normal: 'Tertunda', rpg: 'Berjalan'),
    color: AppColors.warning,
    icons: IconModel(
      normal: FontAwesomeIcons.hourglassHalf,
      rpg: FontAwesomeIcons.fireFlameCurved,
    ),
  );

  static const CategoryModel overdue = CategoryModel(
    terminology: TermModel(normal: 'Terlambat', rpg: 'Kritis'),
    color: AppColors.error,
    icons: IconModel(
      normal: FontAwesomeIcons.circleExclamation,
      rpg: FontAwesomeIcons.skull,
    ),
  );

  static const CategoryModel paid = CategoryModel(
    terminology: TermModel(normal: 'Lunas', rpg: 'Tuntas'),
    color: AppColors.success,
    icons: IconModel(
      normal: FontAwesomeIcons.circleCheck,
      rpg: FontAwesomeIcons.medal,
    ),
  );

  static CategoryModel getbyEnum(StatusType status) {
    switch (status) {
      case StatusType.pending:
        return pending;
      case StatusType.overdue:
        return overdue;
      case StatusType.paid:
        return paid;
    }
  }
}
