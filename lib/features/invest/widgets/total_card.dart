import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/number_utils.dart';

class TotalCard extends StatelessWidget {
  final bool isProfit;
  final Decimal totalCapital;
  final Decimal totalCurrent;
  final double percentage;

  const TotalCard({
    super.key,
    required this.isProfit,
    required this.totalCapital,
    required this.totalCurrent,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final isRpg = context.read<SettingsController>().isRpgMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.surfaceContainerHighest, colorScheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isProfit
              ? AppColors.getSuccess(context).withValues(alpha: 0.3)
              : colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ScreenDict.investTotal.get(isRpg),
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            NumberUtils.toIdr(totalCurrent),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isProfit
                  ? AppColors.getSuccess(context)
                  : colorScheme.error,
            ),
          ),
          Divider(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
            height: 32,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ScreenDict.investModal.get(isRpg),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    NumberUtils.toIdr(totalCapital),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isProfit
                      ? AppColors.getSuccess(context).withValues(alpha: 0.2)
                      : colorScheme.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    FaIcon(
                      isProfit
                          ? FontAwesomeIcons.arrowTrendUp
                          : FontAwesomeIcons.arrowTrendDown,
                      color: isProfit
                          ? AppColors.getSuccess(context)
                          : colorScheme.error,
                      size: 12,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${isProfit ? '+' : ''}${percentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isProfit
                            ? AppColors.getSuccess(context)
                            : colorScheme.error,
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
