import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';

class MedicalRecordScreen extends StatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                    ),
                  Expanded(
                    child: Text('Dossier médical',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                            color: context.textPrimary, letterSpacing: -0.5)),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.ios_share_rounded, size: 20, color: AppColors.primary),
                  ),
                ],
              ),
            ),

            // Patient card
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D1B3E), Color(0xFF1B2E5E)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(child: Text('JD',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jean Dupont',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                          const SizedBox(height: 3),
                          Text('Né le 15/03/1990 · 35 ans · O+',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12)),
                          const SizedBox(height: 6),
                          Row(children: [
                            _MiniTag(label: 'HTA légère', color: AppColors.warning),
                            const SizedBox(width: 6),
                            _MiniTag(label: 'Allergie: Pénicilline', color: AppColors.danger),
                          ]),
                        ],
                      ),
                    ),
                    // QR
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.qr_code_rounded, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor, width: 1),
              ),
              child: TabBar(
                controller: _tab,
                indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: context.textMuted,
                labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'Résumé'),
                  Tab(text: 'Ordonnances'),
                  Tab(text: 'Résultats'),
                  Tab(text: 'Vaccins'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _SummaryTab(),
                  _PrescriptionsTab(),
                  _ResultsTab(),
                  _VaccinesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tabs ───────────────────────────────────────────────────────

class _SummaryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          _SectionLabel('Constantes vitales'),
          const SizedBox(height: 12),
          Row(children: [
            _VitalCard(label: 'Tension', value: '125/82', unit: 'mmHg', icon: Icons.favorite_rounded, color: AppColors.danger, status: 'Légère HTA'),
            const SizedBox(width: 12),
            _VitalCard(label: 'Pouls', value: '72', unit: 'bpm', icon: Icons.monitor_heart_outlined, color: AppColors.primary, status: 'Normal'),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _VitalCard(label: 'IMC', value: '22.7', unit: 'kg/m²', icon: Icons.scale_outlined, color: AppColors.accent, status: 'Normal'),
            const SizedBox(width: 12),
            _VitalCard(label: 'Glycémie', value: '95', unit: 'mg/dL', icon: Icons.water_drop_outlined, color: AppColors.warning, status: 'Normal'),
          ]),

          const SizedBox(height: 24),
          _SectionLabel('Antécédents médicaux'),
          const SizedBox(height: 12),
          _MedHistoryTile(icon: Icons.monitor_heart_outlined, color: AppColors.danger,
              title: 'Hypertension artérielle légère', date: 'Diagnostiqué en 2022', status: 'En traitement'),
          const SizedBox(height: 8),
          _MedHistoryTile(icon: Icons.broken_image_outlined, color: AppColors.ortho,
              title: 'Entorse de la cheville gauche', date: 'Mars 2021', status: 'Guéri'),

          const SizedBox(height: 24),
          _SectionLabel('Allergies'),
          const SizedBox(height: 12),
          _AllergyTile(name: 'Pénicilline', severity: 'Sévère', reaction: 'Éruption cutanée, œdème'),
          const SizedBox(height: 8),
          _AllergyTile(name: 'Arachides', severity: 'Modérée', reaction: 'Urticaire'),

          const SizedBox(height: 24),
          _SectionLabel('Traitements en cours'),
          const SizedBox(height: 12),
          _TreatmentTile(name: 'Amlodipine 5mg', frequency: '1x / jour', since: 'Jan 2023', doctor: 'Dr. Toure'),
        ],
      ),
    );
  }
}

class _PrescriptionsTab extends StatelessWidget {
  final _prescriptions = const [
    _PrescData('Ordonnance — Cardiologie', 'Dr. Amine Toure', '15 Avril 2025', '3 médicaments', true),
    _PrescData('Ordonnance — Ophtalmologie', 'Dr. Cécile Fon', '8 Avril 2025', '1 médicament', true),
    _PrescData('Ordonnance — Généraliste', 'Dr. Samuel Nkama', '22 Mars 2025', '2 médicaments', false),
    _PrescData('Ordonnance — Cardiologie', 'Dr. Amine Toure', '10 Jan 2025', '2 médicaments', false),
  ];

  const _PrescriptionsTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: _prescriptions.length,
      itemBuilder: (_, i) {
        final p = _prescriptions[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF845EF7).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.description_rounded, color: Color(0xFF845EF7), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title, overflow: TextOverflow.ellipsis, maxLines: 2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary)),
                    const SizedBox(height: 3),
                    Text(p.doctor, style: TextStyle(fontSize: 11, color: context.textMuted)),
                    const SizedBox(height: 5),
                    Row(children: [
                      Text(p.date, style: TextStyle(fontSize: 11, color: context.textMuted)),
                      const SizedBox(width: 8),
                      Container(
                        width: 4, height: 4,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: context.textMuted),
                      ),
                      const SizedBox(width: 8),
                      Text(p.count, style: TextStyle(fontSize: 11, color: context.textMuted)),
                    ]),
                  ],
                ),
              ),
              Column(children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.primaryLightColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.download_rounded, color: AppColors.primary, size: 16),
                  ),
                ),
                if (p.isNew) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: context.successBgColor, borderRadius: BorderRadius.circular(4)),
                    child: Text('Nouveau', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: context.successTextColor)),
                  ),
                ],
              ]),
            ],
          ),
        );
      },
    );
  }
}

class _ResultsTab extends StatelessWidget {
  const _ResultsTab();

  @override
  Widget build(BuildContext context) {
    final results = [
      _ResultData('Bilan sanguin complet', 'Laboratoire Central', '10 Avril 2025', 'Normal', AppColors.success),
      _ResultData('Électrocardiogramme (ECG)', 'Hôpital Central', '15 Avril 2025', 'Anomalie légère', AppColors.warning),
      _ResultData('Radiographie thoracique', 'CHU Yaoundé', '22 Mars 2025', 'Normal', AppColors.success),
      _ResultData('Bilan lipidique', 'Laboratoire Central', '10 Jan 2025', 'Normal', AppColors.success),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final r = results[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor, width: 1),
          ),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: r.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(13)),
              child: Icon(Icons.biotech_rounded, color: r.statusColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.name, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary)),
              const SizedBox(height: 3),
              Text(r.lab, style: TextStyle(fontSize: 11, color: context.textMuted)),
              const SizedBox(height: 4),
              Text(r.date, style: TextStyle(fontSize: 11, color: context.textMuted)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: r.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(r.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: r.statusColor)),
              ),
              const SizedBox(height: 6),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: context.textMuted),
            ]),
          ]),
        );
      },
    );
  }
}

class _VaccinesTab extends StatelessWidget {
  const _VaccinesTab();

  @override
  Widget build(BuildContext context) {
    final vaccines = [
      _VaccData('COVID-19 (Pfizer)', '3ème dose', 'Mars 2022', true),
      _VaccData('Fièvre jaune', 'Unique', 'Juin 2019', true),
      _VaccData('Hépatite B', 'Série complète', 'Jan 2015', true),
      _VaccData('Tétanos (rappel)', 'Rappel 10 ans', 'Oct 2018', true),
      _VaccData('Grippe saisonnière', 'Annuel', 'Oct 2024', true),
      _VaccData('Méningite ACWY', 'À faire', null, false),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: vaccines.length,
      itemBuilder: (_, i) {
        final v = vaccines[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: v.done ? (context.borderColor) : AppColors.warning.withValues(alpha: 0.4),
              width: v.done ? 1 : 1.5,
            ),
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: (v.done ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(v.done ? Icons.vaccines_rounded : Icons.warning_amber_rounded,
                  color: v.done ? AppColors.success : AppColors.warning, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v.name, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary)),
              const SizedBox(height: 2),
              Text(v.dose, style: TextStyle(fontSize: 11, color: context.textMuted)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              if (v.date != null)
                Text(v.date!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.textSecondary))
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: context.warningBgColor, borderRadius: BorderRadius.circular(6)),
                  child: Text('À planifier', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.warningTextColor)),
                ),
            ]),
          ]),
        );
      },
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary));
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(5)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final String label, value, unit, status;
  final IconData icon;
  final Color color;
  const _VitalCard({required this.label, required this.value, required this.unit, required this.icon, required this.color, required this.status});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: context.textMuted)),
        ]),
        const SizedBox(height: 8),
        RichText(text: TextSpan(children: [
          TextSpan(text: value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          TextSpan(text: ' $unit', style: TextStyle(fontSize: 10, color: context.textMuted)),
        ])),
        const SizedBox(height: 4),
        Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      ]),
    ));
  }
}

class _MedHistoryTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, date, status;
  const _MedHistoryTile({required this.icon, required this.color, required this.title, required this.date, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary)),
          const SizedBox(height: 2),
          Text(date, style: TextStyle(fontSize: 11, color: context.textMuted)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: status == 'Guéri' ? context.successBgColor : context.warningBgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(status, style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: status == 'Guéri' ? context.successTextColor : context.warningTextColor)),
        ),
      ]),
    );
  }
}

class _AllergyTile extends StatelessWidget {
  final String name, severity, reaction;
  const _AllergyTile({required this.name, required this.severity, required this.reaction});

  @override
  Widget build(BuildContext context) {
    final severityColor = severity == 'Sévère' ? AppColors.danger : AppColors.warning;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: severityColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(children: [
        Icon(Icons.warning_rounded, color: severityColor, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary)),
          const SizedBox(height: 2),
          Text(reaction, style: TextStyle(fontSize: 11, color: context.textMuted)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: severityColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(severity, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: severityColor)),
        ),
      ]),
    );
  }
}

class _TreatmentTile extends StatelessWidget {
  final String name, frequency, since, doctor;
  const _TreatmentTile({required this.name, required this.frequency, required this.since, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: const Color(0xFF845EF7).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.medication_rounded, color: Color(0xFF845EF7), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary)),
          const SizedBox(height: 2),
          Text('$frequency · Depuis $since · $doctor',
              style: TextStyle(fontSize: 11, color: context.textMuted)),
        ])),
        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: context.textMuted),
      ]),
    );
  }
}

class _PrescData {
  final String title, doctor, date, count;
  final bool isNew;
  const _PrescData(this.title, this.doctor, this.date, this.count, this.isNew);
}

class _ResultData {
  final String name, lab, date, status;
  final Color statusColor;
  const _ResultData(this.name, this.lab, this.date, this.status, this.statusColor);
}

class _VaccData {
  final String name, dose;
  final String? date;
  final bool done;
  const _VaccData(this.name, this.dose, this.date, this.done);
}
