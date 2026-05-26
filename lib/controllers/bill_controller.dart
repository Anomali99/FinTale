import 'package:flutter/material.dart';

import '../controllers/transaction_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/wallet_controller.dart';
import '../core/utils/enum_types.dart';
import '../data/local/dao/bill_dao.dart';
import '../data/local/dao/debt_dao.dart';
import '../models/bill_model.dart';
import '../models/debt_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

class BillController with ChangeNotifier {
  final BillDao _billDao;
  final DebtDao _debtDao;
  final UserController _userController;
  final WalletController _walletController;
  final TransactionController _transactionController;
  List<BillModel> bills = [];
  List<DebtModel> debts = [];

  BillController(
    this._billDao,
    this._debtDao,
    this._userController,
    this._walletController,
    this._transactionController,
  ) {
    loadData();
  }

  bool get isFreeDebt {
    for (DebtModel debt in debts) {
      if (!debt.isFinished) {
        return false;
      }
    }
    return true;
  }

  DebtModel getDebtById(int? id) => debts.firstWhere((e) => e.id == id);
  BillModel getBillById(int? id) => bills.firstWhere((e) => e.id == id);

  TransactionModel? getActiveTransaction(int? billId) {
    if (billId != null) {
      for (TransactionModel transaction
          in _transactionController.billTransaction) {
        if (transaction.billId == billId &&
            transaction.status != StatusType.paid) {
          return transaction;
        }
      }
    }
    return null;
  }

  Future<bool> generateBillDraft(BillModel bill) async {
    try {
      final existingPendingTransaction = getActiveTransaction(bill.id);
      if (existingPendingTransaction != null) return false;

      TransactionModel transaction = bill.generateTransaction();
      await _transactionController.createTransaction(
        transaction,
        isDraft: true,
      );
      await _transactionController.loadBillTransaction();
      return true;
    } catch (e) {
      debugPrint("[BILL] An error occurred while create bills: $e");
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> payBill(
    TransactionModel transaction, {
    bool useReserved = false,
  }) async {
    try {
      final wallet = _walletController.getWalletById(transaction.walletId ?? 1);
      wallet.autoExpanse(transaction.amount, useReserved: useReserved);

      if (transaction.debtId != null) {
        final debt = getDebtById(transaction.debtId);

        if (debt.isFinished && debt.bill != null) {
          debt.bill?.toggleActive(false);
        }
        debt.bill?.advanceToNextBill();
        await _debtDao.update(debt);
      } else {
        final bill = getBillById(transaction.billId ?? 1);
        bill.advanceToNextBill();
        await _billDao.update(bill);
      }

      final existingPendingTransaction = getActiveTransaction(
        transaction.billId,
      );

      if (existingPendingTransaction != null) {
        transaction.setTransactionId(existingPendingTransaction.id);
      }

      await _transactionController.createTransaction(transaction);
      await _walletController.updateWallet(wallet);
      await loadDebtData();

      _userController.updateFreeDebt(isFreeDebt);
      await _userController.processRecordTransaction();
      await _userController.saveUser();
      await _walletController.loadData();
      await _userController.loadData();
      await _transactionController.loadBillTransaction();
    } catch (e) {
      debugPrint("[BILL] An error occurred while pay bill: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> payDebt(
    TransactionModel transaction, {
    bool useReserved = false,
  }) async {
    try {
      final wallet = _walletController.getWalletById(transaction.walletId ?? 1);
      final debt = getDebtById(transaction.debtId ?? 1);
      await _transactionController.createTransaction(transaction);
      wallet.autoExpanse(transaction.amount, useReserved: useReserved);
      debt.addPayment(transaction.detailTransaction[0].amount);

      if (debt.isFinished && debt.bill != null) {
        debt.bill?.toggleActive(false);
      }

      await _debtDao.update(debt);
      await _walletController.updateWallet(wallet);
      await loadDebtData();

      _userController.updateFreeDebt(isFreeDebt);
      await _userController.processRecordTransaction();
      await _userController.saveUser();
      await _walletController.loadData();
      await _userController.loadData();
    } catch (e) {
      debugPrint("[BILL] An error occurred while pay debt: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> createBill(BillModel bill) async {
    try {
      if (bill.id == null) {
        await _billDao.create(bill);
      } else {
        await _billDao.update(bill);
      }
      if (bill.debtId == null) {
        await loadBillData();
      } else {
        await loadDebtData();
      }
    } catch (e) {
      debugPrint("[BILL] An error occurred while create bills: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> createDebt(DebtModel debt) async {
    try {
      if (debt.id == null) {
        await _debtDao.create(debt);
        _userController.updateFreeDebt(false);
      } else {
        await _debtDao.update(debt);
      }
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
      bills.sort((a, b) {
        if (a.isActive == b.isActive) return 0;
        return a.isActive ? 1 : -1;
      });
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
