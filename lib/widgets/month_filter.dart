import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class MonthFilter extends StatelessWidget {
  final String selected;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final bool enabled;

  const MonthFilter({
    super.key,
    required this.selected,
    this.enabled = true,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (enabled)
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: onPrev == null
                  ? AppColors.textSecondary.withOpacity(0.3)
                  : AppColors.textSecondary,
            ),
            onPressed: onPrev,
          )
        else
          SizedBox(),
        Text(
          selected,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (enabled)
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: onNext == null
                  ? AppColors.textSecondary.withOpacity(0.3)
                  : AppColors.textSecondary,
            ),
            onPressed: onNext,
          )
        else
          SizedBox(),
      ],
    );
  }
}
