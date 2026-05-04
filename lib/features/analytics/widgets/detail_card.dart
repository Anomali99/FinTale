import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/analytic_model.dart';
import '../../../core/utils/currency_formatter.dart';

class DetailCard extends StatelessWidget {
  final AnalyticModel data;
  final double percentage;
  final bool isSelected;
  final bool isRpg;

  const DetailCard({
    super.key,
    required this.data,
    required this.percentage,
    required this.isSelected,
    required this.isRpg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? data.color.withOpacity(0.1)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? data.color.withOpacity(0.5) : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: data.color.withOpacity(0.2),
                child: FaIcon(data.icon(isRpg), color: data.color, size: 14),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  data.get(isRpg),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                CurrencyFormatter.convertToIdr(data.amount),
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: data.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: AppColors.background,
                    color: data.color,
                    minHeight: 6,
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
