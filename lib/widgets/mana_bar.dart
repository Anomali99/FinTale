import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dictionary.dart';
import '../core/theme/mode_provider.dart';
import '../core/utils/currency_formatter.dart';

class ManaBar extends StatelessWidget {
  final double limit;
  final double spent;

  const ManaBar({super.key, required this.limit, required this.spent});

  @override
  Widget build(BuildContext context) {
    final isRpg = Provider.of<ModeProvider>(context).isRpgMode;
    final remaining = limit - spent;

    final double percentage = limit > 0
        ? (remaining / limit).clamp(0.0, 1.0)
        : 0.0;

    final Color barColor = percentage > 0.2
        ? Colors.blueAccent
        : AppColors.error;

    final String formattedRemaining = CurrencyFormatter.convertToIdr(remaining);

    return Container(
      padding: const EdgeInsets.all(20),
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
              Text(AppDictionary.remainingToday.get(isRpg)),
              Text(
                formattedRemaining,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.background,
              color: barColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Spent: ${CurrencyFormatter.convertToIdr(spent)} / ${CurrencyFormatter.convertToIdr(limit)}',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
