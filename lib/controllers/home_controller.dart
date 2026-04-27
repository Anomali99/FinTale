import 'package:flutter/material.dart';

import '../data/local/dao/transaction_dao.dart';
import '../data/local/dao/wallet_dao.dart';
import '../data/local/pref_service.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';

class HomeController with ChangeNotifier {
  final PrefService _prefService;
  final WalletDao _walletDao;
  final TransactionDao _transactionDao;

  UserModel? currentUser;
  List<WalletModel> wallets = [];
  bool isLoading = true;

  HomeController(this._prefService, this._walletDao, this._transactionDao) {
    loadData();
  }

  String get userName => currentUser?.name ?? 'Petualang';
  int get userLevel => currentUser?.level ?? 1;
  int get userXp => currentUser?.xp ?? 0;

  BigInt get totalBalance {
    return wallets.fold(BigInt.zero, (sum, wallet) => sum + wallet.amount);
  }

  BigInt get remainingDailyLimit =>
      currentUser?.remainingLimitToday ?? BigInt.zero;
  BigInt get maxDailyLimit => currentUser?.currentDailyLimit ?? BigInt.zero;

  bool get isRpg => _prefService.isRpgMode;

  Future<void> loadData() async {
    isLoading = true;
    Future.microtask(() => notifyListeners());
    try {
      currentUser = _prefService.getUser();

      wallets = await _walletDao.readAllActiveData();
    } catch (e) {
      debugPrint("An error occurred while loading: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveWallet(WalletModel wallet) async {
    try {
      if (wallet.id == null) {
        await _walletDao.create(wallet);
      } else {
        await _walletDao.update(wallet);
      }
      await loadData();
    } catch (e) {
      debugPrint("Failed to save wallet: $e");
    }
  }

  Future<void> saveIncome(TransactionModel transaction) async {
    try {
      await _transactionDao.create(transaction);
      WalletModel wallet = wallets.firstWhere(
        (e) => e.id == transaction.walletId,
      );
      if (transaction.type == TransactionType.income) {
        wallet.income(transaction.amount);
      } else {
        WalletModel walletTarget = wallets.firstWhere(
          (e) => e.id == transaction.targetId,
        );
        wallet.expense(transaction.detailTransaction[0].amount);
        walletTarget.income(transaction.amount);
        await _walletDao.update(walletTarget);
      }
      await _walletDao.update(wallet);
      await loadData();
    } catch (e) {
      debugPrint("Failed to save income: $e");
    }
  }
}
