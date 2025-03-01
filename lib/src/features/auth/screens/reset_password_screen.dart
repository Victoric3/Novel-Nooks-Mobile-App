import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eulaiq/src/common/theme/app_theme.dart';
import 'package:eulaiq/src/common/constants/global_state.dart';
import 'package:eulaiq/src/features/auth/blocs/verify_code.dart';

@RoutePage()
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark 
                        ? AppColors.neonCyan.withOpacity(0.3)
                        : AppColors.brandDeepGold.withOpacity(0.3),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                  ),
                  onPressed: () => context.router.pop(),
                ),
              ),
              SizedBox(height: size.height * 0.04),

              // Header
              Text(
                'Reset Password',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: size.width * 0.07,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: isDark
                          ? [AppColors.neonCyan, AppColors.neonPurple]
                          : [AppColors.brandDeepGold, AppColors.brandWarmOrange],
                    ).createShader(Rect.fromLTWH(0, 0, size.width * 0.5, 0)),
                ),
              ),
              SizedBox(height: size.height * 0.02),

              Text(
                'Enter your email address to receive a password reset link',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark 
                      ? AppColors.textPrimary.withOpacity(0.7)
                      : AppColors.neutralDarkGray,
                ),
              ),
              SizedBox(height: size.height * 0.06),

              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.neonCyan.withOpacity(0.3)
                                : AppColors.brandDeepGold.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.neonCyan
                                : AppColors.brandDeepGold,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || !RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.04),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  ref.read(verifyCodeProvider).forgotPassword(
                                    _emailController.text,
                                    ref,
                                    context,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.neonCyan
                              : AppColors.brandDeepGold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Reset Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
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
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}