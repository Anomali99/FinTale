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

  Future<void> saveTransaction(
    TransactionModel transaction, {
    bool excludeDaily = false,
    bool useReserved = false,
  }) async {
    final wallet = _walletController.getWalletById(transaction.walletId ?? 1);
    await _transactionController.createTransaction(transaction);
    BigInt deductedFromReserved = wallet.autoExpanse(
      transaction.amount,
      useReserved: useReserved,
    );

    await _walletController.updateWallet(wallet);
    await _walletController.loadData();

    BigInt deductedFromRegular = transaction.amount - deductedFromReserved;

    if (deductedFromRegular > BigInt.zero && !excludeDaily) {
      _userController.useDaily(deductedFromRegular);
    }

    await _userController.processRecordTransaction();
    await _userController.saveUser();
    await _userController.loadData();
  }
}
