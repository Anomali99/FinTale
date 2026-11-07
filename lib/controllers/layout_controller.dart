import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../controllers/transaction_controller.dart';
import '../core/utils/enum_types.dart';
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
    BuildContext context,
    TransactionModel transaction, {
    bool excludeDaily = false,
    bool useReserved = false,
  }) async {
    try {
      final wallet = _walletController.getWalletById(transaction.walletId);
      await _transactionController.createTransaction(transaction);
      wallet.addAmount(transaction.amount, isIncome: false);

      if (wallet.isEmergency && context.mounted) {
        Decimal expenseAmount = transaction.detailTransaction.isNotEmpty
            ? transaction.detailTransaction[0].amount
            : transaction.amount;
        final firstCategory = transaction.detailTransaction.isNotEmpty
            ? transaction.detailTransaction[0].category
            : null;
        if (firstCategory != TransactionCategory.tax) {
          _userController.addEmergencyTotal(
            context,
            expenseAmount,
            isIncome: false,
          );
        }
      }

      await _walletController.updateWallet(wallet);
      await _walletController.loadData();

      if (!excludeDaily) {
        _userController.useDaily(transaction.amount);
      }

      if (context.mounted) {
        await _userController.processRecordTransaction(context);
      }
      await _userController.saveUser();
      await _userController.loadData();
      return true;
    } catch (e) {
      debugPrint("[LAYOUT] An error occurred while save transaction: $e");
      return false;
    }
  }
}
