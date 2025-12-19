import 'package:flutter/material.dart';

/// ProdVid Color Palette - Based on Stitch Design System
abstract class AppColors {
  // Primary - Electric Blue
  static const Color primary = Color(0xFF135BEC);
  static const Color primaryLight = Color(0xFF4B83F0);
  static const Color primaryDark = Color(0xFF0E47BD);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color backgroundDark = Color(0xFF101622);

  // Surface Colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C2433);
  static const Color surfaceDarkAlt = Color(0xFF192233);
  static const Color surfaceCard = Color(0xFF232F48);

  // Text Colors - Light Mode
  static const Color textPrimaryLight = Color(0xFF111418);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // Text Colors - Dark Mode
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF92A4C9);
  static const Color textTertiaryDark = Color(0xFF556987);

  // Slate Colors (for various UI elements)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  // Accent Colors
  static const Color accent = Color(0xFF8B5CF6);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color orange = Color(0xFFF97316);
  static const Color teal = Color(0xFF14B8A6);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color pink = Color(0xFFEC4899);
  
  // Neon Colors
  static const Color neonCyan = Color(0xFF00D9FF);
  static const Color neonGreen = Color(0xFF00FF88);

  // Borders
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF324467);
  static const Color borderDarkAlt = Color(0xFF1E293B);

  // Overlays
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient instagramGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Premium Badge Gradient
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass Effect
  static Color get glassBackground => backgroundDark.withValues(alpha: 0.6);
  static const Color glassBorder = Color(0x14FFFFFF);
}
