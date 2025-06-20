import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ProjecTree Color Palette from screenshots
  static const Color primaryYellow = Color(0xFFFFCC00);
  static const Color darkBackground = Color(0xFF1A1B23);
  static const Color darkerBackground = Color(0xFF0F1015);
  static const Color inputBackground = Color(0xFF2A2B35);
  static const Color inputBorder = Color(0xFF3A3B45);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF9CA3AF);
  static const Color textPlaceholder = Color(0xFF6B7280);

  // Additional colors needed by other components
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color neutralGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color shadowColor = Color(0x0F000000);
  static const Color glassBackground = Color(0xFFFFFFFE);
  static const Color glassBorder = Color(0x1A000000);

  // Color mappings for backward compatibility
  static const Color primaryColor = primaryYellow;
  static const Color secondaryColor = primaryBlack;
  static const Color accentColor = primaryYellow;
  static const Color textSecondary = neutralGray;
  static const Color errorColor = Color(0xFFDC2626);
  static const Color borderColor = glassBorder;
  static const Color surfaceColor = cardBackground;
  static const Color backgroundColor = lightGray;

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,

    // Typography - Much smaller sizes
    textTheme: TextTheme(
      // Main heading
      headlineLarge: GoogleFonts.inter(
        fontSize: 28.sp, // Reduced from 32
        fontWeight: FontWeight.w700,
        color: textWhite,
        letterSpacing: -0.5,
      ),
      // Subtitle
      headlineMedium: GoogleFonts.inter(
        fontSize: 14.sp, // Reduced from 16
        fontWeight: FontWeight.w400,
        color: textGray,
        height: 1.5,
      ),
      // Form labels
      labelLarge: GoogleFonts.inter(
        fontSize: 13.sp, // Reduced from 14
        fontWeight: FontWeight.w500,
        color: textWhite,
      ),
      // Button text
      labelMedium: GoogleFonts.inter(
        fontSize: 14.sp, // Reduced from 16
        fontWeight: FontWeight.w600,
        color: darkBackground,
      ),
      // Body text
      bodyMedium: GoogleFonts.inter(
        fontSize: 13.sp, // Reduced from 14
        fontWeight: FontWeight.w400,
        color: textGray,
      ),
      // Small text
      bodySmall: GoogleFonts.inter(
        fontSize: 11.sp, // Reduced from 12
        fontWeight: FontWeight.w400,
        color: neutralGray,
      ),
      // Headlines
      headlineSmall: GoogleFonts.inter(
        fontSize: 18.sp, // Reduced from 20
        fontWeight: FontWeight.w600,
        color: textWhite,
      ),
    ),

    colorScheme: const ColorScheme.dark(
      primary: primaryYellow,
      onPrimary: darkBackground,
      secondary: textWhite,
      onSecondary: darkBackground,
      surface: inputBackground,
      onSurface: textWhite,
      background: darkBackground,
      onBackground: textWhite,
    ),

    // Input field theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: inputBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: inputBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: primaryYellow, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h), // Reduced padding
      hintStyle: GoogleFonts.inter(
        fontSize: 13.sp, // Reduced from 14
        color: textPlaceholder,
      ),
    ),

    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryYellow,
        foregroundColor: darkBackground,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 12.h), // Reduced from 16
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.r),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14.sp, // Reduced from 16
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textWhite,
        side: BorderSide(color: inputBorder, width: 1),
        padding: EdgeInsets.symmetric(vertical: 12.h), // Reduced from 16
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 13.sp, // Reduced from 14
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );

  static ThemeData lightTheme = darkTheme; // Use dark theme for now
}
