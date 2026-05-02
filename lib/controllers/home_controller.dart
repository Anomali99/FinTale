import 'package:flutter/material.dart';

import '../models/allocation_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import 'transaction_controller.dart';
import 'user_controller.dart';
import 'wallet_controller.dart';

class HomeController with ChangeNotifier {
  final UserController _userController;
  final WalletController _walletController;
  final TransactionController _transactionController;
  BigInt totalUnallocated = BigInt.zero;
  bool isHideBalance = false;
  bool isLoading = true;

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
    isLoading = true;
    Future.microtask(() => notifyListeners());
    try {
      await _userController.loadData();
      await _walletController.loadData();
      isHideBalance = _userController.isHideBalance;

      totalUnallocated = BigInt.zero;

      for (AllocationModel all in pendingAllocations) {
        totalUnallocated += all.amount;
      }
    } catch (e) {
      debugPrint("[HOME] An error occurred while loading: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveWallet(WalletModel wallet) async {
    try {
      if (wallet.id == null) {
        await _walletController.createWallet(wallet);
        await _userController.processCreateWallet();
      } else {
        await _walletController.updateWallet(wallet);
      }
      await _walletController.loadData();
    } catch (e) {
      debugPrint("[HOME] Failed to save wallet: $e");
    }
  }

  Future<void> saveTransaction(
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
            wallet.reservedIncome(BigInt.from(onePercentageAmount * dreamFund));
          }

          void processAllocation(
            SectorType sector,
            SubSectorType? subSector,
            double percentage,
          ) {
            if (percentage <= 0.0) return;

            BigInt allocatedAmount = BigInt.from(
              onePercentageAmount * percentage,
            );

            int index = pendingAllocations.indexWhere(
              (a) =>
                  a.walletId == transaction.walletId &&
                  a.sector == sector &&
                  a.subSector == subSector,
            );

            if (index != -1) {
              AllocationModel all = pendingAllocations[index];
              all.income(allocatedAmount);
              _userController.updatePending(index, all);
            } else {
              _userController.addPending(
                AllocationModel(
                  walletId: transaction.walletId ?? 1,
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
        wallet.income(transaction.amount);
      } else {
        WalletModel walletTarget = _walletController.getWalletById(
          transaction.targetId,
        );

        BigInt expenseAmount = transaction.detailTransaction.isNotEmpty
            ? transaction.detailTransaction[0].amount
            : transaction.amount;

        BigInt availableAmount = wallet.amount - wallet.reservedAmount;

        if (useReserved == true) {
          wallet.reservedExpense(expenseAmount);
          walletTarget.reservedIncome(transaction.amount);
        } else if (expenseAmount > availableAmount) {
          BigInt overflowAmount = expenseAmount - availableAmount;
          wallet.reservedExpense(overflowAmount);
        }
        wallet.expense(expenseAmount);
        walletTarget.income(transaction.amount);

        await _walletController.updateWallet(walletTarget);
      }

      await _walletController.updateWallet(wallet);
      await loadData();
    } catch (e) {
      debugPrint("[HOME] Failed to save transaction: $e");
    }
  }
}
