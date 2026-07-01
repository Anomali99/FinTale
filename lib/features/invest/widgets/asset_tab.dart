import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../models/assets_model.dart';
import 'invest_card.dart';

class AssetTab extends StatelessWidget {
  final FaIconData icon;
  final List<AssetsModel> assets;
  final Function(AssetsModel) updateAsset;
  final Function(AssetsModel) addInvest;
  final Function(AssetsModel) claimDeviden;
  final Function(AssetsModel) sellAsset;

  const AssetTab({
    super.key,
    required this.icon,
    required this.assets,
    required this.updateAsset,
    required this.addInvest,
    required this.claimDeviden,
    required this.sellAsset,
  });

  @override
  Widget build(BuildContext context) {
    final isRpg = context.read<SettingsController>().isRpgMode;
    final colorScheme = Theme.of(context).colorScheme;

    if (assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 48, color: colorScheme.surfaceContainerHighest),
            const SizedBox(height: 16),
            Text(
              UiDict.getEmptyDesc(
                UiDict.menuInvest.get(isRpg).toLowerCase(),
                isRpg: isRpg,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
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
        return InvestCard(
          asset: assets[index],
          updateAsset: () => updateAsset(assets[index]),
          addInvest: () => addInvest(assets[index]),
          claimDeviden: () => claimDeviden(assets[index]),
          sellAsset: () => sellAsset(assets[index]),
          icon: icon,
        );
      },
    );
  }
}
