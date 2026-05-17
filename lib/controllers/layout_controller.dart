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
    bool? useReserved,
  }) async {
    final wallet = _walletController.getWalletById(transaction.walletId ?? 1);
    await _transactionController.createTransaction(transaction);

    BigInt expenseAmount = transaction.detailTransaction.isNotEmpty
        ? transaction.detailTransaction[0].amount
        : transaction.amount;

    BigInt availableAmount = wallet.amount - wallet.reservedAmount;

    BigInt deductedFromReserved = BigInt.zero;

    if (useReserved == true) {
      deductedFromReserved = expenseAmount > wallet.reservedAmount
          ? wallet.reservedAmount
          : expenseAmount;

      wallet.addReserved(deductedFromReserved, isIncome: false);
    } else if (expenseAmount > availableAmount) {
      BigInt overflowAmount = expenseAmount - availableAmount;

      deductedFromReserved = overflowAmount > wallet.reservedAmount
          ? wallet.reservedAmount
          : overflowAmount;

      wallet.addReserved(deductedFromReserved, isIncome: false);
    }

    wallet.addAmount(expenseAmount, isIncome: false);

    await _walletController.updateWallet(wallet);
    await _walletController.loadData();

    BigInt deductedFromRegular = expenseAmount - deductedFromReserved;

    if (deductedFromRegular > BigInt.zero) {
      _userController.useDaily(deductedFromRegular);
    }

    await _userController.processRecordTransaction();
    await _userController.saveUser();
    await _userController.loadData();
  }
}
