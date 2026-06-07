import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/screen_dict.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/number_utils.dart';

class DailyLimit extends StatelessWidget {
  final bool isRpg;
  final Decimal limit;
  final Decimal spent;
  final Decimal? penalty;

  const DailyLimit({
    super.key,
    required this.limit,
    required this.spent,
    required this.isRpg,
    this.penalty,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExceeded = spent > limit;

    final Decimal remaining = isExceeded ? Decimal.zero : limit - spent;
    final Decimal overage = isExceeded ? spent - limit : Decimal.zero;

    final double percentage = limit > Decimal.zero
        ? (isExceeded
              ? 0.0
              : (remaining.toDouble() / limit.toDouble()).clamp(0.0, 1.0))
        : 0.0;

    final Color barColor = isExceeded
        ? AppColors.error
        : (percentage > 0.2 ? Colors.blueAccent : AppColors.error);

    final String formattedRemaining = NumberUtils.toIdr(remaining);
    final String formattedOverage = NumberUtils.toIdr(overage);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),

        border: isExceeded
            ? Border.all(color: AppColors.error.withOpacity(0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isExceeded
                    ? ScreenDict.homeLimitOver.get(isRpg)
                    : ScreenDict.homeRemainingToday.get(isRpg),
                style: TextStyle(
                  color: isExceeded ? AppColors.error : AppColors.textPrimary,
                  fontWeight: isExceeded ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                isExceeded ? '- $formattedOverage' : formattedRemaining,
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
              backgroundColor: isExceeded
                  ? AppColors.error.withOpacity(0.2)
                  : AppColors.background,
              color: barColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ScreenDict.getHomeSpent(
                        NumberUtils.toIdr(spent),
                        NumberUtils.toIdr(limit),
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (isExceeded) ...[
                      const SizedBox(height: 4),
                      Text(
                        ScreenDict.getHomeLimitOver(formattedOverage),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (penalty != null && penalty! > Decimal.zero)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        ScreenDict.homePenalty,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '- ${NumberUtils.toIdr(penalty!)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
