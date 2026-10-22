import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../models/debt_model.dart';
import 'debts_card.dart';

class DebtsTab extends StatelessWidget {
  final bool isRpg;
  final List<DebtModel> data;
  final Function(DebtModel) onTapCard;

  const DebtsTab({
    super.key,
    required this.data,
    required this.onTapCard,
    required this.isRpg,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              ScreenDict.addDebt.icon(isRpg),
              size: 48,
              color: colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 16),
            Text(
              UiDict.getEmptyDesc(
                ScreenDict.debtsMaster.get(isRpg).toLowerCase(),
                isRpg: isRpg,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return DebtsCard(
          data: item,
          isRpg: isRpg,
          onTap: () => onTapCard(item),
        );
      },
    );
  }
}
