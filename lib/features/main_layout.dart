import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/menu_dict.dart';
import '../core/theme/mode_provider.dart';
import '../widgets/custom_bottom_sheet.dart';
import 'bills/bills_screen.dart';
import 'history/history_screen.dart';
import 'home/home_screen.dart';
import 'invest/invest_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

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
              onTap: () {
                Navigator.pop(context);
              },
            ),
            BottomSheetChild(
              title: MenuDict.daily.get(isRpg),
              subtitle: MenuDict.daily.description ?? "",
              color: Colors.blueAccent,
              icon: MenuDict.daily.icon(isRpg),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRpg = Provider.of<ModeProvider>(context).isRpgMode;

    return Scaffold(
      body: _pages[_selectedIndex],

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
                icon: MenuDict.home.icon(isRpg),
                label: MenuDict.home.get(isRpg),
                index: 0,
              ),
              _buildNavItem(
                icon: MenuDict.bills.icon(isRpg),
                label: MenuDict.bills.get(isRpg),
                index: 1,
              ),

              const SizedBox(width: 48),
              _buildNavItem(
                icon: MenuDict.invest.icon(isRpg),
                label: MenuDict.invest.get(isRpg),
                index: 2,
              ),
              _buildNavItem(
                icon: MenuDict.history.icon(isRpg),
                label: MenuDict.history.get(isRpg),
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required FaIconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _selectedIndex = index),

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
