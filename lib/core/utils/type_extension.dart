import 'package:flutter/material.dart';

import '../../../models/transaction_model.dart';

extension TypeExtension on TransactionType {
  Color get iconColor {
    switch (this) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.blueGrey;
      case TransactionType.debt:
        return Colors.deepOrange;
    }
  }

  Color get iconBgColor => iconColor.withOpacity(0.2);

  Color get amountColor {
    switch (this) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
      case TransactionType.debt:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.grey;
    }
  }

  String get prefix {
    switch (this) {
      case TransactionType.income:
        return '+ ';
      case TransactionType.expense:
      case TransactionType.debt:
        return '- ';
      case TransactionType.transfer:
        return '';
    }
  }
}
