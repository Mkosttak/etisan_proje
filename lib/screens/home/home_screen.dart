import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/layout/web_layout.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/meal_provider.dart';
import '../../data/models/meal_model.dart';
import '../balance/balance_screen.dart';
import '../reservations/reservation_detail_screen.dart';
import '../reservations/reservation_list_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
    final mealProvider = Provider.of<MealProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await Future.wait([
        reservationProvider.loadReservations(authProvider.currentUser!.id),
        mealProvider.loadMeals(),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final reservationProvider = Provider.of<ReservationProvider>(context);
    final isWeb = Helpers.isWeb(context);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user.isAdmin) {
      return const AdminDashboardScreen();
    }

    final allUserReservations = reservationProvider.reservations
        .where((r) => r.userId == user.id)
        .toList();

    final upcomingReservations = allUserReservations
        .where((r) => r.status == 'reserved' && !r.isPast)
        .take(6)
        .toList()
      ..sort((a, b) => a.mealDate.compareTo(b.mealDate));

    if (isWeb) {
      return _buildWebHome(
        context,
        user,
        upcomingReservations,
        totalReservations: allUserReservations.length,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primaryOrange,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildHeroSection(context, user),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildUpcomingReservations(
                  context,
                  upcomingReservations,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, user) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'Günaydın';
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 17) {
      greeting = 'İyi günler';
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'İyi akşamlar';
      greetingIcon = Icons.nights_stay;
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.getHeroGradient(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(greetingIcon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primaryOrange,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primaryOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bakiyeniz',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Helpers.formatCurrency(user.balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BalanceScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: AppColors.primaryOrange,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Yükle',
                            style: TextStyle(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingReservations(
    BuildContext context,
    List upcomingReservations, {
    bool isWeb = false,
  }) {
    if (upcomingReservations.isEmpty) {
      return Container(
        margin: EdgeInsets.all(isWeb ? 0 : 20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isWeb ? AppColors.webCard : AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadow(context),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy,
                size: 48,
                color: AppColors.primaryOrange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz Rezervasyon Yok',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bugün için bir yemek rezervasyonu yapın!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondary(context),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(isWeb ? 0 : 20, 0, isWeb ? 0 : 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Yaklaşan Rezervasyonlar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReservationListScreen()),
                  );
                },
                child: const Text('Tümü'),
              ),
            ],
          ),
        ),
        if (isWeb)
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: upcomingReservations
                .map(
                  (reservation) => SizedBox(
                    width: 320,
                    child: _buildReservationCard(
                      context,
                      reservation,
                      isWeb: true,
                    ),
                  ),
                )
                .toList(),
          )
        else
          ...upcomingReservations.map((reservation) {
            return _buildReservationCard(context, reservation);
          }).toList(),
      ],
    );
  }

  Widget _buildReservationCard(
    BuildContext context,
    reservation, {
    bool isWeb = false,
  }) {
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
        periodColor = AppColors.primaryOrange;
        periodIcon = Icons.restaurant_menu;
    }

    return GestureDetector(
      onTap: () {
        if (Helpers.isWeb(context)) {
          context.push('/reservation/${reservation.id}');
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReservationDetailScreen(reservation: reservation),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isWeb ? 0 : 20, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isWeb ? AppColors.webCard : AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
          border: isWeb ? Border.all(color: AppColors.grey200) : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadow(context).withValues(alpha: isWeb ? 0.1 : 0.15),
              blurRadius: isWeb ? 12 : 15,
              offset: const Offset(0, 6),
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
                    color: periodColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(periodIcon, color: periodColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.mealName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Helpers.formatDate(reservation.mealDate, 'd MMMM yyyy, HH:mm'),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    reservation.mealPeriod.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.grey500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reservation.cafeteriaName,
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  Helpers.formatCurrency(reservation.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebHome(
    BuildContext context,
    user,
    List upcomingReservations, {
    required int totalReservations,
  }) {
    final firstName = user.fullName.split(' ').first;
    final nextReservation = upcomingReservations.isNotEmpty ? upcomingReservations.first : null;
    
    return WebLayout(
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.secondaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Profile Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hoş Geldin, $firstName',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey900,
                            fontSize: 32,
                          ),
                    ),
                    // Profile Button
                    InkWell(
                      onTap: () {
                        context.go('/profile');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.webCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  user.fullName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryOrange,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Profilim',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.grey900,
                                        fontSize: 14,
                                      ),
                                ),
                                Text(
                                  user.email,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.grey600,
                                        fontSize: 12,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.grey600,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Bakiye ve Rezervasyon Kartları
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bakiye Kartı
                    Expanded(
                      flex: 1,
                      child: _buildWebBalanceCard(context, user),
                    ),
                    const SizedBox(width: 24),
                    // Sıradaki Rezervasyon Kartı
                    Expanded(
                      flex: 1,
                      child: _buildWebNextReservationCard(context, nextReservation),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Hızlı İşlemler Başlığı
                Text(
                  'Hızlı İşlemler',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 20),
                
                // Hızlı İşlemler Kartları
                Row(
                  children: [
                    Expanded(
                      child: _buildWebQuickActionCard(
                        context,
                        icon: Icons.calendar_today,
                        title: 'Yeni Rezervasyon Yap',
                        subtitle: 'Haftalık menüden seçimini yap ve yerini ayırt.',
                        onTap: () {
                          context.go('/menu');
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildWebQuickActionCard(
                        context,
                        icon: Icons.account_balance_wallet,
                        title: 'Bakiye Yükle',
                        subtitle: 'Hesabına güvenli bir şekilde para ekle.',
                        onTap: () {
                          context.go('/balance');
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildWebQuickActionCard(
                        context,
                        icon: Icons.swap_horiz,
                        title: 'Para Transfer Et',
                        subtitle: 'Arkadaşlarına kolayca bakiye gönder.',
                        onTap: () {
                          context.go('/swap');
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Yeni Web Widget'ları
  
  Widget _buildWebBalanceCard(BuildContext context, user) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.go('/balance');
        },
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.secondaryGreen,
                AppColors.secondaryGreen.withValues(alpha: 0.8),
                const Color(0xFF10B981), // Emerald-500
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryGreen.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Mevcut Bakiyeniz',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      Helpers.formatCurrency(user.balance),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 32,
                            letterSpacing: -1.0,
                            height: 1.1,
                          ),
                    ),
                  ],
                ),
                // Buton
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        context.go('/balance');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppColors.secondaryGreen,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Bakiye Yükle',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.secondaryGreen,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebNextReservationCard(BuildContext context, reservation) {
    if (reservation == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.webCard,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadow(context).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: AppColors.grey400,
              ),
              const SizedBox(height: 12),
              Text(
                'Yaklaşan rezervasyon yok',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.grey500,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // Meal görselini provider'dan al
    final mealProvider = Provider.of<MealProvider>(context);
    MealModel? meal;
    try {
      meal = mealProvider.meals.firstWhere(
        (m) => m.id == reservation.mealId,
      );
    } catch (e) {
      meal = null;
    }
    final mealImageUrl = meal?.imageUrl;

    // Tarih formatlaması - "Yarın" veya tarih
    String dateText;
    final now = DateTime.now();
    final reservationDate = reservation.mealDate;
    final difference = reservationDate.difference(now);
    
    if (difference.inDays == 0) {
      dateText = 'Bugün, ${Helpers.formatDate(reservationDate, 'HH:mm')}';
    } else if (difference.inDays == 1) {
      dateText = 'Yarın, ${Helpers.formatDate(reservationDate, 'HH:mm')}';
    } else {
      dateText = Helpers.formatDate(reservationDate, 'd MMMM, HH:mm');
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.webCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sol taraf - Bilgiler
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sıradaki Rezervasyonunuz',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey900,
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dateText,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.grey600,
                              fontSize: 14,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reservation.mealName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey900,
                              fontSize: 18,
                            ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      if (Helpers.isWeb(context)) {
                        context.push('/reservation/${reservation.id}');
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReservationDetailScreen(reservation: reservation),
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: AppColors.grey300),
                      ),
                    ),
                    child: Text(
                      'Detayları Gör',
                      style: TextStyle(
                        color: AppColors.grey700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sağ taraf - Görsel alanı
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                color: AppColors.grey100,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: mealImageUrl != null && mealImageUrl.isNotEmpty
                    ? Image.network(
                        mealImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildMealPlaceholder(),
                      )
                    : _buildMealPlaceholder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlaceholder() {
    return Container(
      color: AppColors.grey100,
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 64,
          color: AppColors.grey300,
        ),
      ),
    );
  }

  Widget _buildWebQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.webCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadow(context).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AppColors.secondaryGreen,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey600,
                      fontSize: 14,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
