import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../controllers/history_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/home_dict.dart';
import '../../core/constants/title_dict.dart';
import '../../models/transaction_model.dart';
import '../../models/wallet_model.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/allocation_card.dart';
import 'widgets/balance_card.dart';
import 'widgets/daily_limit.dart';
import 'widgets/income_modal.dart';
import 'widgets/wallet_details.dart';
import 'widgets/wallet_modal.dart';

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
        onTap: (value) => _openUpdateOrAddWallet(context, wallet: value),
        isRpg: isRpg,
      ),
    );
  }

  void _openUpdateOrAddWallet(
    BuildContext context, {
    WalletModel? wallet,
  }) async {
    final WalletModel? result = await showModalBottomSheet<WalletModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WalletModal(wallet: wallet),
    );

    if (result != null && context.mounted) {
      context.read<HomeController>().saveWallet(result);
    }
  }

  void _openAddIncome(BuildContext context) async {
    final homeController = context.read<HomeController>();
    final walletController = context.read<WalletController>();
    final historyController = context.read<HistoryController>();
    final Map<String, dynamic>? result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IncomeModal(
        wallets: walletController.wallets,
        allocation: homeController.activeAllocations,
      ),
    );

    if (result != null && context.mounted) {
      TransactionModel transaction = result['transaction'];
      bool autoAllocation = result['auto_allocation'];
      await homeController.saveTransaction(
        transaction,
        autoAllocation: autoAllocation,
      );
      historyController.applyFilter();
    }
  }

  void _openTransfer(BuildContext context) async {
    final homeController = context.read<HomeController>();
    final walletController = context.read<WalletController>();
    final historyController = context.read<HistoryController>();
    final Map<String, dynamic>? result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          IncomeModal(wallets: walletController.wallets, isTransfer: true),
    );

    if (result != null && context.mounted) {
      TransactionModel transaction = result['transaction'];
      bool useReserved = result['use_reserved'];
      await homeController.saveTransaction(
        transaction,
        useReserved: useReserved,
      );
      historyController.applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();
    final walletController = context.watch<WalletController>();
    final homeController = context.watch<HomeController>();

    if (homeController.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final isRpg = userController.isRpgMode;
    final userName = userController.userName;
    final userTitle = userController.userTitle;
    final userLevel = userController.userLevel;
    final maxLimit = userController.currentDailyLimit;
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          ),
          child: Container(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lv. $userLevel - $userName',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  TitleDict.getByEnum(userTitle).get(isRpg),
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
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
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
            openAddIncome: () => _openAddIncome(context),
            openTransfer: () => _openTransfer(context),
            onToggleHideBalance: homeController.toggleHideBalance,
            isHideBalance: isHideBalance,
            reservedBalance: totalReserved,
            unallocatedBalance: totalUnallocated,
            isRpg: isRpg,
          ),

          const SizedBox(height: 32),

          Text(
            HomeDict.dailyLimit.get(isRpg),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DailyLimit(limit: maxLimit, spent: spentToday, isRpg: isRpg),

          if (pendingAllocations.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              'Pending Allocation',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...pendingAllocations.map((item) {
              return AllocationCard(allocation: item, isRpg: isRpg);
            }),
          ],
        ],
      ),
    );
  }
}
