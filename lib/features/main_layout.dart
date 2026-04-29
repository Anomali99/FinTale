import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../controllers/layout_controller.dart';
import '../controllers/settings_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/menu_dict.dart';
import '../widgets/custom_bottom_sheet.dart';
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

  void _showActionPopup(BuildContext context, bool isRpg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CustomBottomSheet(
          children: [
            BottomSheetChild(
              title: MenuDict.pay.get(isRpg),
              subtitle: MenuDict.pay.description ?? "",
              color: AppColors.error,
              icon: MenuDict.pay.icon(isRpg),
              onTap: () => Navigator.pop(context),
            ),
            BottomSheetChild(
              title: MenuDict.daily.get(isRpg),
              subtitle: MenuDict.daily.description ?? "",
              color: Colors.blueAccent,
              icon: MenuDict.daily.icon(isRpg),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final layoutController = context.watch<LayoutController>();
    final settingsController = context.watch<SettingsController>();

    return Scaffold(
      body: _pages[layoutController.selectedIndex],

      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showActionPopup(context, settingsController.isRpgMode),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: FaIcon(
          MenuDict.pay.icon(settingsController.isRpgMode),
          size: 24,
        ),
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
                icon: MenuDict.home.icon(settingsController.isRpgMode),
                label: MenuDict.home.get(settingsController.isRpgMode),
                index: 0,
                layoutController: layoutController,
              ),
              _buildNavItem(
                context: context,
                icon: MenuDict.bills.icon(settingsController.isRpgMode),
                label: MenuDict.bills.get(settingsController.isRpgMode),
                index: 1,
                layoutController: layoutController,
              ),
              const SizedBox(width: 48),
              _buildNavItem(
                context: context,
                icon: MenuDict.invest.icon(settingsController.isRpgMode),
                label: MenuDict.invest.get(settingsController.isRpgMode),
                index: 2,
                layoutController: layoutController,
              ),
              _buildNavItem(
                context: context,
                icon: MenuDict.history.icon(settingsController.isRpgMode),
                label: MenuDict.history.get(settingsController.isRpgMode),
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
