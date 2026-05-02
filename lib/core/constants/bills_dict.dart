import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';

class BillsDict {
  static const TermModel bills = TermModel(
    normal: 'Tagihan Saat Ini',
    rpg: 'Misi Aktif',
  );

  static const TermModel template = TermModel(
    normal: 'Template Tagihan',
    rpg: 'Master Quest',
  );

  static const TermModel debts = TermModel(normal: 'Hutang', rpg: 'Boss Raid');

  static const TermModel remaining = TermModel(
    normal: 'Sisa Hutang',
    rpg: 'Sisa HP Boss',
  );

  static const CategoryModel pay = CategoryModel(
    terminology: TermModel(normal: 'Bayar', rpg: 'Serang'),
    icons: IconModel(
      normal: FontAwesomeIcons.check,
      rpg: FontAwesomeIcons.wandMagicSparkles,
    ),
  );

  static const IconModel addIcon = IconModel(
    normal: FontAwesomeIcons.receipt,
    rpg: FontAwesomeIcons.dragon,
  );

  static const CategoryModel addTemplate = CategoryModel(
    terminology: TermModel(
      normal: 'Tambah Template Tagihan',
      rpg: 'Tambah Master Quest',
    ),
    description: 'Buat template pembayaran rutin baru',
    icons: IconModel(
      normal: FontAwesomeIcons.receipt,
      rpg: FontAwesomeIcons.scroll,
    ),
  );

  static const CategoryModel addDebt = CategoryModel(
    terminology: TermModel(normal: 'Tambah Hutang', rpg: 'Tambah Boss Raid'),
    description: 'Catat pinjaman atau hutang besar baru',
    icons: IconModel(
      normal: FontAwesomeIcons.buildingColumns,
      rpg: FontAwesomeIcons.dragon,
    ),
  );
}
