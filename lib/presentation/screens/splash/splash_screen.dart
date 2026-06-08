import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../auth/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _orbController;

  late Animation<double> _fadeIn;
  late Animation<double> _logoScale;
  late Animation<double> _logoY;
  late Animation<double> _textFade;
  late Animation<double> _taglineFade;
  late Animation<double> _pulse;
  late Animation<double> _orb;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _orbController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    )..repeat();

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
    );
    _logoY = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.35, 0.65, curve: Curves.easeOut)),
    );
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.5, 0.8, curve: Curves.easeOut)),
    );
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _orb = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.linear),
    );

    _mainController.forward();

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const WelcomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A1128), Color(0xFF1B2E5E), Color(0xFF0D1B3E)],
          ),
        ),
        child: Stack(
          children: [
            // Orbs décoratifs animés
            AnimatedBuilder(
              animation: _orb,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: -80 + 30 * math.sin(_orb.value),
                      right: -60 + 20 * math.cos(_orb.value),
                      child: _GlowOrb(color: AppColors.primary, size: 260, opacity: 0.18),
                    ),
                    Positioned(
                      bottom: -60 + 25 * math.cos(_orb.value + 1),
                      left: -40 + 15 * math.sin(_orb.value + 2),
                      child: _GlowOrb(color: AppColors.accent, size: 220, opacity: 0.14),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.45 + 20 * math.sin(_orb.value + 3),
                      right: 40 + 15 * math.cos(_orb.value + 1),
                      child: _GlowOrb(color: const Color(0xFF845EF7), size: 140, opacity: 0.10),
                    ),
                  ],
                );
              },
            ),

            // Grille décorative subtile
            Positioned.fill(
              child: CustomPaint(painter: _GridPainter()),
            ),

            // Contenu principal
            Center(
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeIn,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Transform.translate(
                          offset: Offset(0, _logoY.value),
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: AnimatedBuilder(
                              animation: _pulse,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulse.value,
                                  child: _LogoWidget(),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Nom de l'appli
                        FadeTransition(
                          opacity: _textFade,
                          child: Column(
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Docto',
                                      style: TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -1.5,
                                        height: 1,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Ping',
                                      style: TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF4D7FFF),
                                        letterSpacing: -1.5,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Ligne décorative
                              Container(
                                width: 48,
                                height: 3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primary, AppColors.accent],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tagline
                        FadeTransition(
                          opacity: _taglineFade,
                          child: Text(
                            'Votre santé, à portée de tap',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.55),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 80),

                        // Indicateur de chargement premium
                        FadeTransition(
                          opacity: _taglineFade,
                          child: _PremiumLoader(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Version en bas
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _taglineFade,
                child: Center(
                  child: Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.25),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B54F8), Color(0xFF4D7FFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 80,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Croix médicale
          SizedBox(
            width: 50,
            height: 50,
            child: CustomPaint(painter: _CrossPainter()),
          ),
          // Point / ping
          Positioned(
            right: 20,
            bottom: 22,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final arm = w * 0.28;
    final thick = w * 0.24;
    // Horizontal
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w / 2, h / 2), width: w - arm, height: thick),
        const Radius.circular(4),
      ),
      paint,
    );
    // Vertical
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w / 2, h / 2), width: thick, height: h - arm),
        const Radius.circular(4),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PremiumLoader extends StatefulWidget {
  @override
  State<_PremiumLoader> createState() => _PremiumLoaderState();
}

class _PremiumLoaderState extends State<_PremiumLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i * 0.25;
            final t = ((_ctrl.value - delay).clamp(0.0, 1.0));
            final scale = 0.6 + 0.4 * math.sin(t * math.pi);
            final opacity = 0.3 + 0.7 * math.sin(t * math.pi);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == 1 ? AppColors.accent : AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _GlowOrb({required this.color, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 0.5;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
