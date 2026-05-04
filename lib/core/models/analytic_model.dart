import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/transaction_detail_model.dart';
import '../constants/category_dict.dart';
import 'category_model.dart';

class AnalyticModel {
  final TransactionCategory id;
  final CategoryModel category;
  BigInt amount;

  AnalyticModel({required this.id, required this.amount})
    : category = CategoryDict.getByTransactionCategory(id);

  void addAmount(BigInt amount) {
    this.amount += amount;
  }

  Color get color => category.color ?? Colors.black;
  FaIconData icon(bool isRpgMode) => category.icon(isRpgMode);
  String get(bool isRpgMode) => category.get(isRpgMode);
}
