import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class CustomTable extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  final Color? color;
  final Color? borderColor;

  const CustomTable({
    super.key,
    this.color,
    this.padding,
    this.decoration,
    this.borderColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration:
          decoration ??
          BoxDecoration(
            color: color?.withOpacity(0.05) ?? AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  borderColor?.withOpacity(0.3) ??
                  (color?.withOpacity(0.3) ??
                      AppColors.primary.withOpacity(0.3)),
            ),
          ),
      child: Column(children: children),
    );
  }
}

class CustomRowTable extends StatelessWidget {
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final TextAlign? labelAlign;
  final TextAlign? valueAlign;
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;
  final bool boldValue;

  const CustomRowTable({
    super.key,
    required this.label,
    required this.value,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.labelStyle,
    this.valueStyle,
    this.labelAlign,
    this.valueAlign,
    this.labelColor,
    this.valueColor,
    this.boldValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.spaceBetween,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: labelAlign ?? TextAlign.left,
          style:
              labelStyle ??
              TextStyle(
                fontSize: 14,
                color: labelColor ?? AppColors.textSecondary,
              ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: valueAlign ?? TextAlign.right,
            style:
                valueStyle ??
                TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: boldValue ? 16 : 14,
                  fontWeight: boldValue ? FontWeight.bold : FontWeight.normal,
                  color: valueColor ?? AppColors.textPrimary,
                ),
          ),
        ),
      ],
    );
  }
}
