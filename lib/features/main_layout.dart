import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../controllers/analytics_controller.dart';
import '../controllers/history_controller.dart';
import '../controllers/layout_controller.dart';
import '../controllers/settings_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/menu_dict.dart';
import '../models/transaction_model.dart';
import '../widgets/custom_bottom_sheet.dart';
import '../widgets/daily_expense.dart';
import 'bills/bills_screen.dart';
import 'history/history_screen.dart';
import 'home/home_screen.dart';
import 'invest/invest_screen.dart';

class MainLayout extends StatelessWidget {
  MainLayout({super.key});

  final List<Widget> _pages = [
    HomeScreen(),
    const BillsScreen(),
    const InvestScreen(),
    const HistoryScreen(),
  ];

  void _submitTransactionHandle(BuildContext context) async {
    final settingsController = context.read<SettingsController>();
    final layoutController = context.read<LayoutController>();
    final historyController = context.read<HistoryController>();
    final analyticsController = context.read<AnalyticsController>();
    final result = await Navigator.push<TransactionModel>(
      context,
      MaterialPageRoute(
        builder: (context) => DailyExpense(isRpg: settingsController.isRpgMode),
      ),
    );
    if (result != null) {
      await layoutController.saveTransaction(result);
      historyController.applyFilter();
      analyticsController.applyFilter();
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
              title: MenuDict.pay.get(isRpg),
              subtitle: MenuDict.pay.description ?? "",
              color: AppColors.error,
              icon: MenuDict.pay.icon(isRpg),
              onTap: () => Navigator.pop(con),
            ),
            BottomSheetChild(
              title: MenuDict.daily.get(isRpg),
              subtitle: MenuDict.daily.description ?? "",
              color: Colors.blueAccent,
              icon: MenuDict.daily.icon(isRpg),
              onTap: () {
                Navigator.pop(con);
                _submitTransactionHandle(context);
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
        child: FaIcon(MenuDict.pay.icon(isRpg), size: 24),
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
                icon: MenuDict.home.icon(isRpg),
                label: MenuDict.home.get(isRpg),
                index: 0,
                layoutController: layoutController,
              ),
              _buildNavItem(
                context: context,
                icon: MenuDict.bills.icon(isRpg),
                label: MenuDict.bills.get(isRpg),
                index: 1,
                layoutController: layoutController,
              ),
              const SizedBox(width: 48),
              _buildNavItem(
                context: context,
                icon: MenuDict.invest.icon(isRpg),
                label: MenuDict.invest.get(isRpg),
                index: 2,
                layoutController: layoutController,
              ),
              _buildNavItem(
                context: context,
                icon: MenuDict.history.icon(isRpg),
                label: MenuDict.history.get(isRpg),
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
