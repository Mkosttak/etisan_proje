from pathlib import Path
content = """import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
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

class _NavigationItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavigationItem(this.label, this.icon, this.activeIcon);
}

const List<_NavigationItem> _navItems = [
  _NavigationItem('Ana Sayfa', Icons.home_outlined, Icons.home),
  _NavigationItem('Rezervasyon', Icons.restaurant_menu_outlined, Icons.restaurant_menu),
  _NavigationItem('Oluştur', Icons.add_circle_outline, Icons.add_circle),
  _NavigationItem('Takas', Icons.swap_horiz_outlined, Icons.swap_horiz),
];

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
    final bool useRail = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      body: useRail
          ? Row(
              children: [
                _buildNavigationRail(),
                const VerticalDivider(width: 1),
                Expanded(child: _buildBody()),
              ],
            )
          : _buildBody(),
      extendBody: true,
      bottomNavigationBar: useRail ? null : _buildBottomNavigation(),
    );
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _currentIndex,
      children: _screens,
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              iconTheme: MaterialStateProperty.all(const IconThemeData(size: 22)),
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
              setState(() => _currentIndex = index);
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: AppColors.primaryOrange.withOpacity(0.15),
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            destinations: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = _currentIndex == index;
              return NavigationDestination(
                icon: Icon(
                  item.icon,
                  color: isSelected ? AppColors.primaryOrange : AppColors.grey600,
                ),
                selectedIcon: Icon(item.activeIcon, color: AppColors.primaryOrange),
                label: item.label,
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() => _currentIndex = index);
      },
      extended: true,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primaryOrange.withOpacity(0.12),
      leading: Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 32),
        child: Text(
          'ETİSAN',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryOrange,
              ),
        ),
      ),
      destinations: List.generate(_navItems.length, (index) {
        final item = _navItems[index];
        return NavigationRailDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.activeIcon, color: AppColors.primaryOrange),
          label: Text(item.label),
        );
      }),
    );
  }
}
"""
Path(r"lib/screens/home/main_navigation.dart").write_text(content)
