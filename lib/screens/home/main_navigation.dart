import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import 'home_screen.dart';
import '../reservations/reservation_list_screen.dart';
import '../reservations/create_reservation_screen.dart';
import '../reservations/cart_screen.dart';
import '../swap/swap_screen.dart';
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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: true,
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final itemCount = cartProvider.itemCount;
          
          if (itemCount == 0) return const SizedBox.shrink();
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
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
                  return const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey600,
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
                  color: _currentIndex == 0 ? AppColors.primaryOrange : AppColors.grey600,
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
                  color: _currentIndex == 1 ? AppColors.primaryOrange : AppColors.grey600,
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
                  color: _currentIndex == 2 ? AppColors.primaryOrange : AppColors.grey600,
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
                  color: _currentIndex == 3 ? AppColors.primaryOrange : AppColors.grey600,
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
}
