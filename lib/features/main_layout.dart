import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dictionary.dart';
import '../core/theme/mode_provider.dart';
import 'home/home_screen.dart';
// import 'bills/bills_screen.dart';
// import 'invest/invest_screen.dart';
// import 'history/history_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const Center(child: Text('Quest Board (Tagihan) - Coming Soon')),
    const Center(child: Text('Armory (Investasi) - Coming Soon')),
    const Center(child: Text('Battle Log (Riwayat) - Coming Soon')),
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
                    AppDictionary.payIcon.get(isRpg),
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
                title: Text(
                  AppDictionary.pay.get(isRpg),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(AppDictionary.payDec.get(isRpg)),
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
                    AppDictionary.dailyIcon.get(isRpg),
                    color: Colors.blueAccent,
                    size: 18,
                  ),
                ),
                title: Text(
                  AppDictionary.daily.get(isRpg),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(AppDictionary.dailyDec.get(isRpg)),
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
        child: FaIcon(AppDictionary.payIcon.get(isRpg), size: 24),
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
                icon: AppDictionary.homeIcon.get(isRpg),
                label: AppDictionary.home.get(isRpg),
                index: 0,
              ),
              _buildNavItem(
                icon: AppDictionary.billsIcon.get(isRpg),
                label: AppDictionary.bills.get(isRpg),
                index: 1,
              ),

              const SizedBox(width: 48),
              _buildNavItem(
                icon: AppDictionary.investIcon.get(isRpg),
                label: AppDictionary.invest.get(isRpg),
                index: 2,
              ),
              _buildNavItem(
                icon: AppDictionary.historyIcon.get(isRpg),
                label: AppDictionary.history.get(isRpg),
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
