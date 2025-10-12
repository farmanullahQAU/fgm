import 'package:flutter/material.dart';
import 'package:fmac/core/values/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'HKGrotesk', // Or any font you use
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.branding,
        primary: AppColors.branding,
        // surface: AppColors.backgroundLight,
        // tertiary: AppColors.tertiary,
        brightness: Brightness.light,
      ),
      // textTheme: GoogleFonts.interTightTextTheme(Typography.blackMountainView),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter', // Or any font you use
      colorScheme: ColorScheme.fromSeed(
        // seedColor: Colors.pink,
        seedColor: AppColors.branding,
        primary: AppColors.branding,
        surface: const Color.fromARGB(255, 46, 45, 45),
        // surfaceContainer: Color(0xff38393e),

        //38393e
        // Dark surface color
        // tertiary: Colors.white,

        // secondary: AppColors.secondary
        // tertiary: AppColors.tertiary,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTightTextTheme(Typography.whiteMountainView),
    );
  }
}
