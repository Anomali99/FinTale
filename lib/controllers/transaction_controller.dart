import 'package:flutter/material.dart';

import '../core/models/analytic_model.dart';
import '../data/local/dao/transaction_dao.dart';
import '../models/transaction_detail_model.dart';
import '../models/transaction_model.dart';

class TransactionController extends ChangeNotifier {
  final TransactionDao _transactionDao;
  List<TransactionModel> transactions = [];
  Map<int, AnalyticModel> detailExpense = {};
  Map<int, AnalyticModel> detailInvest = {};
  BigInt income = BigInt.zero;
  BigInt expense = BigInt.zero;

  BigInt totalIncome = BigInt.zero;
  BigInt totalExpense = BigInt.zero;
  BigInt totalInvest = BigInt.zero;

  final Map<String, List<TransactionModel>> _monthlyCache = {};

  TransactionController(this._transactionDao) {
    loadData();
  }

  BigInt get totalIdle => totalIncome - (totalExpense + totalInvest);

  Future<void> createTransaction(TransactionModel transaction) async {
    await _transactionDao.create(transaction);
    _monthlyCache.clear();
  }

  Future<void> loadDetail({DateTime? startDate, DateTime? endDate}) async {
    try {
      DateTime now = DateTime.now();
      DateTime finalStart = startDate ?? DateTime(now.year, now.month, 1);
      DateTime finalEnd =
          endDate ?? DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      String cacheKey = "${finalStart.year}-${finalStart.month}";
      List<TransactionModel> transaction = [];

      if (_monthlyCache.containsKey(cacheKey)) {
        transaction = List.from(_monthlyCache[cacheKey]!);
      } else {
        transaction = await _transactionDao.getFilteredDataWithChild(
          startDate: finalStart,
          endDate: finalEnd,
          status: [StatusType.paid],
        );

        _monthlyCache[cacheKey] = List.from(transaction);
      }

      totalIncome = BigInt.zero;
      totalExpense = BigInt.zero;
      totalInvest = BigInt.zero;

      Map<TransactionCategory, AnalyticModel> expenseTemp = {};
      Map<TransactionCategory, AnalyticModel> investTemp = {};

      for (TransactionModel transaction in transaction) {
        for (TransactionDetailModel detail in transaction.detailTransaction) {
          if (detail.flow == FlowType.income) {
            totalIncome += detail.amount;
          } else if (detail.flow == FlowType.expense) {
            if ([TransactionCategory.lowRisk].contains(detail.category)) {
              totalInvest += detail.amount;
              investTemp.update(
                detail.category,
                (existing) {
                  existing.addAmount(detail.amount);
                  return existing;
                },
                ifAbsent: () {
                  return AnalyticModel(
                    id: detail.category,
                    amount: detail.amount,
                  );
                },
              );
            } else {
              totalExpense += detail.amount;
              expenseTemp.update(
                detail.category,
                (existing) {
                  existing.addAmount(detail.amount);
                  return existing;
                },
                ifAbsent: () {
                  return AnalyticModel(
                    id: detail.category,
                    amount: detail.amount,
                  );
                },
              );
            }
          }
        }
      }

      detailExpense = Map.from(expenseTemp.values.toList().asMap());
      detailInvest = Map.from(investTemp.values.toList().asMap());
    } catch (e) {
      debugPrint(
        "[TRANSACTION] An error occurred while loading the detail transaction: $e",
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadTransaction({
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
        transactions = await _transactionDao.getFilteredDataWithChild(
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
        for (TransactionDetailModel detail in transaction.detailTransaction) {
          if (detail.flow == FlowType.income) {
            income += detail.amount;
          } else if (detail.flow == FlowType.expense) {
            expense += detail.amount;
          }
        }
      }
    } catch (e) {
      debugPrint(
        "[TRANSACTION] An error occurred while loading the transaction: $e",
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadData() async {
    DateTime now = DateTime.now();
    DateTime finalStart = DateTime(now.year, now.month, 1);
    DateTime finalEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    await loadTransaction(startDate: finalStart, endDate: finalEnd);
    await loadDetail(startDate: finalStart, endDate: finalEnd);
  }
}
