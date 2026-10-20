import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      primaryColor: AppColors.primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: Colors.black,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textDark,
        surfaceContainerHighest: AppColors.surfaceVariantDark,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryDark),
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.textDark),
        bodySmall: TextStyle(color: AppColors.textSecondaryDark),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        constraints: BoxConstraints(maxWidth: 600),
      ),
      dialogTheme: const DialogThemeData(
        constraints: BoxConstraints(maxWidth: 600),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      primaryColor: AppColors.primaryLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        onPrimary: Colors.white,
        secondary: Color(0xFFDAC07A), // muted gold for accents/chips
        onSecondary: Color(0xFF3E2C00),
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textLight,
        surfaceContainerHighest: AppColors.surfaceVariantLight,
        onSurfaceVariant: AppColors.textSecondaryLight,
        outline: Color(0xFFD4CBBE), // warm border color
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryLight),
        titleTextStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 1,
        shadowColor: const Color(0x1A000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.textLight),
        bodySmall: TextStyle(color: AppColors.textSecondaryLight),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        constraints: BoxConstraints(maxWidth: 600),
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: AppColors.surfaceLight,
        elevation: 8,
        shadowColor: Color(0x1A000000),
      ),
      dialogTheme: const DialogThemeData(
        constraints: BoxConstraints(maxWidth: 600),
      ),
    );
  }
}
