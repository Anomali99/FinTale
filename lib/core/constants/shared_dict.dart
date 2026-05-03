import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';

class SharedDict {
  static const String name = 'Nama';
  static const String amount = 'Jumlah';
  static const String title = 'Judul';
  static const String category = 'Kategori';
  static const String requiredTitle = 'Judul tidak boleh kosong.';
  static const String requiredName = 'Nama tidak boleh kosong.';
  static const String requiredAmount = 'Jumlah tidak boleh kosong.';
  static const String requiredWallet = 'Silakan pilih sumber dana.';
  static const String requiredWalletDest = 'Silakan pilih dompet tujuan.';
  static const String requiredCategory = 'Silakan pilih kategori.';
  static const String addNew = 'Tambah Baru';
  static const String saveChanges = 'Simpan Perubahan';

  static const CategoryModel income = CategoryModel(
    terminology: TermModel(normal: 'Pemasukan', rpg: 'Loot (Drop)'),
    color: Color(0xFFFFD700),
    icons: IconModel(
      normal: FontAwesomeIcons.arrowTurnDown,
      rpg: FontAwesomeIcons.sackDollar,
    ),
  );

  static const CategoryModel expense = CategoryModel(
    terminology: TermModel(normal: 'Pengeluaran', rpg: 'Damage Diterima'),
    icons: IconModel(
      normal: FontAwesomeIcons.arrowTrendDown,
      rpg: FontAwesomeIcons.heartCrack,
    ),
  );

  static const CategoryModel transfer = CategoryModel(
    terminology: TermModel(normal: 'Transfer', rpg: 'Distribusi'),
    icons: IconModel(
      normal: FontAwesomeIcons.moneyBillTransfer,
      rpg: FontAwesomeIcons.dolly,
    ),
  );

  static const CategoryModel filter = CategoryModel(
    terminology: TermModel(normal: 'Filter', rpg: 'Sortir Sihir'),
    icons: IconModel(
      normal: FontAwesomeIcons.filter,
      rpg: FontAwesomeIcons.wandMagicSparkles,
    ),
  );

  static const TermModel invest = TermModel(normal: 'Investasi', rpg: 'Armory');

  static const TermModel unallocated = TermModel(
    normal: 'Belum Dialokasikan',
    rpg: 'Mana Menganggur',
  );
}
