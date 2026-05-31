import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/mission_model.dart';
import '../models/term_model.dart';
import '../utils/enum_types.dart';
import 'category_dict.dart';

class GamificationDict {
  static const String titleSystem = 'Sistem Gelar';
  static const String allocationGuide = 'Panduan Alokasi';
  static const String allocationRules = 'Aturan Alokasi';

  static const String skillPoint = 'Poin Reguler';
  static const String skillExtraPoint = 'Poin Ekstra';

  static const String lockedSkill = 'Skill Terkunci';

  static const String lockedSkillDesc =
      'Skill ini akan terbuka secara otomatis seiring kemajuan Anda.';

  static const String missionDaily = 'Tugas Harian';
  static const String missionWeekly = 'Tugas Mingguan';
  static const String missionMonthly = 'Tugas Bulanan';
  static const String missionSpecial = 'Tugas Spesial';

  static const TermModel statistics = TermModel(
    normal: 'Statistik Alokasi',
    rpg: 'Status Karakter',
  );

  static const TermModel allocationTree = TermModel(
    normal: 'Pohon Alokasi',
    rpg: 'Skill Tree',
  );

  static const TermModel titleNovice = TermModel(
    normal: 'Novice Saver',
    rpg: 'Novice Adventurer',
  );
  static const TermModel titleSmart = TermModel(
    normal: 'Smart Budgeter',
    rpg: 'Elite Ranger',
  );
  static const TermModel titleWise = TermModel(
    normal: 'Wise Investor',
    rpg: 'Valiant Knight',
  );
  static const TermModel titleWealth = TermModel(
    normal: 'Wealth Builder',
    rpg: 'Grand Champion',
  );
  static const TermModel titleMaster = TermModel(
    normal: 'Financial Master',
    rpg: 'Guild Legend',
  );

  static const CategoryModel skillDaily = CategoryModel(
    terminology: TermModel(normal: 'Biaya Hidup', rpg: 'Stamina Pokok'),
    description:
        'Energi inti yang dibutuhkan untuk menjaga karaktermu tetap hidup di dunia ini.',
    icons: IconModel(
      normal: FontAwesomeIcons.wallet,
      rpg: FontAwesomeIcons.heartPulse,
    ),
    color: Color(0xFF4FC3F7),
  );

  static const CategoryModel skillRoutine = CategoryModel(
    terminology: TermModel(normal: 'Kebutuhan Pokok', rpg: 'Ransum'),
    description:
        'Barang konsumsi dan biaya tetap seperti makanan dan tempat tinggal. Perawatan wajib untuk bertahan hidup.',
    icons: IconModel(
      normal: FontAwesomeIcons.basketShopping,
      rpg: FontAwesomeIcons.drumstickBite,
    ),
    color: Color(0xFF81D4FA),
  );

  static const CategoryModel skillDream = CategoryModel(
    terminology: TermModel(normal: 'Dana Impian', rpg: 'Peti Harta'),
    description: 'Timbun mana di sini untuk membuka hadiah besar nantinya.',
    icons: IconModel(normal: FontAwesomeIcons.star, rpg: FontAwesomeIcons.gem),
    color: Color(0xFFCE93D8),
  );

  static const CategoryModel skillEmergency = CategoryModel(
    terminology: TermModel(normal: 'Dana Darurat', rpg: 'Pelindung'),
    description:
        'Pertahanan utamamu terhadap serangan kritikal acak dari kehidupan. Menyerap damage mendadak agar misi utamamu tidak terganggu.',
    icons: IconModel(
      normal: FontAwesomeIcons.briefcaseMedical,
      rpg: FontAwesomeIcons.shieldCat,
    ),
    color: Color(0xFF4DB6AC),
  );

  static const CategoryModel skillDebt = CategoryModel(
    terminology: TermModel(normal: 'Bayar Hutang', rpg: 'Serang Boss'),
    description: 'Efek buruk (debuff) yang terus menguras loot kamu.',
    icons: IconModel(
      normal: FontAwesomeIcons.fileInvoiceDollar,
      rpg: FontAwesomeIcons.dragon,
    ),
    color: Color(0xFFE57373),
  );

  static const CategoryModel skillInvestment = CategoryModel(
    terminology: TermModel(normal: 'Investasi', rpg: 'Gudang Senjata'),
    description:
        'Poin skill yang dialokasikan untuk melipatgandakan kekayaan secara pasif. Jalan ninja sejati untuk menguasai late-game.',
    icons: IconModel(
      normal: FontAwesomeIcons.seedling,
      rpg: FontAwesomeIcons.userNinja,
    ),
    color: Color(0xFFFFB300),
  );

  static final MissionModel missionRecordTransaction = MissionModel(
    terminology: const TermModel(
      normal: 'Catat Transaksi',
      rpg: 'Catat Petualangan',
    ),
    icons: const IconModel(
      normal: FontAwesomeIcons.penToSquare,
      rpg: FontAwesomeIcons.penToSquare,
    ),
    description: 'Catat pemasukan dan pengeluaran harianmu.',
    color: Colors.blueAccent,
    xp: '+10 XP',
    frequency: 'Harian',
    limit: '3x',
  );

  static MissionModel missionDailyBudgetCap = MissionModel(
    terminology: TermModel(
      normal: 'Batas Anggaran Harian',
      rpg: 'Batas Penggunaan Mana',
    ),
    icons: IconModel(
      normal: FontAwesomeIcons.wallet,
      rpg: FontAwesomeIcons.wallet,
    ),
    description: 'Selesaikan hari tanpa melebihi batas anggaran harianmu.',
    color: Colors.greenAccent,
    xp: '+25 XP',
    frequency: 'Harian',
    limit: '1x',
  );

  static MissionModel missionWeeklyCheckin = MissionModel(
    terminology: TermModel(
      normal: 'Check-in Mingguan',
      rpg: 'Lapor Guild Mingguan',
    ),
    icons: IconModel(
      normal: FontAwesomeIcons.calendarCheck,
      rpg: FontAwesomeIcons.calendarCheck,
    ),
    description: 'Buka aplikasi setidaknya 5 hari dalam seminggu.',
    color: Colors.teal,
    xp: '+100 XP',
    frequency: 'Mingguan',
    limit: '1x',
  );

  static MissionModel missionConsistentBudgeting = MissionModel(
    terminology: TermModel(
      normal: 'Konsistensi Anggaran',
      rpg: 'Combo Disiplin Mana',
    ),
    icons: IconModel(
      normal: FontAwesomeIcons.chartLine,
      rpg: FontAwesomeIcons.chartLine,
    ),
    description:
        'Pertahankan batas anggaran harianmu selama 5 hari dalam seminggu.',
    color: Colors.cyan,
    xp: '+150 XP',
    frequency: 'Mingguan',
    limit: '1x',
  );

  static MissionModel missionDebtPayment = MissionModel(
    terminology: TermModel(
      normal: 'Pembayaran Hutang',
      rpg: 'Serangan Boss Raid',
    ),
    icons: IconModel(
      normal: FontAwesomeIcons.fileInvoiceDollar,
      rpg: FontAwesomeIcons.fileInvoiceDollar,
    ),
    description: 'Bayar alokasi hutang bulananmu tepat waktu.',
    color: Colors.redAccent,
    xp: '+300 XP',
    frequency: 'Bulanan',
    limit: '1x',
  );

  static MissionModel missionMonthlyReview = MissionModel(
    terminology: TermModel(
      normal: 'Evaluasi Bulanan',
      rpg: 'Laporan Dewan Guild',
    ),
    icons: IconModel(
      normal: FontAwesomeIcons.chartPie,
      rpg: FontAwesomeIcons.chartPie,
    ),
    description: 'Tinjau ringkasan keuanganmu di akhir bulan.',
    color: Colors.deepOrangeAccent,
    xp: '+200 XP',
    frequency: 'Bulanan',
    limit: '1x',
  );

  static MissionModel missionFirstTransaction = MissionModel(
    terminology: TermModel(normal: 'Transaksi Pertama', rpg: 'Quest Pertama'),
    icons: IconModel(
      normal: FontAwesomeIcons.flagCheckered,
      rpg: FontAwesomeIcons.flagCheckered,
    ),
    description: 'Catat transaksi keuangan pertamamu.',
    color: Colors.pinkAccent,
    xp: '+100 XP',
    frequency: 'Spesial',
    limit: '1x',
  );

  static MissionModel missionCreateWallet = MissionModel(
    terminology: TermModel(normal: 'Buat Dompet', rpg: 'Buka Inventory Baru'),
    icons: IconModel(
      normal: FontAwesomeIcons.buildingColumns,
      rpg: FontAwesomeIcons.buildingColumns,
    ),
    description:
        'Buat tempat penyimpanan, rekening bank, atau dompet digital baru.',
    color: Colors.purpleAccent,
    xp: '+50 XP',
    frequency: 'Spesial',
    limit: '3x',
  );

  static MissionModel missionSetAllocation = MissionModel(
    terminology: TermModel(normal: 'Atur Alokasi', rpg: 'Atur Skill Tree'),
    icons: IconModel(
      normal: FontAwesomeIcons.sliders,
      rpg: FontAwesomeIcons.sliders,
    ),
    description: 'Atur persentase alokasi keuanganmu untuk pertama kalinya.',
    color: Colors.indigoAccent,
    xp: '+200 XP',
    frequency: 'Spesial',
    limit: '1x',
  );

  static TermModel getTitleByEnum(TitleType? title) {
    switch (title) {
      case TitleType.noviceSaver:
        return titleNovice;
      case TitleType.smartBudgeter:
        return titleSmart;
      case TitleType.wiseInvestor:
        return titleWise;
      case TitleType.wealthBuilder:
        return titleWealth;
      case TitleType.financialMaster:
        return titleMaster;
      default:
        return titleNovice;
    }
  }

  static CategoryModel getSkillByEnum(Enum item) {
    switch (item) {
      case SectorType.living:
        return skillDaily;
      case SectorType.payDebt:
        return skillDebt;
      case SectorType.emergency:
        return skillEmergency;
      case SectorType.investment:
        return skillInvestment;
      case SubSectorType.essentials:
        return skillRoutine;
      case SubSectorType.dreamFund:
        return skillDream;
      case SubSectorType.lowRisk:
        return CategoryDict.lowRisk;
      case SubSectorType.mediumRisk:
        return CategoryDict.mediumRisk;
      case SubSectorType.highRisk:
        return CategoryDict.highRisk;
      default:
        return skillDaily;
    }
  }

  static String get missionNote1Title =>
      'Prioritas Hibrida ${CategoryDict.lowRisk.get(false)}';
  static String get missionNote2Title =>
      'Sinergi ${skillRoutine.get(false)} & ${skillDream.get(false)}';
  static String get missionNote3Title => 'Status Alokasi Bebas';

  static String get missionNote1 =>
      'Node `${CategoryDict.lowRisk.get(false)}` mengambil persentasenya dari `${skillEmergency.get(false)}` maupun `${skillInvestment.get(false)}`. **`${skillEmergency.get(false)}` adalah prioritas mutlak.** Contohnya, alokasi 30% `${CategoryDict.lowRisk.get(false)}` akan menguras penuh 20% kapasitas `${skillEmergency.get(false)}` terlebih dahulu sebelum mengambil sisa 10%-nya dari `${skillInvestment.get(false)}`.';
  static String get missionNote2 =>
      'Node `${skillRoutine.get(false)}` berbagi wadah poin yang sama dengan `${skillDream.get(false)}`. Anda memiliki kebebasan untuk menabung sebagian pemasukan Anda ke dalam `${skillDream.get(false)}` untuk mewujudkan tujuan besar atau membeli item legendaris di masa depan.';
  static String get missionNote3 =>
      'Setelah `${skillDebt.get(false)}` Anda lunas atau `${skillEmergency.get(false)}` sudah mencapai kapasitas maksimal, Anda akan membuka "Mode Bebas" (Poin Ekstra) di mana poin tersebut dapat didistribusikan ulang ke node mana pun di dalam pohon alokasi.';

  static List<MissionModel> get allMission => [
    missionRecordTransaction,
    missionDailyBudgetCap,
    missionWeeklyCheckin,
    missionConsistentBudgeting,
    missionDebtPayment,
    missionMonthlyReview,
    missionFirstTransaction,
    missionCreateWallet,
    missionSetAllocation,
  ];
}
