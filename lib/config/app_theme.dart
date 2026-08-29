/// Material tema — renk ve punto [AppColors] / [AppType] üzerinden gelir.
library;

import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const colors = ColorScheme.dark(
      surface: AppColors.background,
      primary: AppColors.accent,
      onPrimary: AppColors.background,
      onSurface: AppColors.text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colors,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkRipple.splashFactory,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.text,
          fontWeight: AppType.displayWeight,
          letterSpacing: AppType.displayTracking,
          fontSize: AppType.display,
          height: AppType.displayHeight,
        ),
        titleLarge: TextStyle(
          color: AppColors.text,
          fontWeight: AppType.titleWeight,
          fontSize: AppType.title,
        ),
        bodyLarge: TextStyle(
          color: AppColors.text,
          fontWeight: AppType.bodyWeight,
          fontSize: AppType.body,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textMuted,
          fontWeight: AppType.bodyWeight,
          fontSize: AppType.bodyMuted,
        ),
        labelLarge: TextStyle(
          color: AppColors.background,
          fontWeight: AppType.buttonWeight,
          letterSpacing: AppType.buttonTracking,
          fontSize: AppType.button,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.background
              : AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.text
              : AppColors.surface;
        }),
      ),
    );
  }
}
