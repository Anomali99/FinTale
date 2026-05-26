import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_dict.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/currency_formatter.dart';
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            CustomTable(
              color: AppColors.surfaceVariant,
              borderColor: AppColors.error,
              children: [
                CustomRowTable(
                  label: ScreenDict.debtRemaining.get(isRpg),
                  value: CurrencyFormatter.convertToIdr(debt.currentDebt),
                  valueColor: AppColors.error,
                  boldValue: true,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                CustomRowTable(
                  label: ScreenDict.debtAmount.get(isRpg),
                  value: CurrencyFormatter.convertToIdr(debt.amount),
                ),
                const SizedBox(height: 8),
                CustomRowTable(
                  label: ScreenDict.debtPayAmount.get(isRpg),
                  value: CurrencyFormatter.convertToIdr(debt.paidAmount),
                  valueColor: AppColors.success,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: debt.debtPercentage(isRpg),
                    backgroundColor: AppColors.background,
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
                color: AppColors.primary,
                children: [
                  CustomRowTable(
                    label: ScreenDict.debtBillAmount.get(isRpg),
                    value: CurrencyFormatter.convertToIdr(debt.bill!.amount),
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
                    valueColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            if (!debt.isFinished) ...[
              if (debt.bill != null && debt.bill!.isActive) ...[
                CustomButton(
                  title: ScreenDict.getPayBill(
                    amount: CurrencyFormatter.convertToIdr(debt.bill!.amount),
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
                color: AppColors.primary,
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
                  side: const BorderSide(color: AppColors.textSecondary),
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
                    color: AppColors.textPrimary,
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
