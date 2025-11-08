import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_provider.dart';
import '../../data/services/mock_data_service.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> 
    with SingleTickerProviderStateMixin {
  String? _selectedPreference;
  String? _selectedCafeteria;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> preferences = [
    {
      'value': 'normal',
      'title': 'Normal',
      'description': 'Standart menü',
      'icon': Icons.restaurant,
      'color': AppColors.normalMeal,
    },
    {
      'value': 'vegetarian',
      'title': 'Vejetaryen',
      'description': 'Et içermeyen menü',
      'icon': Icons.eco,
      'color': AppColors.vegetarianMeal,
    },
    {
      'value': 'vegan',
      'title': 'Vegan',
      'description': 'Hayvansal ürün içermeyen',
      'icon': Icons.spa,
      'color': AppColors.veganMeal,
    },
    {
      'value': 'gluten_free',
      'title': 'Glutensiz',
      'description': 'Gluten içermeyen menü',
      'icon': Icons.grain,
      'color': AppColors.glutenFreeMeal,
    },
  ];

  final List<Map<String, dynamic>> cafeterias = [
    {
      'id': 'cafeteria-1',
      'name': 'Merkez Yemekhane',
      'icon': Icons.restaurant_menu,
      'color': Colors.blue,
    },
    {
      'id': 'cafeteria-2',
      'name': 'Mühendislik Fakültesi',
      'icon': Icons.engineering,
      'color': Colors.purple,
    },
    {
      'id': 'cafeteria-3',
      'name': 'Tıp Fakültesi',
      'icon': Icons.local_hospital,
      'color': Colors.red,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _selectedPreference = authProvider.currentUser?.mealPreference;
    _selectedCafeteria = authProvider.currentUser?.preferredCafeteriaId;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _savePreference() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    
    try {
      final updatedUser = authProvider.currentUser!.copyWith(
        mealPreference: _selectedPreference,
        preferredCafeteriaId: _selectedCafeteria,
      );
      
      authProvider.setUser(updatedUser);
      
      if (_selectedPreference != null) {
        mealProvider.setUserPreference(_selectedPreference);
      }
      if (_selectedCafeteria != null) {
        mealProvider.setCafeteriaFilter(_selectedCafeteria);
      }
      
      MockDataService.instance.updateUserPreferences(
        userId: authProvider.currentUser!.id,
        mealPreference: _selectedPreference,
        preferredCafeteriaId: _selectedCafeteria,
      );
    } catch (e) {
      Helpers.showSnackBar(
        context,
        'Tercih kaydedilirken hata oluştu: $e',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Tercihlerim'),
        backgroundColor: AppColors.primaryOrange,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal Preference Section
              _buildSectionHeader(
                'Yemek Tercihi',
                Icons.restaurant,
                'Menü tercihlerinizi seçin',
              ),
              const SizedBox(height: 16),
              ...preferences.map((pref) => _buildPreferenceCard(pref)),
              
              const SizedBox(height: 32),
              
              // Cafeteria Section
              _buildSectionHeader(
                'Yemekhane Seçimi',
                Icons.location_on,
                'Tercih ettiğiniz yemekhaneyi seçin',
              ),
              const SizedBox(height: 16),
              ...cafeterias.map((caf) => _buildCafeteriaCard(caf)),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryOrange, AppColors.secondaryOrange],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryOrange, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceCard(Map<String, dynamic> pref) {
    final isSelected = _selectedPreference == pref['value'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? pref['color'] : AppColors.grey200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: pref['color'].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPreference = pref['value'];
            });
            _savePreference();
            Helpers.showSnackBar(context, '${pref['title']} tercihi seçildi');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: pref['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    pref['icon'],
                    color: pref['color'],
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pref['title'],
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? pref['color'] : AppColors.grey900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pref['description'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: pref['color'],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCafeteriaCard(Map<String, dynamic> caf) {
    final isSelected = _selectedCafeteria == caf['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? caf['color'] : AppColors.grey200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: caf['color'].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCafeteria = caf['id'];
            });
            _savePreference();
            Helpers.showSnackBar(context, '${caf['name']} seçildi');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: caf['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    caf['icon'],
                    color: caf['color'],
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    caf['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? caf['color'] : AppColors.grey900,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: caf['color'],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

