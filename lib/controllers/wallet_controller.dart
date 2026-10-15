import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../models/wallet_model.dart';
import '../core/utils/enum_types.dart';
import '../data/dao/wallet_dao.dart';

class WalletController extends ChangeNotifier {
  final WalletDao _walletDao;
  List<WalletModel> wallets = [];

  WalletModel? cash;
  List<WalletModel> bank = [];
  List<WalletModel> eWallet = [];
  List<WalletModel> platform = [];
  Decimal totalBank = Decimal.zero;
  Decimal totalEWallet = Decimal.zero;
  Decimal totalPlatform = Decimal.zero;
  Decimal totalBalance = Decimal.zero;
  Decimal totalReserved = Decimal.zero;

  WalletController(this._walletDao) {
    loadData();
  }

  WalletModel getWalletById(int? id) => wallets.firstWhere(
        (e) => e.id == id,
        orElse: () =>
            cash ??
            (wallets.isNotEmpty
                ? wallets[0]
                : WalletModel(
                    name: 'Dompet Utama',
                    type: WalletType.cash,
                    amount: Decimal.zero,
                    reservedAmount: Decimal.zero,
                  )),
      );

  Future<void> createWallet(WalletModel newWallet) async {
    try {
      await _walletDao.create(newWallet);
    } catch (e) {
      debugPrint("[WALLET] An error occurred while saving: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateWallet(WalletModel wallet) async {
    try {
      await _walletDao.update(wallet);
    } catch (e) {
      debugPrint("[WALLET] An error occurred while saving: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateMultipleWallet(List<WalletModel> wallets) async {
    try {
      await _walletDao.updateMultiple(wallets);
    } catch (e) {
      debugPrint("[WALLET] An error occurred while saving: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadData() async {
    try {
      wallets = await _walletDao.readAllActiveData();

      bank = [];
      eWallet = [];
      platform = [];

      totalBalance = Decimal.zero;
      totalReserved = Decimal.zero;
      totalBank = Decimal.zero;
      totalEWallet = Decimal.zero;
      totalPlatform = Decimal.zero;

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
