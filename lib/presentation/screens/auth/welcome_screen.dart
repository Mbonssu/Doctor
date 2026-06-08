import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 900), vsync: this);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topH = size.height * 0.52;
    final sheetTop = size.height * 0.50;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: Stack(
        children: [
          // ── Fond haut ──
          Positioned(
            top: 0, left: 0, right: 0,
            height: topH,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0xFF0D1B3E), Color(0xFF1B2E5E)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(top: -50, right: -40,
                      child: Container(width: 200, height: 200,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.15)))),
                  Positioned(top: 80, left: -30,
                      child: Container(width: 120, height: 120,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                              color: AppColors.accent.withValues(alpha: 0.10)))),
                  // SafeArea pour le contenu du haut
                  SafeArea(bottom: false,
                    child: Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _HeroIllustration(),
                          const SizedBox(height: 24),
                          RichText(text: const TextSpan(children: [
                            TextSpan(text: 'Docto', style: TextStyle(fontSize: 32,
                                fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.2)),
                            TextSpan(text: 'Ping', style: TextStyle(fontSize: 32,
                                fontWeight: FontWeight.w900, color: Color(0xFF4D7FFF), letterSpacing: -1.2)),
                          ])),
                          const SizedBox(height: 8),
                          Text('Votre santé, à portée de tap',
                              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Courbe de transition ──
          Positioned(
            top: topH - 20,
            left: 0, right: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: context.bgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32), topRight: Radius.circular(32),
                ),
              ),
            ),
          ),

          // ── Contenu bas ──
          Positioned(
            top: sheetTop, left: 0, right: 0, bottom: 0,
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slideUp,
                child: Container(
                  color: context.bgColor,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Prenez soin de vous',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                            letterSpacing: -0.8, color: context.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Trouvez le bon médecin, réservez en 30 secondes, et gérez tous vos rendez-vous depuis une seule app.',
                        style: TextStyle(fontSize: 14, color: context.textSecondary, height: 1.55),
                      ),
                      const SizedBox(height: 24),
                      Wrap(spacing: 10, runSpacing: 10, children: const [
                        _FeatureBadge(icon: Icons.verified_rounded, label: 'Médecins certifiés'),
                        _FeatureBadge(icon: Icons.schedule_rounded, label: 'Rappels auto'),
                        _FeatureBadge(icon: Icons.lock_outlined, label: 'Données sécurisées'),
                      ]),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const LoginScreen())),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            backgroundColor: AppColors.primary, elevation: 0,
                          ),
                          child: const Text('Se connecter',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen())),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            side: BorderSide(color: context.borderColor, width: 1.5),
                          ),
                          child: Text('Créer un compte',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimary)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'En continuant, vous acceptez nos CGU et politique de confidentialité.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: context.textMuted, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 24),
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
}

class _HeroIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160, height: 160,
      child: Stack(alignment: Alignment.center, children: [
        Container(width: 160, height: 160, decoration: BoxDecoration(
            shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.12))),
        Container(width: 120, height: 120, decoration: BoxDecoration(
            shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.18))),
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF1B54F8), Color(0xFF4D7FFF)]),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.45), blurRadius: 28, offset: const Offset(0, 10))],
          ),
          child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 44),
        ),
        Positioned(right: 14, bottom: 14,
          child: Container(width: 32, height: 32,
            decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1B2E5E), width: 2.5),
                boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.5), blurRadius: 10)]),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 16)),
        ),
      ]),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.textPrimary)),
      ]),
    );
  }
}
