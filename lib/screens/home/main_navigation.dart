import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import 'home_screen.dart';
import '../reservations/reservation_list_screen.dart';
import '../reservations/create_reservation_screen.dart';
import '../reservations/cart_screen.dart';
import '../swap/swap_screen.dart';
import '../balance/balance_screen.dart';
import '../profile/profile_screen.dart';
// Profile is opened from Home header; no separate tab

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = const [
      HomeScreen(),
      ReservationListScreen(),
      CreateReservationScreen(),
      SwapScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = Helpers.isWeb(context);

    if (isWeb) {
      return Scaffold(
        backgroundColor: AppColors.webBackground,
        body: Row(
          children: [
            _buildWebSidebar(context),
            Expanded(
              child: Container(
                color: AppColors.webBackground,
                child: IndexedStack(
                  index: _currentIndex,
                  children: _screens,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildCartFab(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: true,
      floatingActionButton: _buildCartFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.getBottomNavBackground(context),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadow(context).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Theme(
            data: Theme.of(context).copyWith(
              navigationBarTheme: NavigationBarThemeData(
                iconTheme: MaterialStateProperty.all(const IconThemeData(size: 24)),
                labelTextStyle: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryOrange,
                      overflow: TextOverflow.ellipsis,
                      height: 1.2,
                    );
                  }
                  return TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getTextSecondary(context),
                    overflow: TextOverflow.ellipsis,
                    height: 1.2,
                  );
                }),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: AppColors.primaryOrange.withOpacity(0.15),
              height: 64,
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                  color: _currentIndex == 0 ? AppColors.primaryOrange : AppColors.getIconColor(context),
                ),
                selectedIcon: Icon(
                  Icons.home,
                  color: AppColors.primaryOrange,
                ),
                label: 'Ana Sayfa',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.restaurant_menu_outlined,
                  color: _currentIndex == 1 ? AppColors.primaryOrange : AppColors.getIconColor(context),
                ),
                selectedIcon: Icon(
                  Icons.restaurant_menu,
                  color: AppColors.primaryOrange,
                ),
                label: 'Rezervasyon',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: _currentIndex == 2 ? AppColors.primaryOrange : AppColors.getIconColor(context),
                ),
                selectedIcon: Icon(
                  Icons.add_circle,
                  color: AppColors.primaryOrange,
                ),
                label: 'Oluştur',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.swap_horiz_outlined,
                  color: _currentIndex == 3 ? AppColors.primaryOrange : AppColors.getIconColor(context),
                ),
                selectedIcon: Icon(
                  Icons.swap_horiz,
                  color: AppColors.primaryOrange,
                ),
                label: 'Takas',
              ),
              // Profile entry removed from bottom nav; accessible from Home header icon
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildCartFab(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final itemCount = cartProvider.itemCount;

        if (itemCount == 0) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              backgroundColor: AppColors.primaryOrange,
              elevation: 0,
              heroTag: 'cart_button',
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_rounded, size: 26),
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryOrange, width: 2),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 22,
                        minHeight: 22,
                      ),
                      child: Text(
                        '$itemCount',
                        style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              label: const Text(
                'Sepet',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebSidebar(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    final items = [
      _WebNavItem(
        icon: Icons.home_outlined,
        label: 'Ana Sayfa',
        index: 0,
      ),
      _WebNavItem(
        icon: Icons.calendar_month_outlined,
        label: 'Haftalık Menü',
        index: 2,
      ),
      _WebNavItem(
        icon: Icons.event_available_outlined,
        label: 'Rezervasyon Yap',
        index: 1,
      ),
      _WebNavItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Bakiye Yükle',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BalanceScreen()),
          );
        },
      ),
      _WebNavItem(
        icon: Icons.swap_horiz_outlined,
        label: 'Transfer Yap',
        index: 3,
      ),
      _WebNavItem(
        icon: Icons.person_outline,
        label: 'Profilim',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
      ),
    ];

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.webSidebar,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: AppColors.primaryOrange,
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
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected =
                      item.index != null && _currentIndex == item.index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        if (item.index != null) {
                          setState(() {
                            _currentIndex = item.index!;
                          });
                        }
                        item.onTap?.call();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? AppColors.webSidebarHighlight : null,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected
                                  ? AppColors.primaryOrange
                                  : AppColors.grey500,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primaryOrange
                                      : AppColors.grey600,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.primaryOrange,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (user != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryOrange.withOpacity(0.2),
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0] : '?',
                        style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Helpers.formatCurrency(user.balance),
                            style: const TextStyle(
                              color: AppColors.grey600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
  final int? index;
  final VoidCallback? onTap;

  _WebNavItem({
    required this.icon,
    required this.label,
    this.index,
    this.onTap,
  });
}
