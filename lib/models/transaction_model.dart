import 'transaction_detail_model.dart';

enum TransactionType { expense, debt, income, transfer }

enum StatusType { pending, overdue, paid }

class TransactionModel {
  final int? id;
  final int? walletId;
  final int? billId;
  final int? assetsId;
  final int? targetId;
  final String title;
  final BigInt amount;
  final int dateTimestamp;
  final StatusType status;
  final TransactionType type;
  final List<TransactionDetailModel> detailTransaction;

  const TransactionModel({
    required this.type,
    required this.title,
    required this.amount,
    required this.status,
    required this.detailTransaction,
    required this.dateTimestamp,

    this.id,
    this.walletId,
    this.billId,
    this.assetsId,
    this.targetId,
  });
}
