import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ProjecTree Color Palette
  static const Color primaryYellow = Color(0xFFFFCC00);
  static const Color darkBackground = Color(0xFF1A1B23);
  static const Color darkerBackground = Color(0xFF0F1015);
  static const Color inputBackground = Color(0xFF2A2B35);
  static const Color inputBorder = Color(0xFF3A3B45);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF9CA3AF);
  static const Color textPlaceholder = Color(0xFF6B7280);

  // Additional colors
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

    // OPTIMIZED Typography - Better sizes for mobile
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.inter(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: textWhite,
        letterSpacing: -0.3,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: textGray,
        height: 1.3,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: textWhite,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: darkBackground,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: textGray,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: neutralGray,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18.sp,
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

    // OPTIMIZED Input field theme
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
        borderSide: BorderSide(color: primaryYellow, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      hintStyle: GoogleFonts.inter(
        fontSize: 14.sp,
        color: textPlaceholder,
      ),
    ),

    // OPTIMIZED Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryYellow,
        foregroundColor: darkBackground,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textWhite,
        side: BorderSide(color: inputBorder, width: 1),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );

  static ThemeData lightTheme = darkTheme;
}
