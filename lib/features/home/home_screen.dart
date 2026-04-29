import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../controllers/home_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/home_dict.dart';
import '../../core/constants/title_dict.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
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

  void _showWalletDetails(
    BuildContext context,
    List<WalletModel> wallets,
    VoidCallback onAdd,
    bool isRpg,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return WalletDetails(wallets: wallets, onAdd: onAdd, isRpg: isRpg);
      },
    );
  }

  void _openAddWallet(BuildContext context) async {
    final WalletModel? result = await showModalBottomSheet<WalletModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WalletModal(),
    );

    if (result != null && context.mounted) {
      context.read<HomeController>().saveWallet(result);
    }
  }

  void _openAddIncome(BuildContext context) async {
    final homeController = context.read<HomeController>();
    final Map<String, dynamic>? result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IncomeModal(
        wallets: homeController.wallets,
        allocation: homeController.activeAllocations,
      ),
    );

    if (result != null && context.mounted) {
      TransactionModel transaction = result['transaction'];
      bool autoAllocation = result['auto_allocation'];
      homeController.saveTransaction(
        transaction,
        autoAllocation: autoAllocation,
      );
    }
  }

  void _openTransfer(BuildContext context) async {
    final homeController = context.read<HomeController>();
    final Map<String, dynamic>? result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          IncomeModal(wallets: homeController.wallets, isTransfer: true),
    );

    if (result != null && context.mounted) {
      TransactionModel transaction = result['transaction'];
      bool useReserved = result['use_reserved'];
      homeController.saveTransaction(transaction, useReserved: useReserved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeController = context.watch<HomeController>();

    if (homeController.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final isRpg = homeController.isRpg;
    final maxLimit = homeController.maxDailyLimit;
    final spentToday = homeController.currentUser?.todayUsage ?? BigInt.zero;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 24,
        title: GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            if (context.mounted) homeController.loadData();
          },
          child: Container(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lv. ${homeController.userLevel} - ${homeController.userName}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  TitleDict.getByEnum(
                    homeController.currentUser?.title ?? TitleType.noviceSaver,
                  ).get(isRpg),
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
                      value: homeController.userXp / 5000,
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
            totalBalance: homeController.totalBalance,
            showWallets: () => _showWalletDetails(
              context,
              homeController.wallets,
              () => _openAddWallet(context),
              isRpg,
            ),
            openAddIncome: () => _openAddIncome(context),
            openTransfer: () => _openTransfer(context),
            onToggleHideBalance: homeController.toggleHideBalance,
            isHideBalance: homeController.isHideBalance,
            reservedBalance: homeController.totalReserved,
            unallocatedBalance: homeController.totalUnallocated,
            isRpg: isRpg,
          ),

          const SizedBox(height: 32),

          Text(
            HomeDict.dailyLimit.get(isRpg),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DailyLimit(limit: maxLimit, spent: spentToday, isRpg: isRpg),

          if (homeController.pendingAllocations.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              'Pending Allocation',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...homeController.pendingAllocations.map((item) {
              return AllocationCard(allocation: item, isRpg: isRpg);
            }),
          ],
        ],
      ),
    );
  }
}
