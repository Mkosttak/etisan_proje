import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/layout/app_page_container.dart';
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
    return Scaffold(
      backgroundColor: AppColors.webBackground,
      body: SafeArea(
        child: AppPageContainer(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWebHeader(mealProvider),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final useTwoColumns = constraints.maxWidth > 960;

                    final filters = SizedBox(
                      width: useTwoColumns ? 260 : double.infinity,
                      child: _buildWebFilters(mealProvider),
                    );

                    if (useTwoColumns) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          filters,
                          const SizedBox(width: 24),
                          Expanded(child: _buildWebMealSections(mealProvider)),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        filters,
                        const SizedBox(height: 24),
                        _buildWebMealSections(mealProvider),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildWebHeader(MealProvider mealProvider) {
    final formattedDate = _formatWebDate(_selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.webCard,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menü - $formattedDate',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Günün yemek seçeneklerini keşfet',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWebDateButton(
                Icons.chevron_left,
                () => _changeDate(mealProvider, -1),
              ),
              const SizedBox(width: 12),
              _buildWebDateButton(
                Icons.chevron_right,
                () => _changeDate(mealProvider, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebFilters(MealProvider mealProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWebFilterGroup(
          title: 'Yemekhane',
          children: [
            _buildWebFilterOption(
              mealProvider,
              'cafeteria-1',
              'Merkez',
              Icons.storefront,
            ),
            _buildWebFilterOption(
              mealProvider,
              'cafeteria-2',
              'Mühendislik',
              Icons.engineering,
            ),
            _buildWebFilterOption(
              mealProvider,
              'cafeteria-3',
              'Tıp',
              Icons.local_hospital,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildWebFilterGroup(
          title: 'Diyet',
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildWebDietChip(
                  mealProvider,
                  null,
                  'Hepsi',
                  Icons.grid_view,
                ),
                _buildWebDietChip(
                  mealProvider,
                  'normal',
                  'Normal',
                  Icons.restaurant,
                ),
                _buildWebDietChip(
                  mealProvider,
                  'vegetarian',
                  'Vejetaryen',
                  Icons.eco,
                ),
                _buildWebDietChip(
                  mealProvider,
                  'vegan',
                  'Vegan',
                  Icons.spa,
                ),
                _buildWebDietChip(
                  mealProvider,
                  'gluten_free',
                  'Glutensiz',
                  Icons.grain,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWebFilterGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.webCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildWebFilterOption(
    MealProvider mealProvider,
    String cafeteriaId,
    String label,
    IconData icon,
  ) {
    final isSelected = mealProvider.selectedCafeteriaId == cafeteriaId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (!isSelected) {
            mealProvider.setCafeteriaFilter(cafeteriaId);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primaryOrange.withOpacity(0.12) : null,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryOrange
                  : AppColors.grey200,
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    isSelected ? AppColors.primaryOrange : AppColors.grey500,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryOrange
                        : AppColors.grey700,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primaryOrange,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebDietChip(
    MealProvider mealProvider,
    String? type,
    String label,
    IconData icon,
  ) {
    final isSelected =
        type == null ? mealProvider.selectedMealType == null : mealProvider.selectedMealType == type;

    return FilterChip(
      selected: isSelected,
      onSelected: (_) {
        if (type == null) {
          mealProvider.setMealTypeFilter(null);
        } else {
          mealProvider.setMealTypeFilter(isSelected ? null : type);
        }
      },
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? Colors.white : AppColors.primaryOrange,
      ),
      showCheckmark: false,
      backgroundColor: AppColors.primaryOrange.withOpacity(0.08),
      selectedColor: AppColors.primaryOrange,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.primaryOrange,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      label: Text(label),
    );
  }

  Widget _buildWebMealSections(MealProvider mealProvider) {
    if (mealProvider.isLoading) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppColors.webCard,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 24,
              offset: const Offset(0, 12),
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
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.webCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.error.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mealProvider.errorMessage!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
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
          if (i != sections.length - 1) const SizedBox(height: 28),
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

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.webCard,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  section['icon'] as IconData,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                section['title'] as String,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${meals.length} seçenek',
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (meals.isEmpty)
            _buildWebEmptyState(section['title'] as String)
          else
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: meals.map(_buildWebMealCard).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildWebMealCard(MealModel meal) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = cartProvider.isMealInCart(meal.id);

        return Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.webCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.grey200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          meal.description,
                          style: const TextStyle(
                            color: AppColors.grey600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      Helpers.formatCurrency(meal.reservationPrice),
                      style: const TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildWebTag(Icons.schedule, meal.servingTime),
                  _buildWebTag(
                    Icons.restaurant,
                    _getMealTypeLabel(meal.mealType),
                  ),
                  _buildWebTag(
                    Icons.people_alt_outlined,
                    '${meal.availableSpots}/${meal.totalSpots} kontenjan',
                  ),
                  if (meal.allergens.isNotEmpty)
                    _buildWebTag(
                      Icons.warning_amber_rounded,
                      'Alerjen: ${meal.allergens.join(', ')}',
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _addToCart(meal, isInCart),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: Icon(
                        isInCart ? Icons.check : Icons.shopping_bag_outlined,
                      ),
                      label: Text(isInCart ? 'Sepette' : 'Sepete Ekle'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _quickReserve(meal),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primaryOrange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundColor: AppColors.primaryOrange,
                      ),
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Hızlı Al'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWebTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.grey600),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.grey700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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

  Widget _buildWebDateButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      height: 44,
      width: 44,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: AppColors.primaryOrange),
        ),
        onPressed: onPressed,
        child: Icon(icon, color: AppColors.primaryOrange),
      ),
    );
  }

  void _changeDate(MealProvider mealProvider, int offsetDays) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: offsetDays));
    });
    mealProvider.setDateFilter(_selectedDate);
  }

  String _formatWebDate(DateTime date) {
    return '${date.day} ${_getFullMonthName(date.month)} ${_getFullDayName(date.weekday)}';
  }

  String _getMealTypeLabel(String mealType) {
    switch (mealType) {
      case 'vegetarian':
        return 'Vejetaryen';
      case 'vegan':
        return 'Vegan';
      case 'gluten_free':
        return 'Glutensiz';
      default:
        return 'Normal';
    }
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
