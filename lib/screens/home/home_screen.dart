import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/layout/app_page_container.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/meal_provider.dart';
import '../balance/balance_screen.dart';
import '../reservations/create_reservation_screen.dart';
import '../reservations/reservation_detail_screen.dart';
import '../reservations/reservation_list_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../profile/profile_screen.dart';
import '../swap/swap_screen.dart';

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
            color: AppColors.primaryOrange.withOpacity(0.3),
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
                        color: Colors.black.withOpacity(0.1),
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
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
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
                color: AppColors.primaryOrange.withOpacity(0.1),
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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReservationDetailScreen(reservation: reservation),
          ),
        );
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
              color: AppColors.getShadow(context).withOpacity(isWeb ? 0.1 : 0.15),
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
                    color: periodColor.withOpacity(0.1),
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
                    color: AppColors.primaryOrange.withOpacity(0.12),
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
    return Scaffold(
      backgroundColor: AppColors.webBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primaryOrange,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: AppPageContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWebHeader(context, user),
                      const SizedBox(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildWebHeroCard(
                                  context,
                                  user,
                                  totalReservations: totalReservations,
                                  upcomingCount: upcomingReservations.length,
                                ),
                                const SizedBox(height: 24),
                                _buildUpcomingReservations(
                                  context,
                                  upcomingReservations,
                                  isWeb: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          SizedBox(
                            width: 320,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildBalanceSummaryCard(context, user),
                                const SizedBox(height: 24),
                                _buildQuickActionsPanel(context),
                                const SizedBox(height: 24),
                                _buildInsightsPanel(
                                  context,
                                  upcomingCount: upcomingReservations.length,
                                  totalReservations: totalReservations,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebHeader(BuildContext context, user) {
    final firstName = user.fullName.split(' ').first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ana Sayfa',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Merhaba $firstName, bugün neler yapmak istersin?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.grey600,
                  ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.webCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey900,
                        ),
                  ),
                  Text(
                    user.role,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey500,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebHeroCard(
    BuildContext context,
    user, {
    required int totalReservations,
    required int upcomingCount,
  }) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Günaydın';
    } else if (hour < 17) {
      greeting = 'İyi günler';
    } else {
      greeting = 'İyi akşamlar';
    }

    final firstName = user.fullName.split(' ').first;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.webCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $firstName!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Rezervasyonlarını ve bakiye hareketlerini tek bir yerden yönet.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.grey600,
                      ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildHeroActionButton(
                      context,
                      label: 'Yeni Rezervasyon Yap',
                      icon: Icons.add_circle,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CreateReservationScreen(),
                          ),
                        );
                      },
                      isPrimary: true,
                    ),
                    _buildHeroActionButton(
                      context,
                      label: 'Takas Fırsatları',
                      icon: Icons.swap_horiz,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SwapScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          SizedBox(
            width: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bugünün Planı',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey900,
                      ),
                ),
                const SizedBox(height: 16),
                _buildSummaryTile(
                  context,
                  icon: Icons.calendar_month,
                  label: 'Toplam Rezervasyon',
                  value: '$totalReservations',
                ),
                const SizedBox(height: 12),
                _buildSummaryTile(
                  context,
                  icon: Icons.access_time,
                  label: 'Bekleyen Rezervasyon',
                  value: '$upcomingCount',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.grey600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: isPrimary ? AppColors.primaryOrange : AppColors.webCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : AppColors.primaryOrange,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isPrimary ? Colors.white : AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSummaryCard(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.webCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context).withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bakiyen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            Helpers.formatCurrency(user.balance),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryOrange,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BalanceScreen()),
                );
              },
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('Bakiye Yükle'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.webCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı İşlemler',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionTile(
            context,
            icon: Icons.restaurant_menu,
            title: 'Menüyü İncele',
            subtitle: 'Bugünkü yemekleri görüntüle',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateReservationScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildQuickActionTile(
            context,
            icon: Icons.swap_horiz,
            title: 'Transfer Pazarı',
            subtitle: 'Takas fırsatlarını keşfet',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SwapScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildQuickActionTile(
            context,
            icon: Icons.receipt_long,
            title: 'Rezervasyon Geçmişi',
            subtitle: 'Tüm geçmiş işlemlerini gör',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReservationListScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primaryOrange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey600,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsPanel(
    BuildContext context, {
    required int upcomingCount,
    required int totalReservations,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.webCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı Bakış',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
          ),
          const SizedBox(height: 16),
          _buildInsightMetric(
            context,
            label: 'Aktif Rezervasyon',
            value: upcomingCount.toString(),
          ),
          const SizedBox(height: 12),
          _buildInsightMetric(
            context,
            label: 'Toplam Rezervasyon',
            value: totalReservations.toString(),
          ),
          const SizedBox(height: 12),
          _buildInsightMetric(
            context,
            label: 'Son Güncelleme',
            value: Helpers.formatDate(DateTime.now(), 'd MMMM, HH:mm'),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightMetric(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
        ),
      ],
    );
  }
}
