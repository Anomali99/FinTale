import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../controllers/analytics_controller.dart';
import '../controllers/bill_controller.dart';
import '../controllers/history_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/layout_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/wallet_controller.dart';
import '../core/constants/screen_dict.dart';
import '../core/constants/ui_dict.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/enum_types.dart';
import '../core/utils/global_messenger.dart';
import '../models/bill_model.dart';
import '../models/debt_model.dart';
import '../models/transaction_model.dart';
import '../widgets/custom_bottom_sheet.dart';
import 'bills/screens/bills_screen.dart';
import 'bills/widgets/pay_debt_modal.dart';
import 'history/screens/history_screen.dart';
import 'home/screens/home_screen.dart';
import 'invest/screens/invest_screen.dart';

class MainLayout extends StatelessWidget {
  MainLayout({super.key});

  final List<Widget> _pages = [
    HomeScreen(),
    const BillsScreen(),
    const InvestScreen(),
    const HistoryScreen(),
  ];

  void _submitDebtHandle(BuildContext context, bool isRpg) async {
    final homeController = context.read<HomeController>();
    final billController = context.read<BillController>();
    final historyController = context.read<HistoryController>();
    final analyticsController = context.read<AnalyticsController>();
    final wallets = context.read<WalletController>().wallets;
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
          return PayDebtModal(wallets: wallets, debts: debts, bils: bills);
        },
      );

      if (result != null && context.mounted) {
        TransactionModel transaction = result['transaction'];
        bool useReserved = result['use_reserved'];
        bool isBill = result['is_bill'];
        bool isSuccess = false;
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
        await homeController.usePendingBySector(
          amount: transaction.amount,
          sector: SectorType.payDebt,
        );
        await historyController.applyFilter();
        await analyticsController.applyFilter();
        GlobalMessenger.showMessage(
          message: ScreenDict.getDebtNotif(isSuccess: isSuccess, isRpg: isRpg),
          isSuccess: isSuccess,
        );
      }
    } else {
      GlobalMessenger.showMessage(
        message: ScreenDict.debtEmpty.get(isRpg),
        isSuccess: true,
      );
    }
  }

  void _submitTransactionHandle(BuildContext context, bool isRpg) async {
    final layoutController = context.read<LayoutController>();
    final historyController = context.read<HistoryController>();
    final analyticsController = context.read<AnalyticsController>();
    final result =
        await Navigator.pushNamed(context, '/daily-expense')
            as Map<String, dynamic>?;

    if (result != null) {
      TransactionModel transaction = result['transaction'];
      bool useReserved = result['use_reserved'];
      bool excludeDaily = result['exclude_daily'];
      bool isSuccess = await layoutController.saveTransaction(
        transaction,
        useReserved: useReserved,
        excludeDaily: excludeDaily,
      );
      await historyController.applyFilter();
      await analyticsController.applyFilter();
      GlobalMessenger.showMessage(
        message: UiDict.getSaveNotif(
          ScreenDict.historyTransaction.get(isRpg),
          isSuccess: isSuccess,
        ),
        isSuccess: isSuccess,
      );
    }
  }

  void _showActionPopup(BuildContext context, bool isRpg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (con) {
        return CustomBottomSheet(
          children: [
            BottomSheetChild(
              title: UiDict.menuPayDebt.get(isRpg),
              subtitle: UiDict.menuPayDebt.description ?? "",
              color: AppColors.error,
              icon: UiDict.menuPayDebt.icon(isRpg),
              onTap: () {
                Navigator.pop(con);
                _submitDebtHandle(context, isRpg);
              },
            ),
            BottomSheetChild(
              title: UiDict.menuDailyUse.get(isRpg),
              subtitle: UiDict.menuDailyUse.description ?? "",
              color: Colors.blueAccent,
              icon: UiDict.menuDailyUse.icon(isRpg),
              onTap: () {
                Navigator.pop(con);
                _submitTransactionHandle(context, isRpg);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final layoutController = context.watch<LayoutController>();

    final isRpg = settingsController.isRpgMode;

    return Scaffold(
      body: _pages[layoutController.selectedIndex],

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActionPopup(context, isRpg),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: FaIcon(UiDict.menuPayDebt.icon(isRpg), size: 24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        color: AppColors.surface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: UiDict.menuHome.icon(isRpg),
                label: UiDict.menuHome.get(isRpg),
                index: 0,
                layoutController: layoutController,
              ),
              _buildNavItem(
                context: context,
                icon: UiDict.menuBills.icon(isRpg),
                label: UiDict.menuBills.get(isRpg),
                index: 1,
                layoutController: layoutController,
              ),
              const SizedBox(width: 48),
              _buildNavItem(
                context: context,
                icon: UiDict.menuInvest.icon(isRpg),
                label: UiDict.menuInvest.get(isRpg),
                index: 2,
                layoutController: layoutController,
              ),
              _buildNavItem(
                context: context,
                icon: UiDict.menuHistory.icon(isRpg),
                label: UiDict.menuHistory.get(isRpg),
                index: 3,
                layoutController: layoutController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required FaIconData icon,
    required String label,
    required int index,
    required LayoutController layoutController,
  }) {
    final isSelected = layoutController.selectedIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(16),

      onTap: () => layoutController.changeTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(minWidth: 64, minHeight: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
