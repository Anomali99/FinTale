import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/utils/enum_types.dart';
import '../../../core/utils/number_utils.dart';
import '../../../models/wallet_model.dart';

class WalletDetails extends StatelessWidget {
  final bool isRpg;
  final List<WalletModel> wallets;
  final Function(WalletModel?, {bool? lock}) onTap;

  const WalletDetails({
    super.key,
    required this.wallets,
    required this.onTap,
    required this.isRpg,
  });

  @override
  Widget build(BuildContext context) {
    final walletController = context.read<WalletController>();
    final colorScheme = Theme.of(context).colorScheme;
    final cash = walletController.cash;
    final bank = walletController.bank;
    final eWallet = walletController.eWallet;
    final platform = walletController.platform;
    final totalBank = walletController.totalBank;
    final totalEWallet = walletController.totalEWallet;
    final totalPlatform = walletController.totalPlatform;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            controller: controller,
            children: [
              Text(
                ScreenDict.walletDetail.get(isRpg),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              if (cash != null)
                _buildSimpleWalletItem(
                  context: context,
                  wallet: cash,
                  isRpg: isRpg,
                ),

              Divider(
                color: colorScheme.onSurface.withOpacity(0.1),
                height: 32,
              ),

              if (bank.isNotEmpty) ...[
                _buildWalletItem(
                  context: context,
                  icon: FontAwesomeIcons.buildingColumns,
                  title: ScreenDict.walletBank.get(isRpg),
                  totalAmount: totalBank,
                  wallet: bank,
                ),

                Divider(
                  color: colorScheme.onSurface.withOpacity(0.1),
                  height: 16,
                ),
              ],

              if (eWallet.isNotEmpty) ...[
                _buildWalletItem(
                  context: context,
                  icon: FontAwesomeIcons.wallet,
                  title: ScreenDict.walletEwallet.get(isRpg),
                  totalAmount: totalEWallet,
                  wallet: eWallet,
                ),

                Divider(
                  color: colorScheme.onSurface.withOpacity(0.1),
                  height: 16,
                ),
              ],

              if (platform.isNotEmpty) ...[
                _buildWalletItem(
                  context: context,
                  icon: FontAwesomeIcons.mobileScreen,
                  title: ScreenDict.walletPlatform.get(isRpg),
                  totalAmount: totalPlatform,
                  wallet: platform,
                ),

                Divider(
                  color: colorScheme.onSurface.withOpacity(0.1),
                  height: 16,
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => {Navigator.pop(context), onTap(null)},
                  icon: Icon(Icons.add, color: colorScheme.primary),
                  label: Text(
                    ScreenDict.addWallet.get(isRpg),
                    style: TextStyle(color: colorScheme.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletItem({
    required BuildContext context,
    required FaIconData icon,
    required String title,
    required Decimal totalAmount,
    required List<WalletModel> wallet,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: colorScheme.surfaceContainerHighest,
          child: FaIcon(icon, size: 16, color: colorScheme.onSurface),
        ),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: Text(
          NumberUtils.toIdr(totalAmount),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: [
          for (WalletModel entry in wallet)
            _buildSubWalletItem(context: context, wallet: entry),
        ],
      ),
    );
  }

  Widget _buildSimpleWalletItem({
    required BuildContext context,
    required WalletModel wallet,
    required bool isRpg,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => {Navigator.pop(context), onTap(wallet, lock: true)},
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: FaIcon(wallet.icon, size: 16, color: colorScheme.onSurface),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              ScreenDict.walletCash.get(isRpg),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            NumberUtils.toIdr(wallet.amount),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSubWalletItem({
    required BuildContext context,
    required WalletModel wallet,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => {Navigator.pop(context), onTap(wallet)},
      child: Padding(
        padding: const EdgeInsets.only(
          left: 56.0,
          top: 8.0,
          bottom: 8.0,
          right: 8.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              wallet.name,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            Text(
              NumberUtils.toIdr(
                wallet.amount,
                decimalDigits: wallet.type == WalletType.platform ? 3 : null,
              ),
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
