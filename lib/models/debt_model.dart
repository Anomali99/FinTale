import '../core/utils/tier_analyzer.dart';
import 'bill_model.dart';

class DebtModel {
  final int? id;
  final String title;
  final BigInt amount;
  final BillModel? bill;
  BigInt paidAmount;

  DebtModel({
    required this.title,
    required this.amount,

    this.id,
    this.bill,

    BigInt? paidAmount,
  }) : paidAmount = paidAmount ?? BigInt.from(0);

  int get level => TierAnalyzer.calculateDebtLevel(amount);

  void addPayment(BigInt pay) {
    paidAmount += pay;
  }
}
