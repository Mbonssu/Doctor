import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../core/di/app_services.dart';
import '../../../data/models/appointment/appointment_model.dart';
import '../chat/chat_screen.dart';
import '../booking/booking_flow_screen.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final AppointmentModel? appointment;

  const AppointmentDetailScreen({super.key, this.appointment});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  bool _isCancelling = false;

  // ── Helpers depuis AppointmentModel ─────────────────────────
  AppointmentModel? get _apt => widget.appointment;

  String get _doctorName {
    final d = _apt?.doctor;
    if (d?.user == null) return 'Dr. Médecin';
    return 'Dr. ${d!.user!.firstName} ${d.user!.lastName}';
  }

  String get _specialty => _apt?.doctor?.specialty ?? 'Spécialité';

  String get _initials {
    final d = _apt?.doctor?.user;
    if (d == null) return 'MD';
    return '${d.firstName.isNotEmpty ? d.firstName[0] : ''}${d.lastName.isNotEmpty ? d.lastName[0] : ''}'.toUpperCase();
  }

  Color get _color {
    const colors = [AppColors.cardio, AppColors.primary, const Color(0xFF845EF7),
      AppColors.accent, AppColors.neuro, AppColors.pediatrie];
    return colors[(_apt?.doctorId ?? 0) % colors.length];
  }

  String get _statusLabel => switch (_apt?.status ?? '') {
    'pending'   => 'En attente',
    'confirmed' => 'Confirmé',
    'completed' => 'Passé',
    'cancelled' => 'Annulé',
    _           => _apt?.status ?? '—',
  };

  Color get _statusColor => switch (_apt?.status ?? '') {
    'pending'   => AppColors.warning,
    'confirmed' => AppColors.primary,
    'completed' => AppColors.success,
    'cancelled' => AppColors.danger,
    _           => AppColors.textMuted,
  };

  String get _formattedDate {
    final d = _apt?.appointmentDate;
    if (d == null) return '—';
    const months = ['Jan','Fév','Mar','Avr','Mai','Juin','Juil','Août','Sep','Oct','Nov','Déc'];
    const days = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'];
    return '${days[d.weekday-1]} ${d.day} ${months[d.month-1]} ${d.year}';
  }

  String get _formattedTime {
    final d = _apt?.appointmentDate;
    if (d == null) return '—';
    return '${d.hour.toString().padLeft(2,'0')}h${d.minute.toString().padLeft(2,'0')}';
  }

  String get _location =>
    _apt?.doctor?.hospitalName ?? _apt?.doctor?.city ?? 'Non renseigné';

  bool get _isPast =>
    _apt?.status == 'completed' || _apt?.status == 'cancelled';

  bool get _canCancel =>
    _apt?.status == 'pending' || _apt?.status == 'confirmed';

  // ── Actions ─────────────────────────────────────────────────

  Future<void> _cancel() async {
    String reason = '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Annuler le rendez-vous'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Êtes-vous sûr de vouloir annuler ?'),
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Retour')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Annuler le RDV'),
          ),
        ],
      ),
    );
    if (ok != true || _apt == null) return;
    setState(() => _isCancelling = true);
    try {
      await AppServices.appointmentsRepository.cancelAppointment(
        appointmentId: _apt!.id,
        cancellationReason: reason.isEmpty ? 'Annulé par le patient' : reason,
      );
      if (mounted) {
        Navigator.pop(context, true); // retourner true = rafraîchir la liste
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8), Text('RDV annulé'),
          ]),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_apt == null) {
      return Scaffold(
        backgroundColor: context.bgColor,
        appBar: AppBar(backgroundColor: context.bgColor, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pop(context))),
        body: const Center(child: Text('Rendez-vous introuvable')),
      );
    }

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            // ── Header gradient ──
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [_color.withValues(alpha: 0.9), _color],
                ),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                  ),
                  const Expanded(child: Text('Détail du RDV',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Text(_statusLabel,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ]),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                      ),
                      child: Center(child: Text(_initials,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_doctorName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                      const SizedBox(height: 3),
                      Text(_specialty,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                      if (_apt!.doctor?.yearsOfExperience != null) ...[
                        const SizedBox(height: 2),
                        Text('${_apt!.doctor!.yearsOfExperience} ans d\'expérience',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12)),
                      ],
                    ])),
                  ]),
                ),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Info card ──
                _InfoCard(children: [
                  _InfoRow(icon: Icons.calendar_today_rounded, label: 'Date',
                      value: _formattedDate, color: AppColors.primary),
                  const Divider(),
                  _InfoRow(icon: Icons.access_time_rounded, label: 'Heure',
                      value: _formattedTime, color: AppColors.accent),
                  const Divider(),
                  _InfoRow(icon: Icons.location_on_outlined, label: 'Lieu',
                      value: _location, color: AppColors.danger),
                  const Divider(),
                  _InfoRow(icon: Icons.medical_information_outlined, label: 'Motif',
                      value: _apt!.reason ?? 'Consultation générale',
                      color: const Color(0xFF845EF7)),
                  const Divider(),
                  _InfoRow(icon: Icons.timer_outlined, label: 'Durée',
                      value: '${_apt!.durationMinutes} min', color: AppColors.warning),
                  const Divider(),
                  _InfoRow(icon: Icons.attach_money_rounded, label: 'Tarif',
                      value: '${_apt!.consultationFee.toInt()} FCFA',
                      color: AppColors.success),
                  const Divider(),
                  _InfoRow(icon: Icons.tag_rounded, label: 'Référence',
                      value: 'DTP-${_apt!.id.toString().padLeft(6,'0')}',
                      color: context.textMuted),
                ]),

                const SizedBox(height: 20),

                // ── Localisation ──
                _SectionHeader('Localisation'),
                const SizedBox(height: 12),
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: context.cardColor,
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomPaint(painter: _MapMockPainter(), size: Size.infinite),
                    ),
                    Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 36),
                      const SizedBox(height: 4),
                      Text(_location,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                              color: context.textPrimary)),
                    ])),
                    Positioned(right: 12, bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.directions_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 5),
                          Text('Itinéraire', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 20),

                // ── Préparer ma visite ──
                if (!_isPast) ...[
                  _SectionHeader('Préparer ma visite'),
                  const SizedBox(height: 12),
                  const _ChecklistItem(label: 'Carte d\'identité ou passeport', done: true),
                  const _ChecklistItem(label: 'Carnet de santé', done: false),
                  const _ChecklistItem(label: 'Ordonnances précédentes', done: false),
                  const _ChecklistItem(label: 'Résultats d\'analyses', done: false),
                  const _ChecklistItem(label: 'Liste des médicaments en cours', done: false),
                  const SizedBox(height: 20),
                ],

                // ── Notes du médecin (si consultation passée) ──
                if (_apt!.doctorNotes != null && _apt!.doctorNotes!.isNotEmpty) ...[
                  _SectionHeader('Notes du médecin'),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(_apt!.doctorNotes!,
                        style: TextStyle(fontSize: 13, color: context.textPrimary, height: 1.5)),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Actions ──
                if (_canCancel) ...[
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => BookingFlowScreen(
                          doctorId: _apt!.doctorId,
                          doctorName: _doctorName,
                          specialty: _specialty,
                          initials: _initials,
                          color: _color,
                          price: '${_apt!.consultationFee.toInt()} FCFA',
                        ))),
                      icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                      label: const Text('Reprogrammer'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: OutlinedButton.icon(
                      onPressed: _isCancelling ? null : _cancel,
                      icon: _isCancelling
                          ? const SizedBox(width: 14, height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger))
                          : const Icon(Icons.cancel_outlined, size: 16, color: AppColors.danger),
                      label: const Text('Annuler', style: TextStyle(color: AppColors.danger)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.danger, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    )),
                  ]),
                  const SizedBox(height: 12),
                ],

                if (_apt!.status == 'completed') ...[
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => _ReviewScreen(
                          appointmentId: _apt!.id,
                          doctorId: _apt!.doctorId,
                          doctorName: _doctorName,
                          specialty: _specialty,
                          initials: _initials,
                          color: _color,
                        ))),
                      icon: const Icon(Icons.star_rounded, size: 18),
                      label: const Text('Laisser un avis'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning, elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => BookingFlowScreen(
                          doctorId: _apt!.doctorId,
                          doctorName: _doctorName,
                          specialty: _specialty,
                          initials: _initials,
                          color: _color,
                          price: '${_apt!.consultationFee.toInt()} FCFA',
                        ))),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Re-consulter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Chat ──
                SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ChatScreen(doctorName: _doctorName))),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                    label: const Text('Envoyer un message'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Review Screen (branché API) ────────────────────────────────

class _ReviewScreen extends StatefulWidget {
  final int appointmentId, doctorId;
  final String doctorName, specialty, initials;
  final Color color;

  const _ReviewScreen({
    required this.appointmentId, required this.doctorId,
    required this.doctorName, required this.specialty,
    required this.initials, required this.color,
  });

  @override
  State<_ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<_ReviewScreen> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  final _tags = ['Ponctuel', 'À l\'écoute', 'Explications claires', 'Diagnostic précis',
    'Cabinet propre', 'Personnel aimable', 'Délai d\'attente raisonnable'];
  final List<String> _selectedTags = [];
  bool _isLoading = false;

  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez sélectionner une note'),
        backgroundColor: AppColors.warning, behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = AppServices.authSessionManager.user;
      final comment = [
        if (_selectedTags.isNotEmpty) _selectedTags.join(', '),
        if (_commentCtrl.text.isNotEmpty) _commentCtrl.text,
      ].join(' — ');

      await AppServices.reviewsRepository.createReview(
        doctorId: widget.doctorId,
        patientId: user?.id ?? 0,
        rating: _rating,
        comment: comment.isNotEmpty ? comment : 'Consultation satisfaisante',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Merci pour votre avis ! 🌟'),
          backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
          child: Row(children: [
            IconButton(onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 20)),
            Text('Laisser un avis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary)),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Doctor card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.borderColor)),
              child: Row(children: [
                Container(width: 52, height: 52,
                    decoration: BoxDecoration(color: widget.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text(widget.initials,
                        style: TextStyle(color: widget.color, fontWeight: FontWeight.w800, fontSize: 18)))),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.doctorName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                  Text(widget.specialty, style: TextStyle(fontSize: 12, color: widget.color, fontWeight: FontWeight.w500)),
                ]),
              ]),
            ),
            const SizedBox(height: 28),

            // Stars
            Center(child: Text('Quelle est votre note globale ?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimary))),
            const SizedBox(height: 16),
            Center(child: Row(mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedScale(scale: _rating > i ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(_rating > i ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: _rating > i ? AppColors.warning : AppColors.border, size: 42))),
              )),
            )),
            if (_rating > 0) ...[
              const SizedBox(height: 8),
              Center(child: Text(
                ['','Mauvais 😞','Passable 😐','Bien 🙂','Très bien 😊','Excellent 🤩'][_rating],
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textSecondary))),
            ],

            const SizedBox(height: 24),
            Text('Qu\'est-ce qui vous a plu ?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: _tags.map((t) {
              final sel = _selectedTags.contains(t);
              return GestureDetector(
                onTap: () => setState(() => sel ? _selectedTags.remove(t) : _selectedTags.add(t)),
                child: AnimatedContainer(duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: sel ? context.primaryLightColor : context.surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel ? AppColors.primary : AppColors.border, width: 1.5)),
                  child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: sel ? AppColors.primary : context.textSecondary))),
              );
            }).toList()),

            const SizedBox(height: 22),
            Text('Commentaire (optionnel)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 10),
            TextFormField(controller: _commentCtrl, maxLines: 4, maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Partagez votre expérience…',
                  contentPadding: EdgeInsets.all(16))),

            const SizedBox(height: 28),
            SizedBox(width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : const Text('Publier mon avis',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        )),
      ])),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary));
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: context.surfaceColor, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor)),
    child: Column(children: children),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _InfoRow({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 12),
      Text(label, style: TextStyle(fontSize: 13, color: context.textMuted)),
      const Spacer(),
      Flexible(child: Text(value, textAlign: TextAlign.right,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary))),
    ]),
  );
}

class _ChecklistItem extends StatefulWidget {
  final String label; final bool done;
  const _ChecklistItem({required this.label, required this.done});
  @override
  State<_ChecklistItem> createState() => _ChecklistItemState();
}

class _ChecklistItemState extends State<_ChecklistItem> {
  late bool _checked;
  @override
  void initState() { super.initState(); _checked = widget.done; }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => _checked = !_checked),
    child: Padding(padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        AnimatedContainer(duration: const Duration(milliseconds: 180),
          width: 22, height: 22,
          decoration: BoxDecoration(
            color: _checked ? AppColors.success : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _checked ? AppColors.success : AppColors.borderMid, width: 1.5)),
          child: _checked ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null),
        const SizedBox(width: 12),
        Text(widget.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
            color: _checked ? context.textMuted : context.textPrimary,
            decoration: _checked ? TextDecoration.lineThrough : null)),
      ]),
    ),
  );
}

class _MapMockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0,0,size.width,size.height), Paint()..color = const Color(0xFFE8F0E8));
    final road = Paint()..color = Colors.white..strokeWidth = 12..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height*0.5), Offset(size.width, size.height*0.5), road);
    canvas.drawLine(Offset(size.width*0.35, 0), Offset(size.width*0.35, size.height), road);
    final block = Paint()..color = const Color(0xFFD4E0D4);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width*0.05,size.height*0.1,size.width*0.25,size.height*0.3), const Radius.circular(4)), block);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width*0.45,size.height*0.6,size.width*0.45,size.height*0.3), const Radius.circular(4)), block);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
