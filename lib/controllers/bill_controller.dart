import 'package:flutter/material.dart';

import '../controllers/transaction_controller.dart';
import '../controllers/user_controller.dart';
import '../data/local/dao/bill_dao.dart';
import '../data/local/dao/debt_dao.dart';
import '../models/bill_model.dart';
import '../models/debt_model.dart';

class BillController with ChangeNotifier {
  final BillDao _billDao;
  final DebtDao _debtDao;
  final UserController _userController;
  final TransactionController _transactionController;
  List<BillModel> bills = [];
  List<DebtModel> debts = [];

  BillController(
    this._billDao,
    this._debtDao,
    this._userController,
    this._transactionController,
  ) {
    loadData();
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
      _userController.updateFreeDebt(false);
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

  Future<void> loadData() async {
    try {
      await loadDebtData();
      await _transactionController.loadBillTransaction();
    } catch (e) {
      debugPrint("[BILL] An error occurred while loading data: $e");
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
      await loadBillData();
      Map<int, BillModel> billMap = {};
      for (var row in bills) {
        if (row.debtId != null) {
          billMap[row.debtId!] = row;
        }
      }
      debts = debts.map((e) {
        e.updateBill(billMap[e.id]);
        return e;
      }).toList();
    } catch (e) {
      debugPrint("[BILL] An error occurred while loading debt: $e");
    } finally {
      notifyListeners();
    }
  }
}
