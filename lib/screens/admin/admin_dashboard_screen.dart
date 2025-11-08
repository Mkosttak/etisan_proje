import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import 'meal_management_screen.dart';
import 'students_screen.dart';
import 'reports_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr['dashboard']!),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    AppStrings.tr['totalReservations']!,
                    '1,234',
                    Icons.restaurant_menu,
                    AppColors.primaryOrange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    AppStrings.tr['totalRevenue']!,
                    '₺45,678',
                    Icons.attach_money,
                    AppColors.secondaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    AppStrings.tr['cancellationRate']!,
                    '8.5%',
                    Icons.cancel,
                    AppColors.error,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    AppStrings.tr['wasteReport']!,
                    '3.2%',
                    Icons.delete_outline,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Hızlı İşlemler',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildActionCard(
              Icons.add_circle_outline,
              AppStrings.tr['addMeal']!,
              AppStrings.tr['addMealDesc']!,
              AppColors.primaryOrange,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MealManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              Icons.edit_outlined,
              AppStrings.tr['menuManagement']!,
              AppStrings.tr['menuManagementDesc']!,
              AppColors.secondaryBlue,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MealManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              Icons.people_outline,
              AppStrings.tr['students']!,
              AppStrings.tr['studentsDesc']!,
              AppColors.secondaryPurple,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StudentsScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              Icons.bar_chart,
              AppStrings.tr['reports']!,
              AppStrings.tr['reportsDesc']!,
              AppColors.secondaryGreen,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReportsScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              Icons.settings_outlined,
              AppStrings.tr['schoolSettings']!,
              AppStrings.tr['schoolSettingsDesc']!,
              AppColors.grey700,
              () {
                Helpers.showSnackBar(
                  context,
                  'Okul ayarları özelliği yakında eklenecek',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.grey600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String title,
    String description,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.grey600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: AppColors.grey400, size: 20),
          ],
        ),
      ),
    );
  }
}

