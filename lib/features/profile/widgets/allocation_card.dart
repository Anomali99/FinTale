import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/gamification_dict.dart';
import '../../../core/utils/color_extension.dart';
import 'stat_radar.dart';

class AllocationCard extends StatelessWidget {
  final bool isRpg;
  final double livingPercentage;
  final double payDebtPercentage;
  final double emergencyPercentage;
  final double investmentPercentage;
  final VoidCallback onTap;
  const AllocationCard({
    super.key,
    required this.onTap,
    required this.isRpg,
    double? livingPercentage,
    double? payDebtPercentage,
    double? emergencyPercentage,
    double? investmentPercentage,
  }) : livingPercentage = livingPercentage ?? 0.0,
       payDebtPercentage = payDebtPercentage ?? 0.0,
       emergencyPercentage = emergencyPercentage ?? 0.0,
       investmentPercentage = investmentPercentage ?? 0.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  GamificationDict.statistics.get(isRpg),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    StatRadar(
                      stats: [
                        livingPercentage / 100,
                        (payDebtPercentage == 0.0 ? 100.0 : payDebtPercentage) /
                            100,
                        (emergencyPercentage == 0.0
                                ? 100.0
                                : emergencyPercentage) /
                            100,
                        investmentPercentage / 100,
                      ],
                      color: colorScheme.primary,
                    ),

                    FaIcon(
                      FontAwesomeIcons.khanda,
                      size: 16,
                      color: colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ],
                ),

                const SizedBox(width: 32),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _statRow(
                        context,
                        GamificationDict.skillDaily.get(isRpg),
                        '${livingPercentage.toInt().toString()}%',
                        GamificationDict.skillDaily.color ??
                            Colors.blue.adapt(context),
                      ),
                      _statRow(
                        context,
                        GamificationDict.skillDebt.get(isRpg),
                        '${payDebtPercentage.toInt().toString()}%',
                        GamificationDict.skillDebt.color ??
                            Colors.blue.adapt(context),
                      ),
                      _statRow(
                        context,
                        GamificationDict.skillEmergency.get(isRpg),
                        '${emergencyPercentage.toInt().toString()}%',
                        GamificationDict.skillEmergency.color ??
                            Colors.blue.adapt(context),
                      ),
                      _statRow(
                        context,
                        GamificationDict.skillInvestment.get(isRpg),
                        '${investmentPercentage.toInt().toString()}%',
                        GamificationDict.skillInvestment.color ??
                            Colors.blue.adapt(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(BuildContext context, String label, String val, Color col) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: col, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
          ),
          const Spacer(),
          Text(
            val,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
