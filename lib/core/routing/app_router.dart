import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/main_navigation.dart';
import '../../screens/reservations/reservation_list_screen.dart';
import '../../screens/reservations/reservation_detail_screen.dart';
import '../../screens/reservations/create_reservation_screen.dart';
import '../../screens/swap/swap_screen.dart';
import '../../screens/balance/balance_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/reservations/cart_screen.dart';
import '../../providers/reservation_provider.dart';
import '../../core/utils/helpers.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final location = state.matchedLocation;
      final isOnAuthPage = location == '/' || 
                          location == '/login' ||
                          location == '/register';

      // Eğer kullanıcı giriş yapmamışsa ve auth sayfasında değilse, login'e yönlendir
      if (!isAuthenticated && !isOnAuthPage) {
        return '/login';
      }

      // Eğer kullanıcı giriş yapmışsa ve auth sayfasındaysa (splash hariç), ana sayfaya yönlendir
      if (isAuthenticated && isOnAuthPage && location != '/') {
        return '/home';
      }

      return null; // Yönlendirme gerekmiyor
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          final isWeb = Helpers.isWeb(context);
          if (isWeb) {
            return const HomeScreen();
          }
          return const MainNavigation(initialIndex: 0);
        },
      ),
      GoRoute(
        path: '/menu',
        name: 'menu',
        builder: (context, state) {
          final isWeb = Helpers.isWeb(context);
          if (isWeb) {
            return const CreateReservationScreen();
          }
          return const MainNavigation(initialIndex: 2);
        },
      ),
      GoRoute(
        path: '/reservations',
        name: 'reservations',
        builder: (context, state) {
          final isWeb = Helpers.isWeb(context);
          if (isWeb) {
            return const ReservationListScreen();
          }
          return const MainNavigation(initialIndex: 1);
        },
      ),
      GoRoute(
        path: '/reservation/:id',
        name: 'reservation-detail',
        builder: (context, state) {
          final reservationId = state.pathParameters['id']!;
          final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
          final reservation = reservationProvider.getReservationById(reservationId);
          
          if (reservation == null) {
            // Rezervasyon bulunamadıysa, rezervasyonlar listesine yönlendir
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Rezervasyon bulunamadı'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/reservations'),
                      child: const Text('Rezervasyonlara Dön'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return ReservationDetailScreen(reservation: reservation);
        },
      ),
      GoRoute(
        path: '/balance',
        name: 'balance',
        builder: (context, state) => const BalanceScreen(),
      ),
      GoRoute(
        path: '/swap',
        name: 'swap',
        builder: (context, state) {
          final isWeb = Helpers.isWeb(context);
          if (isWeb) {
            return const SwapScreen();
          }
          return const MainNavigation(initialIndex: 3);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Sayfa bulunamadı',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.matchedLocation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );
}

