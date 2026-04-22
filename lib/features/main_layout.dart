import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/menu_dict.dart';
import '../core/theme/mode_provider.dart';
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
    const HomeScreen(),
    const BillsScreen(),
    const InvestScreen(),
    const HistoryScreen(),
  ];

  void _showActionPopup(BuildContext context, bool isRpg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.error.withOpacity(0.2),
                  child: FaIcon(
                    MenuDict.pay.icon(isRpg),
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
                title: Text(
                  MenuDict.pay.get(isRpg),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(MenuDict.pay.decription ?? ''),
                onTap: () {
                  Navigator.pop(context);
                  /* TODO: Buka form bayar hutang */
                },
              ),
              const Divider(color: Colors.white10),

              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent.withOpacity(0.2),
                  child: FaIcon(
                    MenuDict.daily.icon(isRpg),
                    color: Colors.blueAccent,
                    size: 18,
                  ),
                ),
                title: Text(
                  MenuDict.daily.get(isRpg),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(MenuDict.daily.decription ?? ''),
                onTap: () {
                  Navigator.pop(context);
                  /* TODO: Buka form pengeluaran harian */
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
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
      onTap: () => setState(() => _selectedIndex = index),
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
          ),
        ],
      ),
    );
  }
}
