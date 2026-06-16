// import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../core/di/app_services.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/appointment/appointment_model.dart';

// ─── Screen ──────────────────────────────────────────────────────────────────

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _stats = {};
  List<AppointmentModel> _upcoming = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final user = AppServices.authSessionManager.user;
      if (user == null) throw ApiException(message: 'Session expirée');

      // Charger stats + RDV à venir en parallèle
      final results = await Future.wait([
        AppServices.doctorRepository.getMyStats(),
        AppServices.doctorRepository.getMyAppointments(status: 'confirmed', pageSize: 5),
      ]);

      if (!mounted) return;
      setState(() {
        _stats   = results[0] as Map<String, dynamic>;
        final apptResp = results[1] as dynamic;
        _upcoming = apptResp.appointments as List<AppointmentModel>;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() { _errorMessage = e.displayMessage; _isLoading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _errorMessage = 'Erreur de connexion'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) return _LoadingView();
    if (_errorMessage != null) {
      return _ErrorView(message: _errorMessage!, onRetry: _loadDashboardData);
    }

    final user = AppServices.authSessionManager.user;
    final greeting = _buildGreeting();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ─── Header ───────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _DashboardHeader(
                    greeting: greeting,
                    doctorName: 'Dr. ${user?.lastName ?? 'Médecin'}',
                    avatarInitial: user?.firstName[0] ?? 'D',
                  ),
                ),
              ),

              // ─── Stats grid ───────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: _StatsGrid(stats: _stats, upcoming: _upcoming),
                ),
              ),

              // ─── Quick actions ────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: _QuickActions(),
                ),
              ),

              // ─── Upcoming appointments ────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: 'Rendez-vous à venir',
                    subtitle: '${_upcoming.length} planifié(s)',
                    onSeeAll: () {},
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AppointmentCard(appointment: _upcoming[i]),
                    ),
                    childCount: _upcoming.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final String greeting;
  final String doctorName;
  final String avatarInitial;

  const _DashboardHeader({
    required this.greeting,
    required this.doctorName,
    required this.avatarInitial,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontSize: 14,
                  color: context.mutedText,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                doctorName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: context.textColor,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        // Notification bell
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.dividerColor, width: 1),
          ),
          child: Stack(
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 20,
                color: context.mutedText,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              avatarInitial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Stats grid ──────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  final List<AppointmentModel> upcoming;

  const _StatsGrid({required this.stats, required this.upcoming});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayCount = upcoming.where((a) =>
        a.appointmentDate.year == today.year &&
        a.appointmentDate.month == today.month &&
        a.appointmentDate.day == today.day).length;

    final items = [
      _StatData(
        label: 'RDV du jour',
        value: '$todayCount',
        icon: Icons.calendar_today_rounded,
        color: AppColors.primary,
        trend: 'aujourd\'hui',
        trendPositive: true,
      ),
      _StatData(
        label: 'Patients',
        value: '${stats['total_patients'] ?? upcoming.length}',
        icon: Icons.people_outline_rounded,
        color: AppColors.accent,
        trend: 'total',
        trendPositive: true,
      ),
      _StatData(
        label: 'RDV ce mois',
        value: '${stats['appointments_this_month'] ?? upcoming.length}',
        icon: Icons.trending_up_rounded,
        color: AppColors.warning,
        trend: 'ce mois',
        trendPositive: true,
      ),
      _StatData(
        label: 'Note moy.',
        value: '${stats['average_rating'] ?? '—'}',
        icon: Icons.star_rounded,
        color: AppColors.cardio,
        trend: '${stats['total_reviews'] ?? 0} avis',
        trendPositive: true,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _StatCard(data: items[i]),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool trendPositive;

  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.trendPositive,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.black.withValues(alpha: 0.25)
                : data.color.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: data.color, size: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: data.trendPositive
                      ? AppColors.successLight
                      : AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  data.trend,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: data.trendPositive
                        ? AppColors.successText
                        : AppColors.dangerText,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.textColor,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.label,
                style: TextStyle(
                  fontSize: 11,
                  color: context.mutedText,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Quick actions ────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        label: 'Nouveau RDV',
        icon: Icons.add_circle_outline_rounded,
        color: AppColors.primary,
        onTap: () {},
      ),
      _QuickAction(
        label: 'Mes patients',
        icon: Icons.people_outline_rounded,
        color: AppColors.accent,
        onTap: () {},
      ),
      _QuickAction(
        label: 'Ordonnance',
        icon: Icons.description_outlined,
        color: AppColors.warning,
        onTap: () {},
      ),
      _QuickAction(
        label: 'Messages',
        icon: Icons.chat_bubble_outline_rounded,
        color: AppColors.neuro,
        onTap: () {},
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: context.textColor,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: actions
              .map(
                (a) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _QuickActionButton(action: a),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: action.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: action.color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, color: action.color, size: 22),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: action.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.textColor,
                letterSpacing: -0.2,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: context.mutedText,
                ),
              ),
          ],
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'Voir tout',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Appointment card ─────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (appointment.status) {
      'confirmed' => AppColors.success,
      'pending'   => AppColors.warning,
      'completed' => AppColors.primary,
      _           => context.mutedText,
    };
    final statusLabel = switch (appointment.status) {
      'confirmed' => 'Confirmé',
      'pending'   => 'En attente',
      'completed' => 'Complété',
      _           => appointment.status,
    };
    final name    = appointment.patient?.fullName ?? 'Patient';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final time    = '${appointment.appointmentDate.hour.toString().padLeft(2,'0')}h${appointment.appointmentDate.minute.toString().padLeft(2,'0')}';

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.7), AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.textColor, letterSpacing: -0.1)),
          const SizedBox(height: 2),
          Text(appointment.reason ?? appointment.appointmentType, style: TextStyle(fontSize: 12, color: context.mutedText)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(time, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: -0.2)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(statusLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: statusColor)),
          ),
        ]),
      ]),
    );
  }
}

// ─── States ───────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 36,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Réessayer'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
