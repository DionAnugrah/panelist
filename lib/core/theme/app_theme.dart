import 'package:flutter/material.dart';

const _primaryRed = Color(0xFFE53935);

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryRed,
        brightness: Brightness.dark,
      ).copyWith(primary: _primaryRed),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: const Color(0xFF2A2A2A),
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryRed,
        brightness: Brightness.light,
      ).copyWith(primary: _primaryRed),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE0E0E0),
    );
  }
}
