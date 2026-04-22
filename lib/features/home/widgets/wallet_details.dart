import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/home_dict.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/wallet_model.dart';

class WalletDetails extends StatelessWidget {
  final bool isRpg;
  final List<WalletModel> wallets;

  const WalletDetails({super.key, required this.wallets, required this.isRpg});

  @override
  Widget build(BuildContext context) {
    final WalletModel cash = wallets[0];
    final List<WalletModel> bank = wallets
        .where((wallet) => wallet.type == WalletType.bank)
        .toList();
    final List<WalletModel> eWallet = wallets
        .where((wallet) => wallet.type == WalletType.eWallet)
        .toList();
    final List<WalletModel> platform = wallets
        .where((wallet) => wallet.type == WalletType.platform)
        .toList();
    final BigInt totalBank = bank.fold(BigInt.zero, (
      BigInt totalSementara,
      WalletModel wallet,
    ) {
      return totalSementara + wallet.amount;
    });
    final BigInt totalEWallet = eWallet.fold(BigInt.zero, (
      BigInt totalSementara,
      WalletModel wallet,
    ) {
      return totalSementara + wallet.amount;
    });
    final BigInt totalPlatform = platform.fold(BigInt.zero, (
      BigInt totalSementara,
      WalletModel wallet,
    ) {
      return totalSementara + wallet.amount;
    });

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

              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceVariant,
                    child: FaIcon(
                      FontAwesomeIcons.buildingColumns,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  title: Text(
                    HomeDict.bankAccount.get(isRpg),
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: Text(
                    CurrencyFormatter.convertToIdr(totalBank),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  children: [
                    ...bank.asMap().entries.map((entry) {
                      return _buildSubWalletItem(
                        name: entry.value.name,
                        amount: entry.value.amount,
                      );
                    }),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 16),

              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceVariant,
                    child: FaIcon(
                      FontAwesomeIcons.wallet,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  title: Text(
                    HomeDict.eWallet.get(isRpg),
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: Text(
                    CurrencyFormatter.convertToIdr(totalEWallet),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  children: [
                    ...eWallet.asMap().entries.map((entry) {
                      return _buildSubWalletItem(
                        name: entry.value.name,
                        amount: entry.value.amount,
                      );
                    }),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 16),

              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceVariant,
                    child: FaIcon(
                      FontAwesomeIcons.mobileScreen,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  title: Text(
                    HomeDict.platform.get(isRpg),
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: Text(
                    CurrencyFormatter.convertToIdr(totalPlatform),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  children: [
                    ...platform.asMap().entries.map((entry) {
                      return _buildSubWalletItem(
                        name: entry.value.name,
                        amount: entry.value.amount,
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
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
