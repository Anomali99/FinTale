import 'package:flutter/material.dart';

import '../../../models/transaction_detail_model.dart';
import '../../../models/transaction_model.dart';
import '../constants/app_colors.dart';

extension TypeExtension on TransactionType {
  Color get color {
    switch (this) {
      case TransactionType.income:
        return AppColors.success;
      case TransactionType.expense:
        return AppColors.error;
      case TransactionType.transfer:
        return Colors.blueGrey;
      case TransactionType.debt:
        return AppColors.warning;
    }
  }

  Color get bgColor => color.withOpacity(0.2);

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

extension FlowExtension on FlowType {
  Color get ggColor => color.withOpacity(0.2);

  Color get color {
    switch (this) {
      case FlowType.income:
        return AppColors.success;
      case FlowType.expense:
        return AppColors.error;
      case FlowType.transfer:
        return Colors.blueGrey;
    }
  }

  String get prefix {
    switch (this) {
      case FlowType.income:
        return '+ ';
      case FlowType.expense:
        return '- ';
      case FlowType.transfer:
        return '';
    }
  }
}
