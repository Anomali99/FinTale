import 'package:flutter/material.dart';

import '../controllers/transaction_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/wallet_controller.dart';
import '../core/constants/ui_dict.dart';
import '../core/utils/enum_types.dart';
import '../data/dao/bill_dao.dart';
import '../data/dao/debt_dao.dart';
import '../models/bill_model.dart';
import '../models/debt_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../services/notification_service.dart';

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

  Future<void> autoDraftOrNotification({
    required BillModel bill,
    required DateTime today,
    bool isNotifOnly = false,
  }) async {
    DateTime target = bill.targetDate;
    DateTime targetDate = DateTime(target.year, target.month, target.day);

    int diffInDays = targetDate.difference(today).inDays;

    if (bill.type == TimeType.daily) {
      if (diffInDays <= 0 && !isNotifOnly) {
        await generateBillDraft(bill, status: StatusType.overdue);
      }
    } else {
      int generateThreshold = 3;
      if (bill.type == TimeType.monthly) generateThreshold = 15;
      if (bill.type == TimeType.annual) generateThreshold = 30;

      if (diffInDays <= 0 && !isNotifOnly) {
        await generateBillDraft(bill, status: StatusType.overdue);
      } else if (diffInDays <= generateThreshold && !isNotifOnly) {
        await generateBillDraft(bill);
      } else {
        String notificationId = 'bill_${bill.id}';
        bool isExist = await NotificationService().isNotificationScheduled(
          notificationId.hashCode,
        );
        if (!isExist) {
          DateTime scheduleDate = targetDate.subtract(
            Duration(days: generateThreshold),
          );
          scheduleDate = scheduleDate.add(const Duration(hours: 8));

          await NotificationService().scheduleCustomNotification(
            stringId: notificationId,
            title: UiDict.getNotifTitle(bill.title),
            body: UiDict.getNotifBody(generateThreshold.toString()),
            scheduledTime: scheduleDate,
          );
        }
      }
    }
  }

  Future<void> checAndCreateNotification() async {
    try {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      for (BillModel bill in bills) {
        if (!bill.isActive) continue;
        await autoDraftOrNotification(bill: bill, today: today);
      }
    } catch (e) {
      debugPrint("[BILL] An error occurred while chec notification bill: $e");
    }
  }

  Future<bool> generateBillDraft(BillModel bill, {StatusType? status}) async {
    try {
      final existingPendingTransaction = getActiveTransaction(bill.id);

      if (existingPendingTransaction != null && status == null) {
        return false;
      }

      if (status == StatusType.overdue) {
        if (existingPendingTransaction != null) {
          existingPendingTransaction.status = StatusType.overdue;

          await _transactionController.createTransaction(
            existingPendingTransaction,
            isDraft: true,
          );
        } else {
          TransactionModel transaction = bill.generateTransaction(
            status: StatusType.overdue,
          );
          await _transactionController.createTransaction(
            transaction,
            isDraft: true,
          );
        }
      } else {
        TransactionModel transaction = bill.generateTransaction(status: status);
        await _transactionController.createTransaction(
          transaction,
          isDraft: true,
        );
      }

      await _transactionController.loadBillTransaction();
      return true;
    } catch (e) {
      debugPrint("[BILL] An error occurred while generate bill: $e");
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> payBill(
    BuildContext context,
    TransactionModel transaction, {
    bool useReserved = false,
    bool checkExisting = true,
  }) async {
    try {
      final wallet = _walletController.getWalletById(transaction.walletId);
      wallet.autoExpanse(transaction.amount, useReserved: useReserved);

      if (transaction.debtId != null) {
        final debt = getDebtById(transaction.debtId);

        if (debt.bill != null) {
          if (debt.isFinished) {
            debt.bill?.toggleActive(false);
          }
          debt.bill?.advanceToNextBill();
        }
        await _debtDao.update(debt);
        await _userController.processDebtPayment(context);
      } else {
        final bill = getBillById(transaction.billId ?? 1);
        bill.advanceToNextBill();
        await _billDao.update(bill);
      }

      if (checkExisting) {
        final existingPendingTransaction = getActiveTransaction(
          transaction.billId,
        );

        if (existingPendingTransaction != null) {
          transaction.setTransactionId(existingPendingTransaction.id);
        }
      }

      await _transactionController.createTransaction(transaction);
      await _walletController.updateWallet(wallet);
      await loadDebtData();

      _userController.updateFreeDebt(context, isFreeDebt);
      await _userController.processRecordTransaction(context);
      await _userController.saveUser();
      await _walletController.loadData();
      await _userController.loadData();
      await _transactionController.loadBillTransaction();
      return true;
    } catch (e) {
      debugPrint("[BILL] An error occurred while pay bill: $e");
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> payDebt(
    BuildContext context,
    TransactionModel transaction, {
    bool useReserved = false,
  }) async {
    try {
      final wallet = _walletController.getWalletById(transaction.walletId);
      final debt = getDebtById(transaction.debtId ?? 1);
      await _transactionController.createTransaction(transaction);
      wallet.autoExpanse(transaction.amount, useReserved: useReserved);
      debt.addPayment(transaction.detailTransaction[0].amount);

      if (debt.bill != null) {
        if (debt.isFinished) {
          debt.bill?.toggleActive(false);
        }
        debt.bill?.advanceToNextBill();
      }

      await _debtDao.update(debt);
      await _walletController.updateWallet(wallet);
      await loadDebtData();

      _userController.updateFreeDebt(context, isFreeDebt);
      await _userController.processRecordTransaction(context);
      await _userController.processDebtPayment(context);
      await _userController.saveUser();
      await _walletController.loadData();
      return true;
    } catch (e) {
      debugPrint("[BILL] An error occurred while pay debt: $e");
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createBill(BillModel bill) async {
    try {
      if (bill.id == null) {
        await _billDao.create(bill);
      } else {
        await _billDao.update(bill);
      }
      if (bill.isActive) {
        if (_userController.isNotification && bill.type != TimeType.daily) {
          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);

          await autoDraftOrNotification(
            bill: bill,
            today: today,
            isNotifOnly: true,
          );
        }
      } else {
        await NotificationService().cancelNotificationByStringId(
          'bill_${bill.id}',
        );
      }
      if (bill.debtId == null) {
        await loadBillData();
      } else {
        await loadDebtData();
      }
      return true;
    } catch (e) {
      debugPrint("[BILL] An error occurred while create bills: $e");
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createDebt(BuildContext context, DebtModel debt) async {
    try {
      if (debt.id == null) {
        await _debtDao.create(debt);
        _userController.updateFreeDebt(context, false);
      } else {
        await _debtDao.update(debt);
      }
      await loadDebtData();
      if (debt.bill != null) {
        loadBillData();
      }
      return true;
    } catch (e) {
      debugPrint("[BILL] An error occurred while create debt: $e");
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadData() async {
    try {
      await loadDebtData();
      await _transactionController.loadBillTransaction();
      if (_userController.isNotification) {
        await checAndCreateNotification();
      }
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
