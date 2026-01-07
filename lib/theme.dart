import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFD62828); // vermelho destacado
  static const dark = Color(0xFF1F1F1F);
}

ThemeData buildTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    useMaterial3: true,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(height: 1.3),
    ),
  );
}
