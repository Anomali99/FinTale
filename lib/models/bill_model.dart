import 'package:intl/intl.dart';

import '../core/utils/tier_analyzer.dart';
import 'transaction_detail_model.dart';
import 'transaction_model.dart';

enum TimeType { daily, weekly, monthly, annual }

enum DayName { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class BillModel {
  final int? id;
  final int? debtId;
  final String title;
  final BigInt amount;
  final TimeType type;
  final int? day;
  final int? month;
  final DayName? dayName;

  const BillModel({
    required this.title,
    required this.amount,
    required this.type,

    this.id,
    this.debtId,
    this.day,
    this.month,
    this.dayName,
  });

  BillTier get tier => TierAnalyzer.calculateBillTier(amount, type);

  String _getTargetTitle(DateTime targetDate) {
    switch (type) {
      case TimeType.daily:
        return DateFormat('EEEE, dd MMMM yyyy').format(targetDate);

      case TimeType.weekly:
        return DateFormat('dd MMMM yyyy').format(targetDate);

      case TimeType.monthly:
        return DateFormat('MMMM yyyy').format(targetDate);

      case TimeType.annual:
        return DateFormat('yyyy').format(targetDate);
    }
  }

  TransactionModel getTransaction(DateTime transactionDate) {
    final String targetInfo = _getTargetTitle(transactionDate);

    return TransactionModel(
      type: TransactionType.expense,
      billId: id,
      title: title,
      amount: amount,
      status: StatusType.pending,
      dateTimestamp: transactionDate.millisecondsSinceEpoch,
      detailTransaction: [
        TransactionDetailModel(
          title: 'Bill $targetInfo',
          amount: amount,
          flow: FlowType.expense,
          category: debtId != null
              ? TransactionCategory.debtInstallment
              : TransactionCategory.utilities,
        ),
      ],
    );
  }
}
