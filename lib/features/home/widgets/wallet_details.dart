import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/home_dict.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/wallet_model.dart';

class WalletDetails extends StatelessWidget {
  final bool isRpg;
  final List<WalletModel> wallets;
  final VoidCallback onAdd;

  const WalletDetails({
    super.key,
    required this.wallets,
    required this.onAdd,
    required this.isRpg,
  });

  @override
  Widget build(BuildContext context) {
    final WalletModel cash = wallets[0];
    List<WalletModel> bank = [];
    List<WalletModel> eWallet = [];
    List<WalletModel> platform = [];
    BigInt totalBank = BigInt.zero;
    BigInt totalEWallet = BigInt.zero;
    BigInt totalPlatform = BigInt.zero;

    for (WalletModel wallet in wallets) {
      switch (wallet.type) {
        case WalletType.bank:
          bank.add(wallet);
          totalBank += wallet.amount;
          break;
        case WalletType.eWallet:
          eWallet.add(wallet);
          totalEWallet += wallet.amount;
          break;
        case WalletType.platform:
          platform.add(wallet);
          totalPlatform += wallet.amount;
          break;
        case WalletType.cash:
          continue;
      }
    }

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
                HomeDict.walletDetails.get(isRpg),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              _buildSimpleWalletItem(
                icon: FontAwesomeIcons.coins,
                name: HomeDict.cash.get(isRpg),
                amount: cash.amount,
              ),

              const Divider(color: Colors.white10, height: 32),

              if (bank.isNotEmpty) ...[
                _buildWalletItem(
                  context: context,
                  icon: FontAwesomeIcons.buildingColumns,
                  title: HomeDict.bankAccount.get(isRpg),
                  totalAmount: totalBank,
                  wallet: bank,
                ),

                const Divider(color: Colors.white10, height: 16),
              ],

              if (eWallet.isNotEmpty) ...[
                _buildWalletItem(
                  context: context,
                  icon: FontAwesomeIcons.wallet,
                  title: HomeDict.eWallet.get(isRpg),
                  totalAmount: totalEWallet,
                  wallet: eWallet,
                ),

                const Divider(color: Colors.white10, height: 16),
              ],

              if (platform.isNotEmpty) ...[
                _buildWalletItem(
                  context: context,
                  icon: FontAwesomeIcons.mobileScreen,
                  title: HomeDict.platform.get(isRpg),
                  totalAmount: totalPlatform,
                  wallet: platform,
                ),

                const Divider(color: Colors.white10, height: 16),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => {Navigator.pop(context), onAdd()},
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  label: Text(
                    'Add New ${isRpg ? 'Storage' : 'Wallet'}',
                    style: const TextStyle(color: AppColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
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
    required BigInt totalAmount,
    required List<WalletModel> wallet,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceVariant,
          child: FaIcon(icon, size: 16, color: AppColors.textPrimary),
        ),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: Text(
          CurrencyFormatter.convertToIdr(totalAmount),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: [
          ...wallet.asMap().entries.map((entry) {
            return _buildSubWalletItem(
              name: entry.value.name,
              amount: entry.value.amount,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSimpleWalletItem({
    required FaIconData icon,
    required String name,
    required BigInt amount,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.surfaceVariant,
          child: FaIcon(icon, size: 16, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(name, style: const TextStyle(fontSize: 16))),
        Text(
          CurrencyFormatter.convertToIdr(amount),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSubWalletItem({required String name, required BigInt amount}) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 56.0,
        top: 8.0,
        bottom: 8.0,
        right: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(color: AppColors.textSecondary)),
          Text(
            CurrencyFormatter.convertToIdr(amount),
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
