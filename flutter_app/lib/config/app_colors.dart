// lib/config/app_colors.dart
// Minimal color palette. Kept small on purpose — a simple app doesn't
// need a dozen shades. Reuse these everywhere instead of hardcoding colors.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2864EC);
  static const Color primaryDark = Color(0xFF1845AE);
  static const Color primaryLight = Color(0xFFEDF3FF);
  static const Color secondary = Color(0xFF3179BF);

  static const Color background = Color(0xFFFAFBFD);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF17243B);
  static const Color textSecondary = Color(0xFF737E90);

  static const Color border = Color(0xFFEBEEF4);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Work status colors
  static const Color statusPosted = Color(0xFF9CA3AF);
  static const Color statusNotified = Color(0xFFF59E0B);
  static const Color statusAccepted = Color(0xFF3B82F6);
  static const Color statusOnTheWay = Color(0xFF6366F1);
  static const Color statusArrived = Color(0xFF8B5CF6);
  static const Color statusStarted = Color(0xFF06B6D4);
  static const Color statusCompleted = Color(0xFF3179BF);
  static const Color statusCancelled = Color(0xFFEF4444);
}
