import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // MODERN COLOR PALETTE - Inspired by provided website
  static const Color primaryYellow = Color(0xFFFFCC00);

  // Modern neutral colors using OKLCH-inspired values
  static const Color darkBackground = Color(0xFF0A0A0B); // Deeper black
  static const Color darkerBackground = Color(0xFF050506); // Even deeper
  static const Color cardBackground = Color(0xFF1A1A1C); // Modern card bg
  static const Color inputBackground = Color(0xFF1F1F21); // Subtle input bg
  static const Color inputBorder = Color(0xFF2A2A2D); // Softer borders

  // Modern text colors
  static const Color textWhite = Color(0xFFFAFAFA); // Softer white
  static const Color textGray = Color(0xFF9CA3AF); // Balanced gray
  static const Color textMuted = Color(0xFF6B7280); // Muted text
  static const Color textPlaceholder = Color(0xFF4B5563); // Subtle placeholder

  // Light theme colors (keeping compatibility)
  static const Color primaryBlack = Color(0xFF0A0A0B);
  static const Color primaryWhite = Color(0xFFFFFFFE);
  static const Color neutralGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color shadowColor = Color(0x0F000000);
  static const Color glassBackground = Color(0xFFFFFFFE);
  static const Color glassBorder = Color(0x1A000000);

  // Accent colors
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentPurple = Color(0xFF8B5CF6);

  // Color mappings for backward compatibility
  static const Color primaryColor = primaryYellow;
  static const Color secondaryColor = primaryBlack;
  static const Color accentColor = primaryYellow;
  static const Color textSecondary = neutralGray;
  static const Color errorColor = accentRed;
  static const Color borderColor = glassBorder;
  static const Color surfaceColor = cardBackground;
  static const Color backgroundColor = lightGray;

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,

    // MODERN Typography with Poppins (inspired by website)
    textTheme: GoogleFonts.poppinsTextTheme(
      TextTheme(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: textWhite,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: textGray,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: textWhite,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: darkBackground,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: textGray,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 11.sp,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: textWhite,
        ),
      ),
    ),

    colorScheme: const ColorScheme.dark(
      primary: primaryYellow,
      onPrimary: darkBackground,
      secondary: textWhite,
      onSecondary: darkBackground,
      surface: cardBackground,
      onSurface: textWhite,
      background: darkBackground,
      onBackground: textWhite,
    ),

    // Modern input field theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r), // More rounded
        borderSide: BorderSide(color: inputBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: inputBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: primaryYellow, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      hintStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        color: textPlaceholder,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        color: textGray,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Modern button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryYellow,
        foregroundColor: darkBackground,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textWhite,
        side: BorderSide(color: inputBorder, width: 1.5),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // App bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: textWhite,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: textWhite,
      ),
    ),

    // Bottom navigation theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkerBackground,
      selectedItemColor: primaryYellow,
      unselectedItemColor: textGray,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
      ),
    ),
  );

  static ThemeData lightTheme = darkTheme;
}
