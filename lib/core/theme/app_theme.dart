import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,

      // Clean, modern typography
      textTheme: GoogleFonts.poppinsTextTheme(),

      // Standardize the App Bar across all screens
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white, // Makes text/icons white
        elevation: 0,
        centerTitle: true,
      ),

      // Standardize the Grid Cards across all screens
      // Standardize the Grid Cards across all screens
      cardTheme: CardThemeData( // <-- Changed from CardTheme to CardThemeData
        color: AppColors.surface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}