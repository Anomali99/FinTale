import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/status_dict.dart';
import '../../../models/transaction_model.dart';
import 'bill_card.dart';

class BillsTab extends StatelessWidget {
  final bool isRpg;
  final List<TransactionModel> data;

  const BillsTab({super.key, required this.data, required this.isRpg});

  @override
  Widget build(BuildContext context) {
    List<TransactionModel> pending = [];
    List<TransactionModel> paid = [];

    for (TransactionModel item in data) {
      if (item.status == StatusType.paid) {
        paid.add(item);
      } else {
        pending.add(item);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          StatusDict.pending.get(isRpg).toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        if (pending.isEmpty) ...[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  StatusDict.pending.icon(isRpg),
                  size: 48,
                  color: AppColors.surfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Empty ${StatusDict.pending.get(isRpg)} items',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ] else ...[
          for (TransactionModel item in pending)
            BillCard(data: item, isRpg: isRpg),
        ],

        const SizedBox(height: 32),

        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white10)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                StatusDict.paid.get(isRpg).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white10)),
          ],
        ),
        const SizedBox(height: 12),

        if (paid.isEmpty) ...[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  StatusDict.paid.icon(isRpg),
                  size: 48,
                  color: AppColors.surfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Empty ${StatusDict.paid.get(isRpg)} items',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ] else ...[
          for (TransactionModel item in paid)
            BillCard(data: item, isRpg: isRpg, isCleared: true),
        ],

        const SizedBox(height: 100),
      ],
    );
  }
}
