import 'package:flutter/material.dart';

class AppColors {
  // Main Branding from your design
  static const Color primary = Color(0xFF137A9C);
  static const Color primaryLight = Color(0xFF5AB2C8);

  // Backgrounds & Cards
  static const Color background = Color(0xFFF4F7F6);
  static const Color surface = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF757575);

  // Attendance Colors
  static const Color presentBox = Color(0xFFC5F09D);
  static const Color absentBox = Color(0xFFFFC0B3);
  static const Color leaveBox = Color(0xFFFFE599);
  static const Color holidayBox = Color(0xFFD9C2F0);

  // --- ADD THESE 3 LINES BELOW ---
  static const Color success = Color(0xFF10B981); // Green for approved/success
  static const Color error = Color(0xFFEF4444);   // Red for rejected/errors
  static const Color warning = Color(0xFFF59E0B); // Yellow for pending/warnings

  static const Color secondary = Color(0xFF00B4D8); // A nice cyan/blue-accent color
}