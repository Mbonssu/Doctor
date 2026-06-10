import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../core/routes/navigation_helper.dart';
import '../../../core/di/app_services.dart';
import '../../../data/models/appointment/appointment_model.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});
  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final _statuses = ['pending', 'confirmed', 'completed', 'cancelled'];
  final _labels   = ['En attente', 'Confirmé', 'Passé', 'Annulé'];

  final Map<String, List<AppointmentModel>> _appointments = {
    'pending': [], 'confirmed': [], 'completed': [], 'cancelled': [],
  };
  final Map<String, bool>    _loading = {'pending': true, 'confirmed': true, 'completed': false, 'cancelled': false};
  final Map<String, String?> _errors  = {};
  final Map<String, int>     _pages   = {'pending': 1, 'confirmed': 1, 'completed': 1, 'cancelled': 1};
  final Map<String, bool>    _hasMore = {'pending': true, 'confirmed': true, 'completed': true, 'cancelled': true};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _loadAppointments('pending');
    _loadAppointments('confirmed');
    _tabCtrl.addListener(() {
      if (_tabCtrl.indexIsChanging) return;
      final s = _statuses[_tabCtrl.index];
      if (_appointments[s]!.isEmpty && !(_loading[s] ?? false)) {
        _loadAppointments(s);
      }
    });
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  Future<void> _loadAppointments(String status, {bool refresh = false}) async {
    if (refresh) { _pages[status] = 1; _hasMore[status] = true; }
    if (!(_hasMore[status] ?? true)) return;
    setState(() { _loading[status] = true; _errors[status] = null; });
    try {
      final resp = await AppServices.appointmentsRepository.getMyAppointments(
        status: status, page: _pages[status]!, pageSize: 20);
      setState(() {
        if (refresh || _pages[status] == 1) {
          _appointments[status] = resp.appointments;
        } else {
          _appointments[status]!.addAll(resp.appointments);
        }
        _hasMore[status] = resp.appointments.length == 20;
        _pages[status] = (_pages[status] ?? 1) + 1;
      });
    } catch (e) {
      setState(() => _errors[status] = e.toString());
    } finally {
      if (mounted) setState(() => _loading[status] = false);
    }
  }

  Future<void> _cancel(AppointmentModel apt) async {
    String reason = '';
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Annuler le rendez-vous'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Êtes-vous sûr de vouloir annuler ce rendez-vous ?'),
        const SizedBox(height: 12),
        TextFormField(
          onChanged: (v) => reason = v,
          decoration: InputDecoration(hintText: 'Motif (optionnel)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Retour')),
        ElevatedButton(onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          child: const Text('Annuler le RDV')),
      ],
    ));
    if (ok != true) return;
    try {
      await AppServices.appointmentsRepository.cancelAppointment(
        appointmentId: apt.id, cancellationReason: reason.isEmpty ? 'Annulé par le patient' : reason);
      setState(() {
        _appointments[apt.status]?.removeWhere((a) => a.id == apt.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [Icon(Icons.check_circle_rounded, color: Colors.white, size: 18), SizedBox(width: 8), Text('RDV annulé')]),
          backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : $e'), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Row(children: [
            Expanded(child: Text('Mes rendez-vous', style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: context.textPrimary, letterSpacing: -0.5))),
            GestureDetector(
              onTap: () => NavigationHelper.goToBookingFlow(context),
              child: Container(padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: context.surfaceColor, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderColor, width: 1)),
                  child: const Icon(Icons.add_rounded, size: 20, color: AppColors.primary)),
            ),
          ]),
        ),
        // Tabs
        Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: context.surfaceColor, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderColor, width: 1)),
          child: TabBar(
            controller: _tabCtrl,
            indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: context.textMuted,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            tabs: List.generate(4, (i) {
              final count = _appointments[_statuses[i]]?.length ?? 0;
              return Tab(child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(_labels[i]),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text('$count', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800))),
                ],
              ]));
            }),
          ),
        ),
        Expanded(child: TabBarView(
          controller: _tabCtrl,
          children: List.generate(4, (i) {
            final status = _statuses[i];
            final isLoading = _loading[status] ?? false;
            final error = _errors[status];
            final items = _appointments[status] ?? [];
            if (isLoading && items.isEmpty) return const Center(child: CircularProgressIndicator());
            if (error != null && items.isEmpty) return _ErrorState(onRetry: () => _loadAppointments(status, refresh: true));
            if (items.isEmpty) return _EmptyState(label: _labels[i], onBook: () => NavigationHelper.goToBookingFlow(context));
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => _loadAppointments(status, refresh: true),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, idx) => _AppointmentCard(
                  apt: items[idx],
                  onCancel: status != 'cancelled' && status != 'completed'
                      ? () => _cancel(items[idx]) : null,
                ),
              ),
            );
          }),
        )),
      ])),
    );
  }
}

// ── APPOINTMENT CARD ──────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel apt;
  final VoidCallback? onCancel;
  const _AppointmentCard({required this.apt, this.onCancel});

  String get _doctorName {
    final d = apt.doctor;
    if (d?.user == null) return 'Médecin';
    return 'Dr. ${d!.user!.firstName} ${d.user!.lastName}';
  }

  String get _initials {
    final d = apt.doctor?.user;
    if (d == null) return 'MD';
    return '${d.firstName.isNotEmpty ? d.firstName[0] : ''}${d.lastName.isNotEmpty ? d.lastName[0] : ''}'.toUpperCase();
  }

  static const _colors = [Color(0xFF845EF7), Color(0xFF00C48C), Color(0xFFFF6B6B),
    Color(0xFFFF9A3C), AppColors.primary];
  Color get _color => _colors[(apt.doctorId) % _colors.length];

  String get _statusLabel => switch (apt.status) {
    'pending'   => 'En attente',
    'confirmed' => 'Confirmé',
    'completed' => 'Passé',
    'cancelled' => 'Annulé',
    _           => apt.status,
  };

  Color get _statusColor => switch (apt.status) {
    'pending'   => AppColors.warning,
    'confirmed' => AppColors.primary,
    'completed' => AppColors.success,
    'cancelled' => AppColors.danger,
    _           => AppColors.textMuted,
  };

  String get _formattedDate {
    final d = apt.appointmentDate;
    final now = DateTime.now();
    if (d.day == now.day && d.month == now.month && d.year == now.year) return "Aujourd'hui";
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  }

  String get _formattedTime =>
    '${apt.appointmentDate.hour.toString().padLeft(2,'0')}h${apt.appointmentDate.minute.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor;
    return GestureDetector(
      onTap: () => NavigationHelper.goToAppointmentDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.dividerColor),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.all(14), child: Row(children: [
            CircleAvatar(radius: 26, backgroundColor: _color.withValues(alpha: 0.15),
              child: Text(_initials, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _color))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_doctorName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textColor)),
              const SizedBox(height: 2),
              Text(apt.doctor?.specialty ?? apt.appointmentType,
                  style: TextStyle(fontSize: 13, color: context.mutedText)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: sc.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(_statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sc))),
              const SizedBox(height: 6),
              Text(_formattedDate, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textColor)),
              Text(_formattedTime, style: TextStyle(fontSize: 11, color: context.mutedText)),
            ]),
          ])),
          // Info bar
          Container(margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: context.bgColor, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Icon(Icons.attach_money_rounded, size: 14, color: context.mutedText),
              const SizedBox(width: 4),
              Text('${apt.consultationFee.toInt()} FCFA',
                  style: TextStyle(fontSize: 12, color: context.mutedText, fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: context.dividerColor)),
              const SizedBox(width: 12),
              Icon(Icons.timer_outlined, size: 14, color: context.mutedText),
              const SizedBox(width: 4),
              Text('${apt.durationMinutes} min', style: TextStyle(fontSize: 12, color: context.mutedText)),
              const Spacer(),
              if (apt.reason != null)
                Row(children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(apt.reason!, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                ]),
            ]),
          ),
          if (onCancel != null)
            Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    minimumSize: const Size(double.infinity, 38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Annuler le rendez-vous'),
              ),
            ),
        ]),
      ),
    );
  }
}

// ── STATES ────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String label; final VoidCallback onBook;
  const _EmptyState({required this.label, required this.onBook});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.event_busy_rounded, size: 56, color: context.mutedText),
    const SizedBox(height: 12),
    Text('Aucun RDV « $label »', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.mutedText)),
    if (label == 'En attente' || label == 'Confirmé') ...[
      const SizedBox(height: 16),
      ElevatedButton.icon(onPressed: onBook,
        icon: const Icon(Icons.add_rounded, size: 16), label: const Text('Prendre un RDV'),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
    ],
  ]));
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.wifi_off_rounded, size: 56, color: context.mutedText),
    const SizedBox(height: 12),
    Text('Impossible de charger les RDV', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.textColor)),
    const SizedBox(height: 20),
    ElevatedButton.icon(onPressed: onRetry,
      icon: const Icon(Icons.refresh_rounded), label: const Text('Réessayer'),
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
  ]));
}
