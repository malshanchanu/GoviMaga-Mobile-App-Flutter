import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color primaryDark = Color(0xFF0D3B0F);
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentLight = Color(0xFF81C784);
  
  // Secondary Colors
  static const Color secondaryOrange = Color(0xFFFF9800);
  static const Color secondaryBrown = Color(0xFF795548);
  static const Color secondaryYellow = Color(0xFFFFC107);
  
  // Neutral Colors
  static const Color background = Color(0xFFF5F8F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
  
  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, primaryLight, accentGreen],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, Color(0xFFE8F5E9)],
  );
  
  // Shadows
  static List<BoxShadow> cardShadow = [
    const BoxShadow(
      color: Colors.black12,
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> buttonShadow = [
    const BoxShadow(
      color: Colors.black26,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: textSecondary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: textHint,
  );
  
  // ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: accentGreen,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      // FIXED: Remove cardTheme completely to avoid error
      // cardTheme is optional, Flutter will use default
    );
  }
}