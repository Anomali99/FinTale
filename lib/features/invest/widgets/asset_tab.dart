import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/invest_dict.dart';
import '../../../models/assets_model.dart';
import 'invest_card.dart';

class AssetTab extends StatelessWidget {
  final bool isRpg;
  final FaIconData icon;
  final List<AssetsModel> assets;

  const AssetTab({
    super.key,
    required this.icon,
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
        return InvestCard(asset: assets[index], icon: icon, isRpg: isRpg);
      },
    );
  }
}
