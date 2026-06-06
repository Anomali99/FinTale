import 'package:decimal/decimal.dart';

import '../core/constants/screen_dict.dart';
import '../core/constants/ui_dict.dart';
import '../core/utils/enum_types.dart';
import '../core/utils/tier_analyzer.dart';
import '../models/transaction_detail_model.dart';
import '../models/transaction_model.dart';
import 'bill_model.dart';

class DebtModel {
  final int? id;
  final String title;
  final Decimal amount;
  final DebtType type;
  BillModel? bill;
  Decimal paidAmount;

  DebtModel({
    required this.title,
    required this.amount,
    required this.type,

    this.id,
    this.bill,

    Decimal? paidAmount,
  }) : paidAmount = paidAmount ?? Decimal.zero;

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
      amount: Decimal.parse(map['amount'] ?? '0'),
      paidAmount: Decimal.parse(map['paid_amount'] ?? '0'),
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

  int get level =>
      TierAnalyzer.calculateDebtLevel(BigInt.parse(amount.toString()));

  Decimal get currentDebt => amount - paidAmount;

  double debtPercentage(bool isRpg) {
    if (amount > Decimal.zero) {
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

  void addPayment(Decimal pay) {
    paidAmount += pay;
  }

  TransactionModel generateTransaction({
    StatusType? status,
    int? walletId,
    Decimal? totalAmount,
    Decimal? detailAmount,
  }) {
    DateTime now = DateTime.now();
    return TransactionModel(
      type: TransactionType.debt,
      debtId: id,
      walletId: walletId,
      title: '${ScreenDict.billsPayAction.get(false)} $title',
      amount: totalAmount ?? amount,
      status: status ?? StatusType.paid,
      dateTimestamp: now.millisecondsSinceEpoch,
      detailTransaction: [
        TransactionDetailModel(
          title: '${UiDict.amount} ${ScreenDict.billsPayAction.get(false)}',
          amount: detailAmount ?? amount,
          flow: FlowType.expense,
          category: TransactionCategory.debtInstallment,
        ),
      ],
    );
  }
}
