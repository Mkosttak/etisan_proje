import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class WebLayout extends StatelessWidget {
  final Widget child;
  final Widget? floatingActionButton;

  const WebLayout({
    super.key,
    required this.child,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.webBackground,
      body: Row(
        children: [
          _buildWebSidebar(context),
          Expanded(
            child: Container(
              color: AppColors.webBackground,
              child: child,
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildWebSidebar(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // GoRouter'dan mevcut location'ı al (güvenli şekilde)
    String location = '/';
    try {
      final routerState = GoRouterState.of(context);
      location = routerState.matchedLocation;
    } catch (e) {
      // GoRouter state yoksa (örneğin Navigator.push ile açılan sayfalar için)
      // Default olarak '/' kullan
      location = '/';
    }
    
    // Mevcut route'a göre hangi menü öğesinin seçili olduğunu belirle
    final isHome = location == '/home' || location == '/';
    final isMenu = location == '/menu';
    final isReservations = location == '/reservations' || location.startsWith('/reservation');
    final isBalance = location == '/balance';
    final isSwap = location == '/swap';
    final isProfile = location == '/profile';

    final items = [
      _WebNavItem(
        icon: Icons.home_outlined,
        label: 'Ana Sayfa',
        isSelected: isHome,
        onTap: () {
          context.go('/home');
        },
      ),
      _WebNavItem(
        icon: Icons.calendar_month_outlined,
        label: 'Rezervasyon Yap',
        isSelected: isMenu,
        onTap: () {
          context.go('/menu');
        },
      ),
      _WebNavItem(
        icon: Icons.event_available_outlined,
        label: 'Rezervasyonlarım',
        isSelected: isReservations,
        onTap: () {
          context.go('/reservations');
        },
      ),
      _WebNavItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Bakiye Yükle',
        isSelected: isBalance,
        onTap: () {
          context.go('/balance');
        },
      ),
      _WebNavItem(
        icon: Icons.swap_horiz_outlined,
        label: 'Takas',
        isSelected: isSwap,
        onTap: () {
          context.go('/swap');
        },
      ),
      _WebNavItem(
        icon: Icons.person_outline,
        label: 'Profilim',
        isSelected: isProfile,
        onTap: () {
          context.go('/profile');
        },
      ),
    ];

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.webSidebar,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(6, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'E',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'E TİSAN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: AppColors.grey900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Yemekhane Sistemi',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: item.onTap,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: item.isSelected
                                ? AppColors.secondaryGreen.withValues(alpha: 0.1)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                color: item.isSelected
                                    ? AppColors.secondaryGreen
                                    : AppColors.grey600,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: item.isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: item.isSelected
                                        ? AppColors.secondaryGreen
                                        : AppColors.grey700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            if (user != null) ...[
              const Divider(height: 24),
              InkWell(
                onTap: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.logout,
                        color: AppColors.grey600,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Çıkış Yap',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WebNavItem {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  _WebNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
}

