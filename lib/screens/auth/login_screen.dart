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
                constraints: BoxConstraints(
                  maxWidth: isWeb ? 500 : double.infinity,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo ve Başlık
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
                        
                        // Form Container
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Email Field
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
                                
                                // Password Field
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
                                
                                // Forgot Password
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
                                
                                // Login Button
                                CustomButton(
                                  text: AppStrings.tr['login']!,
                                  onPressed: authProvider.isLoading ? () {} : _handleLogin,
                                  isLoading: authProvider.isLoading,
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Divider
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: AppColors.grey300)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'veya',
                                        style: TextStyle(
                                          color: AppColors.grey600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: AppColors.grey300)),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Register Button
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
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
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Demo Accounts
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Hızlı Giriş',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
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
                        ),
                        
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
