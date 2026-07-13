import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/screen_dict.dart';
import '../../../core/utils/color_extension.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isExceeded = spent > limit;

    final Decimal remaining = isExceeded ? Decimal.zero : limit - spent;
    final Decimal overage = isExceeded ? spent - limit : Decimal.zero;

    final double percentage = limit > Decimal.zero
        ? (isExceeded
              ? 0.0
              : (remaining.toDouble() / limit.toDouble()).clamp(0.0, 1.0))
        : 0.0;

    final Color barColor = isExceeded
        ? colorScheme.error
        : (percentage > 0.2
              ? Colors.blueAccent.adapt(context)
              : colorScheme.error);

    final String formattedRemaining = NumberUtils.toIdr(remaining);
    final String formattedOverage = NumberUtils.toIdr(overage);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),

        border: isExceeded
            ? Border.all(color: colorScheme.error.withOpacity(0.5))
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
                  color: isExceeded ? colorScheme.error : colorScheme.onSurface,
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
                  ? colorScheme.error.withOpacity(0.2)
                  : theme.scaffoldBackgroundColor,
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
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isExceeded) ...[
                      const SizedBox(height: 4),
                      Text(
                        ScreenDict.getHomeLimitOver(formattedOverage),
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.error,
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
                      Text(
                        ScreenDict.homePenalty,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '- ${NumberUtils.toIdr(penalty!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.error,
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
