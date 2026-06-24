import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../controllers/transaction_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/wallet_controller.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

class LayoutController extends ChangeNotifier with WidgetsBindingObserver {
  final UserController _userController;
  final WalletController _walletController;
  final TransactionController _transactionController;
  int selectedIndex = 0;

  LayoutController(
    this._userController,
    this._walletController,
    this._transactionController,
  ) {
    WidgetsBinding.instance.addObserver(this);
  }

  void changeTab(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> saveTransaction(
    TransactionModel transaction, {
    bool excludeDaily = false,
    bool useReserved = false,
  }) async {
    try {
      final wallet = _walletController.getWalletById(transaction.walletId);
      await _transactionController.createTransaction(transaction);
      Decimal deductedFromReserved = wallet.autoExpanse(
        transaction.amount,
        useReserved: useReserved,
      );

      await _walletController.updateWallet(wallet);
      await _walletController.loadData();

      Decimal deductedFromRegular = transaction.amount - deductedFromReserved;

      if (deductedFromRegular > Decimal.zero && !excludeDaily) {
        _userController.useDaily(deductedFromRegular);
      }

      await _userController.processRecordTransaction();
      await _userController.saveUser();
      await _userController.loadData();
      return true;
    } catch (e) {
      debugPrint("[LAYOUT] An error occurred while save transaction: $e");
      return false;
    }
  }
}
