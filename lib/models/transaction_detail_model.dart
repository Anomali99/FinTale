enum TransactionCategory {
  food,
  groceries,
  transport,
  entertainment,
  health,
  utilities,
  debtInstallment,
  salary,
  business,
  dividend,
  transfer,
  investment,
}

enum FlowType { expense, income, transfer }

class TransactionDetailModel {
  final int? id;
  final String title;
  final BigInt amount;
  final FlowType flow;
  final TransactionCategory category;

  const TransactionDetailModel({
    required this.title,
    required this.amount,
    required this.category,
    required this.flow,
    this.id,
  });
}
