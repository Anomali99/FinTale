import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_dict.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../models/transaction_model.dart';
import 'transaction_card.dart';

class SectionHistory extends StatelessWidget {
  final bool isRpg;
  final String title;
  final ValueChanged<TransactionModel?> onTap;
  final List<TransactionModel> transactions;

  const SectionHistory({
    super.key,
    required this.title,
    required this.transactions,
    required this.onTap,
    required this.isRpg,
  });

  String _generateSubtitle(BuildContext context, TransactionModel data) {
    final walletController = context.read<WalletController>();
    if (data.type == TransactionType.transfer) {
      String from = walletController.getWalletById(data.walletId ?? 1).name;
      String to = walletController.getWalletById(data.targetId ?? 1).name;
      return '$from ➔ $to';
    }

    if (data.type == TransactionType.expense ||
        data.type == TransactionType.debt) {
      String from = walletController.getWalletById(data.walletId ?? 1).name;
      return 'From: $from';
    }

    if (data.type == TransactionType.income) {
      if (data.assetsId != null) {
        String fromAsset = DummyData.assets[(data.assetsId ?? 1) - 1].name;
        return 'From: $fromAsset';
      }
      String toWallet = walletController.getWalletById(data.walletId ?? 1).name;
      return 'To: $toWallet';
    }

    return '-';
  }

  Widget _buildDateHeader(String dateText) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        bottom: 12.0,
        top: 8.0,
      ),
      child: Text(
        dateText,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateHeader(title),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              for (TransactionModel data in transactions)
                Builder(
                  builder: (context) {
                    FaIconData icon = CategoryDict.getByTransactionCategory(
                      data.detailTransaction[0].category,
                    ).icon(isRpg);

                    return TransactionCard(
                      type: data.type,
                      title: data.title,
                      subtitle: _generateSubtitle(context, data),
                      amount: data.amount,
                      icon: icon,
                      onTap: () => onTap(data),
                    );
                  },
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
