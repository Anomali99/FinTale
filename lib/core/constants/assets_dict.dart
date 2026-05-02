import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/assets_model.dart';
import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';

class AssetsDict {
  static const CategoryModel lowRisk = CategoryModel(
    terminology: TermModel(normal: 'Risiko Rendah', rpg: 'Tanker'),
    color: Color(0xFF81C784),
    description:
        'Aset yang stabil dan aman untuk melindungi modalmu. Meski serangannya (return) kecil, aset ini adalah perisai terkuat menahan volatilitas pasar, memastikan pertumbuhan jangka panjang yang pasti.',
    icons: IconModel(
      normal: FontAwesomeIcons.vault,
      rpg: FontAwesomeIcons.shieldHalved,
    ),
  );

  static const CategoryModel mediumRisk = CategoryModel(
    terminology: TermModel(normal: 'Risiko Menengah', rpg: 'Fighter'),
    color: Color(0xFFFFB74D),
    description:
        'Pasukan garis depan portofoliomu. Menawarkan keseimbangan antara risiko dan hadiah, bertujuan untuk meningkatkan modal dan dividen untuk membangun kekayaan secara konsisten.',
    icons: IconModel(
      normal: FontAwesomeIcons.chartLine,
      rpg: FontAwesomeIcons.handFist,
    ),
  );

  static const CategoryModel highRisk = CategoryModel(
    terminology: TermModel(normal: 'Risiko Tinggi', rpg: 'Assassin'),
    color: Color(0xFFF06292),
    description:
        'Aset liar yang mampu memberikan keuntungan (damage) masif secara cepat—atau kerugian fatal. Cocok untuk strategi pertumbuhan agresif, tapi butuh timing presisi dan nyali yang kuat.',
    icons: IconModel(
      normal: FontAwesomeIcons.rocket,
      rpg: FontAwesomeIcons.userNinja,
    ),
  );

  static CategoryModel getByEnum(RiskType type) {
    switch (type) {
      case RiskType.low:
        return lowRisk;
      case RiskType.medium:
        return mediumRisk;
      case RiskType.high:
        return highRisk;
    }
  }
}
