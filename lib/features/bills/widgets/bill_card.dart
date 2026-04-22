import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/bills_dict.dart';
import '../../../core/utils/currency_formatter.dart';

class BillCard extends StatelessWidget {
  final bool isRpg;
  final String title;
  final String dueDate;
  final double amount;
  final FaIconData icon;
  final bool isUrgent;
  final bool isCleared;

  const BillCard({
    super.key,
    required this.title,
    required this.dueDate,
    required this.amount,
    required this.icon,
    required this.isUrgent,
    required this.isCleared,
    required this.isRpg,
  });

  Color get cardColor => isCleared
      ? AppColors.surfaceVariant.withOpacity(0.5)
      : AppColors.surfaceVariant;

  Color get textColor =>
      isCleared ? AppColors.textSecondary : AppColors.textPrimary;

  Color get accentColor => isCleared
      ? AppColors.success
      : (isUrgent ? AppColors.error : AppColors.primary);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(isCleared ? 0.2 : 0.5),
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
                backgroundColor: accentColor.withOpacity(0.2),
                child: FaIcon(icon, color: accentColor, size: 20),
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
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
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
                      dueDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCleared
                            ? AppColors.textSecondary
                            : accentColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              if (!isCleared) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.convertToIdr(amount),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          /* TODO: Logika Pembayaran */
                        },
                        icon: FaIcon(BillsDict.pay.icon(isRpg), size: 12),
                        label: Text(
                          BillsDict.pay.get(isRpg),
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor.withOpacity(0.2),
                          foregroundColor: accentColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                FaIcon(
                  BillsDict.pay.icon(isRpg),
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
