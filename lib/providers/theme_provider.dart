import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _locale = 'tr'; // 'tr' or 'en'

  bool get isDarkMode => _isDarkMode;
  String get locale => _locale;

  ThemeProvider() {
    _loadPreferences();
  }

  // Load preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _locale = prefs.getString('locale') ?? 'tr';
    notifyListeners();
  }

  // Toggle Dark Mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // Set Dark Mode
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // Change Locale
  Future<void> setLocale(String newLocale) async {
    if (newLocale == 'tr' || newLocale == 'en') {
      _locale = newLocale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('locale', _locale);
      notifyListeners();
    }
  }

  // Get String based on locale
  String getString(Map<String, String> tr, Map<String, String> en, String key) {
    final strings = _locale == 'tr' ? tr : en;
    return strings[key] ?? key;
  }
}

