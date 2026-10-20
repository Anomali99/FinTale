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

  Future<bool> saveWallet(BuildContext context, WalletModel wallet) async {
    try {
      if (wallet.id == null) {
        await _walletController.createWallet(wallet);
        if (context.mounted) {
          await _userController.processCreateWallet(context);
        }

        // New wallet marked as emergency: add its initial amount to target.
        if (wallet.isEmergency &&
            wallet.amount > Decimal.zero &&
            context.mounted) {
          _userController.addEmergencyTotal(
            context,
            wallet.amount,
            isIncome: true,
          );
          await _userController.saveUser();
        }
      } else {
        // Editing an existing wallet — check for isEmergency change.
        final oldWallet = _walletController.getWalletById(wallet.id);
        final bool wasEmergency = oldWallet.isEmergency;
        final bool nowEmergency = wallet.isEmergency;

        await _walletController.updateWallet(wallet);

        // If a parent changed type, cascade to all its pockets.
        if (wallet.isParent && oldWallet.type != wallet.type) {
          final pockets = _walletController.getPocketsForWallet(wallet.id!);
          for (final pocket in pockets) {
            final updated = WalletModel(
              id: pocket.id,
              name: pocket.name,
              type: wallet.type,
              amount: pocket.amount,
              parentId: pocket.parentId,
              isSavings: pocket.isSavings,
              isEmergency: pocket.isEmergency,
            );
            await _walletController.updateWallet(updated);
          }
        }

        // Adjust emergency fund when the flag changed.
        if (wasEmergency != nowEmergency && context.mounted) {
          // Calculate total amount of this wallet (itself + pockets if parent).
          Decimal totalAmount = wallet.amount;
          if (wallet.isParent) {
            final pockets = _walletController.getPocketsForWallet(wallet.id!);
            for (final pocket in pockets) {
              if (pocket.isEmergency == wasEmergency) {
                totalAmount += pocket.amount;
              }
            }
          }

          if (totalAmount > Decimal.zero) {
            _userController.addEmergencyTotal(
              context,
              totalAmount,
              isIncome: nowEmergency, // true=add to total, false=subtract
            );
            await _userController.saveUser();
          }
        }
      }
      await _walletController.loadData();
      return true;
    } catch (e) {
      debugPrint("[HOME] Failed to save wallet: $e");
      return false;
    }
  }

  Future<bool> saveTransaction(
    BuildContext context,
    TransactionModel transaction, {
    bool? autoAllocation,
    bool? useReserved,
  }) async {
    try {
      await _transactionController.createTransaction(transaction);

      WalletModel wallet = _walletController.getWalletById(
        transaction.walletId,
      );

      WalletModel? walletTarget;
      if (transaction.targetId != null) {
        walletTarget = _walletController.getWalletById(transaction.targetId!);
      }

      if (transaction.type == TransactionType.income) {
        if (autoAllocation == true) {
          Decimal calcAllocated(double percentage) {
            if (percentage <= 0.0) return Decimal.zero;
            Decimal pctDec = Decimal.parse(percentage.toString());
            return ((transaction.amount * pctDec) / Decimal.fromInt(100))
                .toDecimal(scaleOnInfinitePrecision: 2);
          }

          Map<Enum, double?> userAllocations = _userController.userAllocations;

          double totalLowRisk = userAllocations[SubSectorType.lowRisk] ?? 0.0;
          double emergencyLimit = userAllocations[SectorType.emergency] ?? 0.0;

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

          // DreamFund allocation: no longer adds to reservedAmount.
          // Pocket-based savings allocation will be handled in Phase 2.

          void processAllocation(
            SectorType sector,
            SubSectorType? subSector,
            double percentage,
          ) {
            if (percentage <= 0.0) return;

            Decimal allocatedAmount = calcAllocated(percentage);

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
        Decimal expenseAmount = transaction.detailTransaction.isNotEmpty
            ? transaction.detailTransaction[0].amount
            : transaction.amount;

        wallet.addAmount(expenseAmount, isIncome: false);
        walletTarget!.addAmount(transaction.amount, isIncome: true);

        await _walletController.updateWallet(walletTarget);
      }

      await _walletController.updateWallet(wallet);

      // Track emergency fund progress
      if (context.mounted) {
        if (transaction.type == TransactionType.income) {
          if (wallet.isEmergency) {
            _userController.addEmergencyTotal(
              context,
              transaction.amount,
              isIncome: true,
            );
          }
        } else if (transaction.type == TransactionType.transfer) {
          // wallet = source (expense side)
          if (wallet.isEmergency) {
            Decimal expenseAmount = transaction.detailTransaction.isNotEmpty
                ? transaction.detailTransaction[0].amount
                : transaction.amount;
            _userController.addEmergencyTotal(
              context,
              expenseAmount,
              isIncome: false,
            );
          }
          // walletTarget = destination (income side)
          if (walletTarget!.isEmergency) {
            _userController.addEmergencyTotal(
              context,
              transaction.amount,
              isIncome: true,
            );
          }
        } else {
          // expense / debt — money leaves wallet
          if (wallet.isEmergency) {
            _userController.addEmergencyTotal(
              context,
              transaction.amount,
              isIncome: false,
            );
          }
        }
      }
      await _userController.saveUser();

      if (context.mounted) {
        await _userController.processRecordTransaction(context);
      }
      await loadData();
      return true;
    } catch (e) {
      debugPrint("[HOME] Failed to save transaction: $e");
      return false;
    }
  }
}
