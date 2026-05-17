import 'package:flutter/material.dart';

import '../../models/wallet_model.dart';
import '../data/local/dao/wallet_dao.dart';

class WalletController extends ChangeNotifier with WidgetsBindingObserver {
  final WalletDao _walletDao;
  List<WalletModel> wallets = [];

  WalletModel? cash;
  List<WalletModel> bank = [];
  List<WalletModel> eWallet = [];
  List<WalletModel> platform = [];
  BigInt totalBank = BigInt.zero;
  BigInt totalEWallet = BigInt.zero;
  BigInt totalPlatform = BigInt.zero;
  BigInt totalBalance = BigInt.zero;
  BigInt totalReserved = BigInt.zero;

  WalletController(this._walletDao) {
    loadData();
  }

  WalletModel getWalletById(int? id) => wallets.firstWhere((e) => e.id == id);

  Future<void> createWallet(WalletModel newWallet) async {
    try {
      _walletDao.create(newWallet);
    } catch (e) {
      debugPrint("[WALLET] An error occurred while saving: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateWallet(WalletModel wallet) async {
    try {
      _walletDao.update(wallet);
    } catch (e) {
      debugPrint("[WALLET] An error occurred while saving: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadData() async {
    try {
      wallets = await _walletDao.readAllActiveData();

      totalBalance = BigInt.zero;
      totalReserved = BigInt.zero;

      for (WalletModel wallet in wallets) {
        totalBalance += wallet.amount;
        totalReserved += wallet.reservedAmount;

        switch (wallet.type) {
          case WalletType.bank:
            bank.add(wallet);
            totalBank += wallet.amount;
            break;
          case WalletType.eWallet:
            eWallet.add(wallet);
            totalEWallet += wallet.amount;
            break;
          case WalletType.platform:
            platform.add(wallet);
            totalPlatform += wallet.amount;
            break;
          case WalletType.cash:
            cash = wallet;
        }
      }
    } catch (e) {
      debugPrint("[WALLET] An error occurred while loading wallet: $e");
    } finally {
      notifyListeners();
    }
  }
}
