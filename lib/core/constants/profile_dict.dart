import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';

class ProfileDict {
  static const String dailyMission = 'Misi Harian';
  static const String weeklyMission = 'Misi Mingguan';
  static const String monthlyMission = 'Misi Bulanan';
  static const String specialMission = 'Misi Spesial';
  static const String titleSystem = 'Sistem Gelar';
  static const String allocationGuide = 'Panduan Alokasi';
  static const String allocationRules = 'Aturan Alokasi';

  static const TermModel stats = TermModel(
    normal: 'Statistik Alokasi',
    rpg: 'Status Karakter',
  );

  static const TermModel allocationTree = TermModel(
    normal: 'Pohon Alokasi',
    rpg: 'Skill Tree',
  );

  static const CategoryModel recordTransaction = CategoryModel(
    terminology: TermModel(normal: 'Catat Transaksi', rpg: 'Catat Petualangan'),
    description: 'Catat pemasukan dan pengeluaran harianmu.',
    icons: IconModel(
      normal: FontAwesomeIcons.penToSquare,
      rpg: FontAwesomeIcons.penToSquare,
    ),
    color: Colors.blueAccent,
  );

  static const CategoryModel dailyBudgetCap = CategoryModel(
    terminology: TermModel(
      normal: 'Batas Anggaran Harian',
      rpg: 'Batas Penggunaan Mana',
    ),
    description: 'Selesaikan hari tanpa melebihi batas anggaran harianmu.',
    icons: IconModel(
      normal: FontAwesomeIcons.wallet,
      rpg: FontAwesomeIcons.wallet,
    ),
    color: Colors.greenAccent,
  );

  static const CategoryModel weeklyCheckin = CategoryModel(
    terminology: TermModel(
      normal: 'Check-in Mingguan',
      rpg: 'Lapor Guild Mingguan',
    ),
    description: 'Buka aplikasi setidaknya 5 hari dalam seminggu.',
    icons: IconModel(
      normal: FontAwesomeIcons.calendarCheck,
      rpg: FontAwesomeIcons.calendarCheck,
    ),
    color: Colors.teal,
  );

  static const CategoryModel consistentBudgeting = CategoryModel(
    terminology: TermModel(
      normal: 'Konsistensi Anggaran',
      rpg: 'Combo Disiplin Mana',
    ),
    description:
        'Pertahankan batas anggaran harianmu selama 5 hari dalam seminggu.',
    icons: IconModel(
      normal: FontAwesomeIcons.chartLine,
      rpg: FontAwesomeIcons.chartLine,
    ),
    color: Colors.cyan,
  );

  static const CategoryModel monthlySavingsGoal = CategoryModel(
    terminology: TermModel(
      normal: 'Target Tabungan Bulanan',
      rpg: 'Target Timbunan Harta',
    ),
    description: 'Berhasil mencapai target tabungan bulananmu.',
    icons: IconModel(
      normal: FontAwesomeIcons.piggyBank,
      rpg: FontAwesomeIcons.piggyBank,
    ),
    color: Colors.amber,
  );

  static const CategoryModel debtPayment = CategoryModel(
    terminology: TermModel(
      normal: 'Pembayaran Hutang',
      rpg: 'Serangan Boss Raid',
    ),
    description: 'Bayar alokasi hutang bulananmu tepat waktu.',
    icons: IconModel(
      normal: FontAwesomeIcons.fileInvoiceDollar,
      rpg: FontAwesomeIcons.fileInvoiceDollar,
    ),
    color: Colors.redAccent,
  );

  static const CategoryModel monthlyReview = CategoryModel(
    terminology: TermModel(
      normal: 'Evaluasi Bulanan',
      rpg: 'Laporan Dewan Guild',
    ),
    description: 'Tinjau ringkasan keuanganmu di akhir bulan.',
    icons: IconModel(
      normal: FontAwesomeIcons.chartPie,
      rpg: FontAwesomeIcons.chartPie,
    ),
    color: Colors.deepOrangeAccent,
  );

  static const CategoryModel firstTransaction = CategoryModel(
    terminology: TermModel(normal: 'Transaksi Pertama', rpg: 'Quest Pertama'),
    description: 'Catat transaksi keuangan pertamamu.',
    icons: IconModel(
      normal: FontAwesomeIcons.flagCheckered,
      rpg: FontAwesomeIcons.flagCheckered,
    ),
    color: Colors.pinkAccent,
  );

  static const CategoryModel createWallet = CategoryModel(
    terminology: TermModel(normal: 'Buat Dompet', rpg: 'Buka Inventory Baru'),
    description:
        'Buat tempat penyimpanan, rekening bank, atau dompet digital baru.',
    icons: IconModel(
      normal: FontAwesomeIcons.buildingColumns,
      rpg: FontAwesomeIcons.buildingColumns,
    ),
    color: Colors.purpleAccent,
  );

  static const CategoryModel setAllocation = CategoryModel(
    terminology: TermModel(normal: 'Atur Alokasi', rpg: 'Atur Skill Tree'),
    description: 'Atur persentase alokasi keuanganmu untuk pertama kalinya.',
    icons: IconModel(
      normal: FontAwesomeIcons.sliders,
      rpg: FontAwesomeIcons.sliders,
    ),
    color: Colors.indigoAccent,
  );

  static const CategoryModel baseDaily = CategoryModel(
    terminology: TermModel(normal: 'Batas Harian Dasar', rpg: 'Base Mana'),
    icons: IconModel(
      normal: FontAwesomeIcons.bolt,
      rpg: FontAwesomeIcons.flask,
    ),
  );
}
