import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

class Helpers {
  // Date Formatting
  static String formatDate(DateTime date, String format) {
    return DateFormat(format).format(date);
  }

  static String formatCurrency(double amount) {
    return '₺${amount.toStringAsFixed(2)}';
  }

  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays == -1) {
      return 'Yesterday';
    } else {
      return formatDate(date, 'EEEE, MMM dd');
    }
  }

  // Status Colors
  static Color getReservationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'reserved':
        return AppColors.reserved;
      case 'consumed':
        return AppColors.consumed;
      case 'cancelled':
        return AppColors.cancelled;
      case 'transferopen':
        return AppColors.transferOpen;
      case 'transferred':
        return AppColors.transferred;
      default:
        return AppColors.grey400;
    }
  }

  static Color getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'normal':
        return AppColors.normalMeal;
      case 'vegetarian':
        return AppColors.vegetarianMeal;
      case 'vegan':
        return AppColors.veganMeal;
      case 'glutenfree':
        return AppColors.glutenFreeMeal;
      default:
        return AppColors.normalMeal;
    }
  }

  static Color getMealPeriodColor(String period) {
    switch (period.toLowerCase()) {
      case 'breakfast':
        return AppColors.breakfast;
      case 'lunch':
        return AppColors.lunch;
      case 'dinner':
        return AppColors.dinner;
      default:
        return AppColors.lunch;
    }
  }

  // Icons
  static IconData getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'normal':
        return Icons.restaurant;
      case 'vegetarian':
        return Icons.eco;
      case 'vegan':
        return Icons.spa;
      case 'glutenfree':
        return Icons.grain;
      default:
        return Icons.restaurant;
    }
  }

  static IconData getMealPeriodIcon(String period) {
    switch (period.toLowerCase()) {
      case 'breakfast':
        return Icons.coffee;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant_menu;
    }
  }

  // Snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gereklidir';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi giriniz';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gereklidir';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gereklidir';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası gereklidir';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
      return 'Geçerli bir telefon numarası giriniz';
    }
    return null;
  }

  // Responsive
  static bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width > 800;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600 && 
           MediaQuery.of(context).size.width <= 800;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= 600;
  }

  static double getResponsiveWidth(BuildContext context) {
    if (isWeb(context)) {
      return 1200;
    } else if (isTablet(context)) {
      return 800;
    } else {
      return MediaQuery.of(context).size.width;
    }
  }
}

