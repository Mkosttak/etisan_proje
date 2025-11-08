import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Etisan Brand (from logo)
  static const Color primaryOrange = Color(0xFFFDB913); // Etisan sarı-turuncu
  static const Color secondaryOrange = Color(0xFFFF8C42); // İkincil turuncu
  static const Color primaryDark = Color(0xFF2C2C2C); // Koyu gri (logo yazısı)
  
  // Secondary Colors
  static const Color secondaryPurple = Color(0xFF7C3AED);
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color secondaryGreen = Color(0xFF10B981);
  static const Color secondaryRed = Color(0xFFEF4444);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Meal Type Colors
  static const Color normalMeal = Color(0xFFFF8C42); // Turuncu
  static const Color vegetarianMeal = Color(0xFF22C55E); // Yeşil
  static const Color veganMeal = Color(0xFF84CC16); // Açık yeşil
  static const Color glutenFreeMeal = Color(0xFFA16207); // Kahverengi
  
  // Meal Period Colors
  static const Color breakfast = Color(0xFFFBBF24);
  static const Color lunch = Color(0xFFF97316);
  static const Color dinner = Color(0xFF8B5CF6);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF1E293B);
  
  // Reservation Status Colors
  static const Color reserved = Color(0xFF3B82F6);
  static const Color consumed = Color(0xFF10B981);
  static const Color cancelled = Color(0xFFEF4444);
  static const Color transferOpen = Color(0xFFF59E0B);
  static const Color transferred = Color(0xFF8B5CF6);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFDB913), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

