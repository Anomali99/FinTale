import 'package:flutter/material.dart';

import '../controllers/transaction_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/wallet_controller.dart';
import '../models/transaction_model.dart';

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

    _loadUserData();
  }

  void changeTab(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void _loadUserData() async {
    _performTimeCheck();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _performTimeCheck();
    }
  }

  Future<void> _performTimeCheck() async {
    if (_userController.currentUser == null) return;
    await _userController.evaluateAndResetDaily();
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> saveTransaction(TransactionModel transaction) async {
    final wallet = _walletController.getWalletById(transaction.walletId ?? 1);
    await _transactionController.createTransaction(transaction);

    wallet.expense(transaction.amount);
    await _walletController.updateWallet(wallet);
    await _walletController.loadData();

    _userController.budget.useDaily(transaction.amount);
    await _userController.processRecordTransaction();
    await _userController.saveUser();
    await _userController.loadData();
  }
}
