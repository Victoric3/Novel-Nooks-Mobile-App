import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:novelnooks/src/common/constants/global_state.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/features/auth/blocs/auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

@RoutePage()
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Use nullable animation variables
  Animation<double>? _fadeAnimation;
  Animation<double>? _scaleAnimation;
  bool _animationsInitialized = false;

  void _initializeAnimations() {
    if (_animationsInitialized) return;
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
    
    _animationsInitialized = true;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _initializeAnimations();
    _controller.forward();
  }
  
  // Handle hot reload
  @override
  void reassemble() {
    super.reassemble();
    _initializeAnimations();
    // Don't restart animation on hot reload to avoid jarring UX
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Make sure animations are initialized
    if (!_animationsInitialized) {
      _initializeAnimations();
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    
    return Scaffold(
      body: Stack(
        children: [
          // Decorative background elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark 
                    ? [AppColors.greenTeal.withOpacity(0.3), Colors.transparent]
                    : [AppColors.brandOrange.withOpacity(0.3), Colors.transparent],
                  stops: const [0.2, 0.7],
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark 
                    ? [AppColors.deepGreenTeal.withOpacity(0.3), Colors.transparent]
                    : [AppColors.brandDeepOrange.withOpacity(0.3), Colors.transparent],
                  stops: const [0.2, 0.7],
                ),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                height: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: isSmallScreen ? 40 : 60),
                      
                      // Hero section - Add null check for animations
                      FadeTransition(
                        opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                        child: ScaleTransition(
                          scale: _scaleAnimation ?? const AlwaysStoppedAnimation(1.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // App logo in a bookshelf style container
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: isDark 
                                    ? AppColors.darkBg 
                                    : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark 
                                        ? AppColors.greenTeal.withOpacity(0.2)
                                        : AppColors.brandOrange.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Hero(
                                  tag: 'app_logo',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      'assets/images/app-logo.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // Headline with gradient text
                              ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: isDark
                                    ? [AppColors.greenTeal, AppColors.deepGreenTeal]
                                    : [AppColors.brandOrange, AppColors.brandDeepOrange],
                                ).createShader(
                                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                ),
                                child: const Text(
                                  'Dive into stories\nthat move you',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Tagline
                              Text(
                                'Your personal reading sanctuary',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark 
                                    ? Colors.white.withOpacity(0.7)
                                    : AppColors.neutralDarkGray.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Illustration
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                          child: Center(
                            child: _buildBookIllustration(isDark),
                          ),
                        ),
                      ),
                      
                      // Auth options
                      FadeTransition(
                        opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                        child: Column(
                          children: [
                            // Primary button - Sign in with Email
                            _AuthButton(
                              iconData: MdiIcons.email,
                              label: 'Sign in with Email',
                              onPressed: () => context.router.push(SignInRoute()),
                              isDark: isDark,
                              type: AuthButtonType.primary,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Google button
                            _AuthButton(
                              iconData: MdiIcons.google,
                              label: 'Continue with Google',
                              onPressed: () {
                                final signInState = ref.read(signInProvider);
                                signInState.signInWithGoogle(context, ref);
                              },
                              isDark: isDark,
                              type: AuthButtonType.secondary,
                              isLoading: ref.watch(googleSignInLoadingProvider),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Guest button
                            _AuthButton(
                              iconData: MdiIcons.incognito,
                              label: 'Browse as Guest',
                              onPressed: () {
                                final signInState = ref.read(signInProvider);
                                signInState.continueAsGuest(context, ref);
                              },
                              isDark: isDark,
                              type: AuthButtonType.outline,
                              isLoading: ref.watch(guestSignInLoadingProvider),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Sign up option
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark 
                                      ? Colors.white.withOpacity(0.7)
                                      : AppColors.neutralDarkGray.withOpacity(0.7),
                                  ),
                                  children: [
                                    const TextSpan(text: "New to Novel Nooks? "),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: GestureDetector(
                                        onTap: () => context.router.push(const SignUpRoute()),
                                        child: Text(
                                          'Create Account',
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
                      
                      SizedBox(height: isSmallScreen ? 24 : 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBookIllustration(bool isDark) {
    return Container(
      width: 220,
      height: 170,
      decoration: BoxDecoration(
        color: isDark 
          ? AppColors.darkBg.withOpacity(0.7) 
          : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Book spine
          Positioned(
            left: 30,
            child: Container(
              width: 15,
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? AppColors.greenTeal : AppColors.brandOrange,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          
          // Book cover
          Positioned(
            left: 38,
            child: Transform(
              alignment: Alignment.centerLeft,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(-0.3),
              child: Container(
                width: 85,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                      ? [AppColors.greenTeal, AppColors.deepTeal]
                      : [AppColors.brandOrange, AppColors.brandDeepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    MdiIcons.bookOpenPageVariant,
                    color: Colors.white.withOpacity(0.8),
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          
          // Second book
          Positioned(
            left: 70,
            child: Container(
              width: 12,
              height: 100,
              decoration: BoxDecoration(
                color: isDark ? AppColors.deepGreenTeal : AppColors.brandDeepOrange,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          
          // Text lines
          Positioned(
            right: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDark 
                      ? AppColors.greenTeal.withOpacity(0.6) 
                      : AppColors.brandOrange.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 90,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDark 
                      ? AppColors.greenLime.withOpacity(0.5) 
                      : AppColors.brandDeepOrange.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 60,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDark 
                      ? AppColors.mediumGreen.withOpacity(0.4) 
                      : AppColors.brandOrange.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

enum AuthButtonType {
  primary,
  secondary,
  outline,
}

class _AuthButton extends StatelessWidget {
  final IconData iconData;
  final String label;
  final VoidCallback onPressed;
  final bool isDark;
  final bool isLoading;
  final AuthButtonType type;

  const _AuthButton({
    required this.iconData,
    required this.label,
    required this.onPressed,
    required this.isDark,
    this.isLoading = false,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    // Determine styles based on type
    final Color buttonColor;
    final Color textColor;
    final Color borderColor;
    final BoxShadow? boxShadow;
    final Gradient? gradient;
    
    switch (type) {
      case AuthButtonType.primary:
        gradient = LinearGradient(
          colors: isDark
            ? [AppColors.greenTeal, AppColors.deepGreenTeal]
            : [AppColors.brandOrange, AppColors.brandDeepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        buttonColor = Colors.transparent;
        textColor = Colors.white;
        borderColor = Colors.transparent;
        boxShadow = BoxShadow(
          color: isDark 
            ? AppColors.greenTeal.withOpacity(0.3)
            : AppColors.brandOrange.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 5),
        );
        break;
        
      case AuthButtonType.secondary:
        gradient = null;
        buttonColor = isDark 
          ? Color.lerp(AppColors.darkBg, Colors.white, 0.1)!
          : Colors.white;
        textColor = isDark ? Colors.white : AppColors.neutralDarkGray;
        borderColor = isDark 
          ? Colors.white.withOpacity(0.1)
          : Colors.grey.withOpacity(0.2);
        boxShadow = BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        );
        break;
        
      case AuthButtonType.outline:
        gradient = null;
        buttonColor = Colors.transparent;
        textColor = isDark 
          ? AppColors.greenTeal
          : AppColors.brandOrange;
        borderColor = isDark 
          ? AppColors.greenTeal
          : AppColors.brandOrange;
        boxShadow = null;
        break;
    }
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient,
        color: buttonColor,
        borderRadius: BorderRadius.circular(16),
        border: type == AuthButtonType.outline 
          ? Border.all(color: borderColor, width: 1.5)
          : type == AuthButtonType.secondary
            ? Border.all(color: borderColor, width: 1)
            : null,
        boxShadow: boxShadow != null ? [boxShadow] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onPressed,
          splashColor: type == AuthButtonType.outline 
            ? (isDark ? AppColors.greenTeal.withOpacity(0.1) : AppColors.brandOrange.withOpacity(0.1))
            : Colors.white24,
          highlightColor: type == AuthButtonType.outline
            ? (isDark ? AppColors.greenTeal.withOpacity(0.05) : AppColors.brandOrange.withOpacity(0.05))
            : Colors.white10,
          child: Center(
            child: isLoading
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconData,
                      color: textColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
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