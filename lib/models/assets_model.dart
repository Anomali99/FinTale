import 'package:decimal/decimal.dart';

import '../core/constants/category_dict.dart';
import '../core/models/category_model.dart';
import '../core/utils/enum_types.dart';

class AssetsModel {
  final int? id;
  final String name;
  final RiskType type;
  final AssetsCategory category;
  final bool hasDividend;
  final bool isEmergency;
  final String unitName;
  Decimal invested;
  Decimal value;
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
    this.hasDividend = false,
    this.isEmergency = false,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "type": type.name,
      "category": category.name,
      "has_dividend": hasDividend ? 1 : 0,
      "is_emergency": isEmergency ? 1 : 0,
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
      invested: Decimal.parse(map['invested'] ?? '0'),
      value: Decimal.parse(map['value'] ?? '0'),
      unit: Decimal.parse(map['unit'] ?? '0'),
      hasDividend: map['has_dividend'] == 1,
      isEmergency: map['is_emergency'] == 1,
    );
  }
}

extension AssetsExtension on AssetsModel {
  void addInvested(Decimal addInvested, Decimal newValue, Decimal newUint) {
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

  CategoryModel get typeDict {
    switch (type) {
      case RiskType.low:
        return CategoryDict.lowRisk;
      case RiskType.medium:
        return CategoryDict.mediumRisk;
      case RiskType.high:
        return CategoryDict.highRisk;
    }
  }
}
