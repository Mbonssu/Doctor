import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  final _statuses = ['En attente', 'Confirmé', 'Complété', 'Annulé'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Charger les rendez-vous depuis l'API
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Rendez-vous',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.textColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: context.mutedText,
          indicatorColor: AppColors.primary,
          tabs: _statuses.map((status) => Tab(text: status)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statuses.map((status) {
          return _AppointmentListTab(
            status: status,
            isLoading: _isLoading,
          );
        }).toList(),
      ),
    );
  }
}

class _AppointmentListTab extends StatelessWidget {
  final String status;
  final bool isLoading;

  const _AppointmentListTab({
    required this.status,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final appointments = _getMockAppointments(status);

    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 64,
              color: context.mutedText,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun rendez-vous $status',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.mutedText,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final apt = appointments[index];
        return _AppointmentCard(
          patientName: apt['patient'] ?? '',
          date: apt['date'] ?? '',
          time: apt['time'] ?? '',
          reason: apt['reason'] ?? '',
          status: status,
        );
      },
    );
  }

  List<Map<String, String>> _getMockAppointments(String status) {
    final Map<String, List<Map<String, String>>> mockData = {
      'En attente': [
        {
          'patient': 'Jean Kouassi',
          'date': '26 mai',
          'time': '09:30',
          'reason': 'Consultation générale',
        },
        {
          'patient': 'Marie Traoré',
          'date': '26 mai',
          'time': '11:00',
          'reason': 'Suivi cardiaque',
        },
      ],
      'Confirmé': [
        {
          'patient': 'Pierre Yao',
          'date': '26 mai',
          'time': '14:30',
          'reason': 'Visite post-opératoire',
        },
        {
          'patient': 'Sophie Dubois',
          'date': '27 mai',
          'time': '10:00',
          'reason': 'Consultation',
        },
      ],
      'Complété': [
        {
          'patient': 'Antoine Martin',
          'date': '25 mai',
          'time': '15:00',
          'reason': 'Consultation',
        },
      ],
      'Annulé': [],
    };

    // 🔧 CORRECTION : Vérifier si la clé existe, sinon retourner une liste vide
    return mockData[status] ?? [];
  }
}

class _AppointmentCard extends StatelessWidget {
  final String patientName;
  final String date;
  final String time;
  final String reason;
  final String status;

  const _AppointmentCard({
    required this.patientName,
    required this.date,
    required this.time,
    required this.reason,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1), // 🔧 withOpacity corrigé
                child: Text(
                  patientName.isNotEmpty ? patientName[0] : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),
                    Text(
                      reason,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.event_outlined, size: 16, color: context.mutedText),
              const SizedBox(width: 6),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.mutedText,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.schedule_outlined, size: 16, color: context.mutedText),
              const SizedBox(width: 6),
              Text(
                time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.mutedText,
                ),
              ),
            ],
          ),
          if (status == 'En attente') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rendez-vous refusé')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    child: const Text('Refuser'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rendez-vous confirmé')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Confirmer'),
                  ),
                ),
              ],
            ),
          ] else if (status == 'Complété')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Laisser une note/feedback
                },
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Ajouter des notes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}