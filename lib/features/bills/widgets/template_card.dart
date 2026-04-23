import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_dict.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/bill_model.dart';

class TemplateCard extends StatelessWidget {
  final bool isRpg;
  final BillModel data;

  const TemplateCard({super.key, required this.data, required this.isRpg});

  String _getScheduleText() {
    switch (data.type) {
      case TimeType.daily:
        return 'Setiap Hari';
      case TimeType.weekly:
        String dayNameStr = data.dayName?.name ?? '';
        if (dayNameStr.isNotEmpty) {
          dayNameStr = dayNameStr[0].toUpperCase() + dayNameStr.substring(1);
        }
        return 'Mingguan (Setiap $dayNameStr)';
      case TimeType.monthly:
        return 'Bulanan (Tgl ${data.day ?? '-'})';
      case TimeType.annual:
        return 'Tahunan (Tgl ${data.day ?? '-'} Bln ${data.month ?? '-'})';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = data.tier.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mainColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              data.debtId == null
                  ? CategoryDict.utilities.icon(isRpg)
                  : CategoryDict.debtInstallment.icon(isRpg),
              size: 20,
              color: mainColor,
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        _getScheduleText(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.convertToIdr(data.amount),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data.tier.title,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: mainColor.withOpacity(0.5)),
                ),
                child: Text(
                  data.tier.rank,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
