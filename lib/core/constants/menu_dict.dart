import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';

class MenuDict {
  static const String settings = 'Pengaturan';
  static const String profile = 'Profil';
  static const String information = 'Panduan & Informasi';
  static const CategoryModel home = CategoryModel(
    terminology: TermModel(normal: 'Beranda', rpg: 'Markas'),
    icons: IconModel(
      normal: FontAwesomeIcons.house,
      rpg: FontAwesomeIcons.chessRook,
    ),
  );

  static const CategoryModel bills = CategoryModel(
    terminology: TermModel(normal: 'Tagihan', rpg: 'Papan Misi'),
    icons: IconModel(
      normal: FontAwesomeIcons.receipt,
      rpg: FontAwesomeIcons.scroll,
    ),
  );

  static const CategoryModel invest = CategoryModel(
    terminology: TermModel(normal: 'Investasi', rpg: 'Armory'),
    icons: IconModel(
      normal: FontAwesomeIcons.chartLine,
      rpg: FontAwesomeIcons.shieldHalved,
    ),
  );

  static const CategoryModel history = CategoryModel(
    terminology: TermModel(normal: 'Riwayat', rpg: 'Catatan'),
    icons: IconModel(
      normal: FontAwesomeIcons.clockRotateLeft,
      rpg: FontAwesomeIcons.bookJournalWhills,
    ),
  );

  static const CategoryModel analytics = CategoryModel(
    terminology: TermModel(normal: 'Analitik', rpg: 'Laporan'),
    icons: IconModel(
      normal: FontAwesomeIcons.chartPie,
      rpg: FontAwesomeIcons.eye,
    ),
  );

  static const CategoryModel pay = CategoryModel(
    terminology: TermModel(normal: 'Bayar Hutang', rpg: 'Serang Boss'),
    description: 'Catat cicilan hutang',
    icons: IconModel(
      normal: FontAwesomeIcons.buildingColumns,
      rpg: FontAwesomeIcons.khanda,
    ),
  );

  static const CategoryModel daily = CategoryModel(
    terminology: TermModel(normal: 'Pengeluaran Harian', rpg: 'Gunakan Mana'),
    description: 'Catat makanan, transportasi, dll.',
    icons: IconModel(
      normal: FontAwesomeIcons.wallet,
      rpg: FontAwesomeIcons.flask,
    ),
  );
}
