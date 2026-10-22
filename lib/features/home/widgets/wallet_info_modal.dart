import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/enum_types.dart';
import '../../../core/utils/number_utils.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_table.dart';

class WalletInfoModal extends StatelessWidget {
  final WalletModel wallet;
  final bool lock;

  const WalletInfoModal({super.key, required this.wallet, this.lock = false});

  @override
  Widget build(BuildContext context) {
    final isRpg = context.read<SettingsController>().isRpgMode;
    final walletController = context.read<WalletController>();
    final colorScheme = Theme.of(context).colorScheme;
    final pockets = walletController.getPocketsForWallet(wallet.id ?? 0);
    final hasPockets = pockets.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: hasPockets ? 0.55 : 0.35,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(24.0),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    child: FaIcon(
                      wallet.icon,
                      size: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wallet.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _walletTypeLabel(wallet.type, isRpg),
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (hasPockets)
                _buildPocketBreakdown(
                  context: context,
                  walletController: walletController,
                  pockets: pockets,
                )
              else
                _buildSimpleBalance(context),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context, {
                        'action': 'edit',
                        'wallet': wallet,
                      }),
                      icon: Icon(
                        Icons.edit,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      label: Text(
                        UiDict.getEdit(UiDict.wallet),
                        style: TextStyle(color: colorScheme.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context, {
                        'action': 'add_pocket',
                        'parentId': wallet.id,
                      }),
                      icon: Icon(
                        Icons.add,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      label: Text(
                        ScreenDict.addPocket,
                        style: TextStyle(color: colorScheme.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimpleBalance(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomTable(
      color: colorScheme.primary,
      borderColor: colorScheme.primary,
      children: [
        CustomRowTable(
          label: UiDict.balance,
          value: NumberUtils.toIdr(
            wallet.amount,
            decimalDigits: wallet.type == WalletType.platform ? 3 : null,
          ),
          boldValue: true,
        ),
      ],
    );
  }

  Widget _buildPocketBreakdown({
    required BuildContext context,
    required WalletController walletController,
    required List<WalletModel> pockets,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = walletController.getParentTotalBalance(wallet.id ?? 0);

    Decimal savingsTotal = Decimal.zero;
    Decimal nonSavingsTotal = Decimal.zero;

    if (wallet.isSavings) {
      savingsTotal += wallet.amount;
    } else {
      nonSavingsTotal += wallet.amount;
    }

    for (final pocket in pockets) {
      if (pocket.isSavings) {
        savingsTotal += pocket.amount;
      } else {
        nonSavingsTotal += pocket.amount;
      }
    }

    return CustomTable(
      color: colorScheme.primary,
      borderColor: colorScheme.primary,
      children: [
        _buildPocketRow(
          context: context,
          label: ScreenDict.mainPocket,
          amount: wallet.amount,
          isSavings: wallet.isSavings,
          isEmergency: wallet.isEmergency,
          isPlatform: wallet.type == WalletType.platform,
        ),

        const SizedBox(height: 4),

        for (final pocket in pockets) ...[
          _buildPocketRow(
            context: context,
            label: pocket.name,
            amount: pocket.amount,
            isSavings: pocket.isSavings,
            isEmergency: pocket.isEmergency,
            isPlatform: wallet.type == WalletType.platform,
            onEdit: () =>
                Navigator.pop(context, {'action': 'edit', 'wallet': pocket}),
          ),
          const SizedBox(height: 4),
        ],

        Divider(
          color: colorScheme.onSurface.withValues(alpha: 0.15),
          height: 16,
        ),

        CustomRowTable(
          label: ScreenDict.subTotalNonSavings,
          value: NumberUtils.toIdr(
            nonSavingsTotal,
            decimalDigits: wallet.type == WalletType.platform ? 3 : null,
          ),
        ),
        const SizedBox(height: 4),
        CustomRowTable(
          label: ScreenDict.subTotalSavings,
          value: NumberUtils.toIdr(
            savingsTotal,
            decimalDigits: wallet.type == WalletType.platform ? 3 : null,
          ),
        ),

        Divider(
          color: colorScheme.onSurface.withValues(alpha: 0.15),
          height: 16,
        ),

        CustomRowTable(
          label: UiDict.total,
          value: NumberUtils.toIdr(
            total,
            decimalDigits: wallet.type == WalletType.platform ? 3 : null,
          ),
          boldValue: true,
        ),
      ],
    );
  }

  Widget _buildPocketRow({
    required BuildContext context,
    required String label,
    required Decimal amount,
    required bool isSavings,
    required bool isEmergency,
    bool isPlatform = false,
    VoidCallback? onEdit,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSavings) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.savings_outlined,
                  size: 14,
                  color: colorScheme.primary,
                ),
              ],
              if (isEmergency) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.shield_outlined,
                  size: 14,
                  color: colorScheme.primary,
                ),
              ],
              if (onEdit != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onEdit,
                  child: Icon(
                    Icons.edit,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          NumberUtils.toIdr(amount, decimalDigits: isPlatform ? 3 : null),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _walletTypeLabel(WalletType type, bool isRpg) {
    switch (type) {
      case WalletType.cash:
        return ScreenDict.walletCash.get(isRpg);
      case WalletType.bank:
        return ScreenDict.walletBank.get(isRpg);
      case WalletType.eWallet:
        return ScreenDict.walletEwallet.get(isRpg);
      case WalletType.platform:
        return ScreenDict.walletPlatform.get(isRpg);
    }
  }
}
