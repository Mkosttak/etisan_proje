import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/layout/app_page_container.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/loading_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import 'create_reservation_screen.dart';
import 'reservation_detail_screen.dart';

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({super.key});

  @override
  State<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animation_controller, curve: Curves.easeInOut);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  AnimationController get _animation_controller => _animationController;

  @override
  void dispose() {
    _tabController.dispose();
    _animation_controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reservationProvider =
        Provider.of<ReservationProvider>(context, listen: false);

    final user = authProvider.currentUser;
    if (user != null) {
      await reservationProvider.loadReservations(user.id);
      if (mounted) {
        _animation_controller.forward(from: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final reservationProvider = Provider.of<ReservationProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: LoadingWidget()));
    }

    final reservations = reservationProvider.reservations;
    final isLoading = reservationProvider.isLoading && reservations.isEmpty;

    final upcomingReservations = reservations
        .where((r) => r.userId == user.id && !r.isPast && r.status == 'reserved')
        .toList()
      ..sort((a, b) => a.mealDate.compareTo(b.mealDate));

    final pastReservations = reservations
        .where((r) =>
            r.userId == user.id &&
            (r.isPast ||
                r.status == 'consumed' ||
                r.status == 'cancelled' ||
                r.transferredToUserId == user.id))
        .toList()
      ..sort((a, b) => b.mealDate.compareTo(a.mealDate));

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: AppPageContainer(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: isLoading
              ? const LoadingWidget()
              : Column(
                  children: [
                    _buildHeroSection(
                      activeCount: upcomingReservations.length,
                      pastCount: pastReservations.length,
                    ),
                    const SizedBox(height: 16),
                    _buildTabSwitcher(),
                    const SizedBox(height: 12),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildReservationList(
                              upcomingReservations,
                              isUpcoming: true,
                            ),
                            _buildReservationList(
                              pastReservations,
                              isUpcoming: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateReservationScreen()),
          );
        },
        backgroundColor: AppColors.primaryOrange,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Rezervasyon'),
      ),
    );
  }

  Widget _buildReservationList(List reservations,
      {required bool isUpcoming}) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryOrange,
      child: reservations.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: _buildEmptyState(isUpcoming),
              ),
            )
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
              itemCount: reservations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildReservationCard(reservations[index], isUpcoming),
            ),
    );
  }

  Widget _buildEmptyState(bool isUpcoming) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFEDD5), Color(0xFFFFFBF5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange.withOpacity(0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              isUpcoming ? Icons.event_available : Icons.history_toggle_off,
              size: 60,
              color: AppColors.primaryOrange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isUpcoming ? 'Henüz aktif rezervasyon yok' : 'Geçmiş kaydın yok',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            isUpcoming
                ? 'Bugün menü seçerek yerini garantileyebilirsin.'
                : 'Yeni rezervasyonların burada listelenecek.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(reservation, bool isUpcoming) {
    final statusMeta = _statusMeta(reservation.status);
    final periodMeta = _periodMeta(reservation.mealPeriod);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReservationDetailScreen(reservation: reservation),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFFFFBF5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: periodMeta.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(periodMeta.icon, color: periodMeta.color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.mealName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_month,
                                size: 14, color: AppColors.grey500),
                            const SizedBox(width: 4),
                            Text(
                              Helpers.formatDate(
                                reservation.mealDate,
                                'dd MMM yyyy',
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.grey600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time,
                                size: 14, color: AppColors.grey500),
                            const SizedBox(width: 4),
                            Text(
                              Helpers.formatDate(reservation.mealDate, 'HH:mm'),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusMeta.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusMeta.icon, size: 14, color: statusMeta.color),
                        const SizedBox(width: 6),
                        Text(
                          statusMeta.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusMeta.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.location_on_outlined,
                      reservation.cafeteriaName,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.account_balance_wallet_outlined,
                      Helpers.formatCurrency(reservation.price),
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
              if (isUpcoming && reservation.isTransferOpen) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_horiz, size: 16, color: AppColors.warning),
                      SizedBox(width: 8),
                      Text(
                        'Takasa Açık',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, {bool alignEnd = false}) {
    return Row(
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.grey600),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection({
    required int activeCount,
    required int pastCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryOrange, AppColors.secondaryOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Rezervasyonlarım',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Planını kolayca yönet',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.calendar_month, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildHeroStat(
                label: 'Aktif',
                value: activeCount.toString(),
                icon: Icons.event_available,
              ),
              const SizedBox(width: 12),
              _buildHeroStat(
                label: 'Geçmiş',
                value: pastCount.toString(),
                icon: Icons.history,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primaryOrange, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primaryOrange,
          borderRadius: BorderRadius.circular(16),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.grey600,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upcoming, size: 18),
                SizedBox(width: 6),
                Text('Aktif'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 18),
                SizedBox(width: 6),
                Text('Geçmiş'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusMeta _statusMeta(String status) {
    switch (status) {
      case 'reserved':
        return _StatusMeta('Aktif', Icons.check_circle, AppColors.secondaryBlue);
      case 'consumed':
        return _StatusMeta('Tüketildi', Icons.restaurant, AppColors.secondaryGreen);
      case 'cancelled':
        return _StatusMeta('İptal', Icons.cancel, AppColors.secondaryRed);
      case 'transferred':
        return _StatusMeta('Transfer', Icons.swap_horiz, AppColors.secondaryPurple);
      default:
        return _StatusMeta('Bilinmiyor', Icons.info, AppColors.grey500);
    }
  }

  _StatusMeta _periodMeta(String period) {
    switch (period) {
      case 'breakfast':
        return _StatusMeta('', Icons.coffee, AppColors.breakfast);
      case 'lunch':
        return _StatusMeta('', Icons.lunch_dining, AppColors.lunch);
      case 'dinner':
        return _StatusMeta('', Icons.dinner_dining, AppColors.dinner);
      default:
        return _StatusMeta('', Icons.restaurant, AppColors.grey500);
    }
  }
}

class _StatusMeta {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusMeta(this.label, this.icon, this.color);
}
