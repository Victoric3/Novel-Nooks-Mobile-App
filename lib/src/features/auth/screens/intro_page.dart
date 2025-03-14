import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

@RoutePage()
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  int _currentPage = 0;
  final int _numPages = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.6, 1.0],
            colors: isDark 
              ? [
                  AppColors.darkBg,
                  Color.lerp(AppColors.darkBg, AppColors.deepTeal, 0.08) ?? AppColors.darkBg,
                  Color.lerp(AppColors.darkBg, AppColors.deepTeal, 0.15) ?? AppColors.darkBg,
                ]
              : [
                  Colors.white,
                  Color.lerp(Colors.white, AppColors.neutralLightGray, 0.5) ?? Colors.white,
                  Color.lerp(Colors.white, AppColors.brandOrange, 0.08) ?? Colors.white,
                ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App logo and name - enhanced
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                child: Column(
                  children: [
                    // Larger logo with better presentation
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: isDark 
                                ? AppColors.greenTeal.withOpacity(0.25)
                                : AppColors.brandOrange.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/app-logo.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // App name with shadow for better visibility
                    Text(
                      'Novel Nooks',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.neutralDarkGray,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: isDark 
                              ? Colors.black.withOpacity(0.5)
                              : Colors.grey.withOpacity(0.3),
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    
                    // Optional tagline
                    Text(
                      'Your personal reading sanctuary',
                      style: textTheme.bodyLarge?.copyWith(
                        color: isDark 
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.neutralDarkGray.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main intro content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  physics: const ClampingScrollPhysics(),
                  children: [
                    _buildIntroPage(
                      context,
                      isDark,
                      'Your Digital Bookshelf',
                      'Organize and access your favorite books anytime, anywhere.',
                      MdiIcons.bookshelf,
                    ),
                    _buildIntroPage(
                      context,
                      isDark,
                      'Immersive Reading',
                      'Customize your reading experience with themes, fonts, and more.',
                      MdiIcons.bookOpenPageVariant,
                    ),
                    _buildIntroPage(
                      context,
                      isDark,
                      'Join the Community',
                      'Connect with readers, share recommendations, and discover new books.',
                      MdiIcons.accountGroup,
                    ),
                  ],
                ),
              ),
              
              // Page indicator - refined
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_numPages, (index) => _buildPageIndicator(index == _currentPage, isDark)),
                ),
              ),
              
              // Action buttons - improved
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        flex: 1,
                        child: TextButton.icon(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: isDark ? AppColors.greenTeal : AppColors.brandOrange,
                          ),
                          label: Text(
                            'Back',
                            style: TextStyle(
                              color: isDark ? AppColors.greenTeal : AppColors.brandOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    else
                      const Spacer(flex: 1),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      flex: 2,
                      child: _customButton(
                        isDark: isDark,
                        label: _currentPage == _numPages - 1 ? 'Get Started' : 'Next',
                        icon: _currentPage == _numPages - 1 
                          ? Icons.login_rounded 
                          : Icons.arrow_forward_rounded,
                        onPressed: () {
                          if (_currentPage < _numPages - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            context.router.replace(const AuthRoute());
                          }
                        },
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
  
  Widget _buildPageIndicator(bool isActive, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive 
          ? (isDark ? AppColors.greenTeal : AppColors.brandOrange)
          : (isDark ? Colors.white30 : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isActive ? [
          BoxShadow(
            color: (isDark ? AppColors.greenTeal : AppColors.brandOrange).withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          )
        ] : null,
      ),
    );
  }
  
  Widget _buildIntroPage(BuildContext context, bool isDark, String title, String subtitle, IconData iconData) {
    // Get screen size to make our layout more responsive
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 600;  // Adjust for smaller screens

    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,  // Take only needed space
        children: [
          // We'll use Flexible instead of Spacer for better control
          Flexible(
            flex: 1,
            child: Container(),
          ),
          
          // Feature illustration - with adaptive sizing
          SizedBox(
            height: isSmallScreen ? 110 : 140,
            child: _buildFeatureIllustration(isDark, iconData),
          ),
          
          SizedBox(height: isSmallScreen ? 20 : 40),
          
          // Title - with shadow
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(  // Smaller text size
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.neutralDarkGray,
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: isDark 
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
                  offset: const Offset(0, 1),
                )
              ],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Subtitle - with constrained height
          Container(
            constraints: BoxConstraints(maxHeight: isSmallScreen ? 60 : 80),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(  // Smaller text size
                color: isDark ? Colors.white70 : AppColors.neutralDarkGray.withOpacity(0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: isSmallScreen ? 3 : 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Use Flexible instead of Spacer to allow content to compress if needed
          Flexible(
            flex: 2,
            child: Container(),
          ),
        ],
      ),
    );
  }

  // Also update the feature illustration to be more adaptive
  Widget _buildFeatureIllustration(bool isDark, IconData iconData) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSize = constraints.maxHeight;
        final innerSize = maxSize * 0.7;  // Adaptive inner container size
        
        return Container(
          width: maxSize,
          height: maxSize,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: isDark 
                ? [
                    AppColors.greenTeal.withOpacity(0.15),
                    AppColors.deepTeal.withOpacity(0.05),
                  ]
                : [
                    AppColors.brandOrange.withOpacity(0.15),
                    AppColors.brandDeepOrange.withOpacity(0.05),
                  ],
              radius: 0.8,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: innerSize,
              height: innerSize,
              padding: EdgeInsets.all(innerSize * 0.2),  // Adaptive padding
              decoration: BoxDecoration(
                color: isDark 
                  ? Color.lerp(AppColors.darkBg, Colors.black, 0.3)?.withOpacity(0.85)
                  : Colors.white.withOpacity(0.85),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                      ? AppColors.greenTeal.withOpacity(0.15)
                      : AppColors.brandOrange.withOpacity(0.15),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => LinearGradient(
                  colors: isDark 
                    ? [AppColors.greenTeal, AppColors.deepGreenTeal]
                    : [AppColors.brandOrange, AppColors.brandDeepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Icon(
                  iconData,
                  size: innerSize * 0.6,  // Adaptive icon size
                ),
              ),
            ),
          ),
        );
      }
    );
  }
  
  Widget _customButton({
    required bool isDark, 
    required String label, 
    required IconData icon, 
    required VoidCallback onPressed
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [AppColors.greenTeal, AppColors.deepGreenTeal]
            : [AppColors.brandOrange, AppColors.brandDeepOrange],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? AppColors.greenTeal.withOpacity(0.25)
              : AppColors.brandOrange.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onPressed,
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Center(
            child: Row(
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
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
