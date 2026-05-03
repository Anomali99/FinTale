import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/shared_dict.dart';
import '../../../core/utils/currency_formatter.dart';

class CashFlowCard extends StatelessWidget {
  final bool isRpg;
  final BigInt totalIncome;
  final BigInt totalExpense;

  const CashFlowCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.isRpg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          _buildFlowBlock(
            amount: totalIncome,
            icon: SharedDict.income.icon(isRpg),
            color: AppColors.success,
          ),

          const SizedBox(width: 12),

          _buildFlowBlock(
            amount: totalExpense,
            icon: SharedDict.expense.icon(isRpg),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildFlowBlock({
    required BigInt amount,
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
                CurrencyFormatter.convertToIdr(amount),
                style: GoogleFonts.poppins(
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
