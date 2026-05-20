import 'package:flutter/material.dart';

import 'category_model.dart';

class MissionModel extends CategoryModel {
  final String xp;
  final String frequency;
  final String limit;
  MissionModel({
    required super.terminology,
    required super.icons,
    required super.description,
    required super.color,
    required this.frequency,
    required this.limit,
    required this.xp,
  });

  @override
  Color get color => super.color ?? Colors.blueAccent;

  @override
  String get description => super.description ?? '';
}
