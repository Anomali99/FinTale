import 'package:decimal/decimal.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/utils/enum_types.dart';

class WalletModel {
  final int? id;
  final String name;
  final WalletType type;
  Decimal amount;
  final int? parentId;
  bool isSavings;
  bool isEmergency;

  WalletModel({
    required this.name,
    required this.type,
    required this.amount,

    this.id,
    this.parentId,
    this.isSavings = false,
    this.isEmergency = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'amount': amount.toString(),
      'parent_id': parentId,
      'is_savings': isSavings ? 1 : 0,
      'is_emergency': isEmergency ? 1 : 0,
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'],
      name: map['name'],
      type: WalletType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => WalletType.cash,
      ),
      amount: Decimal.parse(map['amount'] ?? '0'),
      parentId: map['parent_id'],
      isSavings: (map['is_savings'] ?? 0) == 1,
      isEmergency: (map['is_emergency'] ?? 0) == 1,
    );
  }
}

extension WalletExtension on WalletModel {
  /// Whether this wallet is a pocket (child of a parent wallet).
  bool get isPocket => parentId != null;

  /// Whether this wallet is a parent (top-level) wallet.
  bool get isParent => parentId == null;

  /// Backward-compat: reservedAmount is always zero in the new model.
  /// Savings are now stored in separate pocket rows.
  Decimal get reservedAmount => Decimal.zero;

  /// Backward-compat: regularAmount = amount (no reserved deduction).
  Decimal get regularAmount => amount;

  void addAmount(Decimal amount, {bool isIncome = true}) {
    if (isIncome) {
      this.amount += amount;
    } else {
      this.amount -= amount;
    }
  }

  FaIconData get icon {
    switch (type) {
      case WalletType.cash:
        return FontAwesomeIcons.coins;
      case WalletType.bank:
        return FontAwesomeIcons.buildingColumns;
      case WalletType.eWallet:
        return FontAwesomeIcons.wallet;
      case WalletType.platform:
        return FontAwesomeIcons.mobileScreen;
    }
  }
}
