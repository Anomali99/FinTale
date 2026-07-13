import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/analytics_controller.dart';
import '../../../controllers/history_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/invest_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../controllers/skill_controller.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/category_dict.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/enum_types.dart';
import '../../../core/utils/global_messenger.dart';
import '../../../models/assets_model.dart';
import '../../../models/transaction_model.dart';
import '../widgets/asset_tab.dart';
import '../widgets/dividend_modal.dart';
import '../widgets/sell_asset_modal.dart';
import '../widgets/total_card.dart';
import '../widgets/update_asset_modal.dart';

class InvestScreen extends StatelessWidget {
  const InvestScreen({super.key});

  void _openSellAsset(BuildContext context, AssetsModel asset) async {
    final investController = context.read<InvestController>();
    final walletController = context.read<WalletController>();
    final skillController = context.read<SkillController>();
    final historyController = context.read<HistoryController>();
    final analyticsController = context.read<AnalyticsController>();
    final isRpg = context.read<SettingsController>().isRpgMode;

    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          SellAssetModal(asset: asset, wallets: walletController.wallets),
    );

    if (result != null && context.mounted) {
      TransactionModel transaction = result['transaction'];
      AssetsModel updatedAsset = result['asset'];
      Decimal emergencyDeduction = result['emergency_deduction'];

      bool isSuccess = await investController.sellAsset(
        context,
        transaction,
        updatedAsset,
        emergencyDeduction,
      );

      if (isSuccess) {
        await skillController.loadData();
      }
      await historyController.applyFilter();
      await analyticsController.applyFilter();
      GlobalMessenger.showMessage(
        context,
        message: ScreenDict.getInvestSellNotif(
          isSuccess: isSuccess,
          isRpg: isRpg,
        ),
        isSuccess: isSuccess,
      );
    }
  }

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
      bool isSuccess = await investController.claimDeviden(result);
      await historyController.applyFilter();
      await analyticsController.applyFilter();
      GlobalMessenger.showMessage(
        context,
        message: UiDict.getSaveNotif(
          ScreenDict.investClaim,
          isSuccess: isSuccess,
        ),
        isSuccess: isSuccess,
      );
    }
  }

  void _openUpdateAsset(BuildContext context, AssetsModel asset) async {
    final investController = context.read<InvestController>();
    final skillController = context.read<SkillController>();
    final isRpg = context.read<SettingsController>().isRpgMode;
    final result = await showModalBottomSheet<AssetsModel?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpdateAssetModal(asset: asset),
    );
    if (result != null && context.mounted) {
      bool isSuccess = await investController.updateAsset(context, result);
      if (isSuccess) {
        await skillController.loadData();
      }
      GlobalMessenger.showMessage(
        context,
        message: UiDict.getSaveNotif(
          ScreenDict.investAssetName.get(isRpg),
          isSuccess: isSuccess,
          isUpdate: true,
        ),
        isSuccess: isSuccess,
      );
    }
  }

  void _openAddAsset(BuildContext context) async {
    final homeController = context.read<HomeController>();
    final investController = context.read<InvestController>();
    final walletController = context.read<WalletController>();
    final skillController = context.read<SkillController>();
    final historyController = context.read<HistoryController>();
    final analyticsController = context.read<AnalyticsController>();
    final isRpg = context.read<SettingsController>().isRpgMode;
    final result =
        await Navigator.pushNamed(
              context,
              '/buy-asset',
              arguments: {
                "wallets": walletController.wallets,
                "assets": investController.assets,
              },
            )
            as Map<String, dynamic>?;

    if (result != null && context.mounted) {
      TransactionModel transaction = result['transaction'];
      AssetsModel asset = result['asset'];
      bool useReserved = result['use_reserved'];
      bool isSuccess = await investController.saveTransaction(
        context,
        transaction,
        asset,
        useReserved: useReserved,
      );

      if (isSuccess) {
        await skillController.loadData();
      }
      await homeController.usePendingBySector(
        amount: transaction.amount,
        sector: asset.isEmergency
            ? SectorType.emergency
            : SectorType.investment,
        subSector: asset.type.getSubSector(),
      );
      await historyController.applyFilter();
      await analyticsController.applyFilter();
      GlobalMessenger.showMessage(
        context,
        message: UiDict.getSaveNotif(
          ScreenDict.investAssetName.get(isRpg),
          isSuccess: isSuccess,
        ),
        isSuccess: isSuccess,
      );
    }
  }

  void _openAddInvest(BuildContext context, AssetsModel assets) async {
    final homeController = context.read<HomeController>();
    final investController = context.read<InvestController>();
    final walletController = context.read<WalletController>();
    final historyController = context.read<HistoryController>();
    final analyticsController = context.read<AnalyticsController>();
    final isRpg = context.read<SettingsController>().isRpgMode;
    final result =
        await Navigator.pushNamed(
              context,
              '/buy-asset',
              arguments: {
                "wallets": walletController.wallets,
                "assets": [assets],
                "initialAsset": assets,
              },
            )
            as Map<String, dynamic>?;

    if (result != null && context.mounted) {
      TransactionModel transaction = result['transaction'];
      AssetsModel asset = result['asset'];
      bool isSuccess = await investController.saveTransaction(
        context,
        transaction,
        asset,
      );
      await homeController.usePendingBySector(
        amount: transaction.amount,
        sector: asset.isEmergency
            ? SectorType.emergency
            : SectorType.investment,
        subSector: asset.type.getSubSector(),
      );
      await historyController.applyFilter();
      await analyticsController.applyFilter();
      GlobalMessenger.showMessage(
        context,
        message: ScreenDict.getInvestModalNotif(
          isSuccess: isSuccess,
          isRpg: isRpg,
        ),
        isSuccess: isSuccess,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final investController = context.watch<InvestController>();
    final colorScheme = Theme.of(context).colorScheme;

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
            UiDict.menuInvest.get(isRpg),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: FaIcon(ScreenDict.investAdd.get(isRpg), size: 20),
              onPressed: () => _openAddAsset(context),
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
              ),
            ),

            TabBar(
              indicatorColor: colorScheme.primary,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,

              tabs: [
                Tab(
                  icon: FaIcon(CategoryDict.lowRisk.icon(isRpg), size: 16),
                  text: CategoryDict.lowRisk.get(isRpg),
                ),
                Tab(
                  icon: FaIcon(CategoryDict.mediumRisk.icon(isRpg), size: 16),
                  text: CategoryDict.mediumRisk.get(isRpg),
                ),
                Tab(
                  icon: FaIcon(CategoryDict.highRisk.icon(isRpg), size: 16),
                  text: CategoryDict.highRisk.get(isRpg),
                ),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [
                  AssetTab(
                    icon: CategoryDict.lowRisk.icon(isRpg),
                    addInvest: (value) => _openAddInvest(context, value),
                    updateAsset: (value) => _openUpdateAsset(context, value),
                    claimDeviden: (value) => _openDevidendAsset(context, value),
                    sellAsset: (value) => _openSellAsset(context, value),
                    assets: lowRisk,
                  ),
                  AssetTab(
                    icon: CategoryDict.mediumRisk.icon(isRpg),
                    addInvest: (value) => _openAddInvest(context, value),
                    updateAsset: (value) => _openUpdateAsset(context, value),
                    claimDeviden: (value) => _openDevidendAsset(context, value),
                    sellAsset: (value) => _openSellAsset(context, value),
                    assets: mediumRisk,
                  ),
                  AssetTab(
                    icon: CategoryDict.highRisk.icon(isRpg),
                    addInvest: (value) => _openAddInvest(context, value),
                    updateAsset: (value) => _openUpdateAsset(context, value),
                    claimDeviden: (value) => _openDevidendAsset(context, value),
                    sellAsset: (value) => _openSellAsset(context, value),
                    assets: highRisk,
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
