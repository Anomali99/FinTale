import 'package:flutter/material.dart';

import '../constants/category_dict.dart';
import '../models/category_model.dart';
import '../theme/app_colors.dart';

enum RiskType {
  low,
  medium,
  high;

  TransactionCategory getTransactionCategory() {
    switch (this) {
      case RiskType.low:
        return TransactionCategory.lowRisk;
      case RiskType.medium:
        return TransactionCategory.mediumRisk;
      case RiskType.high:
        return TransactionCategory.highRisk;
    }
  }

  SubSectorType getSubSector() {
    switch (this) {
      case RiskType.low:
        return SubSectorType.lowRisk;
      case RiskType.medium:
        return SubSectorType.mediumRisk;
      case RiskType.high:
        return SubSectorType.highRisk;
    }
  }
}

enum DebtType { creditCard, mortgage, vehicle, personal, business, other }

enum TimeType {
  daily('Harian'),
  weekly('Mingguan'),
  monthly('Bulanan'),
  annual('Tahunan');

  final String value;
  const TimeType(this.value);
}

enum DayName {
  monday('Senin', 1),
  tuesday('Selasa', 2),
  wednesday('Rabu', 3),
  thursday('Kamis', 4),
  friday('Jum\'at', 5),
  saturday('Sabtu', 6),
  sunday('Minggu', 7);

  final String value;
  final int intValue;
  const DayName(this.value, this.intValue);

  static DayName getByIntValue(int intValue) => DayName.values.firstWhere(
    (e) => e.intValue == intValue,
    orElse: () => DayName.sunday,
  );
}

enum MonthName {
  january('Januari', 1),
  february('Februari', 2),
  march('Maret', 3),
  april('April', 4),
  may('Mei', 5),
  june('Juni', 6),
  july('Juli', 7),
  august('Agustus', 8),
  september('September', 9),
  october('Oktober', 10),
  november('November', 11),
  december('Desember', 12);

  final String value;
  final int intValue;
  const MonthName(this.value, this.intValue);

  static MonthName getByIntValue(int intValue) => MonthName.values.firstWhere(
    (e) => e.intValue == intValue,
    orElse: () => MonthName.january,
  );
}

enum TransactionCategory {
  food,
  groceries,
  transport,
  entertainment,
  health,
  utilities,
  debtInstallment,
  salary,
  business,
  dividend,
  transfer,
  lowRisk,
  mediumRisk,
  highRisk;

  CategoryModel get categoryDict => CategoryDict.getByTransactionCategory(this);

  static List<TransactionCategory> get expenseCategories => [
    food,
    groceries,
    transport,
    entertainment,
    health,
    utilities,
  ];

  static List<TransactionCategory> get incomeCategories => [
    salary,
    business,
    dividend,
  ];

  static List<TransactionCategory> get investCategories => [
    lowRisk,
    mediumRisk,
    highRisk,
  ];

  static TransactionCategory getTransactionCategory(RiskType risk) {
    switch (risk) {
      case RiskType.low:
        return TransactionCategory.lowRisk;
      case RiskType.medium:
        return TransactionCategory.mediumRisk;
      case RiskType.high:
        return TransactionCategory.highRisk;
    }
  }
}

enum FlowType {
  expense,
  income,
  transfer;

  Color getBgColor(BuildContext context) => getColor(context).withOpacity(0.2);

  Color getColor(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    switch (this) {
      case FlowType.income:
        return AppColors.getSuccess(context);
      case FlowType.expense:
        return Theme.of(context).colorScheme.error;
      case FlowType.transfer:
        return isLight ? Colors.blueGrey.shade700 : Colors.blueGrey;
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

enum TransactionType {
  income('Pemasukan'),
  expense('Pengeluaran'),
  transfer('Transfer'),
  debt('Pembayaran Hutang');

  final String value;
  const TransactionType(this.value);

  Color getColor(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    switch (this) {
      case TransactionType.income:
        return AppColors.getSuccess(context);
      case TransactionType.expense:
        return Theme.of(context).colorScheme.error;
      case TransactionType.transfer:
        return isLight ? Colors.blueGrey.shade700 : Colors.blueGrey;
      case TransactionType.debt:
        return AppColors.getWarning(context);
    }
  }

  Color getBgColor(BuildContext context) => getColor(context).withOpacity(0.2);

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

enum StatusType {
  pending,
  overdue,
  paid;

  CategoryModel get categoryDict => CategoryDict.getStatusByEnum(this);

  Color getCardColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (this) {
      case StatusType.paid:
        return colorScheme.surfaceContainerHighest.withOpacity(0.5);
      case StatusType.pending:
      case StatusType.overdue:
        return colorScheme.surfaceContainerHighest;
    }
  }

  Color getTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (this) {
      case StatusType.paid:
        return Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
      case StatusType.pending:
      case StatusType.overdue:
        return colorScheme.onSurface;
    }
  }

  Color getAccentColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (this) {
      case StatusType.paid:
        return AppColors.getSuccess(context);
      case StatusType.pending:
        return colorScheme.primary;
      case StatusType.overdue:
        return AppColors.error;
    }
  }
}

enum TitleType {
  noviceSaver,
  smartBudgeter,
  wiseInvestor,
  wealthBuilder,
  financialMaster,
}

enum SectorType { living, payDebt, emergency, investment }

enum SubSectorType {
  essentials,
  dreamFund,
  lowRisk,
  mediumRisk,
  highRisk;

  RiskType? getRisk() {
    switch (this) {
      case SubSectorType.lowRisk:
        return RiskType.low;
      case SubSectorType.mediumRisk:
        return RiskType.medium;
      case SubSectorType.highRisk:
        return RiskType.high;
      default:
        return null;
    }
  }
}

enum AssetsCategory {
  gold('Emas / Logam Mulia'),
  deposit('Deposito Bank'),
  mutualFundMoneyMarket('Reksa Dana Pasar Uang'),
  mutualFundFixedIncome('Reksa Dana Pendapatan Tetap'),
  bonds('Obligasi / Surat Berharga'),
  property('Properti / Real Estat'),
  mutualFundStock('Reksa Dana Saham'),
  stocks('Saham / Ekuitas'),
  crypto('Mata Uang Kripto'),
  p2pLending('P2P Lending / Urun Dana');

  final String value;

  const AssetsCategory(this.value);
}

enum WalletType { cash, bank, eWallet, platform }
