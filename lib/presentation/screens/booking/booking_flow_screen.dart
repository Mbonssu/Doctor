import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../core/di/app_services.dart';
import '../../../data/models/appointment/appointment_create_request.dart';
import 'booking_success_screen.dart';

class BookingFlowScreen extends StatefulWidget {
  final int doctorId;
  final String doctorName;
  final String specialty;
  final String initials;
  final Color color;
  final String price;
  final DateTime? appointmentDate;

  const BookingFlowScreen({
    super.key,
    this.doctorId = 0,
    this.doctorName = 'Dr. Médecin',
    this.specialty = 'Spécialité',
    this.initials = 'MD',
    this.color = AppColors.primary,
    this.price = '0 FCFA',
    this.appointmentDate,
  });

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();

  DateTime get _date => appointmentDate ?? DateTime.now();
  String get formattedDate {
    const months = ['Jan','Fév','Mar','Avr','Mai','Juin','Juil','Août','Sep','Oct','Nov','Déc'];
    const days = ['Lun','Mar','Mer','Jeu','Ven','Sam','Dim'];
    final d = _date;
    return '${days[d.weekday-1]} ${d.day} ${months[d.month-1]}';
  }
  String get formattedTime =>
    '${_date.hour.toString().padLeft(2,'0')}h${_date.minute.toString().padLeft(2,'0')}';
}

class _BookingFlowScreenState extends State<BookingFlowScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  late AnimationController _stepCtrl;
  late Animation<Offset> _slideAnim;

  // Step 1 — Motif
  int _selectedReason = -1;
  final _customReasonCtrl = TextEditingController();
  final _reasons = [
    'Consultation générale',
    'Suivi de traitement',
    'Résultats d\'analyses',
    'Renouvellement d\'ordonnance',
    'Douleur aiguë',
    'Bilan de santé',
    'Avis médical (second avis)',
    'Autre',
  ];

  // Step 2 — Type de consultation
  int _consultType = 0; // 0=présentiel, 1=téléconsult (locked)

  // Step 3 — Pour qui
  int _forWho = 0; // 0=moi, 1=proche
  String _selectedMember = '';
  final _members = ['Sarah Dupont (Épouse)', 'Lucas Dupont (Fils, 8 ans)', 'Marie Dupont (Mère)'];

  // Step 4 — Paiement
  int _paymentMethod = 0;
  final _payments = [
    _PaymentOption(icon: Icons.account_balance_wallet_outlined, label: 'Mobile Money', subtitle: 'MTN / Orange Money', color: AppColors.warning),
    _PaymentOption(icon: Icons.credit_card_rounded, label: 'Carte bancaire', subtitle: 'Visa / Mastercard', color: AppColors.primary),
    _PaymentOption(icon: Icons.payments_outlined, label: 'Paiement sur place', subtitle: 'Espèces à la clinique', color: AppColors.accent),
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _stepCtrl = AnimationController(
        duration: const Duration(milliseconds: 350), vsync: this);
    _slideAnim = Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut));
    _stepCtrl.forward();
  }

  @override
  void dispose() {
    _stepCtrl.dispose();
    _customReasonCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < 3) {
      _stepCtrl.reset();
      setState(() => _step++);
      _stepCtrl.forward();
    } else {
      _confirmBooking();
    }
  }

  void _prevStep() {
    if (_step > 0) {
      _stepCtrl.reset();
      setState(() => _step--);
      _stepCtrl.forward();
    }
  }

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);
    try {
      final user = AppServices.authSessionManager.user;
      final reason = _selectedReason >= 0 ? _reasons[_selectedReason] : null;
      await AppServices.appointmentsRepository.createAppointment(
        AppointmentCreateRequest(
          patientId: user?.id ?? 0,
          doctorId: widget.doctorId,
          appointmentDate: widget._date,
          durationMinutes: 30,
          appointmentType: _consultType == 0 ? 'consultation' : 'teleconsult',
          reason: reason,
        ),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingSuccessScreen(
              doctorName: widget.doctorName,
              specialty: widget.specialty,
              initials: widget.initials,
              color: widget.color,
              date: widget.formattedDate,
              time: widget.formattedTime,
              location: 'Hôpital Central',
              consultType: _consultType == 0 ? 'Présentiel' : 'Téléconsultation',
              motif: reason ?? 'Consultation',
              bookingRef: 'DTP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  bool get _canNext {
    switch (_step) {
      case 0: return _selectedReason >= 0;
      case 1: return _consultType == 0;
      case 2: return _forWho == 0 || _selectedMember.isNotEmpty;
      case 3: return true;
      default: return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final _isDark = context.isDark;
    final steps = ['Motif', 'Type', 'Patient', 'Paiement'];

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                border: Border(
                  bottom: BorderSide(
                    color: context.borderColor,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: _step == 0 ? () => Navigator.pop(context) : _prevStep,
                        icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                      ),
                      Expanded(
                        child: Text(
                          'Prise de rendez-vous',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700, color: context.textPrimary),
                        ),
                      ),
                      Text('${_step + 1} / 4',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress bar
                  Row(
                    children: List.generate(4, (i) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: i <= _step ? AppColors.primary : AppColors.border,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  // Step labels
                  Row(
                    children: List.generate(4, (i) => Expanded(
                      child: Text(
                        steps[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: i == _step ? FontWeight.w700 : FontWeight.w400,
                          color: i <= _step ? AppColors.primary : context.textMuted,
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ),

            // ── Doctor summary chip ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: widget.color.withValues(alpha: 0.2), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(widget.initials,
                            style: TextStyle(color: widget.color, fontWeight: FontWeight.w800, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.doctorName,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
                          Text(widget.specialty,
                              style: TextStyle(fontSize: 12, color: widget.color, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(widget.formattedDate, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.textPrimary)),
                        Text(widget.formattedTime, style: TextStyle(fontSize: 11, color: context.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Step content ──
            Expanded(
              child: SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _stepCtrl,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildStep(),
                  ),
                ),
              ),
            ),

            // ── Bottom CTA ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                border: Border(
                  top: BorderSide(color: context.borderColor, width: 1),
                ),
              ),
              child: Column(
                children: [
                  // Prix visible
                  if (_step == 3)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total à payer',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.textSecondary)),
                          Text(widget.price,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_canNext && !_isLoading) ? _nextStep : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: AppColors.border,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(Colors.white)))
                          : Text(
                              _step < 3 ? 'Continuer →' : 'Confirmer le rendez-vous',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _canNext ? Colors.white : context.textMuted,
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
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _StepMotif(
          reasons: _reasons, selected: _selectedReason,
          customCtrl: _customReasonCtrl,
          onSelect: (i) => setState(() => _selectedReason = i));
      case 1: return _StepType(selected: _consultType, onSelect: (i) => setState(() => _consultType = i));
      case 2: return _StepPatient(
          forWho: _forWho, members: _members, selectedMember: _selectedMember,
          onForWho: (i) => setState(() { _forWho = i; _selectedMember = ''; }),
          onMember: (m) => setState(() => _selectedMember = m));
      case 3: return _StepPayment(
          payments: _payments, selected: _paymentMethod,
          onSelect: (i) => setState(() => _paymentMethod = i),
          price: widget.price, doctorName: widget.doctorName,
          date: widget.formattedDate, time: widget.formattedTime,
          motif: _selectedReason >= 0 ? _reasons[_selectedReason] : '—',
          consultType: _consultType == 0 ? 'Présentiel' : 'Téléconsultation');
      default: return const SizedBox();
    }
  }
}

// ── STEP 1 — Motif ─────────────────────────────────────────────

class _StepMotif extends StatelessWidget {
  final List<String> reasons;
  final int selected;
  final TextEditingController customCtrl;
  final void Function(int) onSelect;

  const _StepMotif({required this.reasons, required this.selected, required this.customCtrl, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Motif de consultation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary, letterSpacing: -0.4)),
        const SizedBox(height: 6),
        Text('Précisez la raison de votre visite pour aider le médecin à se préparer.',
            style: TextStyle(fontSize: 13, color: context.textMuted, height: 1.5)),
        const SizedBox(height: 20),
        ...List.generate(reasons.length, (i) {
          final isSel = selected == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSel ? context.primaryLightColor : context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSel ? AppColors.primary : AppColors.border, width: isSel ? 2 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSel ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSel ? AppColors.primary : AppColors.borderMid,
                        width: 1.5,
                      ),
                    ),
                    child: isSel ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(reasons[i],
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? AppColors.primary : context.textPrimary)),
                  ),
                ],
              ),
            ),
          );
        }),
        if (selected == reasons.length - 1) ...[
          const SizedBox(height: 10),
          TextFormField(
            controller: customCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Décrivez votre motif en quelques mots…',
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ],
      ],
    );
  }
}

// ── STEP 2 — Type ──────────────────────────────────────────────

class _StepType extends StatelessWidget {
  final int selected;
  final void Function(int) onSelect;

  const _StepType({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type de consultation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary, letterSpacing: -0.4)),
        const SizedBox(height: 6),
        Text('Choisissez comment vous souhaitez rencontrer le médecin.',
            style: TextStyle(fontSize: 13, color: context.textMuted, height: 1.5)),
        const SizedBox(height: 24),

        // Présentiel
        _ConsultTypeCard(
          icon: Icons.local_hospital_rounded,
          title: 'Consultation présentielle',
          subtitle: 'Rendez-vous en cabinet ou à l\'hôpital',
          color: AppColors.primary,
          selected: selected == 0,
          locked: false,
          tag: null,
          onTap: () => onSelect(0),
        ),
        const SizedBox(height: 14),

        // Téléconsult — locked V2
        _ConsultTypeCard(
          icon: Icons.videocam_rounded,
          title: 'Téléconsultation',
          subtitle: 'Consultation vidéo depuis chez vous',
          color: const Color(0xFF845EF7),
          selected: selected == 1,
          locked: true,
          tag: 'V2',
          onTap: null,
        ),
        const SizedBox(height: 28),

        // Info card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.primaryLightColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary100, width: 1),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'La consultation présentielle se déroule directement à l\'hôpital ou en cabinet. Pensez à arriver 10 minutes avant.',
                  style: TextStyle(fontSize: 12, color: AppColors.primary, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConsultTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool selected;
  final bool locked;
  final String? tag;
  final VoidCallback? onTap;

  const _ConsultTypeCard({
    required this.icon, required this.title, required this.subtitle,
    required this.color, required this.selected, required this.locked,
    this.tag, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // final _isDark = context.isDark;
    return GestureDetector(
      onTap: locked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: locked
              ? (context.cardColor)
              : selected
                  ? color.withValues(alpha: 0.08)
                  : (context.surfaceColor),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: locked ? AppColors.border : selected ? color : AppColors.border,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: locked ? AppColors.gray100 : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: locked ? context.textMuted : color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: locked ? context.textMuted : context.textPrimary)),
                      if (tag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EBFF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(tag!,
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF845EF7))),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: locked ? context.textMuted : context.textSecondary)),
                ],
              ),
            ),
            if (!locked)
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? color : Colors.transparent,
                  border: Border.all(color: selected ? color : AppColors.borderMid, width: 1.5),
                ),
                child: selected ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
              ),
            if (locked)
              Icon(Icons.lock_outline_rounded, color: context.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── STEP 3 — Pour qui ──────────────────────────────────────────

class _StepPatient extends StatelessWidget {
  final int forWho;
  final List<String> members;
  final String selectedMember;
  final void Function(int) onForWho;
  final void Function(String) onMember;

  const _StepPatient({
    required this.forWho, required this.members, required this.selectedMember,
    required this.onForWho, required this.onMember,
  });

  @override
  Widget build(BuildContext context) {
    // final _isDark = context.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pour qui est ce RDV ?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary, letterSpacing: -0.4)),
        const SizedBox(height: 6),
        Text('Vous pouvez réserver pour vous-même ou pour un proche.',
            style: TextStyle(fontSize: 13, color: context.textMuted, height: 1.5)),
        const SizedBox(height: 24),

        // Pour moi
        _PatientOption(
          icon: Icons.person_rounded,
          title: 'Pour moi',
          subtitle: 'Jean Dupont · Né le 15/03/1990 · O+',
          selected: forWho == 0,
          onTap: () => onForWho(0),
        ),
        const SizedBox(height: 12),

        // Pour un proche
        _PatientOption(
          icon: Icons.people_rounded,
          title: 'Pour un proche',
          subtitle: 'Sélectionnez un membre de votre famille',
          selected: forWho == 1,
          onTap: () => onForWho(1),
        ),

        if (forWho == 1) ...[
          const SizedBox(height: 16),
          ...members.map((m) {
            final isSel = selectedMember == m;
            return GestureDetector(
              onTap: () => onMember(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSel ? context.primaryLightColor : (context.cardColor),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSel ? AppColors.primary : AppColors.border, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: context.primaryLightColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(m, style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel ? AppColors.primary : context.textPrimary)),
                    const Spacer(),
                    if (isSel)
                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          // Ajouter un proche
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5, style: BorderStyle.solid),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text('Ajouter un nouveau proche',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PatientOption extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _PatientOption({required this.icon, required this.title, required this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // final _isDark = context.isDark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? context.primaryLightColor : (context.surfaceColor),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: selected ? Colors.white : context.textMuted, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: selected ? AppColors.primary : context.textPrimary)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: context.textMuted)),
                ],
              ),
            ),
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(color: selected ? AppColors.primary : AppColors.borderMid, width: 1.5),
              ),
              child: selected ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── STEP 4 — Paiement ──────────────────────────────────────────

class _StepPayment extends StatelessWidget {
  final List<_PaymentOption> payments;
  final int selected;
  final void Function(int) onSelect;
  final String price, doctorName, date, time, motif, consultType;

  const _StepPayment({
    required this.payments, required this.selected, required this.onSelect,
    required this.price, required this.doctorName, required this.date,
    required this.time, required this.motif, required this.consultType,
  });

  @override
  Widget build(BuildContext context) {
    // final _isDark = context.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Récapitulatif & Paiement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary, letterSpacing: -0.4)),
        const SizedBox(height: 20),

        // Résumé RDV
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor, width: 1),
          ),
          child: Column(
            children: [
              _SummaryRow(label: 'Médecin', value: doctorName),
              const Divider(height: 20),
              _SummaryRow(label: 'Date', value: date),
              const Divider(height: 20),
              _SummaryRow(label: 'Heure', value: time),
              const Divider(height: 20),
              _SummaryRow(label: 'Motif', value: motif),
              const Divider(height: 20),
              _SummaryRow(label: 'Type', value: consultType),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text('Mode de paiement',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
        const SizedBox(height: 14),

        ...List.generate(payments.length, (i) {
          final p = payments[i];
          final isSel = selected == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSel ? p.color.withValues(alpha: 0.06) : (context.surfaceColor),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSel ? p.color : AppColors.border, width: isSel ? 2 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: p.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(p.icon, color: p.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                            color: isSel ? p.color : context.textPrimary)),
                        Text(p.subtitle, style: TextStyle(fontSize: 12, color: context.textMuted)),
                      ],
                    ),
                  ),
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSel ? p.color : Colors.transparent,
                      border: Border.all(color: isSel ? p.color : AppColors.borderMid, width: 1.5),
                    ),
                    child: isSel ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 16),
        // Sécurité paiement
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, size: 14, color: AppColors.success),
            const SizedBox(width: 6),
            Text('Paiement 100% sécurisé',
                style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: context.textMuted, fontWeight: FontWeight.w400)),
        Text(value, style: TextStyle(fontSize: 13, color: context.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _PaymentOption {
  final IconData icon;
  final String label, subtitle;
  final Color color;
  const _PaymentOption({required this.icon, required this.label, required this.subtitle, required this.color});
}
