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

  bool get isProfit => value > invested;

  double get getPercentage {
    if (invested == BigInt.zero) return 0.0;

    double current = value.toDouble();
    double capital = invested.toDouble();

    return (((current - capital) / capital) * 100).abs();
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "type": type.name,
      "category": category.name,
      "has_dividend": hasDividend ? 1 : 0,
      "unit_name": unitName,
      "invested": invested.toString(),
      "value": value.toString(),
      "unit": unit.toString(),
    };
  }

  factory AssetsModel.fromMap(Map<String, dynamic> map) {
    return AssetsModel(
      id: map['id'],
      name: map['name'],
      type: RiskType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => RiskType.low,
      ),
      category: AssetsCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => AssetsCategory.bonds,
      ),
      unitName: map['unit_name'],
      invested: BigInt.parse(map['invested'] ?? '0'),
      value: BigInt.parse(map['value'] ?? '0'),
      unit: Decimal.parse(map['unit'] ?? '0'),
      hasDividend: map['has_dividend'] == 1,
    );
  }
}
