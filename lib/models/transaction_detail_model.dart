import 'package:decimal/decimal.dart';

import '../core/utils/enum_types.dart';

class TransactionDetailModel {
  final int? id;
  final String title;
  final Decimal amount;
  final FlowType flow;
  final TransactionCategory category;

  const TransactionDetailModel({
    required this.title,
    required this.amount,
    required this.category,
    required this.flow,
    this.id,
  });

  Map<String, dynamic> toMap(int transactionId) {
    return {
      "id": id,
      "transaction_id": transactionId,
      "title": title,
      "amount": amount.toString(),
      "flow": flow.name,
      "category": category.name,
    };
  }

  factory TransactionDetailModel.fromMap(Map<String, dynamic> map) {
    return TransactionDetailModel(
      id: map['id'],
      title: map['title'],
      amount: Decimal.parse(map['amount'] ?? '0'),
      flow: FlowType.values.firstWhere(
        (e) => e.name == map['flow'],
        orElse: () => FlowType.expense,
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TransactionCategory.food,
      ),
    );
  }
}
