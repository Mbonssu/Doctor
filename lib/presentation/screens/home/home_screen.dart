import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../core/routes/navigation_helper.dart';
import '../../../core/utils/modal_utils.dart';
import '../booking/booking_flow_screen.dart';
import '../health/health_screens.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _onRefresh() async => await Future.delayed(const Duration(seconds: 1));

  @override
  Widget build(BuildContext context) {
    final _isDark = context.isDark;
    return Scaffold(
      backgroundColor: context.isDark 
          ? Colors.transparent // Transparent pour voir le gradient du parent
          : context.bgColor,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // HEADER
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF0D1B3E), Color(0xFF1B2E5E)]),
                ),
                child: SafeArea(bottom: false, child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_greeting(), style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
                        const SizedBox(height: 3),
                        const Text('Jean Dupont', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                      ])),
                      GestureDetector(
                        onTap: () => NavigationHelper.goToNotifications(context),
                        child: Stack(children: [
                          Container(width: 44, height: 44, margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22)),
                          const Positioned(top: 8, right: 18,
                              child: CircleAvatar(backgroundColor: AppColors.danger, radius: 4.5)),
                        ]),
                      ),
                      Container(width: 44, height: 44,
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2)),
                          child: const Center(child: Text('JD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)))),
                    ]),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => NavigationHelper.goToSearch(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1)),
                        child: Row(children: [
                          Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.6), size: 20),
                          const SizedBox(width: 10),
                          Text('Médecin, spécialité, symptôme…', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                          const Spacer(),
                          Container(padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 14)),
                        ]),
                      ),
                    ),
                  ]),
                )),
              ),
            ),

            // STATS
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(children: [
                GlassStatCard(value: '2', label: 'RDV à venir', icon: Icons.calendar_month_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                GlassStatCard(value: '12', label: 'Consultations', icon: Icons.medical_services_rounded, color: AppColors.accent,
                    onTap: () => NavigationHelper.goToHealth(context)),
                const SizedBox(width: 12),
                GlassStatCard(value: '4', label: 'Médecins', icon: Icons.people_alt_rounded, color: const Color(0xFF845EF7)),
              ]),
            )),

            // ACTIONS RAPIDES
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _SectionTitle(title: 'Actions rapides'),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _QuickAction(icon: Icons.add_circle_outline_rounded, label: 'Nouveau RDV',
                      color: AppColors.primary, bgColor: context.primaryLightColor,
                      onTap: () => NavigationHelper.goToBookingFlow(context))),
                  const SizedBox(width: 12),
                  Expanded(child: _QuickAction(icon: Icons.local_hospital_rounded, label: 'Urgences',
                      color: AppColors.danger, bgColor: AppColors.dangerLight,
                      onTap: () => _showEmergencySheet(context))),
                  const SizedBox(width: 12),
                  Expanded(child: _QuickAction(icon: Icons.videocam_outlined, label: 'Téléconsult.',
                      color: const Color(0xFF845EF7), bgColor: const Color(0xFFF0EBFF),
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const ComingSoonScreen(feature: 'Téléconsultation'))))),
                  const SizedBox(width: 12),
                  Expanded(child: _QuickAction(icon: Icons.folder_shared_outlined, label: 'Dossier',
                      color: AppColors.accent, bgColor: AppColors.accentLight,
                      onTap: () => NavigationHelper.goToMedicalRecord(context))),
                ]),
              ]),
            )),

            // PROCHAIN RDV
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _SectionTitle(title: 'Prochain rendez-vous', onSeeAll: () {}),
                const SizedBox(height: 14),
                _NextAppointmentCard(),
              ]),
            )),

            // SPÉCIALITÉS
            const SliverToBoxAdapter(child: Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 0, 0),
              child: _SectionTitle(title: 'Spécialités'),
            )),
            SliverToBoxAdapter(child: SizedBox(height: 116, child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              scrollDirection: Axis.horizontal,
              children: const [
                _SpecialtyChip(icon: Icons.favorite_rounded, label: 'Cardiologie', color: AppColors.cardio),
                _SpecialtyChip(icon: Icons.psychology_rounded, label: 'Neurologie', color: AppColors.neuro),
                _SpecialtyChip(icon: Icons.child_care_rounded, label: 'Pédiatrie', color: AppColors.pediatrie),
                _SpecialtyChip(icon: Icons.visibility_rounded, label: 'Ophtalmologie', color: AppColors.ophtalmo),
                _SpecialtyChip(icon: Icons.face_retouching_natural, label: 'Dermatologie', color: AppColors.dermato),
                _SpecialtyChip(icon: Icons.pregnant_woman_rounded, label: 'Gynécologie', color: AppColors.gyneco),
                _SpecialtyChip(icon: Icons.accessible_forward_rounded, label: 'Orthopédie', color: AppColors.ortho),
                _SpecialtyChip(icon: Icons.medical_services_rounded, label: 'Généraliste', color: AppColors.generale),
              ],
            ))),

            // DASHBOARD BANNER
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: GestureDetector(
                onTap: () => NavigationHelper.goToHealth(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFF845EF7), Color(0xFFB197FC)]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(children: [
                    Container(width: 50, height: 50,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 26)),
                    const SizedBox(width: 14),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Tableau de santé', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                      SizedBox(height: 3),
                      Text('12 consultations · 127 500 FCFA de dépenses', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ])),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 18),
                  ]),
                ),
              ),
            )),

            // MÉDECINS
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _SectionTitle(title: 'Médecins recommandés',
                  onSeeAll: () => NavigationHelper.goToSearch(context)),
            )),
            SliverList(delegate: SliverChildListDelegate([
              Padding(padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                  child: _DoctorCard(name: 'Dr. Amine Toure', specialty: 'Cardiologie', rating: 4.9, reviews: 128,
                      price: '15 000 FCFA', available: true, initials: 'AT', color: AppColors.cardio, experience: '10 ans')),
              Padding(padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: _DoctorCard(name: 'Dr. Nathalie Bello', specialty: 'Pédiatrie', rating: 4.8, reviews: 96,
                      price: '12 000 FCFA', available: true, initials: 'NB', color: AppColors.pediatrie, experience: '8 ans')),
              Padding(padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: _DoctorCard(name: 'Dr. Paul Mbarga', specialty: 'Neurologie', rating: 4.7, reviews: 74,
                      price: '18 000 FCFA', available: false, initials: 'PM', color: AppColors.neuro, experience: '15 ans')),
              const SizedBox(height: 32),
            ])),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour 🌅';
    if (h < 18) return 'Bon après-midi ☀️';
    return 'Bonsoir 🌙';
  }

  void _showEmergencySheet(BuildContext context) {
    ModalUtils.showBlurredBottomSheet(
      context: context,
      builder: (_) => _EmergencySheet(),
    );
  }
}

class _EmergencySheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final _isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        const Row(children: [
          Icon(Icons.local_hospital_rounded, color: AppColors.danger, size: 22),
          SizedBox(width: 10),
          Text('Urgences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.danger)),
        ]),
        const SizedBox(height: 16),
        _EItem(icon: Icons.phone_rounded, color: AppColors.danger, title: 'Appel SAMU / Urgences', subtitle: 'Composer le 15 ou le 112', onTap: () {}),
        const SizedBox(height: 10),
        _EItem(icon: Icons.location_on_rounded, color: AppColors.primary, title: 'Hôpital le plus proche', subtitle: 'Voir les urgences autour de moi', onTap: () {
          Navigator.pop(context);
          NavigationHelper.goToMapView(context);
        }),
        const SizedBox(height: 10),
        _EItem(icon: Icons.qr_code_rounded, color: const Color(0xFF845EF7), title: 'Ma carte patient', subtitle: 'Groupe O+ · Allergie Pénicilline',
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const QRCardScreen())); }),
        const SizedBox(height: 16),
      ]),
    );
  }
}

class _EItem extends StatelessWidget {
  final IconData icon; final Color color; final String title, subtitle; final VoidCallback onTap;
  const _EItem({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final _isDark = context.isDark;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: context.isDark ? 0.2 : 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary)),
          Text(subtitle, style: TextStyle(fontSize: 11, color: context.textMuted)),
        ])),
        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: context.textMuted),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title; final VoidCallback? onSeeAll;
  const _SectionTitle({required this.title, this.onSeeAll});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: context.textPrimary, letterSpacing: -0.3)),
    if (onSeeAll != null) GestureDetector(onTap: onSeeAll, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: context.primaryLightColor, borderRadius: BorderRadius.circular(8)),
        child: const Text('Voir tout', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)))),
  ]);
}

class _StatCard extends StatelessWidget {
  final String value, label; final IconData icon; final Color color; final VoidCallback? onTap;
  const _StatCard({required this.value, required this.label, required this.icon, required this.color, this.onTap});
  @override
  Widget build(BuildContext context) {
    final _isDark = context.isDark;
    return Expanded(child: GlassCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withValues(alpha: context.isDark ? 0.2 : 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: color)),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: context.textMuted)),
      ]),
    ));
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon; final String label; final Color color, bgColor; final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.bgColor, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Column(children: [
    Container(width: 56, height: 56, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, color: color, size: 26)),
    const SizedBox(height: 8),
    Text(label, textAlign: TextAlign.center, maxLines: 2,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.textSecondary)),
  ]));
}

class _NextAppointmentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1B54F8), Color(0xFF4D7FFF)]),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
    ),
    child: Column(children: [
      Row(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Text('AT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Dr. Amine Toure', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          Text('Cardiologie', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
            child: const Text('Confirmé', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
      ]),
      const SizedBox(height: 16),
      Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
      const SizedBox(height: 14),
      Row(children: [
        _AI(icon: Icons.calendar_today_rounded, text: 'Demain'),
        const SizedBox(width: 18),
        _AI(icon: Icons.access_time_rounded, text: '14h30'),
        const SizedBox(width: 18),
        _AI(icon: Icons.location_on_outlined, text: 'Hôpital Central'),
        const Spacer(),
        Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16)),
      ]),
    ]),
  );
}

class _AI extends StatelessWidget {
  final IconData icon; final String text;
  const _AI({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, color: Colors.white70, size: 13),
    const SizedBox(width: 4),
    Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
  ]);
}

class _SpecialtyChip extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _SpecialtyChip({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 12),
    child: GestureDetector(onTap: () {}, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 60, height: 60,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1)),
          child: Icon(icon, color: color, size: 28)),
      const SizedBox(height: 8),
      SizedBox(width: 64, child: Text(label, textAlign: TextAlign.center, maxLines: 2,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.textSecondary))),
    ])),
  );
}

class _DoctorCard extends StatelessWidget {
  final String name, specialty, price, initials, experience;
  final double rating; final int reviews; final bool available; final Color color;
  const _DoctorCard({required this.name, required this.specialty, required this.rating, required this.reviews,
      required this.price, required this.available, required this.initials, required this.color, required this.experience});
  @override
  Widget build(BuildContext context) {
    final _isDark = context.isDark;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingFlowScreen(
          doctorName: name, specialty: specialty, initials: initials, color: color, price: price, date: 'Prochaine dispo', time: '—'))),
      child: Row(children: [
        Container(width: 56, height: 56, decoration: BoxDecoration(color: color.withValues(alpha: context.isDark ? 0.2 : 0.12), borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5)),
            child: Center(child: Text(initials, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: available ? AppColors.successBg : AppColors.dangerLight, borderRadius: BorderRadius.circular(6)),
                child: Text(available ? 'Disponible' : 'Complet',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: available ? AppColors.successText : AppColors.dangerText))),
          ]),
          const SizedBox(height: 4),
          Text('$specialty · $experience d\'exp.', style: TextStyle(fontSize: 11, color: context.textMuted)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.star_rounded, color: AppColors.warning, size: 13),
            const SizedBox(width: 3),
            Text('$rating', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.textPrimary)),
            Text(' ($reviews avis)', style: TextStyle(fontSize: 11, color: context.textMuted)),
            const Spacer(),
            Text(price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ]),
        ])),
      ]),
    );
  }
}
