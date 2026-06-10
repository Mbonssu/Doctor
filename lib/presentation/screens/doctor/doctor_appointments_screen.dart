import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../core/di/app_services.dart';
import '../../../data/models/appointment/appointment_model.dart';
import '../chat/chat_screen.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});
  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _search = '';

  // État par statut
  final Map<String, List<AppointmentModel>> _appointments = {
    'pending': [], 'confirmed': [], 'completed': [], 'cancelled': [],
  };
  final Map<String, bool> _loading = {
    'pending': true, 'confirmed': true, 'completed': true, 'cancelled': true,
  };
  final Map<String, String?> _errors = {};
  final Map<String, int> _pages = {
    'pending': 1, 'confirmed': 1, 'completed': 1, 'cancelled': 1,
  };
  final Map<String, bool> _hasMore = {
    'pending': true, 'confirmed': true, 'completed': true, 'cancelled': true,
  };

  final _statuses = ['pending', 'confirmed', 'completed', 'cancelled'];
  final _labels   = ['En attente', 'Confirmé', 'Complété', 'Annulé'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    for (final s in _statuses) { _loadAppointments(s); }
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) return;
      final status = _statuses[_tabCtrl.index];
      if (_appointments[status]!.isEmpty) _loadAppointments(status);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── API ────────────────────────────────────────────────────────────────────

  Future<void> _loadAppointments(String status, {bool refresh = false}) async {
    if (refresh) {
      setState(() { _pages[status] = 1; _hasMore[status] = true; });
    }
    if (!(_hasMore[status] ?? true)) return;
    setState(() { _loading[status] = true; _errors[status] = null; });
    try {
      final resp = await AppServices.doctorRepository.getMyAppointments(
        status: status, page: _pages[status]!, pageSize: 20);
      final items = resp.appointments;
      setState(() {
        if (refresh || _pages[status] == 1) {
          _appointments[status] = items;
        } else {
          _appointments[status]!.addAll(items);
        }
        _hasMore[status] = items.length == 20;
        _pages[status] = (_pages[status] ?? 1) + 1;
      });
    } catch (e) {
      setState(() => _errors[status] = e.toString());
    } finally {
      if (mounted) setState(() => _loading[status] = false);
    }
  }

  Future<void> _confirm(int id, String status) async {
    HapticFeedback.mediumImpact();
    try {
      final updated = await AppServices.doctorRepository.confirmAppointment(id);
      _moveAppointment(id, status, 'confirmed', updated);
      _snack('RDV confirmé', AppColors.success, Icons.check_circle_rounded);
    } catch (e) {
      _snack('Erreur : $e', AppColors.danger, Icons.error_outline_rounded);
    }
  }

  Future<void> _complete(int id, String status) async {
    HapticFeedback.mediumImpact();
    try {
      final updated = await AppServices.doctorRepository.completeAppointment(id);
      _moveAppointment(id, status, 'completed', updated);
      _snack('Consultation terminée', AppColors.success, Icons.check_circle_rounded);
    } catch (e) {
      _snack('Erreur : $e', AppColors.danger, Icons.error_outline_rounded);
    }
  }

  Future<void> _refuse(int id, String status) async {
    String reason = '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Refuser le rendez-vous'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Le patient sera notifié. Motif du refus :'),
          const SizedBox(height: 12),
          TextFormField(
            onChanged: (v) => reason = v,
            decoration: InputDecoration(
              hintText: 'Motif (optionnel)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final updated = await AppServices.doctorRepository.refuseAppointment(
        appointmentId: id, reason: reason.isEmpty ? 'Refusé par le médecin' : reason);
      _moveAppointment(id, status, 'cancelled', updated);
      _snack('RDV refusé', AppColors.warning, Icons.cancel_rounded);
    } catch (e) {
      _snack('Erreur : $e', AppColors.danger, Icons.error_outline_rounded);
    }
  }

  Future<void> _saveNotes(int id, String currentNotes) async {
    final ctrl = TextEditingController(text: currentNotes);
    final saved = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: context.dividerColor, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Notes médicales', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: context.textColor)),
            const SizedBox(height: 4),
            Text('Ces notes sont privées et visibles seulement par vous.',
              style: TextStyle(fontSize: 12, color: context.mutedText)),
            const SizedBox(height: 14),
            TextFormField(
              controller: ctrl,
              maxLines: 6,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Diagnostics, prescriptions, observations...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Enregistrer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ),
    );
    if (saved == null) return;
    try {
      final updated = await AppServices.doctorRepository.addDoctorNotes(
        appointmentId: id, notes: saved);
      setState(() {
        for (final list in _appointments.values) {
          final idx = list.indexWhere((a) => a.id == id);
          if (idx >= 0) { list[idx] = updated; break; }
        }
      });
      _snack('Notes enregistrées', AppColors.success, Icons.check_rounded);
    } catch (e) {
      _snack('Erreur : $e', AppColors.danger, Icons.error_outline_rounded);
    }
  }

  void _moveAppointment(int id, String fromStatus, String toStatus, AppointmentModel updated) {
    setState(() {
      _appointments[fromStatus]?.removeWhere((a) => a.id == id);
      _appointments[toStatus]?.insert(0, updated);
    });
  }

  void _snack(String msg, Color color, IconData icon) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 8), Text(msg)]),
      backgroundColor: color, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  List<AppointmentModel> _filtered(String status) {
    if (_search.isEmpty) return _appointments[status] ?? [];
    final q = _search.toLowerCase();
    return (_appointments[status] ?? []).where((a) {
      final patient = a.patient;
      if (patient == null) return false;
      return '${patient.firstName} ${patient.lastName}'.toLowerCase().contains(q) ||
          (a.reason ?? '').toLowerCase().contains(q);
    }).toList();
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pendingCount = _appointments['pending']?.length ?? 0;
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor, elevation: 0, centerTitle: true,
        title: Text('Rendez-vous',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: context.textColor)),
        actions: [
          if (pendingCount > 0)
            Container(margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(20)),
              child: Text('$pendingCount', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800))),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Rechercher un patient...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); })
                      : null,
                  filled: true, fillColor: context.cardColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.dividerColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.dividerColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                ),
              ),
            ),
            TabBar(
              controller: _tabCtrl, isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primary, unselectedLabelColor: context.mutedText,
              indicatorColor: AppColors.primary,
              tabs: List.generate(4, (i) {
                final count = _appointments[_statuses[i]]?.length ?? 0;
                return Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_labels[i]),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: i == 0 ? AppColors.warning : AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10)),
                      child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: i == 0 ? Colors.white : AppColors.primary))),
                  ],
                ]));
              }),
            ),
          ]),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: List.generate(4, (i) {
          final status = _statuses[i];
          final isLoading = _loading[status] ?? false;
          final error = _errors[status];
          final items = _filtered(status);

          if (isLoading && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null && items.isEmpty) {
            return _ErrorState(message: error, onRetry: () => _loadAppointments(status, refresh: true));
          }
          if (items.isEmpty) return _EmptyState(label: _labels[i]);

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => _loadAppointments(status, refresh: true),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, idx) => _AppointmentCard(
                apt: items[idx],
                onConfirm: () => _confirm(items[idx].id, status),
                onRefuse: () => _refuse(items[idx].id, status),
                onComplete: () => _complete(items[idx].id, status),
                onNotes: () => _saveNotes(items[idx].id, items[idx].doctorNotes ?? ''),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── APPOINTMENT CARD ─────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel apt;
  final VoidCallback onConfirm, onRefuse, onComplete, onNotes;
  const _AppointmentCard({required this.apt, required this.onConfirm,
    required this.onRefuse, required this.onComplete, required this.onNotes});

  Color get _statusColor => switch (apt.status) {
    'pending'   => AppColors.warning,
    'confirmed' => AppColors.primary,
    'completed' => AppColors.success,
    'cancelled' => AppColors.danger,
    _           => AppColors.textMuted,
  };

  String get _statusLabel => switch (apt.status) {
    'pending'   => 'En attente',
    'confirmed' => 'Confirmé',
    'completed' => 'Complété',
    'cancelled' => 'Annulé',
    _           => apt.status,
  };

  String get _patientInitials {
    final p = apt.patient;
    if (p == null) return '?';
    return '${p.firstName.isNotEmpty ? p.firstName[0] : ''}${p.lastName.isNotEmpty ? p.lastName[0] : ''}'.toUpperCase();
  }

  String get _patientName {
    final p = apt.patient;
    if (p == null) return 'Patient inconnu';
    return '${p.firstName} ${p.lastName}';
  }

  String get _formattedDate {
    final d = apt.appointmentDate;
    final now = DateTime.now();
    if (d.day == now.day && d.month == now.month && d.year == now.year) {
      return 'Aujourd\'hui ${_twoDigits(d.hour)}:${_twoDigits(d.minute)}';
    }
    return '${_twoDigits(d.day)}/${_twoDigits(d.month)} ${_twoDigits(d.hour)}:${_twoDigits(d.minute)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  static const _colors = [
    Color(0xFF845EF7), Color(0xFF00C48C), Color(0xFFFF6B6B),
    Color(0xFFFF9A3C), Color(0xFF1B54F8), Color(0xFFE64980),
  ];
  Color get _avatarColor => _colors[(_patientName.codeUnitAt(0)) % _colors.length];

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor;
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          CircleAvatar(radius: 26, backgroundColor: _avatarColor.withValues(alpha: 0.15),
            child: Text(_patientInitials, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _avatarColor))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_patientName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textColor)),
            const SizedBox(height: 2),
            Text(apt.reason ?? 'Consultation', style: TextStyle(fontSize: 13, color: context.mutedText)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: sc.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(_statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sc))),
            const SizedBox(height: 6),
            Text(_formattedDate, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textColor)),
            Text('${apt.durationMinutes} min', style: TextStyle(fontSize: 11, color: context.mutedText)),
          ]),
        ])),

        // Info bar
        if (apt.patient?.phone != null || (apt.doctorNotes?.isNotEmpty ?? false))
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: context.bgColor, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              if (apt.patient?.phone != null) ...[
                Icon(Icons.phone_outlined, size: 14, color: context.mutedText),
                const SizedBox(width: 6),
                Text(apt.patient!.phone ?? '', style: TextStyle(fontSize: 12, color: context.mutedText)),
              ],
              const Spacer(),
              if (apt.doctorNotes?.isNotEmpty ?? false)
                Row(children: const [
                  Icon(Icons.note_outlined, size: 14, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text('Notes', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ]),
            ]),
          ),

        // Actions
        Padding(padding: const EdgeInsets.all(12), child: _buildActions(context)),
      ]),
    );
  }

  Widget _buildActions(BuildContext context) {
    switch (apt.status) {
      case 'pending':
        return Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: onRefuse,
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Refuser'),
          )),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Confirmer'),
          )),
        ]);
      case 'confirmed':
        return Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ChatScreen(doctorName: _patientName))),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            label: const Text('Chat'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          )),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Terminer'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          )),
        ]);
      case 'completed':
        return ElevatedButton.icon(
          onPressed: onNotes,
          icon: const Icon(Icons.edit_note_rounded, size: 16),
          label: Text((apt.doctorNotes?.isEmpty ?? true) ? 'Ajouter des notes' : 'Modifier les notes'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── STATES ───────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.event_busy_rounded, size: 56, color: context.mutedText),
    const SizedBox(height: 12),
    Text('Aucun RDV « $label »',
      style: TextStyle(fontSize: 16, color: context.mutedText, fontWeight: FontWeight.w600)),
  ]));
}

class _ErrorState extends StatelessWidget {
  final String message; final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.wifi_off_rounded, size: 56, color: context.mutedText),
    const SizedBox(height: 12),
    Text('Impossible de charger les RDV', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.textColor)),
    const SizedBox(height: 6),
    Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: context.mutedText)),
    const SizedBox(height: 20),
    ElevatedButton.icon(onPressed: onRetry,
      icon: const Icon(Icons.refresh_rounded),
      label: const Text('Réessayer'),
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
  ]));
}
