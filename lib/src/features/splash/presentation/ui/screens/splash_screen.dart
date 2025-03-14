import 'dart:async';
import 'dart:math';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bookSlideAnimation;
  late Animation<double> _bookRotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _bookSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    
    _bookRotateAnimation = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    startTimeout();
  }

  void startTimeout() {
    Timer(const Duration(seconds: 3), () => context.router.replace(const TabsRoute()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Enhanced gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.5),
                radius: 1.5,
                colors: isDark
                    ? [
                        AppColors.neonPurple.withOpacity(0.15),
                        AppColors.darkBg,
                        AppColors.darkBg,
                      ]
                    : [
                        AppColors.brandWarmOrange.withOpacity(0.1),
                        AppColors.neutralLightGray,
                        Colors.white,
                      ],
              ),
            ),
          ),

          // Animated particles effect (like dust particles in a library)
          CustomPaint(
            painter: ParticlesPainter(
              color: (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                  .withOpacity(0.12),
              particleCount: 40,
            ),
          ),

          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated stacked books
              AnimatedBuilder(
                animation: Listenable.merge([_bookSlideAnimation, _bookRotateAnimation]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bookSlideAnimation.value),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SizedBox(
                        height: size.height * 0.4,
                        width: size.width * 0.7,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Third book (back)
                            Positioned(
                              left: size.width * 0.1,
                              child: Transform.rotate(
                                angle: -0.12 + _bookRotateAnimation.value,
                                child: _buildBook(
                                  isDark: isDark,
                                  width: size.width * 0.3,
                                  height: size.height * 0.25,
                                  color: isDark ? AppColors.darkBgCard : Colors.white,
                                  borderColor: isDark ? AppColors.neonPurple.withOpacity(0.5) : AppColors.brandWarmOrange.withOpacity(0.5),
                                ),
                              ),
                            ),
                            
                            // Second book (middle)
                            Positioned(
                              child: Transform.rotate(
                                angle: 0.08 - _bookRotateAnimation.value,
                                child: _buildBook(
                                  isDark: isDark,
                                  width: size.width * 0.32,
                                  height: size.height * 0.28,
                                  color: isDark ? Color.lerp(AppColors.darkBgCard, AppColors.neonPurple, 0.05)! : Color.lerp(Colors.white, AppColors.brandDeepGold, 0.03)!,
                                  borderColor: isDark ? AppColors.neonCyan.withOpacity(0.6) : AppColors.brandDeepGold.withOpacity(0.6),
                                ),
                              ),
                            ),
                            
                            // First book (front)
                            Positioned(
                              right: size.width * 0.12,
                              child: Transform.rotate(
                                angle: 0.15 - _bookRotateAnimation.value * 2,
                                child: _buildBook(
                                  isDark: isDark,
                                  width: size.width * 0.28,
                                  height: size.height * 0.24,
                                  color: isDark ? Color.lerp(AppColors.darkBgCard, Colors.black, 0.2)! : Colors.white,
                                  borderColor: isDark ? AppColors.neonCyan.withOpacity(0.7) : AppColors.brandDeepGold.withOpacity(0.7),
                                  withBookmark: true,
                                  bookmarkColor: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: size.height * 0.06),
              
              // App Logo and Name
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App logo
                      Container(
                        width: size.width * 0.22,
                        height: size.width * 0.22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark 
                              ? AppColors.darkBgCard.withOpacity(0.4)
                              : Colors.white.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                                  .withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Hero(
                          tag: 'app_logo',
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/app-logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: size.height * 0.025),
                      
                      // App name with gradient text
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: isDark
                              ? [AppColors.neonCyan, AppColors.neonPurple]
                              : [AppColors.brandDeepGold, AppColors.brandWarmOrange],
                        ).createShader(bounds),
                        child: Text(
                          'Novel Nooks',
                          style: TextStyle(
                            fontSize: size.width * 0.07,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Tagline
                      Text(
                        'Your personal reading sanctuary',
                        style: TextStyle(
                          fontSize: size.width * 0.035,
                          color: isDark 
                              ? Colors.white60
                              : AppColors.neutralDarkGray.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBook({
    required bool isDark,
    required double width, 
    required double height, 
    required Color color,
    required Color borderColor,
    bool withBookmark = false,
    Color? bookmarkColor,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(4, 4),
          ),
        ],
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Book spine
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 10,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                    ? [AppColors.neonCyan.withOpacity(0.7), borderColor]
                    : [AppColors.brandDeepGold.withOpacity(0.7), borderColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
          ),
          
          // Book lines (text simulation)
          Positioned(
            left: 20,
            top: height * 0.2,
            right: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                5,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  height: 2,
                  width: index == 1 || index == 3 ? width * 0.5 : width * 0.7,
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                ),
              ),
            ),
          ),
          
          // Bookmark
          if (withBookmark)
            Positioned(
              top: -5,
              right: width * 0.2,
              child: Container(
                width: 20,
                height: 40,
                decoration: BoxDecoration(
                  color: bookmarkColor ?? AppColors.brandDeepGold,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Improved particle effect for a more refined look
class ParticlesPainter extends CustomPainter {
  final Color color;
  final int particleCount;
  final List<Particle> _particles = [];
  
  ParticlesPainter({required this.color, this.particleCount = 30}) {
    _initializeParticles();
  }
  
  void _initializeParticles() {
    final random = Random();
    for (int i = 0; i < particleCount; i++) {
      _particles.add(
        Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: random.nextDouble() * 2.5 + 0.5,
          opacity: random.nextDouble() * 0.6 + 0.2,
        ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in _particles) {
      final paint = Paint()
        ..color = color.withOpacity(particle.opacity);
      
      canvas.drawCircle(
        Offset(
          particle.x * size.width, 
          particle.y * size.height
        ), 
        particle.radius, 
        paint
      );
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => false;
}

class Particle {
  final double x;
  final double y;
  final double radius;
  final double opacity;
  
  Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
  });
}
