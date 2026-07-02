import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CustomColors.primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: CustomColors.lightGreyScaffold,
      appBarTheme: const AppBarTheme(
        backgroundColor: CustomColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: CustomColors.primaryColor,
        unselectedItemColor: Colors.grey,
      ),
      cardColor: Colors.white,
      dividerColor: Colors.grey.shade200,
      useMaterial3: false,
    );
  }

  static ThemeData dark() {
    const surface = Color(0xFF1E1E1E);
    const card    = Color(0xFF2A2A2A);
    const bg      = Color(0xFF121212);

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CustomColors.primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: CustomColors.primaryColor,
        unselectedItemColor: Colors.grey.shade500,
      ),
      cardColor: card,
      dividerColor: Colors.grey.shade800,
      useMaterial3: false,
    );
  }
}