import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../core/routes/navigation_helper.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final _isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mes rendez-vous',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800, color: context.textPrimary,
                          letterSpacing: -0.5),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => NavigationHelper.goToBookingFlow(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: context.borderColor, width: 1),
                      ),
                      child: const Icon(Icons.add_rounded, size: 20, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: context.borderColor, width: 1),
              ),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: context.textMuted,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'À venir'),
                  Tab(text: 'Passés'),
                  Tab(text: 'Annulés'),
                ],
              ),
            ),

            // Contenu onglets
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _UpcomingTab(),
                  _PastTab(),
                  _CancelledTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: const [
        // Badge "Aujourd'hui"
        _DateBadge(label: 'Demain, 19 Mai'),
        SizedBox(height: 10),
        _AppointmentCard(
          doctorName: 'Dr. Amine Toure',
          specialty: 'Cardiologie',
          date: 'Demain',
          time: '14h30',
          location: 'Hôpital Central Yaoundé',
          status: _ApptStatus.confirmed,
          initials: 'AT',
          color: AppColors.cardio,
          isNext: true,
        ),
        SizedBox(height: 20),
        _DateBadge(label: 'Mercredi, 21 Mai'),
        SizedBox(height: 10),
        _AppointmentCard(
          doctorName: 'Dr. Nathalie Bello',
          specialty: 'Pédiatrie',
          date: 'Mer 21 Mai',
          time: '09h00',
          location: 'Clinique La Paix',
          status: _ApptStatus.pending,
          initials: 'NB',
          color: AppColors.pediatrie,
          isNext: false,
        ),
        SizedBox(height: 20),
        _DateBadge(label: 'Lundi, 2 Juin'),
        SizedBox(height: 10),
        _AppointmentCard(
          doctorName: 'Dr. Samuel Nkama',
          specialty: 'Médecine générale',
          date: 'Lun 2 Juin',
          time: '11h00',
          location: 'Centre Médical Obili',
          status: _ApptStatus.confirmed,
          initials: 'SN',
          color: AppColors.generale,
          isNext: false,
        ),
      ],
    );
  }
}

class _PastTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        const _DateBadge(label: 'Avril 2025'),
        const SizedBox(height: 10),
        const _AppointmentCard(
          doctorName: 'Dr. Paul Mbarga',
          specialty: 'Neurologie',
          date: '15 Avril',
          time: '10h30',
          location: 'CHU Yaoundé',
          status: _ApptStatus.completed,
          initials: 'PM',
          color: AppColors.neuro,
          isNext: false,
        ),
        const SizedBox(height: 12),
        const _AppointmentCard(
          doctorName: 'Dr. Cécile Fon',
          specialty: 'Ophtalmologie',
          date: '8 Avril',
          time: '14h00',
          location: 'Clinique Élite',
          status: _ApptStatus.completed,
          initials: 'CF',
          color: AppColors.ophtalmo,
          isNext: false,
        ),
        const SizedBox(height: 20),
        const _DateBadge(label: 'Mars 2025'),
        const SizedBox(height: 10),
        const _AppointmentCard(
          doctorName: 'Dr. Amine Toure',
          specialty: 'Cardiologie',
          date: '22 Mars',
          time: '09h30',
          location: 'Hôpital Central Yaoundé',
          status: _ApptStatus.completed,
          initials: 'AT',
          color: AppColors.cardio,
          isNext: false,
        ),
        const SizedBox(height: 24),
        // CTA ordonnances
        GestureDetector(
          onTap: () => NavigationHelper.goToPrescriptionsList(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.primaryLightColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary100, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.description_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mes ordonnances',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
                      SizedBox(height: 2),
                      Text('3 ordonnances disponibles',
                          style: TextStyle(fontSize: 12, color: context.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CancelledTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        const _AppointmentCard(
          doctorName: 'Dr. Irène Soh',
          specialty: 'Gynécologie',
          date: '10 Avril',
          time: '15h00',
          location: 'Hôpital Général Douala',
          status: _ApptStatus.cancelled,
          initials: 'IS',
          color: AppColors.gyneco,
          isNext: false,
        ),
        const SizedBox(height: 12),
        const _AppointmentCard(
          doctorName: 'Dr. Marc Ela',
          specialty: 'Dermatologie',
          date: '3 Mars',
          time: '11h30',
          location: 'Clinique du Lac',
          status: _ApptStatus.cancelled,
          initials: 'ME',
          color: AppColors.dermato,
          isNext: false,
        ),
        const SizedBox(height: 28),
        Center(
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.event_busy_rounded, color: AppColors.danger, size: 28),
              ),
              const SizedBox(height: 12),
              Text('Pas d\'autres annulations',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: context.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

enum _ApptStatus { confirmed, pending, completed, cancelled }

class _DateBadge extends StatelessWidget {
  final String label;
  const _DateBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: context.textMuted,
                letterSpacing: 0.3)),
        const SizedBox(width: 10),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String doctorName, specialty, date, time, location, initials;
  final _ApptStatus status;
  final Color color;
  final bool isNext;

  const _AppointmentCard({
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.location,
    required this.status,
    required this.initials,
    required this.color,
    required this.isNext,
  });

  Color _statusColor(BuildContext context) {
    switch (status) {
      case _ApptStatus.confirmed: return AppColors.success;
      case _ApptStatus.pending: return AppColors.warning;
      case _ApptStatus.completed: return context.textMuted;
      case _ApptStatus.cancelled: return AppColors.danger;
    }
  }

  String get _statusLabel {
    switch (status) {
      case _ApptStatus.confirmed: return 'Confirmé';
      case _ApptStatus.pending: return 'En attente';
      case _ApptStatus.completed: return 'Terminé';
      case _ApptStatus.cancelled: return 'Annulé';
    }
  }

  Color _statusBg(BuildContext context) {
    switch (status) {
      case _ApptStatus.confirmed: return context.successBgColor;
      case _ApptStatus.pending: return context.warningBgColor;
      case _ApptStatus.completed: return context.cardColor;
      case _ApptStatus.cancelled: return context.dangerBgColor;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isNext ? color.withValues(alpha: 0.3) : (context.borderColor),
          width: isNext ? 1.5 : 1,
        ),
        boxShadow: isNext
            ? [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))]
            : null,
      ),
      child: Column(
        children: [
          // Bande colorée si prochain
          if (isNext)
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Médecin + statut
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(initials,
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.w800, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctorName, overflow: TextOverflow.ellipsis, maxLines: 1,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
                          const SizedBox(height: 3),
                          Text(specialty,
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w400, color: context.textMuted)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _statusBg(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_statusLabel,
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor(context))),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Container(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
                const SizedBox(height: 12),

                // Détails du RDV
                Row(
                  children: [
                    _Detail(icon: Icons.calendar_today_rounded, text: date),
                    const SizedBox(width: 16),
                    _Detail(icon: Icons.access_time_rounded, text: time),
                    const SizedBox(width: 16),
                    Flexible(child: _Detail(icon: Icons.location_on_outlined, text: location)),
                  ],
                ),

                // Actions selon statut
                if (status == _ApptStatus.confirmed || status == _ApptStatus.pending) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(color: AppColors.danger, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Annuler',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.danger)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Reprogrammer',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],

                if (status == _ApptStatus.completed) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => NavigationHelper.goToPrescriptionsList(context),
                          icon: const Icon(Icons.description_outlined, size: 16),
                          label: const Text('Ordonnance'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => NavigationHelper.goToBookingFlow(context),
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Re-consulter'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Detail({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: context.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: context.textSecondary)),
        ),
      ],
    );
  }
}
