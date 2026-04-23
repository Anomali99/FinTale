import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/bills_dict.dart';
import '../../../models/bill_model.dart';
import 'template_card.dart';

class TemplateTab extends StatelessWidget {
  final bool isRpg;
  final List<BillModel> data;

  const TemplateTab({super.key, required this.data, required this.isRpg});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              BillsDict.addTemplate.icon(isRpg),
              size: 48,
              color: AppColors.surfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Empty ${BillsDict.template.get(isRpg)}',
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
        for (BillModel item in data) TemplateCard(data: item, isRpg: isRpg),
        const SizedBox(height: 100),
      ],
    );
  }
}
