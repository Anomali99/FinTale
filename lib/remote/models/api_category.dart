// DTO kategori untuk request ke server FinTale.
// id adalah nama enum TransactionCategory (contoh: "food", "salary").

import '../../../core/utils/enum_types.dart';

class ApiCategory {
  /// Nama enum TransactionCategory, misal "food", "salary", "transport".
  final String id;

  /// Nama tampilan untuk referensi server (bebas format).
  final String name;

  const ApiCategory({required this.id, required this.name});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };

  /// Membuat ApiCategory dari enum TransactionCategory aplikasi.
  factory ApiCategory.fromTransactionCategory(TransactionCategory category) {
    return ApiCategory(
      id: category.name,
      name: category.categoryDict.value,
    );
  }

  /// Daftar semua kategori pengeluaran dan pemasukan yang relevan untuk parser.
  /// Tidak menyertakan kategori invest (lowRisk, mediumRisk, highRisk).
  static List<ApiCategory> get parserCategories {
    return [
      ...TransactionCategory.expenseCategories,
      ...TransactionCategory.incomeCategories,
    ]
        .where(
          (c) => !TransactionCategory.investCategories.contains(c),
        )
        .map(ApiCategory.fromTransactionCategory)
        .toList();
  }
}
