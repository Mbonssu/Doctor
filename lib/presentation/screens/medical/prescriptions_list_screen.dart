import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import 'prescription_detail_screen.dart';

class PrescriptionsListScreen extends StatelessWidget {
  const PrescriptionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prescriptions = [
      _Prescription(
        'Ordonnance #2025-001',
        'Dr. Amine Toure',
        'Cardiologie',
        '15 Jan 2025',
        3,
        'active',
        AppColors.cardio,
      ),
      _Prescription(
        'Ordonnance #2024-089',
        'Dr. Nathalie Bello',
        'Pédiatrie',
        '28 Déc 2024',
        2,
        'completed',
        AppColors.pediatrie,
      ),
      _Prescription(
        'Ordonnance #2024-076',
        'Dr. Paul Mbarga',
        'Neurologie',
        '10 Nov 2024',
        4,
        'completed',
        AppColors.neuro,
      ),
    ];

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text('Mes ordonnances'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _StatCard(
                  label: 'En cours',
                  value: '1',
                  icon: Icons.medication_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Terminées',
                  value: '12',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Total',
                  value: '13',
                  icon: Icons.description_rounded,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: prescriptions.length,
              itemBuilder: (context, index) {
                final prescription = prescriptions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _PrescriptionCard(prescription: prescription),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: context.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: context.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final _Prescription prescription;

  const _PrescriptionCard({required this.prescription});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PrescriptionDetailScreen(
            prescriptionId: prescription.id,
            doctorName: prescription.doctorName,
            specialty: prescription.specialty,
            date: prescription.date,
            color: prescription.color,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: prescription.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: prescription.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prescription.id,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${prescription.doctorName} · ${prescription.specialty}',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: prescription.status == 'active'
                        ? AppColors.successBg
                        : context.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: prescription.status == 'active'
                          ? AppColors.success.withValues(alpha: 0.3)
                          : context.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    prescription.status == 'active' ? 'En cours' : 'Terminée',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: prescription.status == 'active'
                          ? AppColors.successText
                          : context.textMutedColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  label: prescription.date,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.medication_liquid_rounded,
                  label: '${prescription.medicationCount} médicaments',
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded, size: 14),
                    label: const Text('PDF', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share_rounded, size: 14),
                    label: const Text('Partager', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: context.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Prescription {
  final String id;
  final String doctorName;
  final String specialty;
  final String date;
  final int medicationCount;
  final String status;
  final Color color;

  _Prescription(
    this.id,
    this.doctorName,
    this.specialty,
    this.date,
    this.medicationCount,
    this.status,
    this.color,
  );
}
