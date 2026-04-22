import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/invest_dict.dart';
import '../../../core/utils/currency_formatter.dart';

class AssetModel {
  final String id;
  String name;
  String category;
  String type;
  double investedCapital;
  double currentValue;
  double unitCount;
  String unitName;

  AssetModel({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.investedCapital,
    required this.currentValue,
    required this.unitCount,
    required this.unitName,
  });

  double get profitPercentage {
    if (investedCapital == 0) return 0;
    return ((currentValue - investedCapital) / investedCapital);
  }
}

class InvestCard extends StatelessWidget {
  final bool isRpg;
  final AssetModel asset;
  final FaIconData cardIcon;
  final bool isProfit;

  const InvestCard({
    super.key,
    required this.asset,
    required this.cardIcon,
    required this.isProfit,
    required this.isRpg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: FaIcon(cardIcon, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${asset.unitCount} ${asset.unitName} • ${asset.type}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isProfit
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${isProfit ? '+' : ''}${(asset.profitPercentage * 100).toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isProfit ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    InvestDict.invested.get(isRpg),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.convertToIdr(asset.investedCapital),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    InvestDict.invested.get(isRpg),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.convertToIdr(asset.currentValue),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: isProfit ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
