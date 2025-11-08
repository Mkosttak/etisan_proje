import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';
import '../balance/transaction_history_screen.dart';
import 'preferences_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr['profile']!),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.darkGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.white,
                    child: Text(
                      user.fullName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grey300,
                    ),
                  ),
                  if (user.isAdmin) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryPurple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.admin_panel_settings,
                              size: 16, color: AppColors.white),
                          SizedBox(width: 6),
                          Text(
                            'Admin',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // User Info
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                children: [
                  _buildInfoTile(
                    Icons.email_outlined,
                    AppStrings.tr['email']!,
                    user.email,
                  ),
                  if (user.phone != null) ...[
                    const Divider(height: 1),
                    _buildInfoTile(
                      Icons.phone_outlined,
                      AppStrings.tr['phone']!,
                      user.phone!,
                    ),
                  ],
                  if (user.school != null) ...[
                    const Divider(height: 1),
                    _buildInfoTile(
                      Icons.school_outlined,
                      AppStrings.tr['school']!,
                      user.school!,
                    ),
                  ],
                  if (user.studentNumber != null && !user.isAdmin) ...[
                    const Divider(height: 1),
                    _buildInfoTile(
                      Icons.badge_outlined,
                      AppStrings.tr['studentNumber']!,
                      user.studentNumber!,
                    ),
                  ],
                  if (user.isAdmin) ...[
                    const Divider(height: 1),
                    _buildInfoTile(
                      Icons.admin_panel_settings,
                      'Rol',
                      'Yönetici',
                    ),
                  ],
                  const Divider(height: 1),
                  _buildInfoTile(
                    Icons.credit_card_outlined,
                    AppStrings.tr['cardId']!,
                    '#${user.id.substring(0, 8)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    Icons.restaurant_menu,
                    'Yemek Tercihleri',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PreferencesScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(
                    Icons.receipt_long,
                    AppStrings.tr['transactionHistory']!,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TransactionHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(
                    Icons.lock_outline,
                    AppStrings.tr['changePassword']!,
                    onTap: () {
                      Helpers.showSnackBar(
                        context,
                        'Şifre değiştirme özelliği yakında eklenecek',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    Icons.dark_mode_outlined,
                    AppStrings.tr['darkMode']!,
                    themeProvider.isDarkMode,
                    (value) => themeProvider.toggleDarkMode(),
                  ),
                  const Divider(height: 1),
                  _buildLanguageTile(context, themeProvider),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    Icons.notifications_outlined,
                    AppStrings.tr['notifications']!,
                    true,
                    (value) {
                      Helpers.showSnackBar(
                        context,
                        'Bildirim ayarları yakında eklenecek',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _logout(context, authProvider),
                icon: const Icon(Icons.logout),
                label: Text(AppStrings.tr['logout']!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // App Version
            Text(
              'ETİSAN v1.0.0',
              style: const TextStyle(
                color: AppColors.grey500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grey500, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.grey600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey700),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey700),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryOrange,
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      leading: const Icon(Icons.language, color: AppColors.grey700),
      title: Text(AppStrings.tr['language']!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageChip('TR', themeProvider.locale == 'tr', () {
            themeProvider.setLocale('tr');
          }),
          const SizedBox(width: 8),
          _buildLanguageChip('EN', themeProvider.locale == 'en', () {
            themeProvider.setLocale('en');
          }),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange
              : AppColors.grey100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.grey700,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.tr['logout']!),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.tr['cancel']!),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(AppStrings.tr['logout']!),
          ),
        ],
      ),
    );
  }
}

