import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../core/utils/enum_types.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import 'transaction_controller.dart';
import 'user_controller.dart';
import 'wallet_controller.dart';

class HomeController with ChangeNotifier {
  final UserController _userController;
  final WalletController _walletController;
  final TransactionController _transactionController;
  Decimal totalUnallocated = Decimal.zero;
  bool isHideBalance = false;

  HomeController(
    this._userController,
    this._walletController,
    this._transactionController,
  ) {
    loadData();
  }

  Map<Enum, double> get activeAllocations {
    return {
      for (final entry in _userController.userAllocations.entries)
        if (entry.value != null &&
            entry.value! > 0.0 &&
            (entry.key is SubSectorType || entry.key == SectorType.payDebt))
          entry.key: entry.value!,
    };
  }

  List<AllocationModel> get pendingAllocations =>
      _userController.pendingAllocations;

  void toggleHideBalance() {
    bool newValue = !isHideBalance;
    isHideBalance = newValue;
    notifyListeners();
  }

  Future<void> loadData() async {
    Future.microtask(() => notifyListeners());
    try {
      await _userController.loadData();
      await _walletController.loadData();
      isHideBalance = _userController.isHideBalance;

      totalUnallocated = Decimal.zero;

      for (AllocationModel all in pendingAllocations) {
        totalUnallocated += all.amount;
      }
    } catch (e) {
      debugPrint("[HOME] An error occurred while loading: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> updatePending(AllocationModel all) async {
    int index = pendingAllocations.indexWhere(
      (a) => a.sector == all.sector && a.subSector == all.subSector,
    );

    if (index != -1) {
      if (all.amount <= Decimal.zero) {
        _userController.removePending(index);
      } else {
        _userController.updatePending(index, all);
      }
      await _userController.saveUser();
      await _userController.loadData();
    }
  }

  Future<void> usePendingBySector({
    required Decimal amount,
    required SectorType sector,
    SubSectorType? subSector,
  }) async {
    int index = pendingAllocations.indexWhere(
      (a) => a.sector == sector && a.subSector == subSector,
    );
    if (index != -1) {
      AllocationModel all = pendingAllocations[index];
      Decimal total = all.amount - amount;
      if (total <= Decimal.zero) {
        _userController.removePending(index);
      } else {
        _userController.updatePending(
          index,
          AllocationModel(amount: total, sector: sector, subSector: subSector),
        );
      }
      await _userController.saveUser();
      await _userController.loadData();
    }
  }

  Future<bool> saveWallet(WalletModel wallet) async {
    try {
      if (wallet.id == null) {
        await _walletController.createWallet(wallet);
        await _userController.processCreateWallet();
      } else {
        await _walletController.updateWallet(wallet);
      }
      await _walletController.loadData();
      return true;
    } catch (e) {
      debugPrint("[HOME] Failed to save wallet: $e");
      return false;
    }
  }

  Future<bool> saveTransaction(
    TransactionModel transaction, {
    bool? autoAllocation,
    bool? useReserved,
  }) async {
    try {
      await _transactionController.createTransaction(transaction);

      WalletModel wallet = _walletController.getWalletById(
        transaction.walletId,
      );

      if (transaction.type == TransactionType.income) {
        if (autoAllocation == true) {
          double onePercentageAmount = transaction.amount.toDouble() / 100;
          Map<Enum, double?> userAllocations = _userController.userAllocations;

          double totalLowRisk = userAllocations[SubSectorType.lowRisk] ?? 0.0;
          double emergencyLimit = userAllocations[SectorType.emergency] ?? 0.0;
          double dreamFund = userAllocations[SubSectorType.dreamFund] ?? 0.0;

          double emergencyLowRiskPct = 0.0;
          double investLowRiskPct = 0.0;

          if (totalLowRisk > 0.0) {
            if (totalLowRisk <= emergencyLimit) {
              emergencyLowRiskPct = totalLowRisk;
              investLowRiskPct = 0.0;
            } else {
              emergencyLowRiskPct = emergencyLimit;
              investLowRiskPct = totalLowRisk - emergencyLimit;
            }
          }

          if (dreamFund > 0.0) {
            wallet.addReserved(
              Decimal.parse((onePercentageAmount * dreamFund).toString()),
              isIncome: true,
            );
          }

          void processAllocation(
            SectorType sector,
            SubSectorType? subSector,
            double percentage,
          ) {
            if (percentage <= 0.0) return;

            Decimal allocatedAmount = Decimal.parse(
              (onePercentageAmount * percentage).toString(),
            );

            int index = pendingAllocations.indexWhere(
              (a) => a.sector == sector && a.subSector == subSector,
            );

            if (index != -1) {
              AllocationModel all = pendingAllocations[index];
              all.addAmount(allocatedAmount, isIncome: true);
              _userController.updatePending(index, all);
            } else {
              _userController.addPending(
                AllocationModel(
                  sector: sector,
                  subSector: subSector,
                  amount: allocatedAmount,
                ),
              );
            }
          }

          processAllocation(
            SectorType.payDebt,
            null,
            userAllocations[SectorType.payDebt] ?? 0.0,
          );
          processAllocation(
            SectorType.investment,
            SubSectorType.mediumRisk,
            userAllocations[SubSectorType.mediumRisk] ?? 0.0,
          );
          processAllocation(
            SectorType.investment,
            SubSectorType.highRisk,
            userAllocations[SubSectorType.highRisk] ?? 0.0,
          );
          processAllocation(
            SectorType.emergency,
            SubSectorType.lowRisk,
            emergencyLowRiskPct,
          );
          processAllocation(
            SectorType.investment,
            SubSectorType.lowRisk,
            investLowRiskPct,
          );
          await _userController.saveUser();
        }
        wallet.addAmount(transaction.amount, isIncome: true);
      } else {
        WalletModel walletTarget = _walletController.getWalletById(
          transaction.targetId,
        );

        Decimal expenseAmount = transaction.detailTransaction.isNotEmpty
            ? transaction.detailTransaction[0].amount
            : transaction.amount;

        Decimal feeAmount = expenseAmount - transaction.amount;

        Decimal availableAmount = wallet.amount - wallet.reservedAmount;

        if (useReserved == true) {
          Decimal deductedFromReserved = expenseAmount > wallet.reservedAmount
              ? wallet.reservedAmount
              : expenseAmount;

          wallet.addReserved(deductedFromReserved, isIncome: false);

          Decimal arrivingReserved = deductedFromReserved > feeAmount
              ? deductedFromReserved - feeAmount
              : Decimal.zero;

          walletTarget.addReserved(arrivingReserved, isIncome: true);
        } else if (expenseAmount > availableAmount) {
          Decimal overflowAmount = expenseAmount - availableAmount;

          Decimal deductedFromReserved = overflowAmount > wallet.reservedAmount
              ? wallet.reservedAmount
              : overflowAmount;

          wallet.addReserved(deductedFromReserved, isIncome: false);
        }

        wallet.addAmount(expenseAmount, isIncome: false);
        walletTarget.addAmount(transaction.amount, isIncome: true);

        await _walletController.updateWallet(walletTarget);
      }

      await _walletController.updateWallet(wallet);
      await _userController.processRecordTransaction();
      await loadData();
      return true;
    } catch (e) {
      debugPrint("[HOME] Failed to save transaction: $e");
      return false;
    }
  }
}
