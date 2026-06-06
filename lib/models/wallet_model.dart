import 'package:decimal/decimal.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/utils/enum_types.dart';

class WalletModel {
  final int? id;
  final String name;
  final WalletType type;
  Decimal amount;
  Decimal reservedAmount;

  WalletModel({
    required this.name,
    required this.type,
    required this.amount,

    this.id,
    Decimal? reservedAmount,
  }) : reservedAmount = reservedAmount ?? Decimal.zero;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'amount': amount.toString(),
      'reserved_amount': reservedAmount.toString(),
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
      reservedAmount: Decimal.parse(map['reserved_amount'] ?? '0'),
    );
  }
}

extension WalletExtension on WalletModel {
  Decimal get regularAmount =>
      amount > Decimal.zero ? amount - reservedAmount : Decimal.zero;

  void addAmount(Decimal amount, {bool isIncome = true}) {
    if (isIncome) {
      this.amount += amount;
    } else {
      this.amount -= amount;
    }
  }

  void addReserved(Decimal amount, {bool isIncome = true}) {
    if (isIncome) {
      reservedAmount += amount;
    } else {
      reservedAmount -= amount;
    }
  }

  Decimal autoExpanse(Decimal amount, {bool useReserved = false}) {
    Decimal availableAmount = this.amount - reservedAmount;
    Decimal deductedFromReserved = Decimal.zero;

    if (useReserved) {
      deductedFromReserved = amount > reservedAmount ? reservedAmount : amount;

      addReserved(deductedFromReserved, isIncome: false);
    } else if (amount > availableAmount) {
      Decimal overflowAmount = amount - availableAmount;

      deductedFromReserved = overflowAmount > reservedAmount
          ? reservedAmount
          : overflowAmount;

      addReserved(deductedFromReserved, isIncome: false);
    }

    addAmount(amount, isIncome: false);
    return deductedFromReserved;
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
