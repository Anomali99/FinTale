import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconModel {
  final FaIconData normal;
  final FaIconData rpg;

  const IconModel({required this.normal, required this.rpg});

  FaIconData get(bool isRpgMode) => isRpgMode ? rpg : normal;
}
