import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/analytics_controller.dart';
import '../../../controllers/bill_controller.dart';
import '../../../controllers/history_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/invest_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../controllers/skill_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/gamification_dict.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/enum_types.dart';
import '../../../core/utils/global_messenger.dart';
import '../../../models/assets_model.dart';
import '../../../models/bill_model.dart';
import '../../../models/debt_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/user_model.dart';
import '../../../models/wallet_model.dart';
import '../../bills/widgets/pay_debt_modal.dart';
import '../widgets/allocation_card.dart';
import '../widgets/balance_card.dart';
import '../widgets/daily_limit.dart';
import '../widgets/income_modal.dart';
import '../widgets/wallet_details.dart';
import '../widgets/wallet_modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showWalletDetails(BuildContext context, bool isRpg) {
    final walletController = context.read<WalletController>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => WalletDetails(
        wallets: walletController.wallets,
        onTap: (value, {lock}) =>
            _openUpdateOrAddWallet(context, wallet: value, lock: lock),
        isRpg: isRpg,
      ),
    );
  }

  Future<Decimal?> _openPayDebt(
    BuildContext context,
    AllocationModel allocation,
    List<WalletModel> wallets,
  ) async {
    final billController = context.read<BillController>();
    final isRpg = context.read<SettingsController>().isRpgMode;
    List<DebtModel> debts = [];
    List<BillModel> bills = [];
    for (DebtModel debt in billController.debts) {
      if (!debt.isFinished) {
        debts.add(debt);
        if (debt.bill != null) {
          bills.add(debt.bill!);
        }
      }
    }
    if (debts.isNotEmpty) {
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return PayDebtModal(
            pendingAllocation: allocation.amount,
            wallets: wallets,
            debts: debts,
            bils: bills,
          );
        },
      );
      if (result != null && context.mounted) {
        bool isSuccess = false;
        TransactionModel transaction = result['transaction'];
        bool useReserved = result['use_reserved'];
        bool isBill = result['is_bill'];
        if (isBill) {
          isSuccess = await billController.payBill(
            transaction,
            useReserved: useReserved,
          );
        } else {
          isSuccess = await billController.payDebt(
            transaction,
            useReserved: useReserved,
          );
        }
        GlobalMessenger.showMessage(
          message: ScreenDict.getDebtNotif(isSuccess: isSuccess, isRpg: isRpg),
          isSuccess: isSuccess,
        );
        return transaction.amount;
      }
    } else {
      GlobalMessenger.showMessage(
        message: ScreenDict.debtEmpty.get(isRpg),
        isSuccess: true,
      );
    }
    return null;
  }

  Future<Decimal?> _openAddAsset(
    BuildContext context,
    AllocationModel allocation,
    List<WalletModel> wallets,
  ) async {
    final investController = context.read<InvestController>();
    final skillController = context.read<SkillController>();
    final isRpg = context.read<SettingsController>().isRpgMode;
    final risk = allocation.subSector?.getRisk() ?? RiskType.low;
    final assets = investController.getAssetsBySector(
      sec: allocation.sector,
      sub: allocation.subSector ?? SubSectorType.lowRisk,
    );
    final result =
        await Navigator.pushNamed(
              context,
              '/buy-asset',
              arguments: {
                "wallets": wallets,
                "assets": assets,
                "initialRisk": risk,
                "pendingAllocation": allocation.amount,
                "isEmergency": allocation.sector == SectorType.emergency,
              },
            )
            as Map<String, dynamic>?;

    if (result != null && context.mounted) {
      TransactionModel transaction = result['transaction'];
      AssetsModel asset = result['asset'];
      bool isSuccess = await investController.saveTransaction(
        transaction,
        asset,
      );

      if (isSuccess) {
        await skillController.loadData();
      }
      GlobalMessenger.showMessage(
        message: UiDict.getSaveNotif(
          ScreenDict.investAssetName.get(isRpg),
          isSuccess: isSuccess,
        ),
        isSuccess: isSuccess,
      );
      return transaction.amount;
    }
    return null;
  }

  void _onTapAllocation(
    BuildContext context,
    AllocationModel allocation,
  ) async {
    final walletController = context.read<WalletController>();
    final homeController = context.read<HomeController>();
    final historyController = context.read<HistoryController>();
    final billController = context.read<BillController>();
    final analyticsController = context.read<AnalyticsController>();
    final wallets = walletController.wallets;
    Decimal? allocationUse;
    switch (allocation.sector) {
      case SectorType.living:
        break;
      case SectorType.payDebt:
        allocationUse = await _openPayDebt(context, allocation, wallets);
        break;
      case SectorType.emergency:
      case SectorType.investment:
        allocationUse = await _openAddAsset(context, allocation, wallets);
        break;
    }
    if (allocationUse != null) {
      await homeController.updatePending(
        AllocationModel(
          amount: allocation.amount - allocationUse,
          sector: allocation.sector,
          subSector: allocation.subSector,
        ),
      );
      await historyController.applyFilter();
      await analyticsController.applyFilter();
      if (allocation.sector == SectorType.payDebt) {
        await billController.loadData();
      }
    }
  }

  void _openUpdateOrAddWallet(
    BuildContext context, {
    WalletModel? wallet,
    bool? lock,
  }) async {
    final WalletModel? result = await showModalBottomSheet<WalletModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WalletModal(wallet: wallet, lock: lock ?? false),
    );

    if (result != null && context.mounted) {
      bool isSuccess = await context.read<HomeController>().saveWallet(result);
      GlobalMessenger.showMessage(
        message: UiDict.getSaveNotif(
          UiDict.wallet,
          isSuccess: isSuccess,
          isUpdate: wallet != null,
        ),
        isSuccess: isSuccess,
      );
    }
  }

  void _openAddIncomeOrTransfer(
    BuildContext context, {
    bool isTransfer = false,
  }) async {
    final homeController = context.read<HomeController>();
    final walletController = context.read<WalletController>();
    final historyController = context.read<HistoryController>();
    final analyticsController = context.read<AnalyticsController>();
    final isRpg = context.read<SettingsController>().isRpgMode;
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IncomeModal(
        wallets: walletController.wallets,
        allocation: homeController.activeAllocations,
        isTransfer: isTransfer,
      ),
    );

    if (result != null && context.mounted) {
      TransactionModel transaction = result['transaction'];
      bool autoAllocation = result['auto_allocation'];
      bool isSuccess = await homeController.saveTransaction(
        transaction,
        autoAllocation: autoAllocation,
      );
      await historyController.applyFilter();
      await analyticsController.applyFilter();
      GlobalMessenger.showMessage(
        message: UiDict.getSaveNotif(
          isTransfer ? UiDict.transfer.get(isRpg) : UiDict.income.get(isRpg),
          isSuccess: isSuccess,
        ),
        isSuccess: isSuccess,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final userController = context.watch<UserController>();
    final walletController = context.watch<WalletController>();
    final homeController = context.watch<HomeController>();

    final isRpg = settingsController.isRpgMode;
    final userName = userController.userName;
    final userTitle = userController.userTitle;
    final userLevel = userController.userLevel;
    final maxLimit = userController.currentDailyLimit;
    final dailyPenalty = userController.dailyPenalty;
    final spentToday = userController.todayUsage;
    final xpPercentage = userController.xpPercentage;

    final totalBalance = walletController.totalBalance;
    final totalReserved = walletController.totalReserved;
    final isHideBalance = homeController.isHideBalance;
    final pendingAllocations = homeController.pendingAllocations;
    final totalUnallocated = homeController.totalUnallocated;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 24,
        title: GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/profile'),
          child: Container(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lv. $userLevel - $userName',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  GamificationDict.getTitleByEnum(userTitle).get(isRpg),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: xpPercentage,
                      backgroundColor: AppColors.surfaceVariant,
                      color: Colors.amber,
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.gear, size: 20),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              if (context.mounted) homeController.loadData();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          BalanceCard(
            totalBalance: totalBalance,
            showWallets: () => _showWalletDetails(context, isRpg),
            openAddIncome: () =>
                _openAddIncomeOrTransfer(context, isTransfer: false),
            openTransfer: () =>
                _openAddIncomeOrTransfer(context, isTransfer: true),
            onToggleHideBalance: homeController.toggleHideBalance,
            isHideBalance: isHideBalance,
            reservedBalance: totalReserved,
            unallocatedBalance: totalUnallocated,
            isRpg: isRpg,
          ),

          const SizedBox(height: 32),

          Text(
            ScreenDict.homeDailyLimit.get(isRpg),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DailyLimit(
            limit: maxLimit,
            spent: spentToday,
            penalty: dailyPenalty,
            isRpg: isRpg,
          ),

          if (pendingAllocations.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              ScreenDict.homePending.get(isRpg),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...pendingAllocations.map((item) {
              return AllocationCard(
                allocation: item,
                isRpg: isRpg,
                onTap: () => _onTapAllocation(context, item),
              );
            }),
          ],
        ],
      ),
    );
  }
}
