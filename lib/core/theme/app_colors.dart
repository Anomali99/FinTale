import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryDark = Color(0xFFFFD700);
  static const Color primaryLight = Color(0xFFD4AF37);

  static const Color bgDark = Color(0xFF1A1A1A);
  static const Color surfaceDark = Color(0xFF252525);
  static const Color surfaceVariantDark = Color(0xFF333333);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xB3FFFFFF);

  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFE0E0E0);
  static const Color textLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF757575);

  static const Color successDark = Color(0xFF4CAF50);
  static const Color warningDark = Color(0xFFFF9800);

  static const Color successLight = Color(0xFF2E7D32);
  static const Color warningLight = Color(0xFFE65100);

  static Color getSuccess(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? successLight
      : successDark;

  static Color getWarning(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? warningLight
      : warningDark;

  static const Color error = Color(0xFFEF5350);
}
