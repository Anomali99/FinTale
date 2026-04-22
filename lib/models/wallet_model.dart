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
}
