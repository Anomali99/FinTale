import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/bills_dict.dart';
import '../../../models/debt_model.dart';
import 'debts_card.dart';

class DebtsTab extends StatelessWidget {
  final bool isRpg;
  final List<DebtModel> data;

  const DebtsTab({super.key, required this.data, required this.isRpg});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              BillsDict.addDebt.icon(isRpg),
              size: 48,
              color: AppColors.surfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Empty ${BillsDict.debts.get(isRpg)}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        for (DebtModel item in data) DebtsCard(data: item, isRpg: isRpg),
        const SizedBox(height: 100),
      ],
    );
  }
}
