import '../core/utils/enum_types.dart';
import '../core/utils/tier_analyzer.dart';
import 'bill_model.dart';

class DebtModel {
  final int? id;
  final String title;
  final BigInt amount;
  final DebtType type;
  BillModel? bill;
  BigInt paidAmount;

  DebtModel({
    required this.title,
    required this.amount,
    required this.type,

    this.id,
    this.bill,

    BigInt? paidAmount,
  }) : paidAmount = paidAmount ?? BigInt.from(0);

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "amount": amount.toString(),
      "paid_amount": paidAmount.toString(),
      "type": type.name,
    };
  }

  factory DebtModel.fromMap(Map<String, dynamic> map, {BillModel? bill}) {
    return DebtModel(
      id: map['id'],
      title: map['title'],
      amount: BigInt.parse(map['amount'] ?? '0'),
      paidAmount: BigInt.parse(map['paid_amount'] ?? '0'),
      type: DebtType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DebtType.other,
      ),
      bill: bill,
    );
  }
}

extension DebtExtension on DebtModel {
  bool get isFinished => paidAmount >= amount;

  int get level => TierAnalyzer.calculateDebtLevel(amount);

  BigInt get currentDebt => amount - paidAmount;

  double debtPercentage(bool isRpg) {
    if (amount > BigInt.zero) {
      if (isRpg) {
        return (currentDebt.toDouble() / amount.toDouble()).clamp(0.0, 1.0);
      } else {
        return (paidAmount.toDouble() / amount.toDouble()).clamp(0.0, 1.0);
      }
    } else {
      return 0.0;
    }
  }

  void updateBill(BillModel? bill) {
    this.bill = bill;
  }

  void addPayment(BigInt pay) {
    paidAmount += pay;
  }
}
