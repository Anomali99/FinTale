import 'package:decimal/decimal.dart';
import 'package:fintale/core/constants/ui_dict.dart';

import '../../../core/utils/enum_types.dart';
import 'transaction_detail_model.dart';
import 'transaction_model.dart';

class ReceivableModel {
  final int? id;
  final String borrowerName;
  final String title;
  final Decimal amount;
  final int dateTimestamp;
  Decimal paidAmount;
  int? targetDate;
  bool isReminderActive;

  ReceivableModel({
    required this.title,
    required this.borrowerName,
    required this.amount,
    required this.dateTimestamp,
    this.targetDate,
    this.id,
    Decimal? paidAmount,
    this.isReminderActive = false,
  }) : paidAmount = paidAmount ?? Decimal.zero;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "borrower_name": borrowerName,
      "title": title,
      "amount": amount.toString(),
      "paid_amount": paidAmount.toString(),
      "date_timestamp": dateTimestamp,
      "target_date": targetDate,
      "is_reminder_active": isReminderActive ? 1 : 0,
    };
  }

  factory ReceivableModel.fromMap(Map<String, dynamic> map) {
    return ReceivableModel(
      id: map['id'],
      borrowerName: map['borrower_name'] ?? map['inDebt'] ?? '',
      title: map['title'],
      amount: Decimal.parse(map['amount'] ?? '0'),
      paidAmount: Decimal.parse(map['paid_amount'] ?? '0'),
      dateTimestamp: map['date_timestamp'] ?? 0,
      targetDate: map['target_date'] ?? map['targeDate'],
      isReminderActive: (map['is_reminder_active'] ?? 0) == 1,
    );
  }
}

extension ReceivableExtension on ReceivableModel {
  Decimal get currentReceivable => amount - paidAmount;

  bool get isFinished => paidAmount >= amount;

  double get returnPercentage {
    if (amount <= Decimal.zero) return 0.0;
    if (paidAmount >= amount) return 1.0;
    return (paidAmount.toDouble() / amount.toDouble()).clamp(0.0, 1.0);
  }

  void setReminderActive(bool status) {
    isReminderActive = status;
  }

  void addPayment(Decimal pay) {
    paidAmount += pay;
  }

  void setTargetDate(DateTime? date) {
    targetDate = date?.millisecondsSinceEpoch;
  }

  void setIntTargetDate(int? date) {
    targetDate = date;
  }

  void clearTargetDate() {
    targetDate = null;
  }

  TransactionModel generateTransaction({
    StatusType? status,
    int? walletId,
    Decimal? feeAmount,
  }) {
    Decimal totalAmount = amount;
    if (feeAmount != null) totalAmount -= feeAmount;

    List<TransactionDetailModel> details = [
      TransactionDetailModel(
        title: title,
        amount: totalAmount,
        flow: FlowType.expense,
        category: TransactionCategory.lending,
      ),
    ];

    if (feeAmount != null) {
      details.add(
        TransactionDetailModel(
          title: 'Fee',
          amount: feeAmount,
          category: TransactionCategory.utilities,
          flow: FlowType.expense,
        ),
      );
    }

    return TransactionModel(
      type: TransactionType.debt,
      debtId: id,
      walletId: walletId,
      title: UiDict.getLoan(borrowerName),
      amount: amount,
      status: status ?? StatusType.paid,
      dateTimestamp: dateTimestamp,
      detailTransaction: details,
    );
  }
}
