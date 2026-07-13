import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../core/constants/category_dict.dart';
import '../../../core/constants/gamification_dict.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/color_extension.dart';
import '../../../core/utils/number_utils.dart';
import '../../../models/assets_model.dart';
import '../../../widgets/custom_bottom_sheet.dart';

class InvestCard extends StatelessWidget {
  final FaIconData icon;
  final AssetsModel asset;
  final VoidCallback updateAsset;
  final VoidCallback addInvest;
  final VoidCallback claimDeviden;
  final VoidCallback sellAsset;

  const InvestCard({
    super.key,
    required this.icon,
    required this.asset,
    required this.updateAsset,
    required this.addInvest,
    required this.claimDeviden,
    required this.sellAsset,
  });

  void _showAssetOptions(BuildContext context) {
    final isRpg = context.read<SettingsController>().isRpgMode;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CustomBottomSheet(
          title: asset.name,
          hideDriver: true,
          children: [
            BottomSheetChild(
              title: ScreenDict.investAddModal.get(isRpg),
              color: colorScheme.primary,
              icon: FontAwesomeIcons.plus,
              onTap: () {
                Navigator.pop(context);
                addInvest();
              },
            ),
            BottomSheetChild(
              title: ScreenDict.investUpdatePrice.get(isRpg),
              color: Colors.blueAccent.adapt(context),
              icon: FontAwesomeIcons.arrowsRotate,
              onTap: () {
                Navigator.pop(context);
                updateAsset();
              },
            ),
            if (asset.hasDividend)
              BottomSheetChild(
                title: ScreenDict.investClaimDeviden,
                color: AppColors.getSuccess(context),
                icon: FontAwesomeIcons.moneyCheck,
                onTap: () {
                  Navigator.pop(context);
                  claimDeviden();
                },
              ),
            BottomSheetChild(
              title: ScreenDict.investSellAsset.get(isRpg),
              color: colorScheme.error,
              icon: FontAwesomeIcons.moneyBillTransfer,
              onTap: () {
                Navigator.pop(context);
                sellAsset();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRpg = context.read<SettingsController>().isRpgMode;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _showAssetOptions(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primary.withOpacity(0.2),
                  child: FaIcon(icon, size: 14, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              asset.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                                    color: Colors.cyan
                                        .adapt(context)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: FaIcon(
                                    GamificationDict.skillEmergency.icon(isRpg),
                                    size: 12,
                                    color: Colors.cyan.adapt(context),
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
                                    color: Colors.blueAccent
                                        .adapt(context)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: FaIcon(
                                    CategoryDict.dividend.icon(isRpg),
                                    size: 12,
                                    color: Colors.blueAccent.adapt(context),
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
                                      ? AppColors.getSuccess(
                                          context,
                                        ).withOpacity(0.2)
                                      : colorScheme.error.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${asset.isProfit ? '+' : '-'} ${asset.getPercentage.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: asset.isProfit
                                        ? AppColors.getSuccess(context)
                                        : colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '${asset.unit} ${asset.unitName} • ${asset.category.value}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
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
                      ScreenDict.investModal.get(isRpg),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      NumberUtils.toIdr(asset.invested),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ScreenDict.investValue.get(isRpg),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      NumberUtils.toIdr(asset.value),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: asset.isProfit
                            ? AppColors.getSuccess(context)
                            : colorScheme.error,
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
