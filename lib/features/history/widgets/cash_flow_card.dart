import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/ui_dict.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/number_utils.dart';

class CashFlowCard extends StatelessWidget {
  final bool isRpg;
  final Decimal totalIncome;
  final Decimal totalExpense;

  const CashFlowCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.isRpg,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          _buildFlowBlock(
            amount: totalIncome,
            icon: UiDict.income.icon(isRpg),
            color: AppColors.success,
          ),

          const SizedBox(width: 12),

          _buildFlowBlock(
            amount: totalExpense,
            icon: UiDict.expense.icon(isRpg),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildFlowBlock({
    required Decimal amount,
    required FaIconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withOpacity(0.2),
              child: FaIcon(icon, size: 10, color: color),
            ),

            const SizedBox(height: 12),

            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                NumberUtils.toIdr(amount),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
