import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/number_utils.dart';

class OverviewCard extends StatelessWidget {
  final bool isRpg;
  final Decimal totalIncome;
  final Decimal totalExpense;
  final Decimal totalInvest;

  const OverviewCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalInvest,
    required this.isRpg,
  });

  Decimal get unallocated => totalIncome - totalExpense - totalInvest;

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required Decimal amount,
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
          NumberUtils.toIdr(amount),
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
                UiDict.income.get(isRpg),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                NumberUtils.toIdr(totalIncome),
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
                    flex:
                        (totalIncome > Decimal.zero
                                ? (totalExpense.toDouble() /
                                      totalIncome.toDouble() *
                                      100)
                                : 0.0)
                            .toInt(),
                    child: Container(color: AppColors.error),
                  ),
                  Expanded(
                    flex:
                        (totalIncome > Decimal.zero
                                ? (totalInvest.toDouble() /
                                      totalIncome.toDouble() *
                                      100)
                                : 0.0)
                            .toInt(),
                    child: Container(color: AppColors.primary),
                  ),
                  Expanded(
                    flex:
                        (totalIncome > Decimal.zero
                                ? (unallocated.toDouble() /
                                      totalIncome.toDouble() *
                                      100)
                                : 100.0)
                            .toInt(),
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
                label: UiDict.expense.get(isRpg),
                amount: totalExpense,
              ),
              _buildLegendItem(
                color: AppColors.primary,
                label: UiDict.menuInvest.get(isRpg),
                amount: totalInvest,
              ),
              _buildLegendItem(
                color: Colors.white24,
                label: UiDict.unallocated.get(isRpg),
                amount: unallocated,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
