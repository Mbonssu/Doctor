import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../core/routes/navigation_helper.dart';
import '../../../core/utils/modal_utils.dart';
import '../../../core/di/app_services.dart';
import '../../../data/models/appointment/appointment_model.dart';
import '../../../data/models/doctor/doctor_model.dart';
import '../../../data/models/doctor/doctor_list_response.dart';
import '../health/health_screens.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppointmentModel? _nextAppointment;
  List<DoctorModel> _topDoctors = [];
  int _upcomingCount = 0;
  int _unreadNotifs = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final upcoming = await AppServices.appointmentsRepository
          .getUpcomingAppointments(limit: 5);
      final doctorsResp = await AppServices.doctorsRepository
          .searchDoctors(page: 1, pageSize: 3);
      if (mounted) {
        setState(() {
          _nextAppointment = upcoming.isNotEmpty ? upcoming.first : null;
          _upcomingCount = upcoming.length;
          _topDoctors = doctorsResp.doctors;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour 🌅';
    if (h < 18) return 'Bon après-midi ☀️';
    return 'Bonsoir 🌙';
  }

  String get _userInitials {
    final u = AppServices.authSessionManager.user;
    if (u == null) return '?';
    return '${u.firstName.isNotEmpty ? u.firstName[0] : ''}${u.lastName.isNotEmpty ? u.lastName[0] : ''}'.toUpperCase();
  }

  String get _userName {
    final u = AppServices.authSessionManager.user;
    if (u == null) return 'Utilisateur';
    return '${u.firstName} ${u.lastName}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDark ? Colors.transparent : context.bgColor,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadData,
        child: CustomScrollView(slivers: [

          // ── HEADER ──
          SliverToBoxAdapter(child: Container(
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
                    Text(_userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: -0.5)),
                  ])),
                  GestureDetector(
                    onTap: () => NavigationHelper.goToNotifications(context),
                    child: Stack(children: [
                      Container(width: 44, height: 44, margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22)),
                      if (_unreadNotifs > 0)
                        Positioned(top: 6, right: 16, child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                          child: Center(child: Text('$_unreadNotifs',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))))),
                    ]),
                  ),
                  Container(width: 44, height: 44,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2)),
                      child: Center(child: Text(_userInitials,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)))),
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
                      Text('Médecin, spécialité, symptôme…',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                      const Spacer(),
                      Container(padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 14)),
                    ]),
                  ),
                ),
              ]),
            )),
          )),

          // ── STATS ──
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(children: [
              GlassStatCard(value: '$_upcomingCount', label: 'RDV à venir',
                  icon: Icons.calendar_month_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              GlassStatCard(value: '—', label: 'Consultations',
                  icon: Icons.medical_services_rounded, color: AppColors.accent,
                  onTap: () => NavigationHelper.goToHealth(context)),
              const SizedBox(width: 12),
              GlassStatCard(value: '${_topDoctors.length}', label: 'Médecins',
                  icon: Icons.people_alt_rounded, color: const Color(0xFF845EF7)),
            ]),
          )),

          // ── ACTIONS RAPIDES ──
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

          // ── PROCHAIN RDV ──
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _SectionTitle(title: 'Prochain rendez-vous',
                  onSeeAll: () => NavigationHelper.goToAppointments(context)),
              const SizedBox(height: 14),
              _isLoading
                  ? _NextApptSkeleton()
                  : _nextAppointment != null
                      ? _NextAppointmentCard(apt: _nextAppointment!)
                      : _NoAppointmentCard(onBook: () => NavigationHelper.goToBookingFlow(context)),
            ]),
          )),

          // ── SPÉCIALITÉS ──
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

          // ── MÉDECINS RECOMMANDÉS ──
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: _SectionTitle(title: 'Médecins recommandés',
                onSeeAll: () => NavigationHelper.goToSearch(context)),
          )),
          if (_isLoading)
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: Column(children: List.generate(3, (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DoctorSkeleton(),
              ))),
            ))
          else if (_topDoctors.isEmpty)
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: Center(child: Text('Aucun médecin disponible pour l\'instant',
                  style: TextStyle(color: context.mutedText))),
            ))
          else
            SliverList(delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: EdgeInsets.fromLTRB(24, i == 0 ? 14 : 12, 24, 0),
                child: _DoctorCard(doctor: _topDoctors[i]),
              ),
              childCount: _topDoctors.length,
            )),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ]),
      ),
    );
  }

  void _showEmergencySheet(BuildContext context) {
    ModalUtils.showBlurredBottomSheet(context: context, builder: (_) => _EmergencySheet());
  }
}

// ── NEXT APPOINTMENT CARD (réel) ────────────────────────────────────────────

class _NextAppointmentCard extends StatelessWidget {
  final AppointmentModel apt;
  const _NextAppointmentCard({required this.apt});

  String get _doctorName {
    final d = apt.doctor;
    if (d?.user == null) return 'Médecin';
    return 'Dr. ${d!.user!.firstName} ${d.user!.lastName}';
  }

  String get _doctorInitials {
    final d = apt.doctor?.user;
    if (d == null) return 'MD';
    return '${d.firstName.isNotEmpty ? d.firstName[0] : ''}${d.lastName.isNotEmpty ? d.lastName[0] : ''}'.toUpperCase();
  }

  String get _statusLabel => switch (apt.status) {
    'confirmed' => 'Confirmé',
    'pending'   => 'En attente',
    _           => apt.status,
  };

  Color get _statusColor => apt.status == 'confirmed' ? AppColors.accent : AppColors.warning;

  String get _formattedDate {
    final d = apt.appointmentDate;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    if (d.day == now.day && d.month == now.month) return "Aujourd'hui";
    if (d.day == tomorrow.day && d.month == tomorrow.month) return 'Demain';
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}';
  }

  String get _formattedTime =>
    '${apt.appointmentDate.hour.toString().padLeft(2,'0')}h${apt.appointmentDate.minute.toString().padLeft(2,'0')}';

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
        Container(width: 52, height: 52,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(_doctorInitials,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_doctorName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          Text(apt.doctor?.specialty ?? 'Spécialité',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: _statusColor, borderRadius: BorderRadius.circular(8)),
            child: Text(_statusLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
      ]),
      const SizedBox(height: 16),
      Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
      const SizedBox(height: 14),
      Row(children: [
        _AI(icon: Icons.calendar_today_rounded, text: _formattedDate),
        const SizedBox(width: 18),
        _AI(icon: Icons.access_time_rounded, text: _formattedTime),
        if (apt.doctor?.hospitalName != null) ...[
          const SizedBox(width: 18),
          Flexible(child: _AI(icon: Icons.location_on_outlined, text: apt.doctor!.hospitalName!)),
        ],
        const Spacer(),
        Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16)),
      ]),
    ]),
  );
}

class _NoAppointmentCard extends StatelessWidget {
  final VoidCallback onBook;
  const _NoAppointmentCard({required this.onBook});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: context.cardColor, borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.dividerColor),
    ),
    child: Column(children: [
      Icon(Icons.calendar_today_outlined, size: 40, color: context.mutedText),
      const SizedBox(height: 10),
      Text('Aucun rendez-vous prévu', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: context.textColor)),
      const SizedBox(height: 4),
      Text('Prenez votre premier rendez-vous dès maintenant',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: context.mutedText)),
      const SizedBox(height: 14),
      ElevatedButton.icon(onPressed: onBook,
        icon: const Icon(Icons.add_rounded, size: 16),
        label: const Text('Prendre un RDV'),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
    ]),
  );
}

// ── DOCTOR CARD (réelle) ──────────────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  const _DoctorCard({required this.doctor});

  String get name => doctor.user != null
      ? 'Dr. ${doctor.user!.firstName} ${doctor.user!.lastName}' : 'Médecin';
  String get initials => doctor.user != null
      ? '${doctor.user!.firstName.isNotEmpty ? doctor.user!.firstName[0] : ''}${doctor.user!.lastName.isNotEmpty ? doctor.user!.lastName[0] : ''}'.toUpperCase()
      : 'MD';

  static const _colors = [AppColors.cardio, AppColors.neuro, AppColors.pediatrie,
    AppColors.primary, Color(0xFF845EF7), AppColors.accent];
  Color get color => _colors[doctor.id % _colors.length];

  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.all(16),
    onTap: () => NavigationHelper.goToDoctorDetail(context, arguments: {
      'id': doctor.id, 'name': name, 'specialty': doctor.specialty,
      'rating': doctor.rating, 'reviews': doctor.totalReviews,
      'price': '${doctor.consultationFee.toInt()} FCFA',
      'available': doctor.isAvailable, 'initials': initials, 'color': color,
      'experience': '${doctor.yearsOfExperience} ans',
    }),
    child: Row(children: [
      Container(width: 56, height: 56,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5)),
          child: Center(child: Text(initials,
              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textColor))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: doctor.isAvailable ? AppColors.successBg : AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(6)),
              child: Text(doctor.isAvailable ? 'Disponible' : 'Complet',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: doctor.isAvailable ? AppColors.successText : AppColors.dangerText))),
        ]),
        const SizedBox(height: 4),
        Text('${doctor.specialty} · ${doctor.yearsOfExperience} ans d\'exp.',
            style: TextStyle(fontSize: 11, color: context.mutedText)),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.star_rounded, color: AppColors.warning, size: 13),
          const SizedBox(width: 3),
          Text('${doctor.rating}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.textColor)),
          Text(' (${doctor.totalReviews} avis)', style: TextStyle(fontSize: 11, color: context.mutedText)),
          const Spacer(),
          Text('${doctor.consultationFee.toInt()} FCFA',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ]),
      ])),
    ]),
  );
}

// ── SKELETONS ─────────────────────────────────────────────────────────────────

class _NextApptSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 130, decoration: BoxDecoration(
      color: context.cardColor, borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.dividerColor)),
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
  );
}

class _DoctorSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 80, decoration: BoxDecoration(
      color: context.cardColor, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.dividerColor)),
  );
}

// ── AUTRES WIDGETS INCHANGÉS ──────────────────────────────────────────────────

class _EmergencySheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: context.surfaceColor,
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
      _EItem(icon: Icons.phone_rounded, color: AppColors.danger, title: 'SAMU / Urgences', subtitle: 'Composer le 15 ou le 112', onTap: () {}),
      const SizedBox(height: 10),
      _EItem(icon: Icons.location_on_rounded, color: AppColors.primary, title: 'Hôpital le plus proche',
          subtitle: 'Voir les urgences autour de moi', onTap: () { Navigator.pop(context); NavigationHelper.goToMapView(context); }),
      const SizedBox(height: 10),
      _EItem(icon: Icons.qr_code_rounded, color: const Color(0xFF845EF7), title: 'Ma carte patient',
          subtitle: 'Groupe sanguin · Allergies', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const QRCardScreen())); }),
      const SizedBox(height: 16),
    ]),
  );
}

class _EItem extends StatelessWidget {
  final IconData icon; final Color color; final String title, subtitle; final VoidCallback onTap;
  const _EItem({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.all(14), onTap: onTap,
    child: Row(children: [
      Container(width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
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

class _SpecialtyChip extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _SpecialtyChip({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 12),
    child: GestureDetector(
      onTap: () => NavigationHelper.goToSearch(context),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 60, height: 60,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withValues(alpha: 0.2), width: 1)),
            child: Icon(icon, color: color, size: 28)),
        const SizedBox(height: 8),
        SizedBox(width: 64, child: Text(label, textAlign: TextAlign.center, maxLines: 2,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.textSecondary))),
      ]),
    ),
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
