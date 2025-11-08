import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/meal_model.dart';
import '../../data/models/transaction_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: const Text('Sepetim'),
        backgroundColor: AppColors.primaryOrange,
        actions: [
          if (cartProvider.itemCount > 0)
            TextButton.icon(
              onPressed: () {
                cartProvider.clearCart();
                Helpers.showSnackBar(context, 'Sepet temizlendi');
              },
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              label: const Text(
                'Temizle',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: cartProvider.itemCount == 0
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: cartProvider.cartItems.length,
                    itemBuilder: (context, index) {
                      // En yakından en uzağa sıralama
                      final sortedItems = List<MealModel>.from(cartProvider.cartItems)
                        ..sort((a, b) => a.mealDate.compareTo(b.mealDate));
                      final meal = sortedItems[index];
                      return _buildCartItem(context, meal, cartProvider);
                    },
                  ),
                ),
                _buildBottomBar(context, cartProvider, authProvider),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: AppColors.grey400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sepetiniz Boş',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Henüz sepetinize ürün eklemediniz',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.restaurant),
            label: const Text('Yemeklere Göz At'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, MealModel meal, CartProvider cartProvider) {
    Color periodColor;
    IconData periodIcon;
    
    switch (meal.mealPeriod) {
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        periodColor.withOpacity(0.2),
                        periodColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    periodIcon,
                    size: 40,
                    color: periodColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: periodColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                meal.mealPeriod == 'breakfast'
                                    ? 'Kahvaltı'
                                    : meal.mealPeriod == 'lunch'
                                        ? 'Öğle'
                                        : 'Akşam',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: periodColor,
                                ),
                              ),
                            ),
                            if (meal.isFromSwap) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryGreen.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.secondaryGreen.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.swap_horiz_rounded,
                                      size: 12,
                                      color: AppColors.secondaryGreen,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Takas',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                Helpers.formatDate(meal.mealDate, 'dd MMM yyyy'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Helpers.formatCurrency(meal.reservationPrice),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () {
                cartProvider.removeFromCart(meal.id);
                Helpers.showSnackBar(context, 'Sepetten çıkarıldı');
              },
              icon: const Icon(Icons.delete_outline),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(0.1),
                padding: const EdgeInsets.all(8),
              ),
              iconSize: 22,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CartProvider cartProvider, AuthProvider authProvider) {
    final total = cartProvider.totalPrice;
    final user = authProvider.currentUser!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Toplam',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700,
                  ),
                ),
                Text(
                  Helpers.formatCurrency(total),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, size: 16, color: AppColors.grey600),
                const SizedBox(width: 8),
                Text(
                  'Bakiye: ${Helpers.formatCurrency(user.balance)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _processCartReservations(context, cartProvider, authProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 22),
                    SizedBox(width: 12),
                    Text(
                      'Rezervasyonu Tamamla',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processCartReservations(
    BuildContext context,
    CartProvider cartProvider,
    AuthProvider authProvider,
  ) async {
    final user = authProvider.currentUser!;
    final meals = cartProvider.cartItems;
    final total = cartProvider.totalPrice;

    if (user.balance < total) {
      Helpers.showSnackBar(
        context,
        'Yetersiz bakiye! Eksik: ${Helpers.formatCurrency(total - user.balance)}',
        isError: true,
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryOrange),
            SizedBox(width: 12),
            Text('Rezervasyon Onayı'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${meals.length} adet rezervasyon oluşturulacak'),
            const SizedBox(height: 8),
            Text(
              'Toplam: ${Helpers.formatCurrency(total)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
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
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    int successCount = 0;
    int failCount = 0;

    for (final meal in meals) {
      final success = await reservationProvider.createReservation(
        userId: user.id,
        meal: meal,
      );

      if (success) {
        successCount++;
        final newBalance = authProvider.currentUser!.balance - meal.reservationPrice;
        authProvider.updateBalance(newBalance);

        final transaction = TransactionModel(
          id: 'trans-${DateTime.now().millisecondsSinceEpoch}',
          userId: user.id,
          type: 'reservation',
          amount: -meal.reservationPrice,
          balanceAfter: newBalance,
          description: 'Rezervasyon - ${meal.name}',
          createdAt: DateTime.now(),
        );
        transactionProvider.addTransaction(transaction);
      } else {
        failCount++;
        if (context.mounted) {
          Helpers.showSnackBar(
            context,
            '${meal.name} rezerve edilemedi: ${reservationProvider.errorMessage}',
            isError: true,
          );
        }
      }
    }

    if (context.mounted) {
      Helpers.showSnackBar(
        context,
        '$successCount rezervasyon başarılı${failCount > 0 ? ", $failCount başarısız" : ""}',
      );
      
      if (successCount > 0) {
        cartProvider.clearCart();
        Navigator.pop(context);
      }
    }
  }
}

