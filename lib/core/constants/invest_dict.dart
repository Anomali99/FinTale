import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';

class InvestDict {
  static const TermModel total = TermModel(
    normal: 'Total Portofolio',
    rpg: 'Total Kekuatan Pasukan',
  );

  static const TermModel invested = TermModel(
    normal: 'Modal Diinvestasikan',
    rpg: 'Gold Dikerahkan',
  );

  static const TermModel value = TermModel(
    normal: 'Nilai Saat Ini',
    rpg: 'Power Saat Ini',
  );

  static const TermModel empty = TermModel(
    normal: 'Belum ada aset di sini.\nTambah sekarang!',
    rpg: 'Belum ada pasukan di divisi ini.\nRekrut sekarang!',
  );

  static const CategoryModel add = CategoryModel(
    terminology: TermModel(normal: 'Tambah Aset', rpg: 'Rekrut Pasukan'),
    icons: IconModel(
      normal: FontAwesomeIcons.folderPlus,
      rpg: FontAwesomeIcons.flag,
    ),
  );
}
