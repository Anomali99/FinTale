import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/allocation_model.dart';
import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';
import 'assets_dict.dart';
import 'shared_dict.dart';

class SkillDict {
  static const CategoryModel income = SharedDict.income;

  static const CategoryModel dailyParent = CategoryModel(
    terminology: TermModel(normal: 'Biaya Hidup', rpg: 'Stamina'),
    description:
        'Energi inti yang dibutuhkan untuk menjaga karaktermu tetap hidup dan berfungsi di dunia ini.',
    icons: IconModel(
      normal: FontAwesomeIcons.wallet,
      rpg: FontAwesomeIcons.heartPulse,
    ),
    color: Color(0xFF4FC3F7),
  );

  static const CategoryModel dailyRoutine = CategoryModel(
    terminology: TermModel(normal: 'Kebutuhan Pokok', rpg: 'Ransum'),
    description:
        'Barang konsumsi dan biaya tetap seperti makanan dan tempat tinggal. Perawatan wajib untuk bertahan hidup.',
    icons: IconModel(
      normal: FontAwesomeIcons.basketShopping,
      rpg: FontAwesomeIcons.drumstickBite,
    ),
    color: Color(0xFF81D4FA),
  );

  static const CategoryModel dreamFund = CategoryModel(
    terminology: TermModel(normal: 'Dana Impian', rpg: 'Peti Harta'),
    description:
        'Sumber daya yang dikumpulkan untuk tujuan atau item masa depan. Timbun mana di sini untuk membuka hadiah besar nantinya.',
    icons: IconModel(normal: FontAwesomeIcons.star, rpg: FontAwesomeIcons.gem),
    color: Color(0xFFCE93D8),
  );

  static const CategoryModel debt = CategoryModel(
    terminology: TermModel(normal: 'Bayar Hutang', rpg: 'Serang Boss'),
    description:
        'Efek buruk (debuff) yang terus menguras loot kamu. Hapus kutukan ini untuk mengembalikan potensi pendapatan penuhmu.',
    icons: IconModel(
      normal: FontAwesomeIcons.fileInvoiceDollar,
      rpg: FontAwesomeIcons.dragon,
    ),
    color: Color(0xFFE57373),
  );

  static const CategoryModel emergency = CategoryModel(
    terminology: TermModel(normal: 'Dana Darurat', rpg: 'Pelindung'),
    description:
        'Pertahanan utamamu terhadap serangan kritikal acak dari kehidupan. Menyerap damage mendadak agar misi utamamu tidak terganggu.',
    icons: IconModel(
      normal: FontAwesomeIcons.briefcaseMedical,
      rpg: FontAwesomeIcons.shieldCat,
    ),
    color: Color(0xFF4DB6AC),
  );

  static const CategoryModel investment = CategoryModel(
    terminology: TermModel(normal: 'Investasi', rpg: 'Gudang Senjata'),
    description:
        'Poin skill yang dialokasikan untuk melipatgandakan kekayaan secara pasif. Jalan ninja sejati untuk menguasai late-game.',
    icons: IconModel(
      normal: FontAwesomeIcons.seedling,
      rpg: FontAwesomeIcons.userNinja,
    ),
    color: Color(0xFFFFB300),
  );

  static const CategoryModel lowRisk = AssetsDict.lowRisk;
  static const CategoryModel mediumRisk = AssetsDict.mediumRisk;
  static const CategoryModel highRisk = AssetsDict.highRisk;

  static CategoryModel getByEnum(Enum item) {
    switch (item) {
      case SectorType.living:
        return dailyParent;
      case SectorType.payDebt:
        return debt;
      case SectorType.emergency:
        return emergency;
      case SectorType.investment:
        return investment;
      case SubSectorType.essentials:
        return dailyRoutine;
      case SubSectorType.dreamFund:
        return dreamFund;
      case SubSectorType.lowRisk:
        return lowRisk;
      case SubSectorType.highRisk:
        return highRisk;
      case SubSectorType.mediumRisk:
        return mediumRisk;
      default:
        return dailyParent;
    }
  }
}
