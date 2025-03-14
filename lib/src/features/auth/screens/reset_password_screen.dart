import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/common/constants/global_state.dart';
import 'package:novelnooks/src/features/auth/blocs/verify_code.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

@RoutePage()
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> 
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Library background
          _buildLibraryBackground(isDark),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // Back button
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _BookishButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => context.router.pop(),
                        isDark: isDark,
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.08),
                    
                    // Book illustration
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Center(
                        child: _buildForgotPasswordIllustration(isDark),
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.05),
                    
                    // Title with book-themed styling
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _BookmarkTitle(
                        title: 'Reset Password',
                        isDark: isDark,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Enter your email address to receive a password reset link',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark 
                            ? Colors.white70 
                            : AppColors.neutralDarkGray,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.05),
                    
                    // Form
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Email field
                            _BookThemedField(
                              label: 'Email Address',
                              icon: MdiIcons.email,
                              isDark: isDark,
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
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
                            
                            // Reset button
                            _GradientButton(
                              label: 'Send Reset Link',
                              isLoading: isLoading,
                              isDark: isDark,
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
                            ),
                            
                            SizedBox(height: size.height * 0.03),
                            
                            // Return to sign in link
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
                                    const TextSpan(text: "Remember your password? "),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: GestureDetector(
                                        onTap: () => context.router.replace(SignInRoute()),
                                        child: Text(
                                          'Sign In',
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
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom info card
                    SizedBox(height: size.height * 0.06),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark 
                            ? Colors.black26 
                            : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark 
                              ? AppColors.greenTeal.withOpacity(0.2) 
                              : AppColors.brandOrange.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark 
                                  ? AppColors.greenTeal.withOpacity(0.1) 
                                  : AppColors.brandOrange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.info_outline,
                                color: isDark 
                                  ? AppColors.greenTeal 
                                  : AppColors.brandOrange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'You will receive an email with a link to reset your password',
                                style: TextStyle(
                                  color: isDark 
                                    ? Colors.white70 
                                    : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLibraryBackground(bool isDark) {
    return Stack(
      children: [
        // Base color
        Container(
          color: isDark ? AppColors.darkBg : Colors.white,
        ),
        
        // Left bookshelf decoration
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 40,
            decoration: BoxDecoration(
              color: isDark 
                ? AppColors.deepGreenTeal.withOpacity(0.15) 
                : AppColors.brandDeepOrange.withOpacity(0.08),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                12,
                (index) => Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDark 
                      ? AppColors.greenTeal.withOpacity(0.3)
                      : AppColors.brandOrange.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Top decoration
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark 
                  ? [AppColors.greenTeal.withOpacity(0.2), Colors.transparent]
                  : [AppColors.brandOrange.withOpacity(0.2), Colors.transparent],
                stops: const [0.2, 0.7],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildForgotPasswordIllustration(bool isDark) {
    return Container(
      width: 120,
      height: 140,
      decoration: BoxDecoration(
        color: isDark 
          ? Colors.black26 
          : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Book
          Positioned(
            bottom: 30,
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  color: isDark 
                    ? AppColors.darkBg 
                    : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: isDark 
                      ? AppColors.greenTeal.withOpacity(0.5) 
                      : AppColors.brandOrange.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    MdiIcons.bookLock,
                    color: isDark 
                      ? AppColors.greenTeal 
                      : AppColors.brandOrange,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
          
          // Key icon
          Positioned(
            top: 25,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark 
                  ? AppColors.greenTeal.withOpacity(0.2) 
                  : AppColors.brandOrange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                MdiIcons.key,
                color: isDark 
                  ? AppColors.greenTeal 
                  : AppColors.brandOrange,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookishButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDark;

  const _BookishButton({
    required this.icon,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark 
          ? Colors.black26
          : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              icon,
              color: isDark 
                ? AppColors.greenTeal 
                : AppColors.brandOrange,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookmarkTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _BookmarkTitle({
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isDark 
              ? AppColors.greenTeal 
              : AppColors.brandOrange,
            width: 4,
          ),
        ),
      ),
      padding: const EdgeInsets.only(left: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.neutralDarkGray,
        ),
      ),
    );
  }
}

class _BookThemedField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const _BookThemedField({
    required this.label,
    required this.icon,
    required this.isDark,
    this.keyboardType,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark 
          ? Colors.black26
          : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isDark 
            ? AppColors.greenTeal.withOpacity(0.3)
            : AppColors.brandOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          border: InputBorder.none,
          hintText: label,
          hintStyle: TextStyle(
            color: isDark 
              ? Colors.white38
              : Colors.black38,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(right: 8),
            child: Icon(
              icon,
              color: isDark 
                ? AppColors.greenTeal
                : AppColors.brandOrange,
            ),
          ),
        ),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        keyboardType: keyboardType,
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
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [AppColors.greenTeal, AppColors.deepGreenTeal]
            : [AppColors.brandOrange, AppColors.brandDeepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.greenTeal : AppColors.brandOrange)
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}