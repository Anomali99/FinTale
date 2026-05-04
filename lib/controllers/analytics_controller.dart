import 'package:flutter/material.dart';

import 'transaction_controller.dart';

class AnalyticsController with ChangeNotifier {
  final TransactionController _transactionController;

  DateTime selectedMonth = DateTime.now();
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
    applyFilter();
  }

  void onNext() {
    selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    applyFilter();
  }

  void applyFilter() {
    DateTime start;
    DateTime end;

    start = DateTime(selectedMonth.year, selectedMonth.month, 1);
    end = DateTime(selectedMonth.year, selectedMonth.month + 1, 0, 23, 59, 59);

    _transactionController.loadDetail(startDate: start, endDate: end);
    notifyListeners();
  }
}
