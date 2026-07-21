import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/category_dict.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/color_extension.dart';
import '../../../core/utils/number_utils.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../models/receivable_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_table.dart';

class ReceivableDetailCard extends StatelessWidget {
  final ReceivableModel data;
  final VoidCallback? onPay;
  final VoidCallback? onEdit;
  final bool isRpg;
  const ReceivableDetailCard({
    super.key,
    required this.data,
    this.onPay,
    this.onEdit,
    this.isRpg = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: data.isFinished
              ? AppColors.getSuccess(context).withOpacity(0.3)
              : colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: data.isFinished
                        ? CategoryDict.statusPaid
                              .getColor(context)
                              .withOpacity(0.15)
                        : CategoryDict.statusOverdue
                              .getColor(context)
                              .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data.isFinished
                        ? CategoryDict.statusPaid.get(isRpg)
                        : CategoryDict.statusPending.get(isRpg),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: data.isFinished
                          ? CategoryDict.statusPaid.getColor(context)
                          : CategoryDict.statusOverdue.getColor(context),
                    ),
                  ),
                ),
                if (data.isReminderActive && !data.isFinished) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.adapt(context).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.solidBell,
                      size: 11,
                      color: Colors.blueAccent.adapt(context),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            if (data.isFinished) ...[
              CustomTable(
                color: colorScheme.surfaceContainerHighest,
                borderColor: AppColors.getSuccess(context),
                children: [
                  CustomRowTable(
                    label: ScreenDict.receivableTotal.get(isRpg),
                    value: NumberUtils.toIdr(data.amount),
                    valueColor: colorScheme.onSurface,
                    boldValue: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      color: colorScheme.onSurface.withOpacity(0.05),
                      height: 1,
                    ),
                  ),
                  CustomRowTable(
                    label: ScreenDict.receivableDate.get(isRpg),
                    value: TimeFormatter.formatShortWithHour(
                      data.dateTimestamp,
                    ),
                  ),
                  const SizedBox(height: 6),
                  CustomRowTable(
                    label: ScreenDict.receivableTarget.get(isRpg),

                    value: data.targetDate != null
                        ? TimeFormatter.formatShortWithHour(data.targetDate!)
                        : UiDict.noDate,
                    valueColor: AppColors.getSuccess(context),
                  ),
                ],
              ),
            ] else ...[
              CustomTable(
                color: colorScheme.surfaceContainerHighest,
                borderColor: colorScheme.primary,
                children: [
                  CustomRowTable(
                    label: ScreenDict.receivableRemaining.get(isRpg),
                    value: NumberUtils.toIdr(data.currentReceivable),
                    valueColor: colorScheme.primary,
                    boldValue: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      color: colorScheme.onSurface.withOpacity(0.05),
                      height: 1,
                    ),
                  ),
                  CustomRowTable(
                    label: ScreenDict.receivableTotal.get(isRpg),
                    value: NumberUtils.toIdr(data.amount),
                  ),
                  const SizedBox(height: 6),
                  CustomRowTable(
                    label: ScreenDict.receivablePayAmount.get(isRpg),
                    value: NumberUtils.toIdr(data.paidAmount),
                    valueColor: AppColors.getSuccess(context),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: data.returnPercentage,
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      color: AppColors.getSuccess(context),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.onSurface.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ScreenDict.receivableDate.get(isRpg),
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          TimeFormatter.formatShortWithHour(data.dateTimestamp),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ScreenDict.receivableTarget.get(isRpg),
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.targetDate != null
                              ? TimeFormatter.formatShortWithHour(
                                  data.targetDate!,
                                )
                              : UiDict.noDate,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Row(
                spacing: 10.0,
                children: [
                  Flexible(
                    child: CustomButton(
                      title: ScreenDict.recordPayment.get(isRpg),
                      color: AppColors.getSuccess(context),
                      onTap: onPay,
                    ),
                  ),
                  CustomButton(
                    icon: FontAwesomeIcons.pencil,
                    color: colorScheme.primary,
                    onTap: onEdit,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
