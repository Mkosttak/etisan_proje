import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/cart_provider.dart';
import 'home_screen.dart';
import '../reservations/reservation_list_screen.dart';
import '../reservations/create_reservation_screen.dart';
import '../swap/swap_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(MainNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget güncellendiğinde (örneğin route değiştiğinde) index'i güncelle
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = Helpers.isWeb(context);

    // Web için sayfalar kendi WebLayout'unu kullanıyor, bu yüzden direkt sayfayı göster
    if (isWeb) {
      // Web için route'a göre doğru sayfayı göster
      switch (_currentIndex) {
        case 0:
          return const HomeScreen();
        case 1:
          return const ReservationListScreen();
        case 2:
          return const CreateReservationScreen();
        case 3:
          return const SwapScreen();
        default:
          return const HomeScreen();
      }
    }

    // Mobil için IndexedStack kullan (tüm sayfalar hafızada tutulur)
    final screens = const [
      HomeScreen(),
      ReservationListScreen(),
      CreateReservationScreen(),
      SwapScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
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
              color: AppColors.getShadow(context).withValues(alpha: 0.3),
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
                iconTheme: WidgetStateProperty.all(const IconThemeData(size: 24)),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
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
                // GoRouter ile navigasyon (widget yeniden oluşturulacak ve index güncellenecek)
                switch (index) {
                  case 0:
                    context.go('/home');
                    break;
                  case 1:
                    context.go('/reservations');
                    break;
                  case 2:
                    context.go('/menu');
                    break;
                  case 3:
                    context.go('/swap');
                    break;
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: AppColors.primaryOrange.withValues(alpha: 0.15),
              height: 64,
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
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
                  Icons.event_available_outlined,
                  color: _currentIndex == 1 ? AppColors.primaryOrange : AppColors.getIconColor(context),
                ),
                selectedIcon: Icon(
                  Icons.event_available,
                  color: AppColors.primaryOrange,
                ),
                label: 'Rezervasyonlarım',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.calendar_month_outlined,
                  color: _currentIndex == 2 ? AppColors.primaryOrange : AppColors.getIconColor(context),
                ),
                selectedIcon: Icon(
                  Icons.calendar_month,
                  color: AppColors.primaryOrange,
                ),
                label: 'Rezervasyon Yap',
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
                  color: AppColors.primaryOrange.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () {
                context.push('/cart');
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
}
