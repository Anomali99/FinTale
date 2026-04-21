import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class MonthFilter extends StatelessWidget {
  final String selected;
  const MonthFilter({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
          onPressed: () {
            /* Mundur 1 Bulan */
          },
        ),
        Text(
          selected,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onPressed: () {
            /* Maju 1 Bulan */
          },
        ),
      ],
    );
  }
}
