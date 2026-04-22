import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_dict.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../models/transaction_detail_model.dart';
import '../../../models/transaction_model.dart';
import 'transaction_card.dart';

class SectionHistory extends StatelessWidget {
  final bool isRpg;
  final String title;
  final List<TransactionModel> transactions;

  const SectionHistory({
    super.key,
    required this.title,
    required this.transactions,
    required this.isRpg,
  });

  String _generateSubtitle(TransactionModel data) {
    if (data.type == TransactionType.transfer) {
      String from = DummyData.wallets[(data.walletId ?? 1) - 1].name;
      String to = DummyData.wallets[(data.targetId ?? 1) - 1].name;
      return '$from ➔ $to';
    }

    if (data.type == TransactionType.expense ||
        data.type == TransactionType.debt) {
      String from = DummyData.wallets[(data.walletId ?? 1) - 1].name;
      return 'From: $from';
    }

    if (data.type == TransactionType.income) {
      if (data.assetsId != null) {
        String fromAsset = DummyData.assets[(data.assetsId ?? 1) - 1].name;
        return 'From: $fromAsset';
      }
      String toWallet = DummyData.wallets[(data.walletId ?? 1) - 1].name;
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
                    TransactionCategory category = data.detailTransaction
                        .reduce(
                          (curr, next) =>
                              curr.amount > next.amount ? curr : next,
                        )
                        .category;

                    FaIconData icon = CategoryDict.getByTransactionCategory(
                      category,
                    ).icon(isRpg);

                    return TransactionCard(
                      type: data.type,
                      title: data.title,
                      subtitle: _generateSubtitle(data),
                      amount: data.amount,
                      icon: icon,
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
