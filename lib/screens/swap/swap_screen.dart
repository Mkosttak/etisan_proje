import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/meal_model.dart';
import '../../data/models/transaction_model.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({super.key});

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCafeteria;
  String? _selectedMealType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      // Kullanıcı tercihlerini uygula
      final user = authProvider.currentUser!;
      if (user.preferredCafeteriaId != null) {
        setState(() {
          _selectedCafeteria = _getCafeteriaName(user.preferredCafeteriaId!);
        });
      }
      
      await reservationProvider.loadReservations(user.id);
    }
  }

  String _getCafeteriaName(String id) {
    switch (id) {
      case 'cafeteria-1':
        return 'Merkez';
      case 'cafeteria-2':
        return 'Mühendislik';
      case 'cafeteria-3':
        return 'Tıp';
      default:
        return 'Merkez';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final reservationProvider = Provider.of<ReservationProvider>(context);
    final user = authProvider.currentUser!;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.secondaryGreen,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(280),
          child: SingleChildScrollView(
            child: Column(
            children: [
              const SizedBox(height: 16),
              // Date Selector
              _buildDateSelector(),
              const SizedBox(height: 12),
              // Cafeteria Filters
              _buildCafeteriaFilters(),
              const SizedBox(height: 8),
              // Meal Type Filters
              _buildMealTypeFilters(),
              const SizedBox(height: 12),
              // Meal Period Tabs
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
                  labelColor: AppColors.secondaryGreen,
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSwapList(reservationProvider, user.id, 'breakfast'),
          _buildSwapList(reservationProvider, user.id, 'lunch'),
          _buildSwapList(reservationProvider, user.id, 'dinner'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.swap_horiz,
              size: 80,
              color: AppColors.secondaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Takas Yok',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Şu anda takasa açık rezervasyon bulunmuyor',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSwapCard(BuildContext context, reservation) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = cartProvider.isMealInCart(reservation.mealId);
    
    Color periodColor;
    IconData periodIcon;
    
    switch (reservation.mealPeriod) {
      case 'breakfast':
        periodColor = AppColors.breakfast;
        periodIcon = Icons.coffee;
        break;
      case 'lunch':
        periodColor = AppColors.lunch;
        periodIcon = Icons.lunch_dining;
        break;
      case 'dinner':
        periodColor = AppColors.dinner;
        periodIcon = Icons.dinner_dining;
        break;
      default:
        periodColor = AppColors.grey500;
        periodIcon = Icons.restaurant;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreen.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Modern Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.secondaryGreen,
                  AppColors.secondaryGreen.withOpacity(0.85),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
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
                  child: Icon(periodIcon, color: periodColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    reservation.mealName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                // Yemekhane Badge ve Interest Count
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.secondaryBlue.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.secondaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            reservation.cafeteriaName,
                            style: const TextStyle(
                              color: AppColors.secondaryBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Interest count - Sadece ikon ve sayı
                    if (reservation.swapInterestedCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people_rounded,
                              size: 18,
                              color: AppColors.primaryOrange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${reservation.swapInterestedCount}',
                              style: const TextStyle(
                                color: AppColors.primaryOrange,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 14),

                // Menü İçeriği
                if (reservation.mealDescription != null && reservation.mealDescription!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: periodColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: periodColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      reservation.mealDescription!,
                      style: TextStyle(
                        color: AppColors.grey700,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                const SizedBox(height: 16),

                // Action Buttons - Sepete Ekle ve Hızlı Al
                Row(
                  children: [
                    // Sepete Ekle Butonu
                    Expanded(
                      flex: 4,
                      child: OutlinedButton.icon(
                        onPressed: () => _addToCart(context, reservation),
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
                          foregroundColor: isInCart ? AppColors.error : AppColors.secondaryGreen,
                          side: BorderSide(
                            color: isInCart ? AppColors.error : AppColors.secondaryGreen,
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
                    // Hızlı Al Butonu
                    Expanded(
                      flex: 5,
                      child: ElevatedButton(
                        onPressed: () => _quickBuySwap(context, reservation),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 3,
                          shadowColor: AppColors.secondaryGreen.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.flash_on, size: 20),
                            SizedBox(width: 6),
                            Text(
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

  // Date Selector - Küçük
  Widget _buildDateSelector() {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        color: isSelected ? AppColors.secondaryGreen : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected ? AppColors.secondaryGreen : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getMonthName(date.month),
                      style: TextStyle(
                        color: isSelected ? AppColors.secondaryGreen : Colors.white70,
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

  // Cafeteria Filters
  Widget _buildCafeteriaFilters() {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            icon: Icons.restaurant_menu,
            label: 'Merkez',
            isSelected: _selectedCafeteria == 'Merkez',
            onTap: () {
              setState(() {
                _selectedCafeteria = _selectedCafeteria == 'Merkez' ? null : 'Merkez';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            icon: Icons.engineering,
            label: 'Mühendislik',
            isSelected: _selectedCafeteria == 'Mühendislik',
            onTap: () {
              setState(() {
                _selectedCafeteria = _selectedCafeteria == 'Mühendislik' ? null : 'Mühendislik';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            icon: Icons.local_hospital,
            label: 'Tıp',
            isSelected: _selectedCafeteria == 'Tıp',
            onTap: () {
              setState(() {
                _selectedCafeteria = _selectedCafeteria == 'Tıp' ? null : 'Tıp';
              });
            },
          ),
        ],
      ),
    );
  }

  // Meal Type Filters
  Widget _buildMealTypeFilters() {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            icon: Icons.restaurant,
            label: 'Normal',
            isSelected: _selectedMealType == 'Normal',
            onTap: () {
              setState(() {
                _selectedMealType = _selectedMealType == 'Normal' ? null : 'Normal';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            icon: Icons.eco,
            label: 'Vejetaryen',
            isSelected: _selectedMealType == 'Vejetaryen',
            onTap: () {
              setState(() {
                _selectedMealType = _selectedMealType == 'Vejetaryen' ? null : 'Vejetaryen';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            icon: Icons.spa,
            label: 'Vegan',
            isSelected: _selectedMealType == 'Vegan',
            onTap: () {
              setState(() {
                _selectedMealType = _selectedMealType == 'Vegan' ? null : 'Vegan';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            icon: Icons.grain,
            label: 'Glutensiz',
            isSelected: _selectedMealType == 'Glutensiz',
            onTap: () {
              setState(() {
                _selectedMealType = _selectedMealType == 'Glutensiz' ? null : 'Glutensiz';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
              color: isSelected ? AppColors.secondaryGreen : Colors.white,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.secondaryGreen : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Swap List by Period
  Widget _buildSwapList(ReservationProvider reservationProvider, String userId, String period) {
    // Map Turkish period name to English
    String periodKey = period;
    if (period == 'Kahvaltı') periodKey = 'breakfast';
    else if (period == 'Öğle Yemeği') periodKey = 'lunch';
    else if (period == 'Akşam Yemeği') periodKey = 'dinner';

    var reservations = reservationProvider.getTransferOpenReservations(userId)
        .where((r) => r.mealPeriod == periodKey);

    // Apply filters
    if (_selectedCafeteria != null) {
      reservations = reservations.where((r) => r.cafeteriaName == _selectedCafeteria);
    }
    if (_selectedMealType != null) {
      // Map Turkish meal type to English
      String mealTypeKey = _selectedMealType!;
      if (_selectedMealType == 'Normal') mealTypeKey = 'normal';
      else if (_selectedMealType == 'Vejetaryen') mealTypeKey = 'vegetarian';
      else if (_selectedMealType == 'Vegan') mealTypeKey = 'vegan';
      else if (_selectedMealType == 'Glutensiz') mealTypeKey = 'gluten_free';
      
      reservations = reservations.where((r) => r.mealType == mealTypeKey);
    }

    // Date filter
    reservations = reservations.where((r) {
      return r.mealDate.year == _selectedDate.year &&
          r.mealDate.month == _selectedDate.month &&
          r.mealDate.day == _selectedDate.day;
    });

    final filteredList = reservations.toList();

    if (filteredList.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.secondaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 180),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final reservation = filteredList[index];
          return _buildSwapCard(context, reservation);
        },
      ),
    );
  }

  // Sepete Ekle
  void _addToCart(BuildContext context, reservation) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    final mealId = reservation.mealId;
    final isInCart = cartProvider.isMealInCart(mealId);
    
    if (isInCart) {
      cartProvider.removeFromCart(mealId);
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
      // ReservationModel'den MealModel oluştur
      final meal = MealModel(
        id: reservation.mealId,
        name: reservation.mealName,
        description: reservation.mealDescription ?? '',
        mealType: reservation.mealType,
        mealPeriod: reservation.mealPeriod,
        mealDate: reservation.mealDate,
        cafeteriaId: reservation.cafeteriaId,
        cafeteriaName: reservation.cafeteriaName,
        reservationPrice: reservation.price,
        walkInPrice: reservation.price * 1.2, // Takas için varsayılan
        totalSpots: 50,
        availableSpots: 10,
        allergens: [],
        createdAt: reservation.createdAt,
        isFromSwap: true, // Takas üzerinden eklendi
      );
      
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
                      reservation.mealName,
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

  // Hızlı Satın Al
  Future<void> _quickBuySwap(BuildContext context, reservation) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser!;

    if (user.balance < reservation.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Yetersiz bakiye! Eksik: ${Helpers.formatCurrency(reservation.price - user.balance)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.flash_on, color: AppColors.secondaryGreen),
            SizedBox(width: 12),
            Text('Hızlı Al'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservation.mealName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (reservation.mealDescription != null)
              Text(
                reservation.mealDescription!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.grey700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ücret:'),
                Text(
                  Helpers.formatCurrency(reservation.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Yeni Bakiye:'),
                Text(
                  Helpers.formatCurrency(user.balance - reservation.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
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
              backgroundColor: AppColors.secondaryGreen,
            ),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // Takas işlemi simülasyonu
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    
    // Bakiye güncelleme
    final newBalance = user.balance - reservation.price;
    authProvider.updateBalance(newBalance);

    // Transaction oluştur
    final transaction = TransactionModel(
      id: 'trans-${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      type: 'swap',
      amount: -reservation.price,
      balanceAfter: newBalance,
      description: 'Takas - ${reservation.mealName}',
      createdAt: DateTime.now(),
    );
    transactionProvider.addTransaction(transaction);

    if (!mounted) return;

    // Başarılı takas mesajı
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
                    '🎉 Satın Alma Başarılı!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reservation.mealName,
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

    // Listeyi yenile
    _loadData();
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

