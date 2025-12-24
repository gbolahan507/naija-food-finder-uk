import 'package:flutter/material.dart';

/// Centralized color constants for the app
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Brand Colors (Nigerian Flag)
  static const Color primaryGreen = Color(0xFF008751);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color accentGold = Color(0xFFFFD700);

  // Neutral Colors
  static const Color darkText = Color(0xFF2C3E50);
  static const Color lightText = Color(0xFF7F8C8D);
  static const Color darkGrey = Color(0xFF2C3E50);
  static const Color mediumGrey = Color(0xFF95A5A6);
  static const Color lightGrey = Color(0xFFECF0F1);
  static const Color extraLightGrey = Color(0xFFF8F9FA);

  // Status Colors
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // Background Colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFFF5F6FA);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Rating Star Color
  static const Color starYellow = Color(0xFFFFC107);

  // Delivery/Takeaway Badge Colors
  static const Color deliveryBadge = Color(0xFF27AE60);
  static const Color takeawayBadge = Color(0xFF3498DB);

  // Map Marker Colors
  static const Color markerRed = Color(0xFFE74C3C);
  static const Color markerGreen = Color(0xFF27AE60);

  // Social Media Colors (for future use)
  static const Color facebook = Color(0xFF1877F2);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color instagram = Color(0xFFE4405F);
  static const Color whatsapp = Color(0xFF25D366);
}
