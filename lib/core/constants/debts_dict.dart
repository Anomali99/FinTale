import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/debt_model.dart';
import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';

class DebtsDict {
  static const CategoryModel creditCard = CategoryModel(
    terminology: TermModel(normal: 'Kartu Kredit', rpg: 'Debuff Racun'),
    icons: IconModel(
      normal: FontAwesomeIcons.creditCard,
      rpg: FontAwesomeIcons.skullCrossbones,
    ),
  );

  static const CategoryModel mortgage = CategoryModel(
    terminology: TermModel(normal: 'KPR (Rumah)', rpg: 'Pertahanan Kastil'),
    icons: IconModel(
      normal: FontAwesomeIcons.house,
      rpg: FontAwesomeIcons.chessRook,
    ),
  );

  static const CategoryModel vehicle = CategoryModel(
    terminology: TermModel(normal: 'Kredit Kendaraan', rpg: 'Cicilan Mount'),
    icons: IconModel(normal: FontAwesomeIcons.car, rpg: FontAwesomeIcons.horse),
  );

  static const CategoryModel personal = CategoryModel(
    terminology: TermModel(normal: 'Pinjaman Pribadi', rpg: 'Hutang Tavern'),
    icons: IconModel(
      normal: FontAwesomeIcons.handshake,
      rpg: FontAwesomeIcons.beerMugEmpty,
    ),
  );

  static const CategoryModel business = CategoryModel(
    terminology: TermModel(normal: 'Pinjaman Modal', rpg: 'Hutang Merchant'),
    icons: IconModel(
      normal: FontAwesomeIcons.store,
      rpg: FontAwesomeIcons.scaleBalanced,
    ),
  );

  static const CategoryModel other = CategoryModel(
    terminology: TermModel(normal: 'Hutang Lainnya', rpg: 'Kutukan Misterius'),
    icons: IconModel(
      normal: FontAwesomeIcons.fileInvoiceDollar,
      rpg: FontAwesomeIcons.ghost,
    ),
  );

  static CategoryModel getByEnum(DebtType type) {
    switch (type) {
      case DebtType.creditCard:
        return creditCard;
      case DebtType.mortgage:
        return mortgage;
      case DebtType.vehicle:
        return vehicle;
      case DebtType.personal:
        return personal;
      case DebtType.business:
        return business;
      case DebtType.other:
        return other;
    }
  }
}
