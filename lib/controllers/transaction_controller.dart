import 'package:flutter/material.dart';

import '../data/local/dao/transaction_dao.dart';
import '../models/transaction_model.dart';

class TransactionController extends ChangeNotifier {
  final TransactionDao _transactionDao;
  List<TransactionModel> transactions = [];
  BigInt income = BigInt.zero;
  BigInt expense = BigInt.zero;

  final Map<String, List<TransactionModel>> _monthlyCache = {};

  TransactionController(this._transactionDao);

  Future<void> createTransaction(TransactionModel transaction) async {
    await _transactionDao.create(transaction);
    _monthlyCache.clear();
  }

  Future<TransactionModel?> getById(int id) async {
    TransactionModel? result = await _transactionDao.readDataWithChild(id);
    return result;
  }

  Future<void> loadData({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? walletIds,
    List<TransactionType>? types,
  }) async {
    try {
      DateTime now = DateTime.now();
      DateTime finalStart = startDate ?? DateTime(now.year, now.month, 1);
      DateTime finalEnd =
          endDate ?? DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      String cacheKey = "${finalStart.year}-${finalStart.month}";

      bool isCustomFilter =
          (walletIds != null && walletIds.isNotEmpty) ||
          (types != null && types.isNotEmpty);

      if (!isCustomFilter && _monthlyCache.containsKey(cacheKey)) {
        transactions = List.from(_monthlyCache[cacheKey]!);
      } else {
        transactions = await _transactionDao.getFilteredData(
          startDate: finalStart,
          endDate: finalEnd,
          walletId: walletIds,
          type: types,
          status: [StatusType.paid],
        );

        if (!isCustomFilter) {
          _monthlyCache[cacheKey] = List.from(transactions);
        }
      }

      income = BigInt.zero;
      expense = BigInt.zero;

      for (TransactionModel transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          income += transaction.amount;
        } else if (transaction.type != TransactionType.transfer) {
          expense += transaction.amount;
        }
      }
    } catch (e) {
      debugPrint("[TRANSACTION] Terjadi kesalahan saat memuat transaksi: $e");
    } finally {
      notifyListeners();
    }
  }
}
