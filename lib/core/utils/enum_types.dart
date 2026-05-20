enum RiskType { low, medium, high }

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
  monday('Senin'),
  tuesday('Selasa'),
  wednesday('Rabu'),
  thursday('Kamis'),
  friday('Jum\'at'),
  saturday('Sabtu'),
  sunday('Minggu');

  final String value;
  const DayName(this.value);
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
  highRisk,
}

enum FlowType { expense, income, transfer }

enum TransactionType {
  income('Pemasukan'),
  expense('Pengeluaran'),
  transfer('Transfer'),
  debt('Pembayaran Hutang');

  final String value;
  const TransactionType(this.value);
}

enum StatusType { pending, overdue, paid }

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

enum WalletType { cash, bank, eWallet, platform }
