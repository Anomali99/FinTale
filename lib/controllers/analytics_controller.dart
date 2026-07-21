import 'package:flutter/material.dart';

import '../../../core/utils/enum_types.dart';
import 'transaction_controller.dart';

class AnalyticsController with ChangeNotifier {
  final TransactionController _transactionController;

  DateTime selectedMonth = DateTime.now();

  DateTime? customStartDate;
  DateTime? customEndDate;
  List<TransactionCategory> selectedCategories = [];
  List<int> selectedWallets = [];
  bool showExpense = true;
  int touchedIndex = -1;

  AnalyticsController(this._transactionController);

  void onTouchIndex(int index) {
    touchedIndex = index;
    notifyListeners();
  }

  void onTapExpense(bool value) {
    showExpense = value;
    touchedIndex = -1;
    notifyListeners();
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
    DateTime? startDate,
    DateTime? endDate,
    List<TransactionCategory> categories,
    List<int> wallets,
  ) {
    customStartDate = startDate;
    customEndDate = endDate;
    selectedCategories = categories;
    selectedWallets = wallets;
  }

  void resetFilter() {
    customStartDate = null;
    customEndDate = null;
    selectedCategories.clear();
    selectedWallets.clear();

    selectedMonth = DateTime.now();
    applyFilter();
  }

  Future<void> applyFilter() async {
    DateTime start;
    DateTime end;
    bool filtered = false;

    if (customStartDate != null && customEndDate != null) {
      filtered = true;
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

    await _transactionController.loadDetail(
      startDate: start,
      endDate: end,
      categories: selectedCategories.isNotEmpty ? selectedCategories : null,
      walletIds: selectedWallets.isNotEmpty ? selectedWallets : null,
      filtered: filtered,
    );
    notifyListeners();
  }
}
