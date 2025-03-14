import 'package:auto_route/auto_route.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:novelnooks/src/common/constants/global_state.dart';
import 'package:novelnooks/src/features/auth/blocs/auth_handler.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

@RoutePage()
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Controllers to handle field values independently
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
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
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signInState = ref.watch(signInProvider);
    final isLoading = ref.watch(loadingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Library background effect
          _buildLibraryBackground(isDark),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header with navigation
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      // Back button
                      _BookishButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => context.router.pop(),
                        isDark: isDark,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            _BookmarkTitle(
                              title: 'Create Account',
                              isDark: isDark,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Text(
                              'Join Novel Nooks and start your reading journey',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark 
                                  ? Colors.white70 
                                  : AppColors.neutralDarkGray,
                              ),
                            ),
                            
                            SizedBox(height: size.height * 0.04),
                            
                            // Form
                            Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  // Personal info section
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: isDark 
                                        ? Colors.black12
                                        : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              MdiIcons.accountCircle, 
                                              color: isDark 
                                                ? AppColors.greenTeal
                                                : AppColors.brandOrange,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Personal Information',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isDark
                                                  ? Colors.white
                                                  : AppColors.neutralDarkGray,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        // First Name Field
                                        _BookThemedField(
                                          label: 'First Name',
                                          icon: MdiIcons.cardAccountDetails,
                                          controller: _firstNameController,
                                          onChanged: (value) => 
                                              signInState.collectFormData(value, 'firstname'),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter your first name';
                                            }
                                            return null;
                                          },
                                          isDark: isDark,
                                        ),
                                        
                                        const SizedBox(height: 16),
                                        
                                        // Last Name Field
                                        _BookThemedField(
                                          label: 'Last Name',
                                          icon: MdiIcons.cardAccountDetailsOutline,
                                          controller: _lastNameController,
                                          onChanged: (value) =>
                                              signInState.collectFormData(value, 'lastname'),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter your last name';
                                            }
                                            return null;
                                          },
                                          isDark: isDark,
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Account info section
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: isDark 
                                        ? Colors.black12
                                        : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              MdiIcons.shieldAccount, 
                                              color: isDark 
                                                ? AppColors.greenTeal
                                                : AppColors.brandOrange,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Account Credentials',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isDark
                                                  ? Colors.white
                                                  : AppColors.neutralDarkGray,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        // Email Field
                                        _BookThemedField(
                                          label: 'Email Address',
                                          icon: MdiIcons.email,
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          onChanged: (value) => 
                                              signInState.validateForm(value, 'email'),
                                          validator: (value) {
                                            if (!signInState.emailRegExp.hasMatch(value!)) {
                                              return 'Please enter a valid email';
                                            }
                                            return null;
                                          },
                                          isDark: isDark,
                                        ),
                                        
                                        const SizedBox(height: 16),
                                        
                                        // Password Field
                                        _BookThemedField(
                                          label: 'Password',
                                          icon: MdiIcons.lock,
                                          controller: _passwordController,
                                          isPassword: true,
                                          passwordVisible: signInState.passwordVisibility,
                                          onTogglePassword: signInState.togglePasswordVisibility,
                                          onChanged: (value) =>
                                              signInState.validateForm(value, 'password'),
                                          validator: (value) {
                                            if (value!.length < 6) {
                                              return 'Password must be at least 6 characters';
                                            }
                                            return null;
                                          },
                                          isDark: isDark,
                                        ),
                                      
                                        const SizedBox(height: 16),
                                        
                                        // Password strength indicator
                                        _PasswordStrengthIndicator(
                                          password: _passwordController.text,
                                          isDark: isDark,
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(height: size.height * 0.04),
                                  
                                  // Sign Up Button
                                  _GradientButton(
                                    onPressed: isLoading
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
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Sign In Link
                                  Center(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: isDark 
                                            ? Colors.white70
                                            : AppColors.neutralDarkGray,
                                          fontSize: 16,
                                        ),
                                        children: [
                                          const TextSpan(text: 'Already have an account? '),
                                          WidgetSpan(
                                            alignment: PlaceholderAlignment.middle,
                                            child: GestureDetector(
                                              onTap: () => context.router.push(SignInRoute()),
                                              child: Text(
                                                'Sign in',
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
                          ],
                        ),
                      ),
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
  
  Widget _buildLibraryBackground(bool isDark) {
    // (Keep your existing library background code)
    return Stack(
      children: [
        // Base color
        Container(
          color: isDark ? AppColors.darkBg : Colors.white,
        ),
        
        // Bookshelf pattern on side
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
}

// Keep your existing widget helper classes (_BookThemedField, _GradientButton, etc.)
class _BookThemedField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool? passwordVisible;
  final VoidCallback? onTogglePassword;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isDark;
  final TextEditingController? controller;

  const _BookThemedField({
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.passwordVisible,
    this.onTogglePassword,
    this.onChanged,
    this.validator,
    this.keyboardType,
    required this.isDark,
    this.controller,
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
          suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  passwordVisible! 
                    ? Icons.visibility_rounded 
                    : Icons.visibility_off_rounded,
                  color: isDark 
                    ? AppColors.greenTeal.withOpacity(0.8) 
                    : AppColors.brandOrange.withOpacity(0.8),
                  size: 20,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        ),
        obscureText: isPassword && !passwordVisible!,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
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
    this.isLoading = false,
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
                    if (label == 'Next')
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
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

class _GenreChip extends StatelessWidget {
  final String label;
  final bool isDark;

  const _GenreChip({
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isDark 
          ? Colors.black26
          : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark 
            ? AppColors.greenTeal.withOpacity(0.3)
            : AppColors.brandOrange.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark 
            ? Colors.white70
            : Colors.black54,
        ),
      ),
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool isDark;

  const _PasswordStrengthIndicator({
    required this.password,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Simple password strength calculation
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    String strengthText;
    Color strengthColor;
    
    switch (strength) {
      case 0:
      case 1:
        strengthText = 'Weak';
        strengthColor = Colors.red;
        break;
      case 2:
        strengthText = 'Fair';
        strengthColor = Colors.orange;
        break;
      case 3:
        strengthText = 'Good';
        strengthColor = Colors.yellow;
        break;
      case 4:
        strengthText = 'Strong';
        strengthColor = Colors.green;
        break;
      default:
        strengthText = '';
        strengthColor = Colors.grey;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: password.isEmpty ? 0 : strength / 4,
                  backgroundColor: isDark 
                    ? Colors.white10
                    : Colors.black12,
                  color: strengthColor,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (password.isNotEmpty)
              Text(
                strengthText,
                style: TextStyle(
                  fontSize: 12,
                  color: strengthColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        if (password.isNotEmpty && strength < 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Try adding numbers, symbols and uppercase letters',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                  ? Colors.white54
                  : Colors.black54,
              ),
            ),
          ),
      ],
    );
  }
}
