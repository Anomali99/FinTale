import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/invest_dict.dart';
import 'invest_card.dart';

class AssetTab extends StatelessWidget {
  final FaIconData icon;
  final String category;
  final List<AssetModel> assets;
  final bool isRpg;

  const AssetTab({
    super.key,
    required this.icon,
    required this.category,
    required this.assets,
    required this.isRpg,
  });

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 48, color: AppColors.surfaceVariant),
            const SizedBox(height: 16),
            Text(
              InvestDict.empty.get(isRpg),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: 100.0,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        final isProfit = asset.profitPercentage >= 0;

        return InvestCard(
          asset: asset,
          cardIcon: icon,
          isProfit: isProfit,
          isRpg: isRpg,
        );
      },
    );
  }
}
