import 'package:flutter/material.dart';
import '../data/models/meal_model.dart';
import '../data/services/mock_data_service.dart';

class MealProvider with ChangeNotifier {
  List<MealModel> _meals = [];
  List<MealModel> _filteredMeals = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  DateTime? _selectedDate;
  String? _selectedMealType;
  String? _selectedMealPeriod;
  String? _userPreference; // Kullanıcı tercihi (normal, vegetarian, vegan, gluten_free)
  String? _selectedCafeteriaId; // Seçilen yemekhane

  List<MealModel> get meals => _filteredMeals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedMealType => _selectedMealType;
  String? get selectedMealPeriod => _selectedMealPeriod;
  String? get userPreference => _userPreference;
  String? get selectedCafeteriaId => _selectedCafeteriaId;

  // Load Meals
  Future<void> loadMeals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _meals = MockDataService.instance.getMockMeals();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Yemekler yüklenemedi: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply Filters
  void _applyFilters() {
    _filteredMeals = _meals.where((meal) {
      bool matchesDate = _selectedDate == null ||
          (meal.mealDate.year == _selectedDate!.year &&
              meal.mealDate.month == _selectedDate!.month &&
              meal.mealDate.day == _selectedDate!.day);

      bool matchesType = _selectedMealType == null ||
          meal.mealType == _selectedMealType;

      bool matchesPeriod = _selectedMealPeriod == null ||
          meal.mealPeriod == _selectedMealPeriod;

      // Kullanıcı tercihine göre filtrele (eğer tercih varsa)
      bool matchesPreference = _userPreference == null || 
          _userPreference == 'normal' || 
          meal.mealType == _userPreference ||
          (_userPreference == 'gluten_free' && !meal.allergens.contains('gluten'));

      // Yemekhane filtrelemesi
      bool matchesCafeteria = _selectedCafeteriaId == null ||
          meal.cafeteriaId == _selectedCafeteriaId;

      return matchesDate && matchesType && matchesPeriod && matchesPreference && matchesCafeteria;
    }).toList();

    // Sort by date
    _filteredMeals.sort((a, b) => a.mealDate.compareTo(b.mealDate));
  }

  // Set Date Filter
  void setDateFilter(DateTime? date) {
    _selectedDate = date;
    _applyFilters();
    notifyListeners();
  }

  // Set Meal Type Filter
  void setMealTypeFilter(String? type) {
    _selectedMealType = type;
    _applyFilters();
    notifyListeners();
  }

  // Set Meal Period Filter
  void setMealPeriodFilter(String? period) {
    _selectedMealPeriod = period;
    _applyFilters();
    notifyListeners();
  }

  // Set User Preference (from user profile)
  void setUserPreference(String? preference) {
    _userPreference = preference;
    _applyFilters();
    notifyListeners();
  }

  // Set Cafeteria Filter (from user profile)
  void setCafeteriaFilter(String? cafeteriaId) {
    _selectedCafeteriaId = cafeteriaId;
    _applyFilters();
    notifyListeners();
  }

  // Clear Filters
  void clearFilters() {
    _selectedDate = null;
    _selectedMealType = null;
    _selectedMealPeriod = null;
    // User preference is not cleared, it's persistent
    _applyFilters();
    notifyListeners();
  }

  // Get Meal by ID
  MealModel? getMealById(String id) {
    try {
      return _meals.firstWhere((meal) => meal.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update Meal (Admin)
  void updateMeal(MealModel updatedMeal) {
    final index = _meals.indexWhere((meal) => meal.id == updatedMeal.id);
    if (index != -1) {
      _meals[index] = updatedMeal;
      _applyFilters();
      notifyListeners();
    }
  }

  // Add Meal (Admin)
  void addMeal(MealModel meal) {
    _meals.add(meal);
    _applyFilters();
    notifyListeners();
  }

  // Delete Meal (Admin)
  void deleteMeal(String mealId) {
    _meals.removeWhere((meal) => meal.id == mealId);
    _applyFilters();
    notifyListeners();
  }
}

