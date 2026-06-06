import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/category_dict.dart';
import '../utils/enum_types.dart';
import 'category_model.dart';

class AnalyticModel {
  final TransactionCategory id;
  final CategoryModel category;
  Decimal amount;

  AnalyticModel({required this.id, required this.amount})
    : category = CategoryDict.getByTransactionCategory(id);

  void addAmount(Decimal amount) {
    this.amount += amount;
  }

  Color get color => category.color ?? Colors.black;
  FaIconData icon(bool isRpgMode) => category.icon(isRpgMode);
  String get(bool isRpgMode) => category.get(isRpgMode);
}
