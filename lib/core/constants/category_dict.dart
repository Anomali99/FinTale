import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/transaction_detail_model.dart';
import '../../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';

class CategoryDict {
  static const CategoryModel food = CategoryModel(
    type: 'expense',
    color: Colors.redAccent,
    terminology: TermModel(normal: 'Makan & Minum', rpg: 'Ramuan & Ransum'),
    icons: IconModel(
      normal: FontAwesomeIcons.utensils,
      rpg: FontAwesomeIcons.flask,
    ),
  );

  static const CategoryModel groceries = CategoryModel(
    type: 'expense',
    color: Colors.orange,
    terminology: TermModel(normal: 'Kebutuhan Harian', rpg: 'Suplai Guild'),
    icons: IconModel(
      normal: FontAwesomeIcons.basketShopping,
      rpg: FontAwesomeIcons.sackXmark,
    ),
  );

  static const CategoryModel transport = CategoryModel(
    type: 'expense',
    color: Colors.purpleAccent,
    terminology: TermModel(normal: 'Transportasi', rpg: 'Tunggangan (Mounts)'),
    icons: IconModel(normal: FontAwesomeIcons.car, rpg: FontAwesomeIcons.horse),
  );

  static const CategoryModel entertainment = CategoryModel(
    type: 'expense',
    color: Colors.pinkAccent,
    terminology: TermModel(normal: 'Hiburan', rpg: 'Tavern & Pesta'),
    icons: IconModel(
      normal: FontAwesomeIcons.gamepad,
      rpg: FontAwesomeIcons.music,
    ),
  );

  static const CategoryModel health = CategoryModel(
    type: 'expense',
    color: Colors.teal,
    terminology: TermModel(normal: 'Kesehatan & Medis', rpg: 'Healer & Obat'),
    icons: IconModel(
      normal: FontAwesomeIcons.staffSnake,
      rpg: FontAwesomeIcons.heartPulse,
    ),
  );

  static const CategoryModel utilities = CategoryModel(
    type: 'expense',
    color: Colors.blueAccent,
    terminology: TermModel(normal: 'Tagihan & Utilitas', rpg: 'Pajak Guild'),
    icons: IconModel(
      normal: FontAwesomeIcons.fileInvoiceDollar,
      rpg: FontAwesomeIcons.scroll,
    ),
  );

  static const CategoryModel debtInstallment = CategoryModel(
    type: 'debt',
    color: Colors.deepOrange,
    terminology: TermModel(normal: 'Cicilan Hutang', rpg: 'Serangan ke Boss'),
    icons: IconModel(
      normal: FontAwesomeIcons.handHoldingDollar,
      rpg: FontAwesomeIcons.dragon,
    ),
  );

  static const CategoryModel salary = CategoryModel(
    type: 'income',
    color: Colors.green,
    terminology: TermModel(normal: 'Gaji & Upah', rpg: 'Hadiah Misi (Bounty)'),
    icons: IconModel(
      normal: FontAwesomeIcons.briefcase,
      rpg: FontAwesomeIcons.gem,
    ),
  );

  static const CategoryModel business = CategoryModel(
    type: 'income',
    color: Colors.lightGreen,
    terminology: TermModel(
      normal: 'Bisnis & Bonus',
      rpg: 'Keuntungan Merchant',
    ),
    icons: IconModel(
      normal: FontAwesomeIcons.shop,
      rpg: FontAwesomeIcons.scaleBalanced,
    ),
  );

  static const CategoryModel dividend = CategoryModel(
    type: 'income',
    color: Colors.amber,
    terminology: TermModel(normal: 'Dividen & Bunga', rpg: 'Loot Pasif'),
    icons: IconModel(
      normal: FontAwesomeIcons.coins,
      rpg: FontAwesomeIcons.sackDollar,
    ),
  );

  static const CategoryModel transfer = CategoryModel(
    type: 'transfer',
    color: Colors.blueGrey,
    terminology: TermModel(normal: 'Transfer Dompet', rpg: 'Karavan Suplai'),
    icons: IconModel(
      normal: FontAwesomeIcons.arrowRightArrowLeft,
      rpg: FontAwesomeIcons.dolly,
    ),
  );

  static const CategoryModel investment = CategoryModel(
    type: 'transfer',
    color: Colors.indigo,
    terminology: TermModel(normal: 'Investasi', rpg: 'Kirim Pasukan'),
    icons: IconModel(
      normal: FontAwesomeIcons.chartLine,
      rpg: FontAwesomeIcons.shieldHalved,
    ),
  );

  static List<CategoryModel> get all => [
    food,
    groceries,
    transport,
    entertainment,
    health,
    utilities,
    debtInstallment,
    salary,
    business,
    dividend,
    transfer,
    investment,
  ];

  static List<CategoryModel> getByCategoryType(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return [food, groceries, transport, entertainment, health, utilities];
      case TransactionType.income:
        return [salary, business, dividend];
      case TransactionType.transfer:
        return [transfer, investment];
      case TransactionType.debt:
        return [debtInstallment];
    }
  }

  static CategoryModel getByTransactionCategory(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return food;
      case TransactionCategory.groceries:
        return groceries;
      case TransactionCategory.transport:
        return transport;
      case TransactionCategory.entertainment:
        return entertainment;
      case TransactionCategory.health:
        return health;
      case TransactionCategory.utilities:
        return utilities;
      case TransactionCategory.debtInstallment:
        return debtInstallment;
      case TransactionCategory.salary:
        return salary;
      case TransactionCategory.business:
        return business;
      case TransactionCategory.dividend:
        return dividend;
      case TransactionCategory.transfer:
        return transfer;
      case TransactionCategory.investment:
        return investment;
    }
  }
}
