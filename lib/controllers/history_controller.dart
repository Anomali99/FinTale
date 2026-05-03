import 'package:flutter/material.dart';

import '../core/utils/time_formatter.dart';
import '../models/transaction_model.dart';
import 'transaction_controller.dart';

class HistoryController with ChangeNotifier {
  final TransactionController _transactionController;

  DateTime selectedMonth = DateTime.now();

  DateTime? customStartDate;
  DateTime? customEndDate;
  List<TransactionType> selectedTypes = [];
  List<int> selectedWallets = [];

  HistoryController(this._transactionController) {
    applyFilter();
  }

  void onPrev() {
    selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    _clearCustomDateAndFetch();
  }

  void onNext() {
    selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    _clearCustomDateAndFetch();
  }

  void _clearCustomDateAndFetch() {
    customStartDate = null;
    customEndDate = null;
    applyFilter();
  }

  void updateFilter(
    DateTime startDate,
    DateTime? endDate,
    List<TransactionType> types,
    List<int> wallets,
  ) {
    customStartDate = startDate;
    customEndDate = endDate;
    selectedTypes = types;
    selectedWallets = wallets;
  }

  void applyFilter() {
    DateTime start;
    DateTime end;

    if (customStartDate != null && customEndDate != null) {
      start = customStartDate!;
      end = DateTime(
        customEndDate!.year,
        customEndDate!.month,
        customEndDate!.day,
        23,
        59,
        59,
      );
    } else {
      start = DateTime(selectedMonth.year, selectedMonth.month, 1);
      end = DateTime(
        selectedMonth.year,
        selectedMonth.month + 1,
        0,
        23,
        59,
        59,
      );
    }

    _transactionController.loadData(
      startDate: start,
      endDate: end,
      types: selectedTypes.isNotEmpty ? selectedTypes : null,
      walletIds: selectedWallets.isNotEmpty ? selectedWallets : null,
    );
    notifyListeners();
  }

  void resetFilter() {
    customStartDate = null;
    customEndDate = null;
    selectedTypes.clear();
    selectedWallets.clear();

    selectedMonth = DateTime.now();
    applyFilter();
  }

  Map<String, List<TransactionModel>> get groupedTransactions {
    Map<String, List<TransactionModel>> groupedData = {};
    List<TransactionModel> transactions = _transactionController.transactions;

    for (TransactionModel trx in transactions) {
      String dateKey = TimeFormatter.formatShort(trx.dateTimestamp);

      if (!groupedData.containsKey(dateKey)) {
        groupedData[dateKey] = [];
      }

      groupedData[dateKey]!.add(trx);
    }
    return groupedData;
  }
}
