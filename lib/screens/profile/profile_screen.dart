import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/layout/web_layout.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/reservation_provider.dart';
import '../auth/login_screen.dart';
import '../balance/transaction_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
    final user = authProvider.currentUser!;
    final isWeb = Helpers.isWeb(context);

    // Get user statistics
    final userReservations = reservationProvider.getUserReservations(user.id);
    final totalReservations = userReservations.length;
    final activeReservations = userReservations.where((r) => r.status == 'reserved' && !r.isPast).length;
    final totalSpent = userReservations
        .where((r) => r.status == 'consumed')
        .fold(0.0, (sum, r) => sum + r.price);

    if (isWeb) {
      return WebLayout(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Profilim',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey900,
                          fontSize: 32,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Profile Header Card
                  _buildWebProfileHeader(context, user),
                  const SizedBox(height: 24),

                  // Stats and Balance Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance Card
                      Expanded(
                        flex: 1,
                        child: _buildWebBalanceCard(context, user),
                      ),
                      const SizedBox(width: 24),
                      // Stats Cards
                      Expanded(
                        flex: 2,
                        child: _buildWebStatsCards(context, totalReservations, activeReservations, totalSpent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // User Info and Settings Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info Card
                      Expanded(
                        flex: 1,
                        child: _buildWebUserInfoCard(context, user),
                      ),
                      const SizedBox(width: 24),
                      // Settings Card
                      Expanded(
                        flex: 1,
                        child: _buildWebSettingsCard(context, themeProvider, authProvider),
                      ),
                    ],
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // App Version
                  Center(
                    child: Text(
                      'ETİSAN v1.0.0',
                      style: const TextStyle(
                        color: AppColors.grey500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Mobile Layout
    final content = SingleChildScrollView(
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
                      color: AppColors.secondaryPurple.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.3),
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
              color: AppColors.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.getBorder(context)),
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
              color: AppColors.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.getBorder(context)),
            ),
            child: Column(
              children: [
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
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr['profile']!),
      ),
      body: content,
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.getIconColor(context), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, {VoidCallback? onTap}) {
    return Builder(
      builder: (context) => ListTile(
        leading: Icon(icon, color: AppColors.getIconColor(context)),
        title: Text(title, style: TextStyle(color: AppColors.getTextPrimary(context))),
        trailing: Icon(Icons.chevron_right, color: AppColors.getIconColor(context)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Builder(
      builder: (context) => ListTile(
        leading: Icon(icon, color: AppColors.getIconColor(context)),
        title: Text(title, style: TextStyle(color: AppColors.getTextPrimary(context))),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryOrange,
        ),
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      leading: Icon(Icons.language, color: AppColors.getIconColor(context)),
      title: Text(AppStrings.tr['language']!, style: TextStyle(color: AppColors.getTextPrimary(context))),
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

  // Web Layout Widgets
  Widget _buildWebProfileHeader(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange,
            AppColors.primaryOrange.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                user.fullName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrange,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
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
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.admin_panel_settings,
                            size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Yönetici',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebBalanceCard(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.webCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.secondaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bakiye',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.grey600,
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.formatCurrency(user.balance),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey900,
                            fontSize: 28,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.go('/balance');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Bakiye Yükle',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebStatsCards(BuildContext context, int totalReservations, int activeReservations, double totalSpent) {
    return Row(
      children: [
        Expanded(
          child: _buildWebStatCard(
            context,
            'Toplam Rezervasyon',
            totalReservations.toString(),
            Icons.event_available,
            AppColors.primaryOrange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildWebStatCard(
            context,
            'Aktif Rezervasyon',
            activeReservations.toString(),
            Icons.calendar_today,
            AppColors.secondaryGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildWebStatCard(
            context,
            'Toplam Harcama',
            Helpers.formatCurrency(totalSpent),
            Icons.payments,
            AppColors.secondaryPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildWebStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.webCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey600,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                  fontSize: 20,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebUserInfoCard(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.webCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kişisel Bilgiler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 20),
          _buildWebInfoTile(Icons.email_outlined, 'E-posta', user.email),
          if (user.phone != null) ...[
            const SizedBox(height: 16),
            _buildWebInfoTile(Icons.phone_outlined, 'Telefon', user.phone!),
          ],
          if (user.school != null) ...[
            const SizedBox(height: 16),
            _buildWebInfoTile(Icons.school_outlined, 'Okul', user.school!),
          ],
          if (user.studentNumber != null && !user.isAdmin) ...[
            const SizedBox(height: 16),
            _buildWebInfoTile(Icons.badge_outlined, 'Öğrenci No', user.studentNumber!),
          ],
          if (user.isAdmin) ...[
            const SizedBox(height: 16),
            _buildWebInfoTile(Icons.admin_panel_settings, 'Rol', 'Yönetici'),
          ],
          const SizedBox(height: 16),
          _buildWebInfoTile(Icons.credit_card_outlined, 'Kart ID', '#${user.id.substring(0, 8)}'),
        ],
      ),
    );
  }

  Widget _buildWebInfoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.grey600, size: 20),
        ),
        const SizedBox(width: 12),
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
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebSettingsCard(BuildContext context, ThemeProvider themeProvider, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.webCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ayarlar',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 20),
          _buildWebSettingTile(
            context,
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
          const SizedBox(height: 12),
          _buildWebSettingTile(
            context,
            Icons.lock_outline,
            AppStrings.tr['changePassword']!,
            onTap: () {
              Helpers.showSnackBar(
                context,
                'Şifre değiştirme özelliği yakında eklenecek',
              );
            },
          ),
          const SizedBox(height: 12),
          _buildWebSwitchTile(
            context,
            Icons.dark_mode_outlined,
            AppStrings.tr['darkMode']!,
            themeProvider.isDarkMode,
            (value) => themeProvider.toggleDarkMode(),
          ),
          const SizedBox(height: 12),
          _buildWebLanguageTile(context, themeProvider),
          const SizedBox(height: 12),
          _buildWebSwitchTile(
            context,
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
    );
  }

  Widget _buildWebSettingTile(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.grey600, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey900,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.grey400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWebSwitchTile(BuildContext context, IconData icon, String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grey600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey900,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildWebLanguageTile(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.language, color: AppColors.grey600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.tr['language']!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey900,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWebLanguageChip('TR', themeProvider.locale == 'tr', () {
                themeProvider.setLocale('tr');
              }),
              const SizedBox(width: 8),
              _buildWebLanguageChip('EN', themeProvider.locale == 'en', () {
                themeProvider.setLocale('en');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebLanguageChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : AppColors.grey200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.grey700,
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
              if (Helpers.isWeb(context)) {
                context.go('/login');
              } else {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
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

