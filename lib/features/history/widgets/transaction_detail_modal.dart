import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/invest_controller.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/category_dict.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/enum_types.dart';
import '../../../core/utils/number_utils.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../models/assets_model.dart';
import '../../../models/transaction_detail_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/wallet_model.dart';

class TransactionDetailModal extends StatelessWidget {
  final TransactionModel transaction;
  final bool isRpg;

  const TransactionDetailModal({
    super.key,
    required this.transaction,
    required this.isRpg,
  });

  @override
  Widget build(BuildContext context) {
    final walletController = context.read<WalletController>();
    final investController = context.read<InvestController>();
    final colorScheme = Theme.of(context).colorScheme;
    final wallet = walletController.getWalletById(transaction.walletId);
    final status = CategoryDict.getStatusByEnum(transaction.status);
    WalletModel? walletTarget;
    AssetsModel? asset;

    if (transaction.targetId != null) {
      walletTarget = walletController.getWalletById(transaction.targetId!);
    }

    if (transaction.assetsId != null &&
        transaction.type == TransactionType.income) {
      asset = investController.getAssetById(transaction.assetsId!);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),

            CircleAvatar(
              radius: 28,
              backgroundColor: transaction.type.bgColor,
              child: FaIcon(
                CategoryDict.getByTransactionCategory(
                  transaction.detailTransaction[0].category,
                ).icon(isRpg),
                color: transaction.type.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              transaction.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            Text(
              '${transaction.type.prefix} ${NumberUtils.toIdr(transaction.amount)}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: transaction.type.color,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ScreenDict.historyTime.get(isRpg),
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            TimeFormatter.formatShortWithHour(
                              transaction.dateTimestamp,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            UiDict.status,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: status.color?.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.get(isRpg).toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: status.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Colors.white10, height: 1),
                  ),

                  if (transaction.assetsId != null &&
                      transaction.type == TransactionType.income &&
                      asset != null) ...[
                    _buildWalletRow(
                      context,
                      label: UiDict.sourceFunds,
                      value: asset.name,
                      icon: asset.typeDict.icon(isRpg),
                    ),
                    const SizedBox(height: 12),
                  ],

                  _buildWalletRow(
                    context,
                    label: transaction.type == TransactionType.income
                        ? UiDict.saveTo
                        : transaction.type == TransactionType.transfer
                        ? UiDict.originWallet
                        : UiDict.sourceFunds,
                    value: wallet.name,
                    icon: wallet.icon,
                  ),

                  if (transaction.type == TransactionType.transfer &&
                      walletTarget != null) ...[
                    const SizedBox(height: 12),
                    _buildWalletRow(
                      context,
                      label: UiDict.destinationWallet,
                      value: walletTarget.name,
                      icon: walletTarget.icon,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ScreenDict.breakdownDetail,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),

            ...transaction.detailTransaction.map(
              (detail) => _buildDetailItem(context, detail),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletRow(
    BuildContext context, {
    required String label,
    required String value,
    required FaIconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            FaIcon(icon, size: 14, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(BuildContext context, TransactionDetailModel detail) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                FaIcon(
                  CategoryDict.getByTransactionCategory(
                    detail.category,
                  ).icon(isRpg),
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    detail.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${detail.flow.prefix} ${NumberUtils.toIdr(detail.amount)}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: detail.flow.color,
            ),
          ),
        ],
      ),
    );
  }
}
