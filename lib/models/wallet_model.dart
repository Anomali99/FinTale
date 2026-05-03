import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum WalletType { cash, bank, eWallet, platform }

class WalletModel {
  final int? id;
  final String name;
  final WalletType type;
  BigInt amount;
  BigInt reservedAmount;

  WalletModel({
    required this.name,
    required this.type,
    required this.amount,

    this.id,
    BigInt? reservedAmount,
  }) : reservedAmount = reservedAmount ?? BigInt.zero;

  void income(BigInt income) {
    amount += income;
  }

  void expense(BigInt expense) {
    amount -= expense;
  }

  void reservedIncome(BigInt income) {
    reservedAmount += income;
  }

  void reservedExpense(BigInt expense) {
    reservedAmount -= expense;
  }

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
      amount: BigInt.parse(map['amount'] ?? '0'),
      reservedAmount: BigInt.parse(map['reserved_amount'] ?? '0'),
    );
  }
}

extension WalletExten on WalletModel {
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
