import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/category_dict.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/color_extension.dart';
import '../../../core/utils/number_utils.dart';
import '../../../models/bill_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_table.dart';

enum BillActionType { payDirect, generateDraft, edit }

class BillDetailModal extends StatelessWidget {
  final BillModel bill;
  final bool isRpg;

  const BillDetailModal({super.key, required this.bill, this.isRpg = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color mainColor = bill.tier.color.adapt(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    bill.debtId == null
                        ? CategoryDict.utilities.icon(isRpg)
                        : CategoryDict.debtInstallment.icon(isRpg),
                    size: 28,
                    color: mainColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: mainColor.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              bill.tier.rank,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!bill.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.onSurfaceVariant.withOpacity(
                                  0.2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'NONAKTIF',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bill.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomTable(
              color: colorScheme.surfaceContainerHighest,
              borderColor: mainColor,
              children: [
                CustomRowTable(
                  label: ScreenDict.billAmount.get(isRpg),
                  value: NumberUtils.toIdr(bill.amount),
                  valueColor: colorScheme.onSurface,
                  boldValue: true,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    color: colorScheme.onSurface.withOpacity(0.1),
                    height: 1,
                  ),
                ),
                CustomRowTable(
                  label: ScreenDict.billType.get(isRpg),
                  value: bill.getScheduleTitle(),
                ),
                const SizedBox(height: 12),
                CustomRowTable(
                  label: ScreenDict.nextBill.get(isRpg),
                  value: bill.nextDueDate != null
                      ? DateFormat('dd MMM yyyy').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            bill.nextDueDate!,
                          ),
                        )
                      : UiDict.noDate,
                  valueColor: colorScheme.primary,
                  boldValue: true,
                ),
                const SizedBox(height: 12),
                CustomRowTable(
                  label: ScreenDict.billTypes.get(isRpg),
                  value: ScreenDict.getBillTypes(
                    isBillDebt: bill.debtId != null,
                    isRpg: isRpg,
                  ),
                  valueColor: bill.debtId != null
                      ? colorScheme.error
                      : Colors.blueAccent.adapt(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (bill.isActive) ...[
              CustomButton(
                title: ScreenDict.getPayBill(isRpg: isRpg),
                color: colorScheme.primary,
                onTap: () {
                  Navigator.pop(context, BillActionType.payDirect);
                },
              ),
              const SizedBox(height: 12),

              CustomButton(
                title: ScreenDict.generatBill.get(isRpg),
                color: Colors.orange.adapt(context),
                onTap: () {
                  Navigator.pop(context, BillActionType.generateDraft);
                },
              ),
              const SizedBox(height: 12),
            ] else ...[
              Center(
                child: Text(
                  ScreenDict.billWarning.get(isRpg),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.error, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: BorderSide(color: colorScheme.onSurfaceVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, BillActionType.edit);
                },
                child: Text(
                  UiDict.getEdit(ScreenDict.billsMaster.get(isRpg)),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
