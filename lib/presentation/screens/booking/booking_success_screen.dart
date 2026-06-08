import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../home/main_navigation.dart';

class BookingSuccessScreen extends StatefulWidget {
  final String doctorName, specialty, initials, date, time, location, consultType, motif, bookingRef;
  final Color color;

  const BookingSuccessScreen({
    super.key,
    required this.doctorName, required this.specialty, required this.initials,
    required this.color, required this.date, required this.time,
    required this.location, required this.consultType, required this.motif,
    required this.bookingRef,
  });

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkCtrl;
  late AnimationController _confettiCtrl;
  late AnimationController _cardCtrl;
  late Animation<double> _checkScale;
  late Animation<double> _cardSlide;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _confettiCtrl = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
    _cardCtrl = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    _checkScale = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
    _cardSlide = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);

    Future.delayed(const Duration(milliseconds: 100), () {
      _checkCtrl.forward();
      _confettiCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () => _cardCtrl.forward());
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _confettiCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final _isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: Stack(
        children: [
          // Confetti
          AnimatedBuilder(
            animation: _confettiCtrl,
            builder: (_, _) => CustomPaint(
              painter: _ConfettiPainter(_confettiCtrl.value),
              size: MediaQuery.of(context).size,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                child: Column(
                  children: [
                    // Check animé
                    ScaleTransition(
                      scale: _checkScale,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.accent, Color(0xFF00E5A0)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
                      ),
                    ),

                    const SizedBox(height: 28),
                    Text(
                      'Rendez-vous confirmé !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w900,
                        color: context.textPrimary, letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Votre RDV a été enregistré avec succès.\nUn rappel vous sera envoyé 1h avant.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: context.textMuted, height: 1.5),
                    ),

                    const SizedBox(height: 32),

                    // Ticket RDV
                    SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                          .animate(_cardSlide),
                      child: FadeTransition(
                        opacity: _cardSlide,
                        child: _BookingTicket(widget: widget),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.calendar_today_outlined, size: 16),
                            label: const Text('Calendrier'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.share_outlined, size: 16),
                            label: const Text('Partager'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const MainNavigation()),
                          (route) => false,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Retour à l\'accueil',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
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
}

class _BookingTicket extends StatelessWidget {
  final BookingSuccessScreen widget;
  const _BookingTicket({required this.widget});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          // Top coloré
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              border: Border(bottom: BorderSide(color: widget.color.withValues(alpha: 0.15), width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Text(widget.initials,
                      style: TextStyle(color: widget.color, fontWeight: FontWeight.w800, fontSize: 20))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.doctorName,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.textPrimary)),
                      const SizedBox(height: 3),
                      Text(widget.specialty,
                          style: TextStyle(fontSize: 13, color: widget.color, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: context.successBgColor, borderRadius: BorderRadius.circular(8)),
                  child: Text('Confirmé',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.successTextColor)),
                ),
              ],
            ),
          ),

          // Infos
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _TicketRow(icon: Icons.calendar_today_rounded, label: 'Date', value: widget.date),
                const SizedBox(height: 12),
                _TicketRow(icon: Icons.access_time_rounded, label: 'Heure', value: widget.time),
                const SizedBox(height: 12),
                _TicketRow(icon: Icons.location_on_outlined, label: 'Lieu', value: widget.location),
                const SizedBox(height: 12),
                _TicketRow(icon: Icons.medical_information_outlined, label: 'Motif', value: widget.motif),
                const SizedBox(height: 12),
                _TicketRow(icon: Icons.videocam_outlined, label: 'Type', value: widget.consultType),
              ],
            ),
          ),

          // Tiret de découpe
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(30, (i) => Expanded(
                child: Container(
                  height: 1,
                  color: i.isEven ? AppColors.border : Colors.transparent,
                ),
              )),
            ),
          ),

          // Bas — Ref + QR
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Référence',
                        style: TextStyle(fontSize: 11, color: context.textMuted, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(widget.bookingRef,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                            color: context.textPrimary, letterSpacing: 1)),
                  ],
                ),
                const Spacer(),
                // QR Code simplifié
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: context.textPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomPaint(painter: _QRPainter()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _TicketRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.textMuted),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 13, color: context.textMuted, fontWeight: FontWeight.w400)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary)),
      ],
    );
  }
}

// Confetti Painter
class _ConfettiPainter extends CustomPainter {
  final double progress;
  final _rng = math.Random(42);
  final _colors = [AppColors.primary, AppColors.accent, AppColors.warning, AppColors.danger, const Color(0xFF845EF7)];

  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress > 0.8) return;
    for (int i = 0; i < 60; i++) {
      final x = _rng.nextDouble() * size.width;
      final startY = -20.0;
      final endY = size.height * 0.7;
      final y = startY + (endY - startY) * progress + _rng.nextDouble() * 40 * math.sin(progress * math.pi * 2 + i);
      final opacity = (1 - progress / 0.8).clamp(0.0, 1.0);
      final paint = Paint()..color = _colors[i % _colors.length].withValues(alpha: opacity * 0.8);
      final w = 6.0 + _rng.nextDouble() * 6;
      final h = 4.0 + _rng.nextDouble() * 4;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * 2 * (i.isEven ? 1 : -1) + i.toDouble());
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: w, height: h), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

// QR simplifié
class _QRPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    final cell = size.width / 8;
    final pattern = [
      [1,1,1,1,1,1,1,0], [1,0,0,0,0,0,1,0], [1,0,1,1,1,0,1,0],
      [1,0,1,1,1,0,1,0], [1,0,0,0,0,0,1,0], [1,1,1,1,1,1,1,0],
      [0,1,0,1,0,1,0,1], [1,0,1,0,1,0,1,0],
    ];
    for (int r = 0; r < pattern.length; r++) {
      for (int c = 0; c < pattern[r].length; c++) {
        if (pattern[r][c] == 1) {
          canvas.drawRect(Rect.fromLTWH(c * cell + 2, r * cell + 2, cell - 1, cell - 1), p);
        }
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
