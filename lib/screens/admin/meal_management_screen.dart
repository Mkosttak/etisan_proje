import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/meal_provider.dart';

class MealManagementScreen extends StatelessWidget {
  const MealManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menü Yönetimi'),
      ),
      body: mealProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: mealProvider.meals.length,
              itemBuilder: (context, index) {
                final meal = mealProvider.meals[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Helpers.getMealTypeColor(meal.mealType).withOpacity(0.2),
                      child: Icon(
                        Helpers.getMealTypeIcon(meal.mealType),
                        color: Helpers.getMealTypeColor(meal.mealType),
                      ),
                    ),
                    title: Text(meal.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Helpers.formatDate(meal.mealDate, 'dd MMM yyyy')),
                        Text(
                          '${meal.availableSpots}/${meal.totalSpots} yer',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Text(
                      Helpers.formatCurrency(meal.reservationPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Helpers.showSnackBar(context, 'Yemek ekleme formu yakında eklenecek');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

