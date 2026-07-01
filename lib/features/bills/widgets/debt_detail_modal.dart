import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/category_dict.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/number_utils.dart';
import '../../../models/debt_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_table.dart';

enum DebtActionType { payDirect, payBill, edit }

class DebtDetailModal extends StatelessWidget {
  final DebtModel debt;
  final bool isRpg;

  const DebtDetailModal({super.key, required this.debt, this.isRpg = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.error.withOpacity(0.2),
                  child: FaIcon(
                    CategoryDict.getDebtByEnum(debt.type).icon(isRpg),
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lv. ${debt.level}',
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        debt.title,
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
              borderColor: AppColors.error,
              children: [
                CustomRowTable(
                  label: ScreenDict.debtRemaining.get(isRpg),
                  value: NumberUtils.toIdr(debt.currentDebt),
                  valueColor: AppColors.error,
                  boldValue: true,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                CustomRowTable(
                  label: ScreenDict.debtAmount.get(isRpg),
                  value: NumberUtils.toIdr(debt.amount),
                ),
                const SizedBox(height: 8),
                CustomRowTable(
                  label: ScreenDict.debtPayAmount.get(isRpg),
                  value: NumberUtils.toIdr(debt.paidAmount),
                  valueColor: AppColors.success,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: debt.debtPercentage(isRpg),
                    backgroundColor: theme.scaffoldBackgroundColor,
                    color: AppColors.success,
                    minHeight: 8,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (debt.bill != null) ...[
              Text(
                ScreenDict.debtBill.get(isRpg),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              CustomTable(
                color: colorScheme.primary,
                children: [
                  CustomRowTable(
                    label: ScreenDict.debtBillAmount.get(isRpg),
                    value: NumberUtils.toIdr(debt.bill!.amount),
                    boldValue: true,
                  ),
                  const SizedBox(height: 8),
                  CustomRowTable(
                    label: ScreenDict.billType.get(isRpg),
                    value: debt.bill!.type.name.toUpperCase(),
                  ),
                  const SizedBox(height: 8),
                  CustomRowTable(
                    label: ScreenDict.nextBill.get(isRpg),
                    value: debt.bill!.nextDueDate != null
                        ? DateFormat('dd MMM yyyy').format(
                            DateTime.fromMillisecondsSinceEpoch(
                              debt.bill!.nextDueDate!,
                            ),
                          )
                        : UiDict.noDate,
                    valueColor: colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            if (!debt.isFinished) ...[
              if (debt.bill != null && debt.bill!.isActive) ...[
                CustomButton(
                  title: ScreenDict.getPayBill(
                    amount: NumberUtils.toIdr(debt.bill!.amount),
                    isRpg: isRpg,
                  ),
                  color: AppColors.success,
                  onTap: () {
                    Navigator.pop(context, DebtActionType.payBill);
                  },
                ),
                const SizedBox(height: 12),
              ],

              CustomButton(
                title: ScreenDict.getPayDebt(isCustom: true, isRpg: isRpg),
                color: colorScheme.primary,
                onTap: () {
                  Navigator.pop(context, DebtActionType.payDirect);
                },
              ),
              const SizedBox(height: 12),
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
                  Navigator.pop(context, DebtActionType.edit);
                },
                child: Text(
                  UiDict.getEdit(ScreenDict.debtsMaster.get(isRpg)),
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
