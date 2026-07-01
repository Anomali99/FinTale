import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (enabled)
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: onPrev == null
                  ? colorScheme.onSurfaceVariant.withOpacity(0.3)
                  : colorScheme.onSurfaceVariant,
            ),
            onPressed: onPrev,
          )
        else
          SizedBox(),
        Text(
          selected,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        if (enabled)
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: onNext == null
                  ? colorScheme.onSurfaceVariant.withOpacity(0.3)
                  : colorScheme.onSurfaceVariant,
            ),
            onPressed: onNext,
          )
        else
          SizedBox(),
      ],
    );
  }
}
