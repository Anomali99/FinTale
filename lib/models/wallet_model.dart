enum WalletType { cash, bank, eWallet, platform }

class WalletModel {
  final int? id;
  final String name;
  final WalletType type;
  BigInt amount;

  WalletModel({
    required this.name,
    required this.type,
    required this.amount,

    this.id,
  });

  void income(BigInt income) {
    amount += income;
  }

  void expense(BigInt expense) {
    amount -= expense;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'amount': amount.toString(),
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
    );
  }
}
