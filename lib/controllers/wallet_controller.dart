import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../models/wallet_model.dart';
import '../core/utils/enum_types.dart';
import '../data/dao/wallet_dao.dart';

class WalletController extends ChangeNotifier {
  final WalletDao _walletDao;

  List<WalletModel> wallets = [];

  List<WalletModel> allWallets = [];

  Map<int, List<WalletModel>> pockets = {};

  WalletModel? cash;
  List<WalletModel> bank = [];
  List<WalletModel> eWallet = [];
  List<WalletModel> platform = [];
  Decimal totalBank = Decimal.zero;
  Decimal totalEWallet = Decimal.zero;
  Decimal totalPlatform = Decimal.zero;
  Decimal totalBalance = Decimal.zero;
  Decimal totalSavings = Decimal.zero;

  Decimal get totalReserved => Decimal.zero;

  WalletController(this._walletDao) {
    loadData();
  }

  WalletModel getWalletById(int? id) => allWallets.firstWhere(
    (e) => e.id == id,
    orElse: () =>
        cash ??
        (allWallets.isNotEmpty
            ? allWallets[0]
            : WalletModel(
                name: 'Dompet Utama',
                type: WalletType.cash,
                amount: Decimal.zero,
              )),
  );

  List<WalletModel> getPocketsForWallet(int parentId) =>
      pockets[parentId] ?? [];

  Decimal getParentTotalBalance(int parentId) {
    WalletModel parent = getWalletById(parentId);
    Decimal total = parent.amount;
    for (WalletModel pocket in getPocketsForWallet(parentId)) {
      total += pocket.amount;
    }
    return total;
  }

  String getDisplayName(WalletModel wallet) {
    if (wallet.isPocket) {
      final parent = allWallets.firstWhere(
        (e) => e.id == wallet.parentId,
        orElse: () => wallet,
      );
      return '${parent.name} (${wallet.name})';
    }

    if (wallet.id != null && pockets.containsKey(wallet.id)) {
      return '${wallet.name} (Kantong Utama)';
    }

    return wallet.name;
  }

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
      allWallets = await _walletDao.readAllActiveData();

      wallets = [];
      pockets = {};
      bank = [];
      eWallet = [];
      platform = [];

      totalBalance = Decimal.zero;
      totalSavings = Decimal.zero;
      totalBank = Decimal.zero;
      totalEWallet = Decimal.zero;
      totalPlatform = Decimal.zero;

      for (WalletModel wallet in allWallets) {
        if (wallet.isPocket) {
          pockets.putIfAbsent(wallet.parentId!, () => []);
          pockets[wallet.parentId!]!.add(wallet);

          if (wallet.isSavings) {
            totalSavings += wallet.amount;
          }
        } else {
          wallets.add(wallet);
        }

        totalBalance += wallet.amount;

        switch (wallet.type) {
          case WalletType.bank:
            if (wallet.isParent) bank.add(wallet);
            totalBank += wallet.amount;
            break;
          case WalletType.eWallet:
            if (wallet.isParent) eWallet.add(wallet);
            totalEWallet += wallet.amount;
            break;
          case WalletType.platform:
            if (wallet.isParent) platform.add(wallet);
            totalPlatform += wallet.amount;
            break;
          case WalletType.cash:
            if (wallet.isParent) cash = wallet;
        }
      }
    } catch (e) {
      debugPrint("[WALLET] An error occurred while loading wallet: $e");
    } finally {
      notifyListeners();
    }
  }
}
