import 'package:auto_route/auto_route.dart';
import 'package:eulaiq/src/common/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eulaiq/src/common/common.dart';
import 'package:eulaiq/src/common/constants/global_state.dart';
import 'package:eulaiq/src/features/auth/blocs/auth_handler.dart';

@RoutePage()
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signInState = ref.watch(signInProvider);
    final isLoading = ref.watch(loadingProvider);
    ref.watch(errorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button with gradient border
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isDark
                              ? AppColors.neonCyan.withOpacity(0.3)
                              : AppColors.brandDeepGold.withOpacity(0.3),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color:
                          isDark ? AppColors.textPrimary : AppColors.textDark,
                    ),
                    onPressed: () => context.router.pop(),
                  ),
                ),
                SizedBox(height: size.height * 0.04),

                // Header with gradient
                ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors:
                            isDark
                                ? [AppColors.neonCyan, AppColors.neonPurple]
                                : [
                                  AppColors.brandDeepGold,
                                  AppColors.brandWarmOrange,
                                ],
                      ).createShader(bounds),
                  child: Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Start your medical learning journey',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color:
                        isDark
                            ? AppColors.textPrimary.withOpacity(0.7)
                            : AppColors.neutralDarkGray,
                  ),
                ),
                SizedBox(height: size.height * 0.06),

                // Sign Up Form
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // First Name Field
                      _GradientBorderField(
                        label: 'First Name',
                        onChanged:
                            (value) =>
                                signInState.collectFormData(value, 'firstname'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),

                      // Last Name Field
                      _GradientBorderField(
                        label: 'Last Name',
                        onChanged:
                            (value) =>
                                signInState.collectFormData(value, 'lastname'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),

                      // Email Field
                      _GradientBorderField(
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        onChanged:
                            (value) => signInState.validateForm(value, 'email'),
                        validator: (value) {
                          if (!signInState.emailRegExp.hasMatch(value!)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),

                      // Password Field
                      _GradientBorderField(
                        label: 'Password',
                        isPassword: true,
                        passwordVisible: signInState.passwordVisibility,
                        onTogglePassword: signInState.togglePasswordVisibility,
                        onChanged:
                            (value) =>
                                signInState.validateForm(value, 'password'),
                        validator: (value) {
                          if (value!.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        isDark: isDark,
                      ),
                      SizedBox(height: size.height * 0.06),

                      // Sign Up Button
                      _GradientButton(
                        onPressed:
                            isLoading || !signInState.continueButtonEnabled
                                ? null
                                : () {
                                  if (formKey.currentState!.validate()) {
                                    signInState.signUp(context, ref);
                                  }
                                },
                        isLoading: isLoading,
                        label: 'Create Account',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),

                      // Sign In Link
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color:
                                  isDark
                                      ? AppColors.textPrimary
                                      : AppColors.textDark,
                              fontSize: 16,
                            ),
                            children: [
                              const TextSpan(text: 'Already have an account? '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap:
                                      () => context.router.push(SignInRoute()),
                                  child: Text(
                                    'Sign in',
                                    style: TextStyle(
                                      color:
                                          isDark
                                              ? AppColors.neonCyan
                                              : AppColors.brandDeepGold,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientBorderField extends StatelessWidget {
  final String label;
  final bool isPassword;
  final bool? passwordVisible;
  final VoidCallback? onTogglePassword;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isDark;

  const _GradientBorderField({
    required this.label,
    this.isPassword = false,
    this.passwordVisible,
    this.onTogglePassword,
    this.onChanged,
    this.validator,
    this.keyboardType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color:
              isDark
                  ? AppColors.textPrimary.withOpacity(0.7)
                  : AppColors.neutralDarkGray,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color:
                isDark
                    ? AppColors.neonCyan.withOpacity(0.3)
                    : AppColors.brandDeepGold.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
          ),
        ),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    passwordVisible! ? Icons.visibility : Icons.visibility_off,
                    color:
                        isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                  ),
                  onPressed: onTogglePassword,
                )
                : null,
      ),
      obscureText: isPassword && !passwordVisible!,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(
        color: isDark ? AppColors.textPrimary : AppColors.textDark,
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;
  final bool isDark;

  const _GradientButton({
    required this.onPressed,
    required this.isLoading,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [AppColors.neonCyan, AppColors.neonPurple]
                  : [AppColors.brandDeepGold, AppColors.brandWarmOrange],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                .withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child:
            isLoading
                ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.darkBg : Colors.white,
                    ),
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkBg : Colors.white,
                  ),
                ),
      ),
    );
  }
}
