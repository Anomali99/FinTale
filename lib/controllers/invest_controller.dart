import 'package:flutter/material.dart';

import '../controllers/transaction_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/wallet_controller.dart';
import '../data/local/dao/asset_dao.dart';
import '../models/assets_model.dart';
import '../models/transaction_model.dart';

class InvestController with ChangeNotifier {
  final AssetDao _assetDao;
  final UserController _userController;
  final WalletController _walletController;
  final TransactionController _transactionController;

  List<AssetsModel> assets = [];
  List<AssetsModel> lowRisk = [];
  List<AssetsModel> mediumRisk = [];
  List<AssetsModel> highRisk = [];
  BigInt totalInvested = BigInt.zero;
  BigInt totalValue = BigInt.zero;

  InvestController(
    this._assetDao,
    this._userController,
    this._walletController,
    this._transactionController,
  ) {
    loadData();
  }

  bool get isOverallProfit => totalValue > totalInvested;

  double get overallPercentage {
    if (totalInvested == BigInt.zero) return 0.0;
    double current = totalValue.toDouble();
    double capital = totalInvested.toDouble();
    return (((current - capital) / capital) * 100).abs();
  }

  Future<void> saveTransaction(
    TransactionModel transaction,
    AssetsModel asset,
  ) async {
    try {
      if (asset.id == null) {
        int assetId = await _assetDao.create(asset);
        transaction.setAssetId(assetId);
      } else {
        await _assetDao.update(asset);
      }

      final wallet = _walletController.getWalletById(transaction.walletId);
      wallet.expense(transaction.amount);
      await _walletController.updateWallet(wallet);
      await _transactionController.createTransaction(transaction);
      await _userController.processRecordTransaction();
      await loadData();
    } catch (e) {
      debugPrint("[INVEST] Failed to save asset: $e");
    }
  }

  Future<void> loadData() async {
    try {
      assets = await _assetDao.readAllActiveData();

      totalInvested = BigInt.zero;
      totalValue = BigInt.zero;
      lowRisk.clear();
      mediumRisk.clear();
      highRisk.clear();

      for (AssetsModel asset in assets) {
        totalInvested += asset.invested;
        totalValue += asset.value;

        switch (asset.type) {
          case RiskType.low:
            lowRisk.add(asset);
            break;
          case RiskType.medium:
            mediumRisk.add(asset);
            break;
          case RiskType.high:
            highRisk.add(asset);
            break;
        }
      }
    } catch (e) {
      debugPrint("[INVEST] An error occurred while loading assets: $e");
    } finally {
      notifyListeners();
    }
  }
}
