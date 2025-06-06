import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - New Palette
  static const brandOrange = Color(0xFFE77503);
  static const brandDeepOrange = Color(0xFFC33608);
  
  // Green Gradient Colors
  static const greenLime = Color(0xFF8EB123);
  static const greenTeal = Color(0xFF23A88B);
  static const deepTeal = Color(0xFF148686);
  static const deepGreenTeal = Color(0xFF148A68);
  static const mediumGreen = Color(0xFF4EA244);

  // Neutral Colors
  static const neutralLightGray = Color(0xFFF3F4F6);
  static const neutralDarkGray = Color(0xFF374151);

  // Dark Theme Colors
  static const darkBg = Color(0xFF1B1B1B);
  static const bgGlass = Color(0xE61B1B1B);

  // Text Colors
  static const textPrimary = Color(0xFFF8F9FA);
  static const textDark = Color(0xFF2D2D2D);

  // Legacy color names kept for compatibility
  // These now point to the new color palette
  static const brandDeepGold = brandDeepOrange;
  static const brandWarmOrange = brandOrange;
  static const neonCyan = greenTeal;
  static const neonPurple = deepTeal;
  
  // Card Colors
  static const darkBgCard = Color(0x1A23A88B); // Using greenTeal with opacity
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        primaryColor: AppColors.brandOrange,
        colorScheme: const ColorScheme.light(
          primary: AppColors.brandOrange,
          secondary: AppColors.brandDeepOrange,
          tertiary: AppColors.greenLime,
          background: AppColors.neutralLightGray,
          surface: AppColors.neutralLightGray,
          onPrimary: AppColors.textPrimary,
          onSecondary: AppColors.textPrimary,
          onBackground: AppColors.textDark,
          onSurface: AppColors.textDark,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.neutralLightGray,
          selectedItemColor: AppColors.brandWarmOrange,
          unselectedItemColor: AppColors.neutralDarkGray.withOpacity(0.5),
          elevation: 0,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        primaryColor: AppColors.neonCyan,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonCyan,
          secondary: AppColors.neonPurple,
          background: AppColors.darkBg,
          surface: AppColors.darkBg,
          onPrimary: AppColors.textPrimary,
          onSecondary: AppColors.textPrimary,
          onBackground: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkBg,
          selectedItemColor: AppColors.neonCyan,
          unselectedItemColor: AppColors.textPrimary.withOpacity(0.5),
          elevation: 0,
        ),
      );
}