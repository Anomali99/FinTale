import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../controllers/analytics_controller.dart';
import '../../controllers/history_controller.dart';
import '../../controllers/invest_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/assets_dict.dart';
import '../../core/constants/invest_dict.dart';
import '../../core/constants/menu_dict.dart';
import '../../models/assets_model.dart';
import '../../models/transaction_model.dart';
import 'widgets/asset_tab.dart';
import 'widgets/buy_asset_modal.dart';
import 'widgets/dividend_modal.dart';
import 'widgets/total_card.dart';
import 'widgets/update_asset_modal.dart';

class InvestScreen extends StatelessWidget {
  const InvestScreen({super.key});

  void _openDevidendAsset(BuildContext context, AssetsModel asset) async {
    final investController = context.read<InvestController>();
    final walletController = context.read<WalletController>();
    final historyController = context.read<HistoryController>();
    final analyticsController = context.read<AnalyticsController>();
    final result = await showModalBottomSheet<TransactionModel?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          DividendModal(asset: asset, wallets: walletController.wallets),
    );

    if (result != null && context.mounted) {
      await investController.claimDeviden(result);
      historyController.applyFilter();
      analyticsController.applyFilter();
    }
  }

  void _openUpdateAsset(BuildContext context, AssetsModel asset) async {
    final investController = context.read<InvestController>();
    final result = await showModalBottomSheet<AssetsModel?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpdateAssetModal(asset: asset),
    );
    if (result != null && context.mounted) {
      await investController.updateAsset(result);
    }
  }

  void _openAddAsset(BuildContext context, bool isRpg) async {
    final investController = context.read<InvestController>();
    final walletController = context.read<WalletController>();
    final historyController = context.read<HistoryController>();
    final analyticsController = context.read<AnalyticsController>();
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BuyAssetModal(
        wallets: walletController.wallets,
        assets: investController.assets,
        isRpg: isRpg,
      ),
    );

    if (result != null && context.mounted) {
      TransactionModel transaction = result['transaction'];
      AssetsModel asset = result['asset'];
      bool useReserved = result['use_reserved'];
      await investController.saveTransaction(
        transaction,
        asset,
        useReserved: useReserved,
      );
      historyController.applyFilter();
      analyticsController.applyFilter();
    }
  }

  void _openAddInvest(
    BuildContext context,
    AssetsModel assets,
    bool isRpg,
  ) async {
    final investController = context.read<InvestController>();
    final walletController = context.read<WalletController>();
    final historyController = context.read<HistoryController>();
    final analyticsController = context.read<AnalyticsController>();
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BuyAssetModal(
        initialAsset: assets,
        wallets: walletController.wallets,
        assets: [assets],
        isRpg: isRpg,
      ),
    );

    if (result != null && context.mounted) {
      TransactionModel transaction = result['transaction'];
      AssetsModel asset = result['asset'];
      await investController.saveTransaction(transaction, asset);
      historyController.applyFilter();
      analyticsController.applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final investController = context.watch<InvestController>();

    final isRpg = settingsController.isRpgMode;

    final lowRisk = investController.lowRisk;
    final mediumRisk = investController.mediumRisk;
    final highRisk = investController.highRisk;
    final totalInvested = investController.totalInvested;
    final totalValue = investController.totalValue;
    final overallPercentage = investController.overallPercentage;
    final isOverallProfit = investController.isOverallProfit;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            MenuDict.invest.get(isRpg),
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: FaIcon(InvestDict.add.icon(isRpg), size: 20),
              onPressed: () => _openAddAsset(context, isRpg),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TotalCard(
                isProvit: isOverallProfit,
                totalCapital: totalInvested,
                totalCurrent: totalValue,
                percentage: overallPercentage,
                isRpg: isRpg,
              ),
            ),

            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,

              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,

              tabs: [
                Tab(
                  icon: FaIcon(AssetsDict.lowRisk.icon(isRpg), size: 16),
                  text: AssetsDict.lowRisk.get(isRpg),
                ),
                Tab(
                  icon: FaIcon(AssetsDict.mediumRisk.icon(isRpg), size: 16),
                  text: AssetsDict.mediumRisk.get(isRpg),
                ),
                Tab(
                  icon: FaIcon(AssetsDict.highRisk.icon(isRpg), size: 16),
                  text: AssetsDict.highRisk.get(isRpg),
                ),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [
                  AssetTab(
                    icon: AssetsDict.lowRisk.icon(isRpg),
                    addInvest: (value) => _openAddInvest(context, value, isRpg),
                    updateAsset: (value) => _openUpdateAsset(context, value),
                    claimDeviden: (value) => _openDevidendAsset(context, value),
                    assets: lowRisk,
                    isRpg: isRpg,
                  ),
                  AssetTab(
                    icon: AssetsDict.mediumRisk.icon(isRpg),
                    addInvest: (value) => _openAddInvest(context, value, isRpg),
                    updateAsset: (value) => _openUpdateAsset(context, value),
                    claimDeviden: (value) => _openDevidendAsset(context, value),
                    assets: mediumRisk,
                    isRpg: isRpg,
                  ),
                  AssetTab(
                    icon: AssetsDict.highRisk.icon(isRpg),
                    addInvest: (value) => _openAddInvest(context, value, isRpg),
                    updateAsset: (value) => _openUpdateAsset(context, value),
                    claimDeviden: (value) => _openDevidendAsset(context, value),
                    assets: highRisk,
                    isRpg: isRpg,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
