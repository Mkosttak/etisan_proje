import 'package:flutter/material.dart';
import '../data/models/meal_model.dart';

class CartProvider with ChangeNotifier {
  final List<MealModel> _cartItems = [];

  List<MealModel> get cartItems => _cartItems;
  int get itemCount => _cartItems.length;
  
  double get totalPrice {
    return _cartItems.fold(0, (sum, meal) => sum + meal.reservationPrice);
  }

  bool isMealInCart(String mealId) {
    return _cartItems.any((meal) => meal.id == mealId);
  }

  void addToCart(MealModel meal) {
    if (!isMealInCart(meal.id)) {
      _cartItems.add(meal);
      notifyListeners();
    }
  }

  void removeFromCart(String mealId) {
    _cartItems.removeWhere((meal) => meal.id == mealId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}

