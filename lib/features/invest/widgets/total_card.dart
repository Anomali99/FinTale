import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dictionary.dart';
import '../../../core/utils/currency_formatter.dart';

class TotalCard extends StatelessWidget {
  final bool isRpg;
  final bool isProvit;
  final double totalCapital;
  final double totalCurrent;
  final double percentage;

  const TotalCard({
    super.key,
    required this.isProvit,
    required this.totalCapital,
    required this.totalCurrent,
    required this.percentage,
    required this.isRpg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfaceVariant, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isProvit
              ? AppColors.success.withOpacity(0.3)
              : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            InvestDict.totalPortfolio.get(isRpg),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.convertToIdr(totalCurrent),
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isProvit ? AppColors.success : AppColors.error,
            ),
          ),
          const Divider(color: Colors.white10, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    InvestDict.investedCapital.get(isRpg),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.convertToIdr(totalCapital),
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
                  color: isProvit
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    FaIcon(
                      isProvit
                          ? FontAwesomeIcons.arrowTrendUp
                          : FontAwesomeIcons.arrowTrendDown,
                      color: isProvit ? AppColors.success : AppColors.error,
                      size: 12,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${isProvit ? '+' : ''}${(percentage * 100).toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isProvit ? AppColors.success : AppColors.error,
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
