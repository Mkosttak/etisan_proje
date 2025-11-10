import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/layout/web_layout.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/cart_provider.dart';
import '../../data/models/meal_model.dart';
import '../../data/models/transaction_model.dart';

class CreateReservationScreen extends StatefulWidget {
  const CreateReservationScreen({super.key});

  @override
  State<CreateReservationScreen> createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadData();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    
    // Yemekhane otomatik seçimi - önce kullanıcının tercihi, yoksa varsayılan
    if (authProvider.currentUser?.preferredCafeteriaId != null) {
      mealProvider.setCafeteriaFilter(authProvider.currentUser!.preferredCafeteriaId);
    } else {
      // Varsayılan olarak ilk yemekhaneyi seç (Merkez Yemekhane)
      mealProvider.setCafeteriaFilter('cafeteria-1');
    }

    mealProvider.setDateFilter(_selectedDate);
    await mealProvider.loadMeals();
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final isWeb = Helpers.isWeb(context);

    if (isWeb && mealProvider.selectedMealPeriod != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          mealProvider.setMealPeriodFilter(null);
        }
      });
    }

    return isWeb
        ? _buildWebLayout(context, mealProvider)
        : _buildMobileLayout(context, mealProvider);
  }

  Widget _buildMobileLayout(BuildContext context, MealProvider mealProvider) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(280),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildDateSelector(mealProvider),
                const SizedBox(height: 12),
                _buildCafeteriaFilters(mealProvider),
                const SizedBox(height: 8),
                _buildCompactMealTypeFilters(mealProvider),
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: AppColors.primaryOrange,
                    unselectedLabelColor: Colors.white,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    tabs: const [
                      Tab(
                        height: 50,
                        icon: Icon(Icons.coffee, size: 20),
                        text: 'Kahvaltı',
                      ),
                      Tab(
                        height: 50,
                        icon: Icon(Icons.lunch_dining, size: 20),
                        text: 'Öğle',
                      ),
                      Tab(
                        height: 50,
                        icon: Icon(Icons.dinner_dining, size: 20),
                        text: 'Akşam',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMealsList(mealProvider, 'breakfast'),
                _buildMealsList(mealProvider, 'lunch'),
                _buildMealsList(mealProvider, 'dinner'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, MealProvider mealProvider) {
    return WebLayout(
      child: Row(
        children: [
          // Sol Filtre Paneli
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: AppColors.webCard,
              border: Border(
                right: BorderSide(
                  color: AppColors.grey200,
                  width: 1,
                ),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildWebFilters(mealProvider),
            ),
          ),
          // Ana İçerik
          Expanded(
            child: Container(
              color: AppColors.webBackground,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWebHeader(context, mealProvider),
                    const SizedBox(height: 16),
                    _buildWebMealSections(mealProvider),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cafeteria Filters (takas sayfası gibi)
  Widget _buildCafeteriaFilters(MealProvider mealProvider) {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            mealProvider,
            'cafeteria-1',
            'Merkez',
            Icons.restaurant_menu,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            mealProvider,
            'cafeteria-2',
            'Mühendislik',
            Icons.engineering,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            mealProvider,
            'cafeteria-3',
            'Tıp',
            Icons.local_hospital,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    MealProvider mealProvider,
    String cafeteriaId,
    String label,
    IconData icon,
  ) {
    final isSelected = mealProvider.selectedCafeteriaId == cafeteriaId;
    
    return InkWell(
      onTap: () {
        if (isSelected) {
          // Eğer zaten seçiliyse, değiştirmeye izin verme (en az bir seçili olmalı)
          return;
        }
        mealProvider.setCafeteriaFilter(cafeteriaId);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AppColors.primaryOrange : Colors.white,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primaryOrange : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Compact version for AppBar (turuncu tema)
  Widget _buildCompactMealTypeFilters(MealProvider mealProvider) {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCompactMealTypeChip(
            mealProvider,
            'normal',
            'Normal',
            Icons.restaurant,
          ),
          const SizedBox(width: 8),
          _buildCompactMealTypeChip(
            mealProvider,
            'vegetarian',
            'Vejetaryen',
            Icons.eco,
          ),
          const SizedBox(width: 8),
          _buildCompactMealTypeChip(
            mealProvider,
            'vegan',
            'Vegan',
            Icons.spa,
          ),
          const SizedBox(width: 8),
          _buildCompactMealTypeChip(
            mealProvider,
            'gluten_free',
            'Glutensiz',
            Icons.grain,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMealTypeChip(
    MealProvider mealProvider,
    String type,
    String label,
    IconData icon,
  ) {
    final isSelected = mealProvider.selectedMealType == type;

    return InkWell(
      onTap: () {
        mealProvider.setMealTypeFilter(isSelected ? null : type);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AppColors.primaryOrange : Colors.white,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primaryOrange : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebHeader(BuildContext context, MealProvider mealProvider) {
    final cartProvider = Provider.of<CartProvider>(context);
    final formattedDate = _formatWebDate(_selectedDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Menü - $formattedDate',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.grey900,
          ),
        ),
        // Sepet İkonu
        Stack(
          children: [
            IconButton(
              onPressed: () {
                // Sepet sayfasına git - CartScreen'e yönlendir
                context.push('/cart');
              },
              icon: const Icon(
                Icons.shopping_cart_outlined,
                size: 28,
                color: AppColors.grey700,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.all(8),
              ),
            ),
            if (cartProvider.itemCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildWebFilters(MealProvider mealProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // E TİSAN Yemekhane Başlığı
        Row(
          children: [
            const Icon(
              Icons.restaurant_menu,
              size: 24,
              color: AppColors.primaryOrange,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'E TİSAN Yemekhane',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Tarih Seçimi
        _buildWebDateSelector(mealProvider),
        const SizedBox(height: 16),
        // Yemekhane Seçimi
        _buildWebCafeteriaSelector(mealProvider),
        const SizedBox(height: 16),
        // Diyet Seçimi
        _buildWebDietSelector(mealProvider),
        const SizedBox(height: 12), // Alt boşluk
      ],
    );
  }

  Widget _buildWebDateSelector(MealProvider mealProvider) {
    // Seçili tarihin öncesi, kendisi ve sonrası
    final prevDate = _selectedDate.add(const Duration(days: -1));
    final nextDate = _selectedDate.add(const Duration(days: 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Tarih',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 75,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sol ok butonu
              IconButton(
                onPressed: () => _scrollDateSelector(mealProvider, -1),
                icon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.grey500,
                  size: 20,
                ),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
              ),
              const SizedBox(width: 8),
              // Önceki tarih
              Expanded(
                child: _buildDateCard(prevDate, false, mealProvider),
              ),
              const SizedBox(width: 8),
              // Seçili tarih (orta)
              Expanded(
                flex: 2,
                child: _buildDateCard(_selectedDate, true, mealProvider),
              ),
              const SizedBox(width: 8),
              // Sonraki tarih
              Expanded(
                child: _buildDateCard(nextDate, false, mealProvider),
              ),
              const SizedBox(width: 8),
              // Sağ ok butonu
              IconButton(
                onPressed: () => _scrollDateSelector(mealProvider, 1),
                icon: const Icon(
                  Icons.chevron_right,
                  color: AppColors.grey500,
                  size: 20,
                ),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard(DateTime date, bool isSelected, MealProvider mealProvider) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
        mealProvider.setDateFilter(date);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryOrange
                : AppColors.grey200,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _getDayName(date.weekday),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.grey800
                    : AppColors.grey500,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.grey800
                    : AppColors.grey900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              _getMonthName(date.month),
              style: TextStyle(
                fontSize: 9,
                color: isSelected
                    ? AppColors.grey800
                    : AppColors.grey500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollDateSelector(MealProvider mealProvider, int days) {
    // Tarihi değiştir
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    mealProvider.setDateFilter(_selectedDate);
  }

  Widget _buildWebCafeteriaSelector(MealProvider mealProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Yemekhane',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.grey200,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWebRadioOption(
                mealProvider,
                'cafeteria-1',
                'Merkez',
                Icons.restaurant,
                onTap: () => mealProvider.setCafeteriaFilter('cafeteria-1'),
              ),
              const SizedBox(height: 6),
              _buildWebRadioOption(
                mealProvider,
                'cafeteria-2',
                'Mühendislik',
                Icons.engineering,
                onTap: () => mealProvider.setCafeteriaFilter('cafeteria-2'),
              ),
              const SizedBox(height: 6),
              _buildWebRadioOption(
                mealProvider,
                'cafeteria-3',
                'Tıp',
                Icons.local_hospital,
                onTap: () => mealProvider.setCafeteriaFilter('cafeteria-3'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebRadioOption(
    MealProvider mealProvider,
    String value,
    String label,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    final isSelected = mealProvider.selectedCafeteriaId == value;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFF9C4) // yellow-100
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: mealProvider.selectedCafeteriaId,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primaryOrange,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primaryOrange;
                }
                return AppColors.grey400;
              }),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryOrange
                  : AppColors.grey500,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AppColors.grey900
                      : AppColors.grey700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebDietSelector(MealProvider mealProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Diyet',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.grey200,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWebDietRadioOption(
                mealProvider,
                null,
                'Normal',
                Icons.restaurant_menu,
                onTap: () => mealProvider.setMealTypeFilter(null),
              ),
              const SizedBox(height: 6),
              _buildWebDietRadioOption(
                mealProvider,
                'vegetarian',
                'Vejetaryen',
                Icons.eco,
                onTap: () => mealProvider.setMealTypeFilter('vegetarian'),
              ),
              const SizedBox(height: 6),
              _buildWebDietRadioOption(
                mealProvider,
                'vegan',
                'Vegan',
                Icons.grass,
                onTap: () => mealProvider.setMealTypeFilter('vegan'),
              ),
              const SizedBox(height: 6),
              _buildWebDietRadioOption(
                mealProvider,
                'gluten_free',
                'Glutensiz',
                Icons.grain,
                onTap: () => mealProvider.setMealTypeFilter('gluten_free'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebDietRadioOption(
    MealProvider mealProvider,
    String? value,
    String label,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    final isSelected = mealProvider.selectedMealType == value;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFF9C4) // yellow-100
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Radio<String?>(
              value: value,
              groupValue: mealProvider.selectedMealType,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primaryOrange,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primaryOrange;
                }
                return AppColors.grey400;
              }),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryOrange
                  : AppColors.grey500,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AppColors.grey900
                      : AppColors.grey700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildWebMealSections(MealProvider mealProvider) {
    if (mealProvider.isLoading) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.webCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
      );
    }

    if (mealProvider.errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.webCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mealProvider.errorMessage!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final sections = [
      {'period': 'breakfast', 'title': 'Kahvaltı', 'icon': Icons.coffee},
      {'period': 'lunch', 'title': 'Öğle Yemeği', 'icon': Icons.lunch_dining},
      {'period': 'dinner', 'title': 'Akşam Yemeği', 'icon': Icons.dinner_dining},
    ];

    return Column(
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          _buildWebMealSection(mealProvider, sections[i]),
          if (i != sections.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildWebMealSection(
    MealProvider mealProvider,
    Map<String, dynamic> section,
  ) {
    final period = section['period'] as String;
    final meals = mealProvider.meals
        .where((meal) => meal.mealPeriod == period)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kategori Başlığı - Modern Tasarım
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryOrange.withValues(alpha: 0.1),
                AppColors.primaryOrange.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryOrange.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  section['icon'] as IconData,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                section['title'] as String,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Yemek Kartları (Grid Layout)
        if (meals.isEmpty)
          _buildWebEmptyState(section['title'] as String)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              // Daha fazla sütun göster - ekranda daha çok kart görünsün
              final crossAxisCount = constraints.maxWidth > 1400
                  ? 6
                  : constraints.maxWidth > 1100
                      ? 5
                      : constraints.maxWidth > 900
                          ? 4
                          : constraints.maxWidth > 700
                              ? 3
                              : 2;
              // Aspect ratio - kartların genişlik/yükseklik oranı
              // Daha düşük değer = daha yüksek kartlar (büyük butonlar için yeterli alan)
              final childAspectRatio = constraints.maxWidth > 800 ? 1.3 : 1.2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  return _buildWebMealCard(meals[index]);
                },
              );
            },
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildWebMealCard(MealModel meal) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = cartProvider.isMealInCart(meal.id);
        return _ModernMealCard(
          meal: meal,
          isInCart: isInCart,
          onAddToCart: () => _addToCart(meal, isInCart),
          onQuickReserve: () => _quickReserve(meal),
        );
      },
    );
  }

  Widget _buildWebEmptyState(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(24),
        color: AppColors.webBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            '$title için menü bulunamadı',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Farklı bir tarih veya filtre deneyin.',
            style: TextStyle(
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatWebDate(DateTime date) {
    return '${date.day} ${_getFullMonthName(date.month)} ${_getFullDayName(date.weekday)}';
  }



  Widget _buildDateSelector(MealProvider mealProvider,
      {EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16)}) {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: 15,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = _selectedDate.year == date.year &&
              _selectedDate.month == date.month &&
              _selectedDate.day == date.day;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
                mealProvider.setDateFilter(date);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 65,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getDayName(date.weekday),
                      style: TextStyle(
                        color: isSelected ? AppColors.primaryOrange : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected ? AppColors.primaryOrange : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getMonthName(date.month),
                      style: TextStyle(
                        color: isSelected ? AppColors.primaryOrange : Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealsList(MealProvider mealProvider, String period) {
    final meals = mealProvider.meals
        .where((meal) => meal.mealPeriod == period)
        .toList();

    if (mealProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryOrange),
      );
    }

    if (meals.isEmpty) {
      return _buildEmptyState(period);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 180),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return _buildModernMealCard(meal);
      },
    );
  }

  Widget _buildEmptyState(String period) {
    return Builder(
      builder: (context) {
        String periodName = period == 'breakfast'
            ? 'Kahvaltı'
            : period == 'lunch'
                ? 'Öğle'
                : 'Akşam';

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                period == 'breakfast'
                    ? Icons.coffee
                    : period == 'lunch'
                        ? Icons.lunch_dining
                        : Icons.dinner_dining,
                size: 80,
                color: AppColors.getIconColor(context),
              ),
              const SizedBox(height: 16),
              Text(
                '$periodName için yemek yok',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Başka bir tarih deneyin',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getTextSecondary(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernMealCard(MealModel meal) {
    Color periodColor;
    switch (meal.mealPeriod) {
      case 'breakfast':
        periodColor = AppColors.breakfast;
        break;
      case 'lunch':
        periodColor = AppColors.lunch;
        break;
      case 'dinner':
        periodColor = AppColors.dinner;
        break;
      default:
        periodColor = AppColors.grey500;
    }

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = cartProvider.isMealInCart(meal.id);
        
        return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [periodColor.withOpacity(0.8), periodColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    Helpers.formatCurrency(meal.reservationPrice),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: periodColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                if (meal.description.isNotEmpty)
                  Text(
                    meal.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextSecondary(context),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const SizedBox(height: 12),

                // Info Row
                Row(
                  children: [
                    if (meal.mealType == 'vegetarian')
                      _buildInfoChip(
                        Icons.eco,
                        'Vejetaryen',
                        AppColors.vegetarianMeal,
                      ),
                    if (meal.mealType == 'vegan')
                      _buildInfoChip(
                        Icons.spa,
                        'Vegan',
                        AppColors.veganMeal,
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action Buttons - Modern ve Belirgin
                Row(
                  children: [
                    // Sepete Ekle Butonu
                    Expanded(
                      flex: 4,
                      child: OutlinedButton.icon(
                        onPressed: meal.isAvailable
                            ? () => _addToCart(meal, isInCart)
                            : null,
                        icon: Icon(
                          isInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart,
                          size: 20,
                        ),
                        label: Text(
                          isInCart ? 'Sepetten Çıkar' : 'Sepete Ekle',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isInCart
                              ? AppColors.error
                              : AppColors.primaryOrange,
                          side: BorderSide(
                            color: isInCart
                                ? AppColors.error
                                : AppColors.primaryOrange,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Hızlı Al Butonu - Daha Belirgin
                    Expanded(
                      flex: 5,
                      child: ElevatedButton(
                        onPressed: meal.isAvailable ? () => _quickReserve(meal) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: periodColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 3,
                          shadowColor: periodColor.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.flash_on, size: 20),
                            const SizedBox(width: 6),
                            const Text(
                              'Hızlı Al',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(MealModel meal, bool isInCart) {
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (mealProvider.selectedCafeteriaId == null) {
      Helpers.showSnackBar(context, 'Lütfen önce bir yemekhane seçin', isError: true);
      return;
    }

    if (isInCart) {
      cartProvider.removeFromCart(meal.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.remove_shopping_cart, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Text(
                'Sepetten çıkarıldı',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      cartProvider.addToCart(meal);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${meal.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Sepete eklendi',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'Sepete Git',
            textColor: Colors.white,
            onPressed: () {
              // Sepet sayfasına git
            },
          ),
        ),
      );
    }
  }

  Future<void> _quickReserve(MealModel meal) async {
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser!;

    if (mealProvider.selectedCafeteriaId == null) {
      Helpers.showSnackBar(context, 'Lütfen önce bir yemekhane seçin', isError: true);
      return;
    }

    if (user.balance < meal.reservationPrice) {
      Helpers.showSnackBar(
        context,
        'Yetersiz bakiye! Eksik: ${Helpers.formatCurrency(meal.reservationPrice - user.balance)}',
        isError: true,
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.flash_on, color: AppColors.primaryOrange),
            SizedBox(width: 12),
            Text('Hızlı Rezervasyon'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meal.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ücret:'),
                Text(
                  Helpers.formatCurrency(meal.reservationPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    final success = await reservationProvider.createReservation(
      userId: user.id,
      meal: meal,
    );

    if (!mounted) return;

    if (success) {
      final newBalance = user.balance - meal.reservationPrice;
      authProvider.updateBalance(newBalance);

      final transaction = TransactionModel(
        id: 'trans-${DateTime.now().millisecondsSinceEpoch}',
        userId: user.id,
        type: 'reservation',
        amount: -meal.reservationPrice,
        balanceAfter: newBalance,
        description: 'Rezervasyon - ${meal.name}',
        createdAt: DateTime.now(),
      );
      transactionProvider.addTransaction(transaction);

      // Başarılı rezervasyon animasyonlu mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🎉 Rezervasyon Başarılı!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meal.name,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Yeni bakiye: ${Helpers.formatCurrency(newBalance)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      Helpers.showSnackBar(
        context,
        reservationProvider.errorMessage ?? 'Rezervasyon başarısız',
        isError: true,
      );
    }
  }

  String _getFullDayName(int weekday) {
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return days[(weekday - 1) % days.length];
  }

  String _getFullMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return months[(month - 1) % months.length];
  }

  String _getDayName(int weekday) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    return months[month - 1];
  }
}

// Modern Meal Card Widget - Hover efektleri ile
class _ModernMealCard extends StatefulWidget {
  final MealModel meal;
  final bool isInCart;
  final VoidCallback onAddToCart;
  final VoidCallback onQuickReserve;

  const _ModernMealCard({
    required this.meal,
    required this.isInCart,
    required this.onAddToCart,
    required this.onQuickReserve,
  });

  @override
  State<_ModernMealCard> createState() => _ModernMealCardState();
}

class _ModernMealCardState extends State<_ModernMealCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0, _isHovered ? 1.02 : 1.0, 1.0),
        decoration: BoxDecoration(
          color: AppColors.webCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? AppColors.primaryOrange.withValues(alpha: 0.5)
                : AppColors.grey200.withValues(alpha: 0.5),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.primaryOrange.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: _isHovered ? 12 : 8,
              offset: Offset(0, _isHovered ? 4 : 2),
              spreadRadius: _isHovered ? 2 : 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // İçerik Bölümü - Modern Tasarım
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    AppColors.grey50.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Başlık ve Fiyat
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.meal.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey900,
                            height: 1.25,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryOrange,
                              AppColors.primaryOrange.withValues(alpha: 0.9),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryOrange.withValues(alpha: 0.3),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          Helpers.formatCurrency(widget.meal.reservationPrice),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Açıklama
                  Text(
                    widget.meal.description,
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 10,
                      height: 1.35,
                      letterSpacing: 0.05,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Buton Bölümü - Modern ve Büyük Tasarım
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.grey50,
                    AppColors.grey100.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Sepete Ekle Butonu (Outline) - Modern ve Büyük
                  Expanded(
                    child: _ModernButton(
                      onPressed: widget.onAddToCart,
                      isOutlined: true,
                      isSelected: widget.isInCart,
                      icon: widget.isInCart ? Icons.check_circle : Icons.add_shopping_cart,
                      label: widget.isInCart ? 'Sepette' : 'Sepete Ekle',
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Hızlı Al Butonu (Dolu) - Modern ve Büyük
                  Expanded(
                    child: _ModernButton(
                      onPressed: widget.onQuickReserve,
                      isOutlined: false,
                      icon: Icons.bolt,
                      label: 'Hızlı Al',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modern Buton Widget - Hover ve animasyon efektleri ile
class _ModernButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isOutlined;
  final bool isSelected;
  final IconData icon;
  final String label;

  const _ModernButton({
    required this.onPressed,
    required this.isOutlined,
    this.isSelected = false,
    required this.icon,
    required this.label,
  });

  @override
  State<_ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<_ModernButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOutlined) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() => _isHovered = true);
          _animationController.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _animationController.reverse();
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: _isHovered
                  ? LinearGradient(
                      colors: widget.isSelected
                          ? [
                              AppColors.secondaryGreen.withValues(alpha: 0.15),
                              AppColors.secondaryGreen.withValues(alpha: 0.2),
                            ]
                          : [
                              AppColors.primaryOrange.withValues(alpha: 0.1),
                              AppColors.primaryOrange.withValues(alpha: 0.15),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.secondaryGreen
                    : AppColors.primaryOrange,
                width: _isHovered ? 2.5 : 2,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: (widget.isSelected
                                ? AppColors.secondaryGreen
                                : AppColors.primaryOrange)
                            .withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        size: 18,
                        color: widget.isSelected
                            ? AppColors.secondaryGreen
                            : AppColors.primaryOrange,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.3,
                            color: widget.isSelected
                                ? AppColors.secondaryGreen
                                : AppColors.primaryOrange,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // Hızlı Al Butonu (Dolu)
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() => _isHovered = true);
          _animationController.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _animationController.reverse();
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isHovered
                    ? [
                        AppColors.primaryOrange,
                        AppColors.secondaryOrange,
                      ]
                    : [
                        AppColors.primaryOrange,
                        AppColors.primaryOrange.withValues(alpha: 0.9),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange.withValues(
                    alpha: _isHovered ? 0.6 : 0.4,
                  ),
                  blurRadius: _isHovered ? 10 : 6,
                  offset: Offset(0, _isHovered ? 5 : 3),
                  spreadRadius: _isHovered ? 2 : 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.4,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
