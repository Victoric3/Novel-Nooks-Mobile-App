import 'dart:math';
import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:eulaiq/src/common/common.dart';
import 'package:eulaiq/src/common/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Add this
        children: [
          // Background with dynamic gradient
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              decoration: BoxDecoration(gradient: _buildGradient(isDark)),
            ),
          ),

          // Particle effect for dark mode
          if (isDark)
            Positioned.fill(
              child: AnimatedParticleField(
                colors: const [AppColors.neonCyan, AppColors.neonPurple],
                controller: _controller,
              ),
            ),

          // Main content
          SafeArea(
            child: LayoutBuilder(
              // Add LayoutBuilder
              builder: (context, constraints) {
                return SingleChildScrollView(
                  // Add ScrollView for small screens
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      // Add IntrinsicHeight
                      child: Column(
                        children: [
                          const Spacer(flex: 2),

                          // Mascot section with constrained size
                          Hero(
                            tag: 'app_mascot',
                            child: SizedBox(
                              width: size.width * 0.5, // Reduce from 0.6 to 0.5
                              height: size.width * 0.5,
                              child: Stack(
                                fit: StackFit.expand, // Add this
                                alignment: Alignment.center,
                                children: [
                                  // Glass effect background
                                  _GlassContainer(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            isDark
                                                ? AppColors.darkBgCard
                                                    .withOpacity(0.3)
                                                : Colors.white.withOpacity(0.8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.neonCyan
                                                .withOpacity(0.2),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Animated mascot
                                  // In the AnimatedBuilder for the mascot
                                  AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          0,
                                          6 *
                                              sin(
                                                _controller.value * 4 * pi,
                                              ), // Increased frequency and reduced amplitude
                                        ),
                                        child: Transform.rotate(
                                          angle:
                                              0.03 *
                                              sin(
                                                _controller.value * 2 * pi,
                                              ), // Adjusted rotation
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Image.asset(
                                      'assets/brand_assets/Eula.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                            height: size.height * 0.04,
                          ), // Responsive spacing
                          // Orbital feature icons with constrained size
                          SizedBox(
                            height: size.height * 0.15, // Responsive height
                            child: _OrbitalFeatureIcons(
                              controller: _controller,
                            ),
                          ),

                          SizedBox(height: size.height * 0.04),

                          // Animated text content
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _AnimatedIntroText(
                              controller: _controller,
                              isDark: isDark,
                              textTheme: textTheme,
                            ),
                          ),

                          const Spacer(flex: 2),

                          // CTA button
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: size.height * 0.05,
                              left: 24,
                              right: 24,
                            ),
                            child: _NeonButton(
                              onPressed:
                                  () => context.router.replace(const AuthRoute()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

LinearGradient _buildGradient(bool isDark) {
  return isDark
      ? LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.darkBg,
          AppColors.darkBg,
          AppColors.neonPurple.withOpacity(0.1),
        ],
        stops: const [0.0, 0.7, 1.0],
      )
      : LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.neutralLightGray,
          AppColors.brandDeepGold.withOpacity(0.05),
        ],
      );
}

class _GlassContainer extends StatelessWidget {
  final Widget child;

  const _GlassContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: child,
      ),
    );
  }
}

class _OrbitalFeatureIcons extends StatefulWidget {
  final AnimationController controller;

  const _OrbitalFeatureIcons({required this.controller});

  @override
  __OrbitalFeatureIconsState createState() => __OrbitalFeatureIconsState();
}

class __OrbitalFeatureIconsState extends State<_OrbitalFeatureIcons> {
  final List<Map<String, dynamic>> _features = [
    {'icon': Icons.auto_stories, 'label': 'Smart Text Conversion'},
    {'icon': Icons.audiotrack, 'label': 'Personalized Audio'},
    {'icon': Icons.slow_motion_video, 'label': 'AI Video Lessons'},
    {'icon': Icons.psychology, 'label': 'Eula AI Assistant'},
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 120,
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: List.generate(_features.length, (index) {
                // Slow down rotation by reducing multiplier from 2 to 1
                final angle =
                    2 * pi * index / _features.length +
                    widget.controller.value * pi; // Reduced from 2 * pi to pi

                return Transform.translate(
                  offset: Offset(60 * cos(angle), 60 * sin(angle)),
                  child: Transform.rotate(
                    angle: -angle, // Counter-rotate icons to keep them upright
                    child: _FeatureIcon(
                      icon: _features[index]['icon'] as IconData,
                      label: _features[index]['label'] as String,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.neonCyan
                              : AppColors.brandDeepGold,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureIcon({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  State<_FeatureIcon> createState() => _FeatureIconState();
}

class _FeatureIconState extends State<_FeatureIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_hoverController.value * 0.1),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(
                  0.1 + (_hoverController.value * 0.1),
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (isHovered)
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 20 + (_hoverController.value * 2),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FeatureDetails {
  final String title;
  final String description;

  FeatureDetails({required this.title, required this.description});
}

class _AnimatedIntroText extends StatefulWidget {
  final AnimationController controller;
  final bool isDark;
  final TextTheme textTheme;

  const _AnimatedIntroText({
    required this.controller,
    required this.isDark,
    required this.textTheme,
  });

  @override
  State<_AnimatedIntroText> createState() => _AnimatedIntroTextState();
}

class _AnimatedIntroTextState extends State<_AnimatedIntroText>
    with SingleTickerProviderStateMixin {
  final List<String> _taglines = [
    'Bite-Sized Learning',
    'PDF to Podcast in 1 Click',
    'Context-Aware Study Plans',
    'Crowd-Sourced Mnemonics',
  ];

  int _currentIndex = 0;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _currentIndex = (_currentIndex + 1) % _taglines.length);
        _textController.reset();
        _textController.forward();
      }
    });

    _textController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder:
              (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
          child: Text(
            _taglines[_currentIndex],
            key: ValueKey<int>(_currentIndex),
            style: widget.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.2,
              foreground:
                  Paint()
                    ..shader = LinearGradient(
                      colors:
                          widget.isDark
                              ? [AppColors.neonCyan, AppColors.neonPurple]
                              : [
                                AppColors.brandDeepGold,
                                AppColors.brandWarmOrange,
                              ],
                    ).createShader(const Rect.fromLTWH(0, 0, 300, 20)),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'AI-curated medical learning, tailored to you',
          style: widget.textTheme.titleMedium?.copyWith(
            color:
                widget.isDark ? AppColors.neonCyan : AppColors.neutralDarkGray,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _textController.value,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
          ),
          minHeight: 2,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class _NeonButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _NeonButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors:
              isDark
                  ? [AppColors.neonPurple, AppColors.neonCyan]
                  : [AppColors.brandWarmOrange, AppColors.brandDeepGold],
        ),
        boxShadow: [
          if (isDark)
            BoxShadow(
              color: AppColors.neonCyan.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Get Started',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkBg : Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_rounded,
              size: 20,
              color: isDark ? AppColors.darkBg : Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedParticleField extends StatefulWidget {
  final List<Color> colors;
  final AnimationController controller;

  const AnimatedParticleField({
    super.key,
    required this.colors,
    required this.controller,
  });

  @override
  _AnimatedParticleFieldState createState() => _AnimatedParticleFieldState();
}

class _AnimatedParticleFieldState extends State<AnimatedParticleField> {
  final List<Particle> particles = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateParticles);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeParticles();
      _isInitialized = true;
    }
  }

  void _initializeParticles() {
    particles.clear();
    final size = MediaQuery.of(context).size;
    for (var i = 0; i < 50; i++) {
      particles.add(
        Particle(
          color: widget.colors[i % widget.colors.length],
          screenSize: size,
        ),
      );
    }
  }

  void _updateParticles() {
    setState(() {
      for (final particle in particles) {
        particle.update();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ParticlePainter(particles: particles));
  }
}

class Particle {
  final Color color;
  Offset position;
  final double speed;
  final double angle;
  final double size;
  final double opacity;

  Particle({required this.color, required Size screenSize})
    : position = Offset(
        Random().nextDouble() * screenSize.width,
        Random().nextDouble() * screenSize.height,
      ),
      speed = Random().nextDouble() * 0.5 + 0.2,
      angle = Random().nextDouble() * 2 * pi,
      size = Random().nextDouble() * 2 + 1,
      opacity = Random().nextDouble() * 0.5 + 0.2;

  void update() {
    position += Offset(sin(angle) * speed, cos(angle) * speed);
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  _ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint =
          Paint()
            ..color = particle.color.withOpacity(particle.opacity)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
