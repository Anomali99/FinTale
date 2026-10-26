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

  static const CategoryModel loanDisbursement = CategoryModel(
    type: 'income',
    color: Colors.indigo,
    terminology: TermModel(normal: 'Pencairan Pinjaman', rpg: 'Pinjaman Guild'),
    icons: IconModel(
      normal: FontAwesomeIcons.buildingColumns,
      rpg: FontAwesomeIcons.fileContract,
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
    terminology: TermModel(normal: 'Transfer', rpg: 'Karavan Suplai'),
    icons: IconModel(
      normal: FontAwesomeIcons.arrowRightArrowLeft,
      rpg: FontAwesomeIcons.dolly,
    ),
  );

  static const CategoryModel pocketTransfer = CategoryModel(
    type: 'transfer',
    color: Color(0xFF5C6BC0),
    terminology: TermModel(normal: 'Antar Kantong', rpg: 'Pindah Kantong Logistik'),
    icons: IconModel(
      normal: FontAwesomeIcons.boxesPacking,
      rpg: FontAwesomeIcons.sackDollar,
    ),
  );

  static const CategoryModel topUp = CategoryModel(
    type: 'transfer',
    color: Color(0xFF42A5F5),
    terminology: TermModel(normal: 'Top Up', rpg: 'Isi Saldo Sihir'),
    icons: IconModel(
      normal: FontAwesomeIcons.wallet,
      rpg: FontAwesomeIcons.coins,
    ),
  );

  static const CategoryModel emergencyFund = CategoryModel(
    type: 'transfer',
    color: Color(0xFFE57373),
    terminology: TermModel(normal: 'Dana Darurat', rpg: 'Pasokan Darurat'),
    icons: IconModel(
      normal: FontAwesomeIcons.shieldHeart,
      rpg: FontAwesomeIcons.shieldHeart,
    ),
  );

  static const CategoryModel savings = CategoryModel(
    type: 'transfer',
    color: Color(0xFF26A69A),
    terminology: TermModel(normal: 'Tabungan', rpg: 'Pundi Tabungan'),
    icons: IconModel(
      normal: FontAwesomeIcons.piggyBank,
      rpg: FontAwesomeIcons.gem,
    ),
  );

  static const CategoryModel cashWithdrawal = CategoryModel(
    type: 'transfer',
    color: Color(0xFFFF8A65),
    terminology: TermModel(normal: 'Tarik Tunai', rpg: 'Tarik Koin Peti'),
    icons: IconModel(
      normal: FontAwesomeIcons.moneyBillWave,
      rpg: FontAwesomeIcons.sackDollar,
    ),
  );

  static const CategoryModel cashDeposit = CategoryModel(
    type: 'transfer',
    color: Color(0xFF66BB6A),
    terminology: TermModel(normal: 'Setor Tunai', rpg: 'Simpan ke Brankas'),
    icons: IconModel(
      normal: FontAwesomeIcons.moneyBills,
      rpg: FontAwesomeIcons.vault,
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

  static const CategoryModel fashion = CategoryModel(
    type: 'expense',
    color: Colors.pinkAccent,
    terminology: TermModel(normal: 'Fashion & Pakaian', rpg: 'Armor & Kostum'),
    icons: IconModel(
      normal: FontAwesomeIcons.shirt,
      rpg: FontAwesomeIcons.hatWizard,
    ),
  );

  static const CategoryModel gadget = CategoryModel(
    type: 'expense',
    color: Colors.blueAccent,
    terminology: TermModel(
      normal: 'Gadget & Elektronik',
      rpg: 'Artefak Teknologi',
    ),
    icons: IconModel(
      normal: FontAwesomeIcons.laptop,
      rpg: FontAwesomeIcons.wandMagicSparkles,
    ),
  );

  static const CategoryModel streaming = CategoryModel(
    type: 'expense',
    color: Colors.deepPurpleAccent,
    terminology: TermModel(
      normal: 'Layanan Streaming',
      rpg: 'Gulungan Pengetahuan',
    ),
    icons: IconModel(
      normal: FontAwesomeIcons.tv,
      rpg: FontAwesomeIcons.bookOpen,
    ),
  );

  static const CategoryModel gaming = CategoryModel(
    type: 'expense',
    color: Colors.indigoAccent,
    terminology: TermModel(normal: 'Games & Gaming', rpg: 'Arena Pertempuran'),
    icons: IconModel(
      normal: FontAwesomeIcons.gamepad,
      rpg: FontAwesomeIcons.diceD20,
    ),
  );

  static const CategoryModel hobby = CategoryModel(
    type: 'expense',
    color: Colors.teal,
    terminology: TermModel(normal: 'Hobi & Koleksi', rpg: 'Koleksi Relik'),
    icons: IconModel(
      normal: FontAwesomeIcons.palette,
      rpg: FontAwesomeIcons.dragon,
    ),
  );

  static const CategoryModel concert = CategoryModel(
    type: 'expense',
    color: Colors.amber,
    terminology: TermModel(normal: 'Konser & Event', rpg: 'Festival Kerajaan'),
    icons: IconModel(
      normal: FontAwesomeIcons.ticketSimple,
      rpg: FontAwesomeIcons.crown,
    ),
  );

  static const CategoryModel travel = CategoryModel(
    type: 'expense',
    color: Colors.cyan,
    terminology: TermModel(normal: 'Liburan & Wisata', rpg: 'Ekspedisi Dunia'),
    icons: IconModel(
      normal: FontAwesomeIcons.earthAsia,
      rpg: FontAwesomeIcons.mapLocationDot,
    ),
  );

  static const CategoryModel hangout = CategoryModel(
    type: 'expense',
    color: Colors.orangeAccent,
    terminology: TermModel(normal: 'Nongkrong & Kafe', rpg: 'Pertemuan Tavern'),
    icons: IconModel(
      normal: FontAwesomeIcons.mugHot,
      rpg: FontAwesomeIcons.beerMugEmpty,
    ),
  );

  static const CategoryModel fuel = CategoryModel(
    type: 'expense',
    color: Colors.deepOrangeAccent,
    terminology: TermModel(normal: 'Bensin & Parkir', rpg: 'Bahan Bakar Mount'),
    icons: IconModel(
      normal: FontAwesomeIcons.gasPump,
      rpg: FontAwesomeIcons.fire,
    ),
  );

  static const CategoryModel vehicleService = CategoryModel(
    type: 'expense',
    color: Colors.blueGrey,
    terminology: TermModel(normal: 'Servis Kendaraan', rpg: 'Perawatan Mount'),
    icons: IconModel(
      normal: FontAwesomeIcons.screwdriverWrench,
      rpg: FontAwesomeIcons.hammer,
    ),
  );

  static const CategoryModel rideshare = CategoryModel(
    type: 'expense',
    color: Colors.lightGreenAccent,
    terminology: TermModel(normal: 'Taksi & Ojol', rpg: 'Kurir Guild'),
    icons: IconModel(
      normal: FontAwesomeIcons.motorcycle,
      rpg: FontAwesomeIcons.personRunning,
    ),
  );

  static const CategoryModel travelTicket = CategoryModel(
    type: 'expense',
    color: Colors.lightBlueAccent,
    terminology: TermModel(normal: 'Tiket Perjalanan', rpg: 'Surat Izin Jalan'),
    icons: IconModel(
      normal: FontAwesomeIcons.planeDeparture,
      rpg: FontAwesomeIcons.scroll,
    ),
  );

  static const CategoryModel publicTransport = CategoryModel(
    type: 'expense',
    color: Colors.indigoAccent,
    terminology: TermModel(normal: 'Transportasi Umum', rpg: 'Kapal Publik'),
    icons: IconModel(
      normal: FontAwesomeIcons.trainSubway,
      rpg: FontAwesomeIcons.ship,
    ),
  );

  static const CategoryModel giftGiving = CategoryModel(
    type: 'expense',
    color: Colors.pinkAccent,
    terminology: TermModel(normal: 'Hadiah & Kado', rpg: 'Persembahan'),
    icons: IconModel(
      normal: FontAwesomeIcons.gift,
      rpg: FontAwesomeIcons.boxOpen,
    ),
  );

  static const CategoryModel socialEvent = CategoryModel(
    type: 'expense',
    color: Colors.purpleAccent,
    terminology: TermModel(normal: 'Acara Sosial', rpg: 'Pesta Perayaan'),
    icons: IconModel(
      normal: FontAwesomeIcons.peopleGroup,
      rpg: FontAwesomeIcons.wineGlass,
    ),
  );

  static const CategoryModel other = CategoryModel(
    type: 'expense',
    color: Colors.grey,
    terminology: TermModel(normal: 'Lainnya', rpg: 'Pengeluaran Misterius'),
    icons: IconModel(
      normal: FontAwesomeIcons.ellipsis,
      rpg: FontAwesomeIcons.question,
    ),
  );

  static const CategoryModel gift = CategoryModel(
    type: 'income',
    color: Colors.pinkAccent,
    terminology: TermModel(normal: 'Hadiah & Bonus', rpg: 'Loot Tak Terduga'),
    icons: IconModel(
      normal: FontAwesomeIcons.gift,
      rpg: FontAwesomeIcons.wandMagicSparkles,
    ),
  );

  static const CategoryModel otherIncome = CategoryModel(
    type: 'income',
    color: Colors.grey,
    terminology: TermModel(
      normal: 'Pendapatan Lainnya',
      rpg: 'Pendapatan Misterius',
    ),
    icons: IconModel(
      normal: FontAwesomeIcons.ellipsis,
      rpg: FontAwesomeIcons.question,
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
    terminology: TermModel(normal: 'Aktif', rpg: 'Berjalan'),
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
    fashion,
    gadget,
    streaming,
    gaming,
    hobby,
    concert,
    travel,
    hangout,
    fuel,
    vehicleService,
    rideshare,
    travelTicket,
    publicTransport,
    transport,
    entertainment,
    giftGiving,
    socialEvent,
    charity,
    health,
    utilities,
    lending,
    debtInstallment,
    other,
    salary,
    business,
    loanDisbursement,
    debtCollection,
    dividend,
    gift,
    otherIncome,
    transfer,
    pocketTransfer,
    topUp,
    emergencyFund,
    savings,
    cashWithdrawal,
    cashDeposit,
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
      case TransactionCategory.fashion:
        return fashion;
      case TransactionCategory.gadget:
        return gadget;
      case TransactionCategory.streaming:
        return streaming;
      case TransactionCategory.gaming:
        return gaming;
      case TransactionCategory.hobby:
        return hobby;
      case TransactionCategory.concert:
        return concert;
      case TransactionCategory.travel:
        return travel;
      case TransactionCategory.hangout:
        return hangout;
      case TransactionCategory.fuel:
        return fuel;
      case TransactionCategory.vehicleService:
        return vehicleService;
      case TransactionCategory.rideshare:
        return rideshare;
      case TransactionCategory.travelTicket:
        return travelTicket;
      case TransactionCategory.publicTransport:
        return publicTransport;
      case TransactionCategory.giftGiving:
        return giftGiving;
      case TransactionCategory.socialEvent:
        return socialEvent;
      case TransactionCategory.other:
        return other;
      case TransactionCategory.salary:
        return salary;
      case TransactionCategory.business:
        return business;
      case TransactionCategory.loanDisbursement:
        return loanDisbursement;
      case TransactionCategory.debtCollection:
        return debtCollection;
      case TransactionCategory.dividend:
        return dividend;
      case TransactionCategory.gift:
        return gift;
      case TransactionCategory.otherIncome:
        return otherIncome;
      case TransactionCategory.transfer:
        return transfer;
      case TransactionCategory.pocketTransfer:
        return pocketTransfer;
      case TransactionCategory.topUp:
        return topUp;
      case TransactionCategory.emergencyFund:
        return emergencyFund;
      case TransactionCategory.savings:
        return savings;
      case TransactionCategory.cashWithdrawal:
        return cashWithdrawal;
      case TransactionCategory.cashDeposit:
        return cashDeposit;
      case TransactionCategory.lowRisk:
        return lowRisk;
      case TransactionCategory.mediumRisk:
        return mediumRisk;
      case TransactionCategory.highRisk:
        return highRisk;
    }
  }
}
