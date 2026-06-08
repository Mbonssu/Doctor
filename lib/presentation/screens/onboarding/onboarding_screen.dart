import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../auth/welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _current = 0;
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final _slides = const [
    _Slide(
      icon: Icons.search_rounded,
      color: AppColors.primary,
      gradient: [Color(0xFF1B54F8), Color(0xFF4D7FFF)],
      title: 'Trouvez le bon médecin',
      subtitle:
          'Parcourez des centaines de spécialistes certifiés près de chez vous. Filtrez par spécialité, disponibilité et tarif.',
      tag: '✅ Médecins vérifiés',
    ),
    _Slide(
      icon: Icons.calendar_month_rounded,
      color: AppColors.accent,
      gradient: [Color(0xFF00C48C), Color(0xFF00E5A0)],
      title: 'Réservez en 30 secondes',
      subtitle:
          'Plus d\'attente au téléphone. Choisissez votre créneau en ligne, recevez une confirmation immédiate.',
      tag: '⚡ Confirmation instantanée',
    ),
    _Slide(
      icon: Icons.folder_shared_rounded,
      color: Color(0xFF845EF7),
      gradient: [Color(0xFF845EF7), Color(0xFFB197FC)],
      title: 'Votre dossier médical',
      subtitle:
          'Ordonnances, résultats, antécédents — tout en un seul endroit. Partagez-le avec vos médecins en un tap.',
      tag: '🔒 Données chiffrées',
    ),
    _Slide(
      icon: Icons.notifications_active_rounded,
      color: AppColors.danger,
      gradient: [Color(0xFFFF4D4F), Color(0xFFFF7875)],
      title: 'Ne ratez plus rien',
      subtitle:
          'Rappels automatiques avant chaque RDV, notifications de résultats, et suivi de vos traitements en temps réel.',
      tag: '🔔 Rappels intelligents',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _fade =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _slides.length - 1) {
      _animCtrl.reset();
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
      _animCtrl.forward();
    } else {
      _goToApp();
    }
  }

  void _goToApp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const WelcomeScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_current];

    return Scaffold(
      body: Stack(
        children: [
          // Fond animé
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [...slide.gradient, const Color(0xFF0D1B3E)],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // Déco cercles
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 24, 0),
                    child: GestureDetector(
                      onTap: _goToApp,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Passer',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    itemCount: _slides.length,
                    onPageChanged: (i) {
                      setState(() => _current = i);
                      _animCtrl.reset();
                      _animCtrl.forward();
                    },
                    itemBuilder: (_, i) {
                      final s = _slides[i];
                      return FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slide,
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(32, 32, 32, 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Illustration
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(40),
                                    border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        width: 2),
                                  ),
                                  child: Icon(s.icon,
                                      size: 68, color: Colors.white),
                                ),
                                const SizedBox(height: 40),
                                // Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(s.tag,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  s.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.8,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  s.subtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withValues(alpha: 0.75),
                                    height: 1.6,
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

                // Bottom controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                  child: Column(
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _current ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _current
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Bouton
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                          child: Text(
                            _current < _slides.length - 1
                                ? 'Continuer'
                                : 'Commencer maintenant',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: slide.color,
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
        ],
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final String title;
  final String subtitle;
  final String tag;

  const _Slide({
    required this.icon,
    required this.color,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.tag,
  });
}
