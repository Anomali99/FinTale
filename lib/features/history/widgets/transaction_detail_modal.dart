import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_dict.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../core/utils/type_extension.dart';
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
    final wallet = walletController.getWalletById(transaction.walletId!);
    WalletModel? walletTarget;

    if (transaction.targetId != null) {
      walletTarget = walletController.getWalletById(transaction.targetId!);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
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
              backgroundColor: transaction.type.iconBgColor,
              child: FaIcon(
                CategoryDict.getByTransactionCategory(
                  transaction.detailTransaction[0].category,
                ).icon(isRpg),
                color: transaction.type.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              transaction.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            Text(
              '${transaction.type.prefix} ${CurrencyFormatter.convertToIdr(transaction.amount)}',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: transaction.type.iconColor,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
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
                          const Text(
                            'Waktu Petualangan',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            TimeFormatter.formatShort(
                              transaction.dateTimestamp,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: transaction.status == StatusType.paid
                                  ? AppColors.success.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              transaction.status.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: transaction.status == StatusType.paid
                                    ? AppColors.success
                                    : Colors.orange,
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

                  _buildWalletRow(
                    label: transaction.type == TransactionType.income
                        ? 'Disimpan ke'
                        : 'Dompet Asal',
                    value: wallet.name,
                    icon: wallet.icon,
                  ),

                  if (transaction.type == TransactionType.transfer) ...[
                    const SizedBox(height: 12),
                    _buildWalletRow(
                      label: 'Dompet Tujuan',
                      value: walletTarget?.name ?? '',
                      icon:
                          walletTarget?.icon ??
                          FontAwesomeIcons.buildingColumns,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Rincian Item (Breakdown)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            ...transaction.detailTransaction.map(
              (detail) => _buildDetailItem(detail),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletRow({
    required String label,
    required String value,
    required FaIconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            FaIcon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(TransactionDetailModel detail) {
    Color flowColor = detail.flow == FlowType.income
        ? AppColors.success
        : AppColors.error;
    String flowPrefix = detail.flow == FlowType.income ? '+ ' : '- ';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              FaIcon(
                CategoryDict.getByTransactionCategory(
                  detail.category,
                ).icon(isRpg),
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                detail.title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Text(
            '$flowPrefix${CurrencyFormatter.convertToIdr(detail.amount)}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: flowColor,
            ),
          ),
        ],
      ),
    );
  }
}
