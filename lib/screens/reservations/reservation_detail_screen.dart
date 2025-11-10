import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/layout/web_layout.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/reservation_model.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';

class ReservationDetailScreen extends StatefulWidget {
  final ReservationModel reservation;

  const ReservationDetailScreen({super.key, required this.reservation});

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final isWeb = Helpers.isWeb(context);
    final color = Helpers.getMealPeriodColor(widget.reservation.mealPeriod);
    final icon = Helpers.getMealPeriodIcon(widget.reservation.mealPeriod);
    final canCancel = widget.reservation.canBeCancelled;
    final isActive = widget.reservation.status == 'reserved';

    if (isWeb) {
      return _buildWebLayout(context, color, icon, canCancel, isActive);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervasyon Detayı'),
        backgroundColor: AppColors.primaryOrange,
      ),
      body: _buildMobileLayout(context, color, icon, canCancel, isActive),
    );
  }

  Widget _buildWebLayout(
    BuildContext context,
    Color color,
    IconData icon,
    bool canCancel,
    bool isActive,
  ) {
    return WebLayout(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Back Button
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/reservations'),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Rezervasyon Detayı',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey900,
                            fontSize: 28,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Main Content Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column - Menu Card and Details
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          // Menu Header Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withValues(alpha: 0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    icon,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  widget.reservation.mealName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  Helpers.formatDate(
                                    widget.reservation.mealDate,
                                    'EEEE, dd MMMM yyyy',
                                  ),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Details Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                                  'Rezervasyon Bilgileri',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.grey900,
                                        fontSize: 20,
                                      ),
                                ),
                                const SizedBox(height: 24),
                                _buildWebDetailRow(
                                  Icons.access_time,
                                  'Saat',
                                  Helpers.formatDate(widget.reservation.mealDate, 'HH:mm'),
                                ),
                                const SizedBox(height: 20),
                                _buildWebDetailRow(
                                  Icons.restaurant,
                                  'Öğün',
                                  widget.reservation.mealPeriod == 'breakfast'
                                      ? 'Kahvaltı'
                                      : widget.reservation.mealPeriod == 'lunch'
                                          ? 'Öğle Yemeği'
                                          : 'Akşam Yemeği',
                                ),
                                const SizedBox(height: 20),
                                _buildWebDetailRow(
                                  Icons.location_on,
                                  'Yemekhane',
                                  widget.reservation.cafeteriaName,
                                ),
                                const SizedBox(height: 20),
                                _buildWebDetailRow(
                                  Icons.account_balance_wallet,
                                  'Ücret',
                                  Helpers.formatCurrency(widget.reservation.price),
                                  valueColor: AppColors.primaryOrange,
                                ),
                                const SizedBox(height: 20),
                                _buildWebDetailRow(
                                  Icons.info_outline,
                                  'Durum',
                                  widget.reservation.status == 'reserved'
                                      ? 'Aktif'
                                      : widget.reservation.status == 'consumed'
                                          ? 'Tüketildi'
                                          : widget.reservation.status == 'cancelled'
                                              ? 'İptal'
                                              : 'Bilinmiyor',
                                  valueColor: widget.reservation.status == 'reserved'
                                      ? AppColors.secondaryGreen
                                      : widget.reservation.status == 'consumed'
                                          ? AppColors.secondaryBlue
                                          : AppColors.secondaryRed,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 24),

                    // Right Column - QR Code and Actions
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          // QR Code Card
                          if (isActive) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                                children: [
                                  Text(
                                    'QR Kod',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.grey900,
                                          fontSize: 20,
                                        ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.grey200,
                                        width: 2,
                                      ),
                                    ),
                                    child: QrImageView(
                                      data: widget.reservation.id,
                                      version: QrVersions.auto,
                                      size: 220,
                                      backgroundColor: Colors.white,
                                      eyeStyle: const QrEyeStyle(
                                        eyeShape: QrEyeShape.square,
                                        color: AppColors.black,
                                      ),
                                      dataModuleStyle: const QrDataModuleStyle(
                                        dataModuleShape: QrDataModuleShape.square,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Yemek almak için bu kodu gösterin',
                                    style: TextStyle(
                                      color: AppColors.grey600,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Action Buttons
                          if (isActive) ...[
                            // Satışa Çıkar Butonu
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _openForSwap(context),
                                icon: Icon(
                                  widget.reservation.isTransferOpen
                                      ? Icons.shopping_bag
                                      : Icons.sell_outlined,
                                  size: 20,
                                ),
                                label: Text(
                                  widget.reservation.isTransferOpen
                                      ? 'Satıştan Kaldır'
                                      : 'Satışa Çıkar',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.reservation.isTransferOpen
                                      ? AppColors.warning
                                      : AppColors.secondaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // İptal Butonu
                            if (canCancel)
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _cancelReservation(context),
                                  icon: const Icon(Icons.cancel_outlined, size: 20),
                                  label: const Text('Rezervasyonu İptal Et'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: const BorderSide(
                                      color: AppColors.error,
                                      width: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                          ],

                          // Status Messages
                          if (widget.reservation.isConsumed) ...[
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.secondaryGreen.withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: AppColors.secondaryGreen),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Bu rezervasyon tüketilmiştir.',
                                      style: TextStyle(
                                        color: AppColors.grey800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (widget.reservation.isCancelled) ...[
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.error.withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.cancel, color: AppColors.error),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Bu rezervasyon iptal edilmiştir.',
                                      style: TextStyle(
                                        color: AppColors.grey800,
                                        fontSize: 13,
                                      ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    Color color,
    IconData icon,
    bool canCancel,
    bool isActive,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.white, size: 48),
                const SizedBox(height: 16),
                Text(
                  widget.reservation.mealName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Helpers.formatDate(widget.reservation.mealDate, 'EEEE, dd MMMM yyyy'),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Details Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.getBorder(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rezervasyon Bilgileri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  Icons.access_time,
                  'Saat',
                  Helpers.formatDate(widget.reservation.mealDate, 'HH:mm'),
                ),
                Divider(height: 32, color: AppColors.getDivider(context)),
                _buildDetailRow(
                  Icons.restaurant,
                  'Öğün',
                  widget.reservation.mealPeriod == 'breakfast'
                      ? 'Kahvaltı'
                      : widget.reservation.mealPeriod == 'lunch'
                          ? 'Öğle Yemeği'
                          : 'Akşam Yemeği',
                ),
                Divider(height: 32, color: AppColors.getDivider(context)),
                _buildDetailRow(
                  Icons.location_on,
                  'Yemekhane',
                  widget.reservation.cafeteriaName,
                ),
                Divider(height: 32, color: AppColors.getDivider(context)),
                _buildDetailRow(
                  Icons.account_balance_wallet,
                  'Ücret',
                  Helpers.formatCurrency(widget.reservation.price),
                  valueColor: AppColors.primaryOrange,
                ),
                Divider(height: 32, color: AppColors.getDivider(context)),
                _buildDetailRow(
                  Icons.info_outline,
                  'Durum',
                  widget.reservation.status == 'reserved'
                      ? 'Aktif'
                      : widget.reservation.status == 'consumed'
                          ? 'Tüketildi'
                          : widget.reservation.status == 'cancelled'
                              ? 'İptal'
                              : 'Bilinmiyor',
                  valueColor: widget.reservation.status == 'reserved'
                      ? AppColors.secondaryGreen
                      : widget.reservation.status == 'consumed'
                          ? AppColors.secondaryBlue
                          : AppColors.secondaryRed,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // QR Code
          if (isActive) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.getCardColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.getBorder(context)),
              ),
              child: Column(
                children: [
                  Text(
                    'QR Kod',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.getBorder(context), width: 2),
                    ),
                    child: QrImageView(
                      data: widget.reservation.id,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: AppColors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Yemek almak için bu kodu gösterin',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Action Buttons
          if (isActive) ...[
            // Satışa Çıkar Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openForSwap(context),
                icon: Icon(
                  widget.reservation.isTransferOpen
                      ? Icons.shopping_bag
                      : Icons.sell_outlined,
                  size: 20,
                ),
                label: Text(
                  widget.reservation.isTransferOpen
                      ? 'Satıştan Kaldır'
                      : 'Rezervasyonu Satışa Çıkar',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.reservation.isTransferOpen
                      ? AppColors.warning
                      : AppColors.secondaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // İptal Butonu
            if (canCancel)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelReservation(context),
                  icon: const Icon(Icons.cancel_outlined, size: 20),
                  label: const Text('Rezervasyonu İptal Et'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],

          // Status Messages
          if (widget.reservation.isConsumed)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondaryGreen.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.secondaryGreen),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bu rezervasyon tüketilmiştir.',
                      style: TextStyle(
                        color: AppColors.grey800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (widget.reservation.isCancelled)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cancel, color: AppColors.error),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bu rezervasyon iptal edilmiştir.',
                      style: TextStyle(
                        color: AppColors.grey800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.grey600),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.grey600,
              fontSize: 15,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.grey900,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Builder(
      builder: (context) => Row(
        children: [
          Icon(icon, size: 20, color: AppColors.getIconColor(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.getTextPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openForSwap(BuildContext context) async {
    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              widget.reservation.isTransferOpen ? Icons.shopping_bag : Icons.sell_outlined,
              color: AppColors.secondaryGreen,
            ),
            const SizedBox(width: 12),
            Text(widget.reservation.isTransferOpen ? 'Satıştan Kaldır' : 'Satışa Çıkar'),
          ],
        ),
        content: Text(
          widget.reservation.isTransferOpen
              ? 'Bu rezervasyonu satıştan kaldırmak istediğinize emin misiniz?'
              : 'Bu rezervasyonu satışa çıkarmak istediğinize emin misiniz? Diğer kullanıcılar bu rezervasyonu satın alabilecek.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryGreen,
            ),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await reservationProvider.openForTransfer(widget.reservation.id);

    if (!mounted) return;

    if (success) {
      setState(() {});
      Helpers.showSnackBar(
        context,
        widget.reservation.isTransferOpen
            ? 'Rezervasyon satıştan kaldırıldı'
            : 'Rezervasyon satışa çıkarıldı',
      );
    } else {
      Helpers.showSnackBar(
        context,
        reservationProvider.errorMessage ?? 'İşlem başarısız',
        isError: true,
      );
    }
  }

  Future<void> _cancelReservation(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.error),
            SizedBox(width: 12),
            Text('Rezervasyonu İptal Et'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bu rezervasyonu iptal etmek istediğinize emin misiniz?'),
            const SizedBox(height: 12),
            Text(
              'İade tutarı: ${Helpers.formatCurrency(widget.reservation.price * 0.5)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryGreen,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await reservationProvider.cancelReservation(widget.reservation.id);

    if (!mounted) return;

    if (success) {
      final refundAmount = widget.reservation.price * 0.5;
      final newBalance = authProvider.currentUser!.balance + refundAmount;
      authProvider.updateBalance(newBalance);

      final transaction = TransactionModel(
        id: 'trans-${DateTime.now().millisecondsSinceEpoch}',
        userId: authProvider.currentUser!.id,
        type: 'refund',
        amount: refundAmount,
        balanceAfter: newBalance,
        description: 'İade - ${widget.reservation.mealName}',
        createdAt: DateTime.now(),
      );
      transactionProvider.addTransaction(transaction);

      Helpers.showSnackBar(context, 'Rezervasyon iptal edildi');
      if (Helpers.isWeb(context)) {
        context.go('/reservations');
      } else {
        Navigator.pop(context);
      }
    } else {
      Helpers.showSnackBar(
        context,
        reservationProvider.errorMessage ?? 'İptal başarısız',
        isError: true,
      );
    }
  }
}
