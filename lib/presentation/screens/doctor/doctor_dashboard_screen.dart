import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../core/di/app_services.dart';
import '../../../core/network/api_exception.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = AppServices.authSessionManager.user;
      if (user == null) {
        setState(() {
          _errorMessage = 'Utilisateur non trouvé';
          _isLoading = false;
        });
        return;
      }

      // TODO: Récupérer les stats du docteur via DoctorService
      // Pour maintenant, on simule les données
      setState(() {
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.bgColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: context.bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.danger)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDashboardData,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                'Tableau de Bord',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 24),

              // Cartes de statistiques
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StatCard(
                    title: 'RDV du jour',
                    value: '8',
                    icon: Icons.calendar_today_rounded,
                    color: AppColors.primary,
                    context: context,
                  ),
                  _StatCard(
                    title: 'Patients',
                    value: '324',
                    icon: Icons.people_outline_rounded,
                    color: const Color(0xFF00C48C),
                    context: context,
                  ),
                  _StatCard(
                    title: 'Revenus (mois)',
                    value: '2.4M',
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFFFFB800),
                    context: context,
                  ),
                  _StatCard(
                    title: 'Note moyenne',
                    value: '4.8',
                    icon: Icons.star_rounded,
                    color: const Color(0xFFFF6B6B),
                    context: context,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Section: Rendez-vous à venir
              Text(
                'Rendez-vous à venir',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 12),
              _UpcomingAppointmentsList(context: context),

              const SizedBox(height: 32),

              // Section: Patients récents
              Text(
                'Patients récents',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 12),
              _RecentPatientsList(context: context),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final BuildContext context;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.mutedText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingAppointmentsList extends StatelessWidget {
  final BuildContext context;

  const _UpcomingAppointmentsList({required this.context});

  @override
  Widget build(BuildContext context) {
    // TODO: Charger les vrais rendez-vous depuis l'API
    return Column(
      children: [
        _AppointmentTile(
          patientName: 'Jean Kouassi',
          time: '09:30',
          type: 'Consultation',
          context: context,
        ),
        const SizedBox(height: 12),
        _AppointmentTile(
          patientName: 'Marie Traoré',
          time: '11:00',
          type: 'Suivi',
          context: context,
        ),
        const SizedBox(height: 12),
        _AppointmentTile(
          patientName: 'Pierre Yao',
          time: '14:30',
          type: 'Consultation',
          context: context,
        ),
      ],
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final String patientName;
  final String time;
  final String type;
  final BuildContext context;

  const _AppointmentTile({
    required this.patientName,
    required this.time,
    required this.type,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person_outline_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                Text(
                  type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentPatientsList extends StatelessWidget {
  final BuildContext context;

  const _RecentPatientsList({required this.context});

  @override
  Widget build(BuildContext context) {
    // TODO: Charger les vrais patients depuis l'API
    return Column(
      children: [
        _PatientTile('Alice Dupont', 'Cardiologue', context),
        const SizedBox(height: 8),
        _PatientTile('Bob Martin', 'Généraliste', context),
        const SizedBox(height: 8),
        _PatientTile('Carol Johnson', 'Pédiatre', context),
      ],
    );
  }
}

class _PatientTile extends StatelessWidget {
  final String name;
  final String lastVisit;
  final BuildContext context;

  const _PatientTile(this.name, this.lastVisit, this.context);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.dividerColor, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                Text(
                  lastVisit,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.mutedText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded, color: context.mutedText),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
