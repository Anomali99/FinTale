import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/profile_dict.dart';
import '../../../core/constants/skill_dict.dart';
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ProfileDict.stats.get(isRpg),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textSecondary,
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
                      color: AppColors.primary,
                    ),

                    const FaIcon(
                      FontAwesomeIcons.khanda,
                      size: 16,
                      color: Colors.white24,
                    ),
                  ],
                ),

                const SizedBox(width: 32),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _statRow(
                        SkillDict.dailyParent.get(isRpg),
                        '${livingPercentage.toInt().toString()}%',
                        SkillDict.dailyParent.color ?? Colors.blue,
                      ),
                      _statRow(
                        SkillDict.debt.get(isRpg),
                        '${payDebtPercentage.toInt().toString()}%',
                        SkillDict.debt.color ?? Colors.blue,
                      ),
                      _statRow(
                        SkillDict.emergency.get(isRpg),
                        '${emergencyPercentage.toInt().toString()}%',
                        SkillDict.emergency.color ?? Colors.blue,
                      ),
                      _statRow(
                        SkillDict.investment.get(isRpg),
                        '${investmentPercentage.toInt().toString()}%',
                        SkillDict.investment.color ?? Colors.blue,
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

  Widget _statRow(String label, String val, Color col) {
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
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
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
