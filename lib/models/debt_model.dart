import '../core/utils/tier_analyzer.dart';
import 'bill_model.dart';

enum DebtType { creditCard, mortgage, vehicle, personal, business, other }

class DebtModel {
  final int? id;
  final String title;
  final BigInt amount;
  final DebtType type;
  final BillModel? bill;
  BigInt paidAmount;

  DebtModel({
    required this.title,
    required this.amount,
    required this.type,

    this.id,
    this.bill,

    BigInt? paidAmount,
  }) : paidAmount = paidAmount ?? BigInt.from(0);

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

  void addPayment(BigInt pay) {
    paidAmount += pay;
  }
}
