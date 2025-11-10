import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../core/layout/app_page_container.dart';
import '../../core/layout/web_layout.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/services/mock_data_service.dart';
import 'transaction_history_screen.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<double> quickAmounts = [50, 100, 200, 500];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
    _loadTransactions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await transactionProvider.loadTransactions(authProvider.currentUser!.id);
    }
  }

  void _selectQuickAmount(double amount) {
    setState(() {
      _amountController.text = amount.toStringAsFixed(0);
    });
  }

  Future<void> _loadBalance() async {
    final amount = double.tryParse(_amountController.text);

    if (amount == null) {
      Helpers.showSnackBar(context, 'Geçerli bir tutar giriniz', isError: true);
      return;
    }

    if (amount < AppConstants.minBalanceLoad || amount > AppConstants.maxBalanceLoad) {
      Helpers.showSnackBar(
        context,
        'Tutar ${AppConstants.minBalanceLoad}-${AppConstants.maxBalanceLoad} TL arasında olmalıdır',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    try {
      await MockDataService.instance.mockLoadBalance(
        authProvider.currentUser!.id,
        amount,
      );

      final newBalance = authProvider.currentUser!.balance + amount;
      authProvider.updateBalance(newBalance);

      final transaction = TransactionModel(
        id: 'trans-${DateTime.now().millisecondsSinceEpoch}',
        userId: authProvider.currentUser!.id,
        type: 'load',
        amount: amount,
        balanceAfter: newBalance,
        description: AppStrings.tr['balanceLoaded']!,
        createdAt: DateTime.now(),
      );

      transactionProvider.addTransaction(transaction);

      _amountController.clear();
      Helpers.showSnackBar(context, AppStrings.tr['balanceLoadedSuccess']!);
    } catch (e) {
      Helpers.showSnackBar(
        context,
        'Bakiye yüklenemedi: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser!;
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final recentTransactions = transactionProvider.transactions.take(3).toList();
    final isWeb = Helpers.isWeb(context);

    return isWeb
        ? _buildWebLayout(context, user, recentTransactions)
        : _buildMobileLayout(context, user, recentTransactions);
  }

  Widget _buildMobileLayout(BuildContext context, user,
      List<TransactionModel> recentTransactions) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryOrange, AppColors.secondaryOrange],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Bakiyem',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.getBackground(context),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildBalanceCard(user),
                              const SizedBox(height: 24),
                              _buildLoadBalanceSection(),
                              const SizedBox(height: 24),
                              _buildRecentTransactions(recentTransactions),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, user,
      List<TransactionModel> recentTransactions) {
    return WebLayout(
      child: SafeArea(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: AppPageContainer(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bakiye Yükleme',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hoş geldiniz, ${user.fullName}',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.webCard,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 28,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 900;

                          final formColumn = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildBalanceCard(user, isWeb: true),
                              const SizedBox(height: 24),
                              _buildLoadBalanceSection(isWeb: true),
                            ],
                          );

                          final transactionsColumn = _buildRecentTransactions(
                            recentTransactions,
                            isWeb: true,
                          );

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: formColumn,
                                ),
                                const SizedBox(width: 32),
                                Expanded(
                                  flex: 2,
                                  child: transactionsColumn,
                                ),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              formColumn,
                              const SizedBox(height: 32),
                              transactionsColumn,
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(user, {bool isWeb = false}) {
    if (isWeb) {
      final firstName = user.fullName.split(' ').first;
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primaryOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hoş geldiniz, $firstName',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Mevcut bakiyeniz',
                        style: TextStyle(
                          color: AppColors.grey500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              Helpers.formatCurrency(user.balance),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryOrange,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(
                  Icons.shield_outlined,
                  color: AppColors.grey500,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ödeme altyapımız ETİSAN güvencesiyle korunmaktadır.',
                    style: TextStyle(
                      color: AppColors.grey500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Mevcut Bakiye',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    Helpers.formatCurrency(user.balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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

  Widget _buildLoadBalanceSection({bool isWeb = false}) {
    return Builder(
      builder: (context) {
        final cardColor = isWeb ? Colors.white : AppColors.getCardColor(context);
        final borderColor = isWeb ? AppColors.grey200 : AppColors.getBorder(context);
        final shadow = isWeb
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.getShadow(context),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ];

        return Container(
          padding: EdgeInsets.all(isWeb ? 20 : 24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
            boxShadow: shadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_circle, color: AppColors.primaryOrange, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Bakiye Yükle',
                    style: TextStyle(
                      fontSize: isWeb ? 22 : 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Quick Amount Buttons
              Text(
                'Hızlı Seçim',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextSecondary(context),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickAmounts.map((amount) {
                  final isSelected = _amountController.text == amount.toStringAsFixed(0);
                  return InkWell(
                    onTap: () => _selectQuickAmount(amount),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryOrange
                            : (isWeb
                                ? AppColors.webBackground
                                : AppColors.getChipBackground(context)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryOrange
                              : (isWeb
                                  ? AppColors.grey200
                                  : AppColors.getBorder(context)),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '${amount.toInt()} TL',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isWeb
                                  ? AppColors.grey700
                                  : AppColors.getChipText(context)),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Custom Amount Input
              Text(
                'veya Özel Tutar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextSecondary(context),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Tutar giriniz',
                  suffixText: 'TL',
                  filled: true,
                  fillColor:
                      isWeb ? AppColors.webBackground : AppColors.getInputFill(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isWeb ? AppColors.grey200 : AppColors.getBorder(context),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isWeb ? AppColors.grey200 : AppColors.getBorder(context),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Min: ${AppConstants.minBalanceLoad} TL - Max: ${AppConstants.maxBalanceLoad} TL',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextSecondary(context),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Load Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loadBalance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Bakiye Yükle',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentTransactions(List<TransactionModel> transactions,
      {bool isWeb = false}) {
    return Builder(
      builder: (context) => Container(
        padding: EdgeInsets.all(isWeb ? 24 : 20),
        decoration: BoxDecoration(
          color: isWeb ? Colors.white : AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(isWeb ? 24 : 20),
          border: Border.all(
            color: isWeb ? AppColors.grey200 : AppColors.getBorder(context),
          ),
          boxShadow: [
            (isWeb
                ? BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  )
                : BoxShadow(
                    color: AppColors.getShadow(context),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ))
          ],
        ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long,
                      color: AppColors.primaryOrange, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Son İşlemler',
                    style: TextStyle(
                      fontSize: isWeb ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const TransactionHistoryScreen()),
                  );
                },
                child: const Text('Tümünü Gör'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isWeb
                    ? AppColors.webBackground
                    : AppColors.getInputFill(context),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long,
                      size: 48, color: AppColors.getIconColor(context)),
                  const SizedBox(height: 12),
                  Text(
                    'Henüz işlem yok',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          else
            ...transactions.map(
              (transaction) =>
                  _buildTransactionItem(transaction, isWeb: isWeb),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction,
      {bool isWeb = false}) {
    return Builder(
      builder: (context) {
        final isPositive = transaction.amount > 0;
        
        IconData icon;
        Color iconColor;
        
        switch (transaction.type) {
          case 'load':
            icon = Icons.add_circle;
            iconColor = AppColors.secondaryGreen;
            break;
          case 'reservation':
            icon = Icons.restaurant;
            iconColor = AppColors.primaryOrange;
            break;
          case 'refund':
            icon = Icons.refresh;
            iconColor = AppColors.secondaryBlue;
            break;
          default:
            icon = Icons.attach_money;
            iconColor = AppColors.grey500;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isWeb ? Colors.white : AppColors.getInputFill(context),
            borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
            border: Border.all(
              color: isWeb ? AppColors.grey200 : AppColors.getBorder(context),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.formatDate(transaction.createdAt, 'dd MMM yyyy, HH:mm'),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isPositive ? '+' : ''}${Helpers.formatCurrency(transaction.amount)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? AppColors.secondaryGreen : AppColors.secondaryRed,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

