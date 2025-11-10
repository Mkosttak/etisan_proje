import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/layout/web_layout.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/meal_model.dart';
import '../../data/models/transaction_model.dart';
import 'package:go_router/go_router.dart';

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
    final isWeb = Helpers.isWeb(context);

    if (isWeb) {
      return _buildWebLayout(context, reservationProvider, user.id);
    }

    // Mobil layout - MainNavigation içinde kullanıldığı için Scaffold kullanmıyoruz
    return Column(
      children: [
        // Header bölümü - AppBar yerine Container kullanıyoruz
        Container(
          color: AppColors.secondaryGreen,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildDateSelector(),
                const SizedBox(height: 12),
                _buildCafeteriaFilters(),
                const SizedBox(height: 8),
                _buildMealTypeFilters(),
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
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
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSwapList(reservationProvider, user.id, 'breakfast'),
              _buildSwapList(reservationProvider, user.id, 'lunch'),
              _buildSwapList(reservationProvider, user.id, 'dinner'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebLayout(BuildContext context, ReservationProvider reservationProvider, String userId) {
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
              child: _buildWebFilters(),
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
                    _buildWebHeader(context),
                    const SizedBox(height: 16),
                    _buildWebSwapSections(reservationProvider, userId),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // E TİSAN Yemekhane Başlığı
        Row(
          children: [
            const Icon(
              Icons.swap_horiz,
              size: 24,
              color: AppColors.secondaryGreen,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Transfer Pazarı',
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
        _buildWebDateSelector(),
        const SizedBox(height: 16),
        // Yemekhane Seçimi
        _buildWebCafeteriaSelector(),
        const SizedBox(height: 16),
        // Diyet Seçimi
        _buildWebDietSelector(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildWebDateSelector() {
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
              IconButton(
                onPressed: () => _scrollDateSelector(-1),
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
              Expanded(
                child: _buildWebDateCard(prevDate, false),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _buildWebDateCard(_selectedDate, true),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildWebDateCard(nextDate, false),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _scrollDateSelector(1),
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

  Widget _buildWebDateCard(DateTime date, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondaryGreen
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.secondaryGreen
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
                    ? Colors.white
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
                    ? Colors.white
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
                    ? Colors.white
                    : AppColors.grey500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollDateSelector(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  Widget _buildWebCafeteriaSelector() {
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
              _buildWebCafeteriaRadioOption(
                'Merkez',
                Icons.restaurant,
                onTap: () => setState(() => _selectedCafeteria = 'Merkez'),
              ),
              const SizedBox(height: 6),
              _buildWebCafeteriaRadioOption(
                'Mühendislik',
                Icons.engineering,
                onTap: () => setState(() => _selectedCafeteria = 'Mühendislik'),
              ),
              const SizedBox(height: 6),
              _buildWebCafeteriaRadioOption(
                'Tıp',
                Icons.local_hospital,
                onTap: () => setState(() => _selectedCafeteria = 'Tıp'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebCafeteriaRadioOption(
    String label,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedCafeteria == label;

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
            // Radio widget yerine custom indicator kullanıyoruz (deprecated groupValue/onChanged yerine)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.secondaryGreen : AppColors.grey400,
                  width: 2,
                ),
                color: isSelected ? AppColors.secondaryGreen : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected
                  ? AppColors.secondaryGreen
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

  Widget _buildWebDietSelector() {
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
                null,
                'Normal',
                Icons.restaurant_menu,
                onTap: () => setState(() => _selectedMealType = null),
              ),
              const SizedBox(height: 6),
              _buildWebDietRadioOption(
                'Vejetaryen',
                'Vejetaryen',
                Icons.eco,
                onTap: () => setState(() => _selectedMealType = 'Vejetaryen'),
              ),
              const SizedBox(height: 6),
              _buildWebDietRadioOption(
                'Vegan',
                'Vegan',
                Icons.grass,
                onTap: () => setState(() => _selectedMealType = 'Vegan'),
              ),
              const SizedBox(height: 6),
              _buildWebDietRadioOption(
                'Glutensiz',
                'Glutensiz',
                Icons.grain,
                onTap: () => setState(() => _selectedMealType = 'Glutensiz'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebDietRadioOption(
    String? value,
    String label,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedMealType == value;

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
            // Radio widget yerine custom indicator kullanıyoruz (deprecated groupValue/onChanged yerine)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.secondaryGreen : AppColors.grey400,
                  width: 2,
                ),
                color: isSelected ? AppColors.secondaryGreen : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected
                  ? AppColors.secondaryGreen
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

  Widget _buildWebHeader(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final formattedDate = _formatWebDate(_selectedDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Transfer Pazarı - $formattedDate',
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

  String _formatWebDate(DateTime date) {
    final days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    final months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return '${date.day} ${months[date.month - 1]} ${days[date.weekday - 1]}';
  }

  Widget _buildWebSwapSections(ReservationProvider reservationProvider, String userId) {
    final sections = [
      {'period': 'breakfast', 'title': 'Kahvaltı', 'icon': Icons.coffee},
      {'period': 'lunch', 'title': 'Öğle Yemeği', 'icon': Icons.lunch_dining},
      {'period': 'dinner', 'title': 'Akşam Yemeği', 'icon': Icons.dinner_dining},
    ];

    return Column(
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          _buildWebSwapSection(reservationProvider, userId, sections[i]),
          if (i != sections.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildWebSwapSection(
    ReservationProvider reservationProvider,
    String userId,
    Map<String, dynamic> section,
  ) {
    final period = section['period'] as String;
    var reservations = reservationProvider.getTransferOpenReservations(userId)
        .where((r) => r.mealPeriod == period);

    // Apply filters
    if (_selectedCafeteria != null) {
      reservations = reservations.where((r) => r.cafeteriaName == _selectedCafeteria);
    }
    if (_selectedMealType != null) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kategori Başlığı - Modern Tasarım
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondaryGreen.withValues(alpha: 0.1),
                AppColors.secondaryGreen.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.secondaryGreen.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreen,
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
        // Rezervasyon Kartları (Grid Layout)
        if (filteredList.isEmpty)
          _buildWebEmptyState(section['title'] as String)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              // Haftalık menü sayfasındaki gibi daha fazla sütun ve daha kompakt kartlar
              final crossAxisCount = constraints.maxWidth > 1400
                  ? 6
                  : constraints.maxWidth > 1100
                      ? 5
                      : constraints.maxWidth > 900
                          ? 4
                          : constraints.maxWidth > 700
                              ? 3
                              : 2;
              // Aspect ratio - overflow'u önlemek için biraz daha düşük (daha yüksek kartlar)
              final childAspectRatio = constraints.maxWidth > 800 ? 1.25 : 1.15;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return _buildWebSwapCard(context, filteredList[index]);
                },
              );
            },
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildWebEmptyState(String category) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.webCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.grey200,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.swap_horiz,
              size: 48,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 12),
            Text(
              '$category için takas bulunmuyor',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
              color: AppColors.secondaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.swap_horiz,
              size: 80,
              color: AppColors.secondaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          Builder(
            builder: (context) => Text(
              'Takas Yok',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(context),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) => Text(
              'Şu anda takasa açık rezervasyon bulunmuyor',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebSwapCard(BuildContext context, reservation) {
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

        return _ModernSwapCard(
          reservation: reservation,
          periodColor: periodColor,
          periodIcon: periodIcon,
          isInCart: isInCart,
          onAddToCart: () => _addToCart(context, reservation),
          onQuickBuy: () => _quickBuySwap(context, reservation),
        );
      },
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
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context),
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
                  AppColors.secondaryGreen.withValues(alpha: 0.85),
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
                        color: Colors.black.withValues(alpha: 0.1),
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
                        color: AppColors.secondaryBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.secondaryBlue.withValues(alpha: 0.3),
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
                          color: AppColors.primaryOrange.withValues(alpha: 0.15),
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
                      color: periodColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: periodColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      reservation.mealDescription!,
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                const SizedBox(height: 16),

                // Action Buttons - Modern ve Büyük Tasarım
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
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // Sepete Ekle Butonu (Outline) - Modern ve Büyük
                      Expanded(
                        child: _ModernSwapButton(
                          onPressed: () => _addToCart(context, reservation),
                          isOutlined: true,
                          isSelected: isInCart,
                          icon: isInCart ? Icons.check_circle : Icons.add_shopping_cart,
                          label: isInCart ? 'Sepette' : 'Sepete Ekle',
                          color: isInCart ? AppColors.error : AppColors.secondaryGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Hızlı Al Butonu (Dolu) - Modern ve Büyük
                      Expanded(
                        child: _ModernSwapButton(
                          onPressed: () => _quickBuySwap(context, reservation),
                          isOutlined: false,
                          icon: Icons.bolt,
                          label: 'Hızlı Al',
                          color: AppColors.secondaryGreen,
                        ),
                      ),
                    ],
                  ),
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
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
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
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
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
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
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

// Modern Buton Widget - Hover ve animasyon efektleri ile (Swap Screen için)
class _ModernSwapButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isOutlined;
  final bool isSelected;
  final IconData icon;
  final String label;
  final Color color;

  const _ModernSwapButton({
    required this.onPressed,
    required this.isOutlined,
    this.isSelected = false,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  State<_ModernSwapButton> createState() => _ModernSwapButtonState();
}

class _ModernSwapButtonState extends State<_ModernSwapButton> with SingleTickerProviderStateMixin {
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
                      colors: [
                        widget.color.withValues(alpha: 0.1),
                        widget.color.withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.color,
                width: _isHovered ? 2.5 : 2,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.2),
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
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon,
                        size: 14,
                        color: widget.color,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.1,
                            color: widget.color,
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
                        widget.color,
                        widget.color.withValues(alpha: 0.85),
                      ]
                    : [
                        widget.color,
                        widget.color.withValues(alpha: 0.9),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(
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
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          widget.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.2,
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

// Modern Swap Card Widget - Web için modern kart tasarımı
class _ModernSwapCard extends StatefulWidget {
  final reservation;
  final Color periodColor;
  final IconData periodIcon;
  final bool isInCart;
  final VoidCallback onAddToCart;
  final VoidCallback onQuickBuy;

  const _ModernSwapCard({
    required this.reservation,
    required this.periodColor,
    required this.periodIcon,
    required this.isInCart,
    required this.onAddToCart,
    required this.onQuickBuy,
  });

  @override
  State<_ModernSwapCard> createState() => _ModernSwapCardState();
}

class _ModernSwapCardState extends State<_ModernSwapCard> {
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
                ? AppColors.secondaryGreen.withValues(alpha: 0.5)
                : AppColors.grey200.withValues(alpha: 0.5),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.secondaryGreen.withValues(alpha: 0.15)
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
            // İçerik Bölümü - Overflow'u önlemek için kompakt
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
                          widget.reservation.mealName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey900,
                            height: 1.2,
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
                              AppColors.secondaryGreen,
                              AppColors.secondaryGreen.withValues(alpha: 0.9),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondaryGreen.withValues(alpha: 0.3),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          Helpers.formatCurrency(widget.reservation.price),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Yemekhane ve İlgi Sayısı (kompakt)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.secondaryBlue.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 10,
                                color: AppColors.secondaryBlue,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.reservation.cafeteriaName,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondaryBlue,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (widget.reservation.swapInterestedCount > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_rounded,
                                size: 10,
                                color: AppColors.primaryOrange,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${widget.reservation.swapInterestedCount}',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Açıklama
                  Text(
                    widget.reservation.mealDescription ?? '',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.grey600,
                      height: 1.3,
                      letterSpacing: 0.05,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Buton Bölümü - Overflow'u önlemek için daha kompakt
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                  Expanded(
                    child: _ModernSwapButton(
                      onPressed: widget.onAddToCart,
                      isOutlined: true,
                      isSelected: widget.isInCart,
                      icon: widget.isInCart ? Icons.check_circle : Icons.add_shopping_cart,
                      label: widget.isInCart ? 'Sepette' : 'Sepete Ekle',
                      color: widget.isInCart ? AppColors.error : AppColors.secondaryGreen,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _ModernSwapButton(
                      onPressed: widget.onQuickBuy,
                      isOutlined: false,
                      icon: Icons.bolt,
                      label: 'Hızlı Al',
                      color: AppColors.secondaryGreen,
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

