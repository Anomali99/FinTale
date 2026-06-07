import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/enum_types.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../models/transaction_model.dart';

class ActiveBillCard extends StatelessWidget {
  final bool isRpg;
  final TransactionModel data;
  final VoidCallback? onTap;
  const ActiveBillCard({
    super.key,
    required this.data,
    required this.isRpg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCleared = data.status == StatusType.paid;
    final color = data.status.accentColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: data.status.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(isCleared ? 0.2 : 0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: FaIcon(
                  data.detailTransaction[0].category.categoryDict.icon(isRpg),
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
                        color: isCleared ? AppColors.textSecondary : color,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              FaIcon(
                data.status.categoryDict.icon(isRpg),
                color: color,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
