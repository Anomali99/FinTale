import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_dict.dart';
import '../../../core/constants/status_dict.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../models/transaction_model.dart';

extension StatusTypeUI on StatusType {
  Color get cardColor {
    switch (this) {
      case StatusType.paid:
        return AppColors.surfaceVariant.withOpacity(0.5);
      case StatusType.pending:
      case StatusType.overdue:
        return AppColors.surfaceVariant;
    }
  }

  Color get textColor {
    switch (this) {
      case StatusType.paid:
        return AppColors.textSecondary;
      case StatusType.pending:
      case StatusType.overdue:
        return AppColors.textPrimary;
    }
  }

  Color get accentColor {
    switch (this) {
      case StatusType.paid:
        return AppColors.success;
      case StatusType.pending:
        return AppColors.primary;
      case StatusType.overdue:
        return AppColors.error;
    }
  }
}

class BillCard extends StatelessWidget {
  final bool isRpg;
  final TransactionModel data;
  final bool isCleared;

  const BillCard({
    super.key,
    required this.data,
    required this.isRpg,
    this.isCleared = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: data.status.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.status.accentColor.withOpacity(isCleared ? 0.2 : 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          /* TODO: Buka BottomSheet Detail / Edit Tagihan */
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: data.status.accentColor.withOpacity(0.2),
                child: FaIcon(
                  CategoryDict.getByTransactionCategory(
                    data.detailTransaction[0].category,
                  ).icon(isRpg),
                  color: data.status.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: data.status.textColor,
                              decoration: isCleared
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      TimeFormatter.formatShort(data.dateTimestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: isCleared
                            ? AppColors.textSecondary
                            : data.status.accentColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              if (isCleared) ...[
                FaIcon(
                  StatusDict.paid.icon(isRpg),
                  color: AppColors.success,
                  size: 28,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
