import 'package:decimal/decimal.dart';

import '../core/utils/enum_types.dart';
import 'transaction_detail_model.dart';

class TransactionModel {
  int? id;
  final int? walletId;
  int? debtId;
  int? billId;
  int? assetsId;
  int? receivableId;
  final int? targetId;
  final String title;
  final Decimal amount;
  int dateTimestamp;
  StatusType status;
  final TransactionType type;
  final List<TransactionDetailModel> detailTransaction;

  TransactionModel({
    required this.type,
    required this.title,
    required this.amount,
    required this.status,
    required this.detailTransaction,
    required this.dateTimestamp,

    this.id,
    this.walletId,
    this.debtId,
    this.billId,
    this.assetsId,
    this.receivableId,
    this.targetId,
  });

  void setTransactionId(int? id) {
    this.id = id;
  }

  void setAssetId(int id) {
    assetsId = id;
  }

  void setBillId(int id) {
    billId = id;
  }

  void setDebtId(int id) {
    debtId = id;
  }

  void setReceivableId(int id) {
    receivableId = id;
  }

  void setStatus(StatusType status) {
    this.status = status;
  }

  void setDateTimestamp(DateTime date) {
    dateTimestamp = date.millisecondsSinceEpoch;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "wallet_id": walletId,
      "debt_id": debtId,
      "bill_id": billId,
      "receivable_id": receivableId,
      "assets_id": assetsId,
      "target_id": targetId,
      "title": title,
      "amount": amount.toString(),
      "type": type.name,
      "status": status.name,
      "date_timestamp": dateTimestamp,
    };
  }

  factory TransactionModel.fromMap(
    Map<String, dynamic> map, {
    List<TransactionDetailModel>? details,
  }) {
    return TransactionModel(
      id: map['id'],
      walletId: map['wallet_id'],
      debtId: map['debt_id'],
      billId: map['bill_id'],
      receivableId: map['receivable_id'],
      assetsId: map['assets_id'],
      targetId: map['target_id'],
      title: map['title'],
      amount: Decimal.parse(map['amount'] ?? '0'),
      dateTimestamp: map['date_timestamp'],
      status: StatusType.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StatusType.pending,
      ),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      detailTransaction: details ?? [],
    );
  }
}
