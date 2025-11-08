import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../home/main_navigation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'student';
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
    _fullNameController.dispose();
    _emailController.dispose();
    _studentNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        Helpers.showSnackBar(
          context,
          AppStrings.tr['passwordMismatch']!,
          isError: true,
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        studentNumber: _selectedRole == 'student' ? _studentNumberController.text.trim() : null,
        role: _selectedRole,
      ).then((success) {
        if (!mounted) return;

        if (success) {
          Helpers.showSnackBar(context, AppStrings.tr['registerSuccess']!);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
        } else {
          Helpers.showSnackBar(
            context,
            authProvider.errorMessage ?? AppStrings.tr['registerError']!,
            isError: true,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isWeb = Helpers.isWeb(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.secondaryOrange,
              AppColors.primaryOrange,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: AppColors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Geri',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
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
                            children: [
                              // Header
                              Builder(
                                builder: (context) => Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.getCardColor(context),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.getShadow(context),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.person_add,
                                    size: 50,
                                    color: AppColors.primaryOrange,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              const Text(
                                'Hesap Oluştur',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              const Text(
                                'Bilgilerinizi girerek başlayın',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              
                              const SizedBox(height: 40),
                              
                              // Form Container
                              Builder(
                                builder: (context) => Container(
                                  padding: const EdgeInsets.all(28),
                                  decoration: BoxDecoration(
                                    color: AppColors.getCardColor(context),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.getShadow(context),
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
                                      // Role Selection
                                      Builder(
                                        builder: (context) => Text(
                                          'Rol Seçimi',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.getTextPrimary(context),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildRoleChip(
                                              'Öğrenci',
                                              Icons.school,
                                              'student',
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildRoleChip(
                                              'Personel',
                                              Icons.badge,
                                              'staff',
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Full Name
                                      CustomTextField(
                                        controller: _fullNameController,
                                        label: AppStrings.tr['fullName']!,
                                        prefixIcon: Icons.person_outline,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return AppStrings.tr['fullNameRequired']!;
                                          }
                                          return null;
                                        },
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Email
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
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Student Number (only for students)
                                      if (_selectedRole == 'student') ...[
                                        CustomTextField(
                                          controller: _studentNumberController,
                                          label: AppStrings.tr['studentNumber']!,
                                          prefixIcon: Icons.badge_outlined,
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (_selectedRole == 'student') {
                                              if (value == null || value.isEmpty) {
                                                return AppStrings.tr['studentNumberRequired']!;
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      
                                      // Password
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
                                          if (value.length < 6) {
                                            return 'Şifre en az 6 karakter olmalı';
                                          }
                                          return null;
                                        },
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Confirm Password
                                      CustomTextField(
                                        controller: _confirmPasswordController,
                                        label: 'Şifre Tekrar',
                                        prefixIcon: Icons.lock_outline,
                                        obscureText: _obscureConfirmPassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: AppColors.grey600,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureConfirmPassword = !_obscureConfirmPassword;
                                            });
                                          },
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Lütfen şifrenizi tekrar girin';
                                          }
                                          return null;
                                        },
                                      ),
                                      
                                      const SizedBox(height: 28),
                                      
                                      // Register Button
                                      CustomButton(
                                        text: AppStrings.tr['register']!,
                                        onPressed: authProvider.isLoading ? () {} : _handleRegister,
                                        isLoading: authProvider.isLoading,
                                      ),
                                    ],
                                  ),
                                ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String label, IconData icon, String role) {
    final isSelected = _selectedRole == role;
    
    return Builder(
      builder: (context) => InkWell(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primaryOrange 
                : AppColors.getChipBackground(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primaryOrange 
                  : AppColors.getBorder(context),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? AppColors.white 
                    : AppColors.getIconColor(context),
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected 
                      ? AppColors.white 
                      : AppColors.getTextPrimary(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
