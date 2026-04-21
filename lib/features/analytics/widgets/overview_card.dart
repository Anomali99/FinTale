import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dictionary.dart';
import '../../../core/utils/currency_formatter.dart';

class OverviewCard extends StatelessWidget {
  final bool isRpg;
  final double totalIncome;
  final double totalExpense;
  final double totalInvest;

  const OverviewCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalInvest,
    required this.isRpg,
  });

  double get unallocated => totalIncome - totalExpense - totalInvest;

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required double amount,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.convertToIdr(amount),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                HomeDict.income.get(isRpg),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                CurrencyFormatter.convertToIdr(totalIncome),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 16,
              child: Row(
                children: [
                  Expanded(
                    flex: (totalExpense / totalIncome * 100).toInt(),
                    child: Container(color: AppColors.error),
                  ),
                  Expanded(
                    flex: (totalInvest / totalIncome * 100).toInt(),
                    child: Container(color: AppColors.primary),
                  ),
                  Expanded(
                    flex: (unallocated / totalIncome * 100).toInt(),
                    child: Container(color: Colors.white24),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                color: AppColors.error,
                label: HistoryDict.expense.get(isRpg),
                amount: totalExpense,
              ),
              _buildLegendItem(
                color: AppColors.primary,
                label: MenuDict.invest.get(isRpg),
                amount: totalInvest,
              ),
              _buildLegendItem(
                color: Colors.white24,
                label: HistoryDict.unallocated.get(isRpg),
                amount: unallocated,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
