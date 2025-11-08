import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import '../home/main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      ).then((success) {
        if (!mounted) return;

        if (success) {
          Helpers.showSnackBar(context, AppStrings.tr['loginSuccess']!);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
        } else {
          Helpers.showSnackBar(
            context,
            authProvider.errorMessage ?? AppStrings.tr['loginError']!,
            isError: true,
          );
        }
      });
    }
  }

  void _quickLogin(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    // Otomatik giriş yap
    _handleLogin();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isWeb = Helpers.isWeb(context);

    return isWeb
        ? _buildWebLayout(context, authProvider)
        : _buildMobileLayout(context, authProvider);
  }

  Widget _buildMobileLayout(
      BuildContext context, AuthProvider authProvider) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryOrange,
              AppColors.secondaryOrange,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            size: 60,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Hoş Geldiniz!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'ETİSAN Yemekhane Sistemi',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 50),
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: _buildFormContent(context, authProvider),
                        ),
                        const SizedBox(height: 32),
                        _buildQuickLoginPanel(isWeb: false),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, AuthProvider authProvider) {
    return Scaffold(
      backgroundColor: AppColors.webBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.webCard,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 32,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 880;

                        Widget buildLeftPanel() {
                          return Container(
                            padding: const EdgeInsets.all(40),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                bottomLeft: Radius.circular(32),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant_menu,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                const Text(
                                  'Yemekhane sisteminize hoş geldiniz',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Hızlı, kolay ve güvenli rezervasyon deneyimi ile tüm işlemlerinizi web üzerinden yönetin.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.25),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.fastfood,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        Widget buildFormPanel() {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 48 : 32,
                              vertical: isWide ? 48 : 32,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(32),
                                bottomRight: Radius.circular(32),
                                topLeft: Radius.circular(isWide ? 0 : 32),
                                bottomLeft: Radius.circular(isWide ? 0 : 32),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'E TİSAN Yemekhane Sistemi',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.grey500,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Giriş Yap',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildFormContent(context, authProvider,
                                    isWeb: true),
                                const SizedBox(height: 32),
                                _buildQuickLoginPanel(isWeb: true),
                              ],
                            ),
                          );
                        }

                        if (isWide) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(child: buildLeftPanel()),
                              Expanded(child: buildFormPanel()),
                            ],
                          );
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF1D4ED8),
                                    Color(0xFF1E3A8A),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'E TİSAN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Yemekhane sisteminize hoş geldiniz',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            buildFormPanel(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, AuthProvider authProvider,
      {bool isWeb = false}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: _emailController,
            label: AppStrings.tr['email']!,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.tr['emailRequired']!;
              }
              if (!value.contains('@')) {
                return AppStrings.tr['emailInvalid']!;
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _passwordController,
            label: AppStrings.tr['password']!,
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.grey600,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.tr['passwordRequired']!;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Helpers.showSnackBar(
                  context,
                  'Şifre sıfırlama özelliği yakında eklenecek',
                );
              },
              child: const Text(
                'Şifremi Unuttum?',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: AppStrings.tr['login']!,
            onPressed: authProvider.isLoading ? () {} : _handleLogin,
            isLoading: authProvider.isLoading,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.grey300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'veya',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: isWeb ? 14 : 13,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppColors.grey300)),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(
                color: AppColors.primaryOrange,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppStrings.tr['register']!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLoginPanel({required bool isWeb}) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 24 : 20),
      decoration: BoxDecoration(
        color: isWeb
            ? AppColors.webBackground
            : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWeb
              ? AppColors.grey200
              : Colors.white.withOpacity(0.3),
        ),
        boxShadow: isWeb
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
    child: Column(
        crossAxisAlignment:
            isWeb ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            'Hızlı Giriş',
            style: TextStyle(
              color: isWeb ? AppColors.grey800 : AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment:
                isWeb ? WrapAlignment.start : WrapAlignment.center,
            children: [
              _buildQuickLoginChip(
                'Öğrenci',
                Icons.school,
                () => _quickLogin('student@etisan.com', 'password123'),
              ),
              _buildQuickLoginChip(
                'Personel',
                Icons.badge,
                () => _quickLogin('staff@etisan.com', 'password123'),
              ),
              _buildQuickLoginChip(
                'Admin',
                Icons.admin_panel_settings,
                () => _quickLogin('admin@etisan.com', 'password123'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLoginChip(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primaryOrange),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
