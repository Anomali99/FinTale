import 'package:flutter/material.dart';

import '../controllers/transaction_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/wallet_controller.dart';
import '../core/utils/enum_types.dart';
import '../data/dao/asset_dao.dart';
import '../models/assets_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

class InvestController with ChangeNotifier {
  final AssetDao _assetDao;
  final UserController _userController;
  final WalletController _walletController;
  final TransactionController _transactionController;

  List<AssetsModel> assets = [];
  List<AssetsModel> lowEmergency = [];
  List<AssetsModel> lowNotEmergency = [];
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

  List<AssetsModel> get lowRisk => [...lowEmergency, ...lowNotEmergency];

  AssetsModel getAssetById(int id) => assets.firstWhere((e) => e.id == id);

  List<AssetsModel> getAssetsBySector({
    SectorType? sec,
    required SubSectorType sub,
  }) {
    switch (sub) {
      case SubSectorType.highRisk:
        return highRisk;
      case SubSectorType.mediumRisk:
        return mediumRisk;
      case SubSectorType.lowRisk:
        switch (sec) {
          case SectorType.emergency:
            return lowEmergency;
          case SectorType.investment:
            return lowNotEmergency;
          default:
            return lowRisk;
        }
      default:
        return [];
    }
  }

  Future<bool> updateAsset(AssetsModel asset) async {
    try {
      if (asset.id != null) {
        final oldAsset = getAssetById(asset.id!);
        if (oldAsset.isEmergency != asset.isEmergency) {
          _userController.addEmergencyTotal(
            asset.invested,
            isIncome: asset.isEmergency,
          );
        }
        await _assetDao.update(asset);
        await loadData();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> claimDeviden(TransactionModel transaction) async {
    try {
      await _transactionController.createTransaction(transaction);
      final wallet = _walletController.getWalletById(transaction.walletId);
      wallet.addAmount(transaction.amount, isIncome: true);
      await _walletController.updateWallet(wallet);
      await _walletController.loadData();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sellAsset(
    TransactionModel transaction,
    AssetsModel asset,
    BigInt emergencyDeduction,
  ) async {
    try {
      await _assetDao.update(asset);

      final wallet = _walletController.getWalletById(transaction.walletId);
      wallet.addAmount(transaction.amount, isIncome: true);

      if (asset.isEmergency) {
        _userController.addEmergencyTotal(emergencyDeduction, isIncome: false);
      }

      await _walletController.updateWallet(wallet);
      await _walletController.loadData();
      await _transactionController.createTransaction(transaction);
      await _userController.processRecordTransaction();
      await _userController.saveUser();
      await loadData();

      return true;
    } catch (e) {
      debugPrint("[INVEST] Failed to sell asset: $e");
      return false;
    }
  }

  Future<bool> saveTransaction(
    TransactionModel transaction,
    AssetsModel asset, {
    bool useReserved = false,
  }) async {
    try {
      if (asset.id == null) {
        int assetId = await _assetDao.create(asset);
        transaction.setAssetId(assetId);
      } else {
        await _assetDao.update(asset);
      }

      final wallet = _walletController.getWalletById(transaction.walletId);
      wallet.autoExpanse(transaction.amount, useReserved: useReserved);

      if (asset.isEmergency) {
        _userController.addEmergencyTotal(
          transaction.detailTransaction[0].amount,
          isIncome: true,
        );
      }

      await _walletController.updateWallet(wallet);
      await _walletController.loadData();
      await _transactionController.createTransaction(transaction);
      await _userController.processRecordTransaction();
      await _userController.saveUser();
      await loadData();
      return true;
    } catch (e) {
      debugPrint("[INVEST] Failed to save asset: $e");
      return false;
    }
  }

  Future<void> loadData() async {
    try {
      assets = await _assetDao.readAllActiveData();

      totalInvested = BigInt.zero;
      totalValue = BigInt.zero;
      lowEmergency.clear();
      lowNotEmergency.clear();
      mediumRisk.clear();
      highRisk.clear();

      for (AssetsModel asset in assets) {
        totalInvested += asset.invested;
        totalValue += asset.value;

        switch (asset.type) {
          case RiskType.low:
            if (asset.isEmergency) {
              lowEmergency.add(asset);
            } else {
              lowNotEmergency.add(asset);
            }
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
