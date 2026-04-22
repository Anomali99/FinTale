import 'package:decimal/decimal.dart';

enum RiskType { low, medium, high }

enum AssetsCategory {
  gold('Gold / Precious Metals'),
  deposit('Bank Deposit'),
  mutualFundMoneyMarket('Money Market Mutual Fund'),
  mutualFundFixedIncome('Fixed Income Mutual Fund'),
  bonds('Bonds / Securities'),
  property('Real Estate / Property'),
  mutualFundStock('Equity Mutual Fund'),
  stocks('Stocks / Equities'),
  crypto('Cryptocurrency'),
  p2pLending('P2P Lending / Crowdfunding');

  final String value;

  const AssetsCategory(this.value);
}

class AssetsModel {
  final int? id;
  final String name;
  final RiskType type;
  final AssetsCategory category;
  final bool hasDividend;
  final String unitName;
  BigInt invested;
  BigInt value;
  Decimal unit;

  AssetsModel({
    required this.name,
    required this.type,
    required this.category,
    required this.unitName,
    required this.invested,
    required this.value,
    required this.unit,

    this.id,

    bool? hasDividend,
  }) : hasDividend = hasDividend ?? false;

  void addInvested(BigInt addInvested, BigInt newValue, Decimal newUint) {
    invested += addInvested;
    value = newValue;
    unit = newUint;
  }
}
