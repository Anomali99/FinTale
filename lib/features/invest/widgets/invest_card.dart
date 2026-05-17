import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_dict.dart';
import '../../../core/constants/invest_dict.dart';
import '../../../core/constants/skill_dict.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/assets_model.dart';
import '../../../widgets/custom_bottom_sheet.dart';

class InvestCard extends StatelessWidget {
  final bool isRpg;
  final FaIconData icon;
  final AssetsModel asset;
  final VoidCallback updateAsset;
  final VoidCallback addInvest;
  final VoidCallback claimDeviden;

  const InvestCard({
    super.key,
    required this.icon,
    required this.asset,
    required this.isRpg,
    required this.updateAsset,
    required this.addInvest,
    required this.claimDeviden,
  });

  void _showAssetOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CustomBottomSheet(
          title: asset.name,
          hideDriver: true,
          children: [
            BottomSheetChild(
              title: InvestDict.buyOrAddModal,
              color: AppColors.primary,
              icon: FontAwesomeIcons.plus,
              onTap: () {
                Navigator.pop(context);
                addInvest();
              },
            ),
            BottomSheetChild(
              title: InvestDict.updatePrice,
              color: Colors.blueAccent,
              icon: FontAwesomeIcons.arrowsRotate,
              onTap: () {
                Navigator.pop(context);
                updateAsset();
              },
            ),
            if (asset.hasDividend)
              BottomSheetChild(
                title: InvestDict.claimDeviden,
                color: AppColors.success,
                icon: FontAwesomeIcons.moneyCheck,
                onTap: () {
                  Navigator.pop(context);
                  claimDeviden();
                },
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showAssetOptions(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                  child: FaIcon(icon, size: 14, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            asset.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Row(
                            children: [
                              if (asset.isEmergency) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.cyan.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: FaIcon(
                                    SkillDict.emergency.icon(isRpg),
                                    size: 12,
                                    color: Colors.cyan,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              if (asset.hasDividend) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: FaIcon(
                                    CategoryDict.dividend.icon(isRpg),
                                    size: 12,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: asset.isProfit
                                      ? AppColors.success.withOpacity(0.2)
                                      : AppColors.error.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${asset.isProfit ? '+' : '-'} ${asset.getPercentage.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: asset.isProfit
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '${asset.unit} ${asset.unitName} • ${asset.category.value}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
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
                      CurrencyFormatter.convertToIdr(asset.invested),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      InvestDict.value.get(isRpg),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.convertToIdr(asset.value),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: asset.isProfit
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
