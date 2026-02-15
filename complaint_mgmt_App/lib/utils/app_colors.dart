import 'package:flutter/material.dart';

class AppColors {
  // SaaS Premium Palette
  static const Color primary = Color(0xFF2563EB);    // Royal Blue
  static const Color primaryDark = Color(0xFF1E3A8A); // Darker Blue for gradients
  static const Color darkNavy = Color(0xFF0F172A);   // Deep Navy
  static const Color secondaryDark = Color(0xFF1E293B);
  static const Color accent = Color(0xFF14B8A6);     // Teal
  static const Color background = Color(0xFFF8FAFC); // Very Light Gray
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color cardWhite = Color(0xFFFFFFFF);   // Added for compatibility
  static const Color lightText = Color(0xFFE2E8F0);
  static const Color mutedText = Color(0xFF94A3B8);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);

  // Functional
  static const Color success = Color(0xFF14B8A6);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);        // Added for compatibility

  // Status Aliases
  static const Color statusOpen = primary;
  static const Color statusInProgress = warning;
  static const Color statusResolved = success;
  static const Color priorityHigh = error;
  static const Color priorityMedium = warning;
  static const Color priorityLow = success;
  static const Color statusPending = primary;
}
