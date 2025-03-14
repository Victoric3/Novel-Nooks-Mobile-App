import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:novelnooks/src/common/constants/global_state.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/features/auth/blocs/auth_handler.dart';

@RoutePage()
class SignInScreen extends ConsumerWidget {
  SignInScreen({super.key});
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signInState = ref.watch(signInProvider);
    final isLoading = ref.watch(loadingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Decorative background elements
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark 
                    ? [AppColors.deepTeal.withOpacity(0.2), Colors.transparent]
                    : [AppColors.brandOrange.withOpacity(0.15), Colors.transparent],
                  stops: const [0.2, 0.7],
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              height: 230,
              width: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark 
                    ? [AppColors.greenLime.withOpacity(0.15), Colors.transparent]
                    : [AppColors.brandDeepOrange.withOpacity(0.1), Colors.transparent],
                  stops: const [0.2, 0.7],
                ),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // Back button
                    GestureDetector(
                      onTap: () => context.router.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark 
                            ? AppColors.darkBg.withOpacity(0.8) 
                            : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: isDark 
                            ? AppColors.greenTeal 
                            : AppColors.brandOrange,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.05),
                    
                    // Bookshelf illustration
                    Center(
                      child: _buildBookshelfImage(isDark),
                    ),
                    
                    SizedBox(height: size.height * 0.04),
                    
                    // Title with book-themed graphic
                    Center(
                      child: Column(
                        children: [
                          _buildBookmarkTitle(
                            context, 
                            'Welcome Back', 
                            isDark,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sign in to continue your reading journey',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark 
                                ? Colors.white70 
                                : AppColors.neutralDarkGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.05),
                    
                    // Form
                    Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email field
                          _CustomTextField(
                            icon: Icons.email_outlined,
                            hint: 'Email Address',
                            isDark: isDark,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) => 
                                signInState.validateForm(value, 'email'),
                            validator: (value) {
                              if (!signInState.emailRegExp.hasMatch(value!)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Password field
                          _CustomTextField(
                            icon: Icons.lock_outline_rounded,
                            hint: 'Password',
                            isDark: isDark,
                            isPassword: true,
                            passwordVisible: signInState.passwordVisibility,
                            onTogglePassword: signInState.togglePasswordVisibility,
                            onChanged: (value) =>
                                signInState.validateForm(value, 'password'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          
                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.router.push(const ResetPasswordRoute()),
                              style: TextButton.styleFrom(
                                foregroundColor: isDark 
                                  ? AppColors.greenTeal 
                                  : AppColors.brandOrange,
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: size.height * 0.04),
                          
                          // Sign in button
                          _GradientButton(
                            label: 'Sign In',
                            isLoading: isLoading,
                            isDark: isDark,
                            onPressed: isLoading || !signInState.continueButtonEnabled
                              ? null
                              : () {
                                if (formKey.currentState!.validate()) {
                                  signInState.signIn(context, ref);
                                }
                              },
                          ),
                          
                          SizedBox(height: size.height * 0.03),
                          
                          // Sign up link
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: isDark 
                                    ? Colors.white70
                                    : Colors.black87,
                                  fontSize: 15,
                                ),
                                children: [
                                  const TextSpan(text: "New to Novel Nooks? "),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: GestureDetector(
                                      onTap: () => context.router.push(const SignUpRoute()),
                                      child: Text(
                                        'Create an account',
                                        style: TextStyle(
                                          color: isDark 
                                            ? AppColors.greenTeal 
                                            : AppColors.brandOrange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: size.height * 0.02),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBookshelfImage(bool isDark) {
    return Container(
      width: 120,
      height: 100,
      decoration: BoxDecoration(
        color: isDark 
          ? AppColors.darkBg.withOpacity(0.3) 
          : AppColors.neutralLightGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Book 1
          Positioned(
            left: 20,
            bottom: 10,
            child: Container(
              width: 18,
              height: 75,
              decoration: BoxDecoration(
                color: isDark ? AppColors.greenTeal : AppColors.brandOrange,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(2, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          
          // Book 2
          Positioned(
            left: 42,
            bottom: 10,
            child: Container(
              width: 18,
              height: 65,
              decoration: BoxDecoration(
                color: isDark ? AppColors.deepTeal : AppColors.brandDeepOrange,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(2, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          
          // Book 3
          Positioned(
            left: 64,
            bottom: 10,
            child: Container(
              width: 18,
              height: 70,
              decoration: BoxDecoration(
                color: isDark ? AppColors.mediumGreen : AppColors.brandOrange.withOpacity(0.7),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(2, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          
          // Book 4
          Positioned(
            left: 86,
            bottom: 10,
            child: Container(
              width: 18,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? AppColors.greenLime : AppColors.brandDeepOrange.withOpacity(0.7),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(2, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          
          // Shelf
          Positioned(
            left: 10,
            right: 10,
            bottom: 5,
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: isDark 
                  ? Colors.grey.shade800 
                  : Colors.brown.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBookmarkTitle(BuildContext context, String title, bool isDark) {
    return Stack(
      children: [
        // Bookmark shape
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [AppColors.greenTeal, AppColors.deepTeal] 
                : [AppColors.brandOrange, AppColors.brandDeepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: isDark 
                  ? AppColors.greenTeal.withOpacity(0.3) 
                  : AppColors.brandOrange.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        
        // Bookmark triangle cutout
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 16,
              height: 8,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBg : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool isDark;
  final bool isPassword;
  final bool? passwordVisible;
  final VoidCallback? onTogglePassword;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _CustomTextField({
    required this.icon,
    required this.hint,
    required this.isDark,
    this.isPassword = false,
    this.passwordVisible,
    this.onTogglePassword,
    this.onChanged,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark 
          ? AppColors.darkBg.withOpacity(0.6) 
          : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark 
              ? Colors.white38 
              : Colors.black38,
            fontSize: 15,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: isDark 
                    ? Colors.white12
                    : Colors.black12,
                  width: 1,
                ),
              ),
            ),
            child: Icon(
              icon,
              color: isDark 
                ? AppColors.greenTeal 
                : AppColors.brandOrange,
              size: 22,
            ),
          ),
          suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  passwordVisible! 
                    ? Icons.visibility_rounded 
                    : Icons.visibility_off_rounded,
                  color: isDark 
                    ? AppColors.greenTeal 
                    : AppColors.brandOrange,
                  size: 20,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        ),
        obscureText: isPassword && !passwordVisible!,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 15,
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isDark;
  final VoidCallback? onPressed;

  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.isDark,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [AppColors.greenTeal, AppColors.deepGreenTeal]
            : [AppColors.brandOrange, AppColors.brandDeepOrange],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? AppColors.greenTeal.withOpacity(0.3)
              : AppColors.brandOrange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Center(
            child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
