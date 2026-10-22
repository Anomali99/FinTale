import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../models/bill_model.dart';
import 'bill_card.dart';

class BillsTab extends StatelessWidget {
  final bool isRpg;
  final List<BillModel> data;
  final Function(BillModel) onTapCard;

  const BillsTab({
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
              ScreenDict.addBill.icon(isRpg),
              size: 48,
              color: colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 16),
            Text(
              UiDict.getEmptyDesc(
                ScreenDict.billsMaster.get(isRpg).toLowerCase(),
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
        return BillCard(data: item, isRpg: isRpg, onTap: () => onTapCard(item));
      },
    );
  }
}
