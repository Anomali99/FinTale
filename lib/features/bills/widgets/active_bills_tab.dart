import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/category_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/enum_types.dart';
import '../../../models/transaction_model.dart';
import 'active_bill_card.dart';

class ActiveBillsTab extends StatelessWidget {
  final bool isRpg;
  final Function(TransactionModel) onTap;
  final List<TransactionModel> data;

  const ActiveBillsTab({
    super.key,
    required this.data,
    required this.onTap,
    required this.isRpg,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          CategoryDict.statusPending.get(isRpg).toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        if (pending.isEmpty) ...[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    CategoryDict.statusPending.icon(isRpg),
                    size: 48,
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    UiDict.getEmptyDesc(
                      CategoryDict.statusPending.get(isRpg).toLowerCase(),
                      isRpg: isRpg,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          for (TransactionModel item in pending)
            ActiveBillCard(data: item, isRpg: isRpg, onTap: () => onTap(item)),
        ],

        const SizedBox(height: 32),

        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white10)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                CategoryDict.statusPaid.get(isRpg).toUpperCase(),
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
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    CategoryDict.statusPaid.icon(isRpg),
                    size: 48,
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    UiDict.getEmptyDesc(
                      CategoryDict.statusPaid.get(isRpg).toLowerCase(),
                      isRpg: isRpg,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          for (TransactionModel item in paid)
            ActiveBillCard(data: item, isRpg: isRpg),
        ],

        const SizedBox(height: 100),
      ],
    );
  }
}
