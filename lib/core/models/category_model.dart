import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/color_extension.dart';
import 'icon_model.dart';
import 'term_model.dart';

class CategoryModel {
  final TermModel terminology;
  final IconModel icons;
  final String? description;
  final String? type;
  final Color? lightColor;
  final Color? color;

  const CategoryModel({
    required this.terminology,
    required this.icons,
    this.description,
    this.type,
    this.lightColor,
    this.color,
  });

  String get(bool isRpgMode) => terminology.get(isRpgMode);
  FaIconData icon(bool isRpgMode) => icons.get(isRpgMode);

  String get value => terminology.get(false);

  Color getColor(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (isLight) {
      if (lightColor != null) return lightColor!;

      if (color != null) return color!.adapt(context);
    }

    return color ?? (isLight ? Colors.black : Colors.white);
  }
}
