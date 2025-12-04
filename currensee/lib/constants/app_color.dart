import 'package:flutter/material.dart';

class AppColors {
  // Primary Blue Shades (Main Theme)
  static const Color primary = Color(0xFF1976D2);      // Main primary blue
  static const Color primaryDark = Color(0xFF0D47A1);  // Dark blue
  static const Color primaryLight = Color(0xFF42A5F5); // Light blue
  static const Color primaryExtraLight = Color(0xFFE3F2FD); // Very light blue

  // Secondary Blues
  static const Color secondary = Color(0xFF26A69A);    // Teal blue
  static const Color secondaryDark = Color(0xFF00897B);
  static const Color secondaryLight = Color(0xFF64FFDA);

  // Accent Colors
  static const Color accent = Color(0xFF448AFF);       // Bright blue accent
  static const Color accentDark = Color(0xFF2979FF);
  static const Color accentLight = Color(0xFF82B1FF);

  // Background Colors
  static const Color background = Color(0xFFF8FBFF);   // Very light blue background
  static const Color surface = Color(0xFFFFFFFF);      // White surface
  static const Color card = Color(0xFFE8F4FF);         // Light blue card background

  // Status Colors
  static const Color success = Color(0xFF4CAF50);      // Green
  static const Color warning = Color(0xFFFFC107);      // Amber
  static const Color error = Color(0xFFF44336);        // Red
  static const Color info = Color(0xFF2196F3);         // Info blue

  // Text Colors
  static const Color textPrimary = Color(0xFF1A237E);  // Dark blue text
  static const Color textSecondary = Color(0xFF37474F); // Dark gray-blue
  static const Color textDisabled = Color(0xFF78909C); // Gray-blue disabled

  // Grey Shades with Blue Tint
  static const Color grey = Color(0xFF90A4AE);         // Blue-grey
  static const Color greyLight = Color(0xFFCFD8DC);    // Light blue-grey
  static const Color greyDark = Color(0xFF546E7A);     // Dark blue-grey

  // Additional Blues
  static const Color blue50 = Color(0xFFE3F2FD);
  static const Color blue100 = Color(0xFFBBDEFB);
  static const Color blue200 = Color(0xFF90CAF9);
  static const Color blue300 = Color(0xFF64B5F6);
  static const Color blue400 = Color(0xFF42A5F5);
  static const Color blue500 = Color(0xFF2196F3);
  static const Color blue600 = Color(0xFF1E88E5);
  static const Color blue700 = Color(0xFF1976D2);
  static const Color blue800 = Color(0xFF1565C0);
  static const Color blue900 = Color(0xFF0D47A1);

  // Divider
  static const Color divider = Color(0xFFB3E5FC);      // Light blue divider
}

// Theme Data for your app (Updated for newer Flutter versions)
ThemeData getAppTheme() {
  return ThemeData(
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryDark,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
      brightness: Brightness.light,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme:  FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Card Theme
    cardTheme:  CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme:  InputDecorationTheme(
      filled: true,
      fillColor: AppColors.blue50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.blue200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.blue200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error),
      ),
      labelStyle: TextStyle(color: AppColors.textSecondary),
      hintStyle: TextStyle(color: AppColors.grey),
    ),

    // Text Theme (Updated for newer Flutter versions)
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textSecondary),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.textDisabled),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.primary,
      size: 24,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.blue100,
    ),

    // Chip Theme
    chipTheme:  ChipThemeData(
      backgroundColor: AppColors.blue50,
      labelStyle: TextStyle(color: AppColors.primary),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      secondarySelectedColor: AppColors.primary,
      selectedColor: AppColors.primaryLight,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // SnackBar Theme
    snackBarTheme:  SnackBarThemeData(
      backgroundColor: AppColors.primary,
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    ),
  );
}

// Alternative: Simple version that works with all Flutter versions
ThemeData getSimpleAppTheme() {
  return ThemeData(
    primaryColor: AppColors.primary,
    primaryColorDark: AppColors.primaryDark,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.surface,
    
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    
    // Simple text theme that works everywhere
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.textDisabled),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );
}