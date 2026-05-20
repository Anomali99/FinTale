import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'enum_types.dart';

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

extension StatusExtension on StatusType {
  Color get cardColor {
    switch (this) {
      case StatusType.paid:
        return AppColors.surfaceVariant.withOpacity(0.5);
      case StatusType.pending:
      case StatusType.overdue:
        return AppColors.surfaceVariant;
    }
  }

  Color get textColor {
    switch (this) {
      case StatusType.paid:
        return AppColors.textSecondary;
      case StatusType.pending:
      case StatusType.overdue:
        return AppColors.textPrimary;
    }
  }

  Color get accentColor {
    switch (this) {
      case StatusType.paid:
        return AppColors.success;
      case StatusType.pending:
        return AppColors.primary;
      case StatusType.overdue:
        return AppColors.error;
    }
  }
}
