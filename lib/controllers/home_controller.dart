import 'package:flutter/material.dart';

import '../data/local/dao/wallet_dao.dart';
import '../data/local/pref_service.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';

class HomeController with ChangeNotifier {
  final PrefService _prefService;
  final WalletDao _walletDao;

  UserModel? currentUser;
  List<WalletModel> wallets = [];
  bool isLoading = true;

  HomeController(this._prefService, this._walletDao) {
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
      debugPrint("Terjadi kesalahan saat memuat markas: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
