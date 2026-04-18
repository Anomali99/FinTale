import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dictionary.dart';
import '../../core/theme/mode_provider.dart';
import '../../services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modeProvider = Provider.of<ModeProvider>(context);
    final isRpg = modeProvider.isRpgMode;
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppDictionary.dashboard.get(isRpg)),
        actions: [
          Row(
            children: [
              const Icon(Icons.calculate, size: 16),
              Switch(
                value: isRpg,
                onChanged: (value) => modeProvider.toggleMode(),
                activeThumbColor: AppColors.primary,
              ),
              const Icon(Icons.shield, size: 16),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppDictionary.balance.get(isRpg),
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const Text(
              'Rp 10.000.000',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),

            _buildInfoCard(
              AppDictionary.debt.get(isRpg),
              'Rp 5.000.000',
              AppColors.primary,
            ),
            _buildInfoCard(
              AppDictionary.expenseBudget.get(isRpg),
              'Rp 3.000.000',
              AppColors.primaryDark,
            ),
            _buildInfoCard(
              AppDictionary.income.get(isRpg),
              'Rp 8.000.000',
              AppColors.success,
            ),

            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => authService.signOut(),
              child: Text(AppDictionary.logout.get(isRpg)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(Icons.monetization_on, color: color),
          ),
          title: Text(title),
          trailing: Text(
            amount,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
