import 'package:flutter/material.dart';

import '../controllers/transaction_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/wallet_controller.dart';
import '../core/utils/mission_extension.dart';
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

  bool get isRpg => _userController.isRpgMode;

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

  void _performTimeCheck() {
    if (_userController.currentUser == null) return;

    bool isReset = _userController.currentUser!.progress.checkAndReset();

    if (isReset && _userController.currentUser != null) {
      _userController.saveUser();
      notifyListeners();
    }
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
    await _userController.processRecordTransaction();
  }
}
