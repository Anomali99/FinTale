import 'package:flutter/material.dart';

import '../data/local/dao/bill_dao.dart';
import '../data/local/dao/debt_dao.dart';
import '../models/bill_model.dart';
import '../models/debt_model.dart';

class BillController with ChangeNotifier {
  final BillDao _billDao;
  final DebtDao _debtDao;
  List<BillModel> bills = [];
  List<DebtModel> debts = [];

  BillController(this._billDao, this._debtDao) {
    loadBillData();
    loadDebtData();
  }

  Future<void> createBill(BillModel bill) async {
    try {
      await _billDao.create(bill);
      await loadBillData();
    } catch (e) {
      debugPrint("[BILL] An error occurred while create bills: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> createDebt(DebtModel debt) async {
    try {
      await _debtDao.create(debt);
      await loadDebtData();
      if (debt.bill != null) {
        loadBillData();
      }
    } catch (e) {
      debugPrint("[BILL] An error occurred while create debt: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadBillData() async {
    try {
      bills = await _billDao.readAllActiveData();
    } catch (e) {
      debugPrint("[BILL] An error occurred while loading bills: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadDebtData() async {
    try {
      debts = await _debtDao.readAllActiveData();
    } catch (e) {
      debugPrint("[BILL] An error occurred while loading debt: $e");
    } finally {
      notifyListeners();
    }
  }
}
