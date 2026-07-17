import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';
import '../utils/enum_types.dart';

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

  static const CategoryModel lending = CategoryModel(
    type: 'expense',
    color: Colors.deepOrangeAccent,
    terminology: TermModel(
      normal: 'Memberi Pinjaman',
      rpg: 'Pinjaman Petualang',
    ),
    icons: IconModel(
      normal: FontAwesomeIcons.handHoldingDollar,
      rpg: FontAwesomeIcons.coins,
    ),
  );

  static const CategoryModel charity = CategoryModel(
    type: 'expense',
    color: Colors.cyan,
    terminology: TermModel(normal: 'Amal & Donasi', rpg: 'Sumbangan Kuil'),
    icons: IconModel(
      normal: FontAwesomeIcons.handHoldingHeart,
      rpg: FontAwesomeIcons.church,
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

  static const CategoryModel debtCollection = CategoryModel(
    type: 'income',
    color: Colors.teal,
    terminology: TermModel(
      normal: 'Pembayaran Piutang',
      rpg: 'Penebusan Kontrak',
    ),
    icons: IconModel(
      normal: FontAwesomeIcons.moneyCheckDollar,
      rpg: FontAwesomeIcons.sackDollar,
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

  static const CategoryModel lowRisk = CategoryModel(
    type: 'Investasi',
    color: Color(0xFF81C784),
    terminology: TermModel(normal: 'Risiko Rendah', rpg: 'Tanker'),
    description:
        'Aset yang stabil dan aman untuk melindungi modalmu. Meski serangannya (return) kecil, aset ini adalah perisai terkuat menahan volatilitas pasar.',
    icons: IconModel(
      normal: FontAwesomeIcons.vault,
      rpg: FontAwesomeIcons.shieldHalved,
    ),
  );

  static const CategoryModel mediumRisk = CategoryModel(
    type: 'Investasi',
    color: Color(0xFFFFB74D),
    terminology: TermModel(normal: 'Risiko Menengah', rpg: 'Fighter'),
    description:
        'Pasukan garis depan portofoliomu. Menawarkan keseimbangan antara risiko dan hadiah.',
    icons: IconModel(
      normal: FontAwesomeIcons.chartLine,
      rpg: FontAwesomeIcons.handFist,
    ),
  );

  static const CategoryModel highRisk = CategoryModel(
    type: 'Investasi',
    color: Color(0xFFF06292),
    terminology: TermModel(normal: 'Risiko Tinggi', rpg: 'Assassin'),
    description:
        'Aset liar yang mampu memberikan keuntungan masif secara cepat—atau kerugian fatal.',
    icons: IconModel(
      normal: FontAwesomeIcons.rocket,
      rpg: FontAwesomeIcons.userNinja,
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

  static const CategoryModel personalLoan = CategoryModel(
    terminology: TermModel(normal: 'Pinjaman Pribadi', rpg: 'Hutang Tavern'),
    icons: IconModel(
      normal: FontAwesomeIcons.handshake,
      rpg: FontAwesomeIcons.beerMugEmpty,
    ),
  );

  static const CategoryModel businessLoan = CategoryModel(
    terminology: TermModel(normal: 'Pinjaman Modal', rpg: 'Hutang Merchant'),
    icons: IconModel(
      normal: FontAwesomeIcons.store,
      rpg: FontAwesomeIcons.scaleBalanced,
    ),
  );

  static const CategoryModel otherDebt = CategoryModel(
    terminology: TermModel(normal: 'Hutang Lainnya', rpg: 'Kutukan Misterius'),
    icons: IconModel(
      normal: FontAwesomeIcons.fileInvoiceDollar,
      rpg: FontAwesomeIcons.ghost,
    ),
  );

  static const CategoryModel statusPending = CategoryModel(
    terminology: TermModel(normal: 'Tertunda', rpg: 'Berjalan'),
    color: Colors.amber,
    icons: IconModel(
      normal: FontAwesomeIcons.hourglassHalf,
      rpg: FontAwesomeIcons.fireFlameCurved,
    ),
  );

  static const CategoryModel statusOverdue = CategoryModel(
    terminology: TermModel(normal: 'Terlambat', rpg: 'Kritis'),
    color: Colors.red,
    icons: IconModel(
      normal: FontAwesomeIcons.circleExclamation,
      rpg: FontAwesomeIcons.skull,
    ),
  );

  static const CategoryModel statusPaid = CategoryModel(
    terminology: TermModel(normal: 'Lunas', rpg: 'Tuntas'),
    color: Colors.green,
    icons: IconModel(
      normal: FontAwesomeIcons.circleCheck,
      rpg: FontAwesomeIcons.medal,
    ),
  );

  static List<CategoryModel> get all => [
    food,
    groceries,
    transport,
    entertainment,
    health,
    lending,
    charity,
    utilities,
    debtInstallment,
    salary,
    business,
    debtCollection,
    dividend,
    transfer,
    lowRisk,
    mediumRisk,
    highRisk,
  ];

  static CategoryModel getAssetByEnum(RiskType type) {
    switch (type) {
      case RiskType.low:
        return lowRisk;
      case RiskType.medium:
        return mediumRisk;
      case RiskType.high:
        return highRisk;
    }
  }

  static CategoryModel getDebtByEnum(DebtType type) {
    switch (type) {
      case DebtType.creditCard:
        return creditCard;
      case DebtType.mortgage:
        return mortgage;
      case DebtType.vehicle:
        return vehicle;
      case DebtType.personal:
        return personalLoan;
      case DebtType.business:
        return businessLoan;
      case DebtType.other:
        return otherDebt;
    }
  }

  static CategoryModel getStatusByEnum(StatusType status) {
    switch (status) {
      case StatusType.pending:
        return statusPending;
      case StatusType.overdue:
        return statusOverdue;
      case StatusType.paid:
        return statusPaid;
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
      case TransactionCategory.lending:
        return lending;
      case TransactionCategory.charity:
        return charity;
      case TransactionCategory.utilities:
        return utilities;
      case TransactionCategory.debtInstallment:
        return debtInstallment;
      case TransactionCategory.salary:
        return salary;
      case TransactionCategory.business:
        return business;
      case TransactionCategory.debtCollection:
        return debtCollection;
      case TransactionCategory.dividend:
        return dividend;
      case TransactionCategory.transfer:
        return transfer;
      case TransactionCategory.lowRisk:
        return lowRisk;
      case TransactionCategory.mediumRisk:
        return mediumRisk;
      case TransactionCategory.highRisk:
        return highRisk;
    }
  }
}
