// ════════════════════════════════════════════════════════════════
// HEALTH DASHBOARD
// ════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';

class HealthDashboardScreen extends StatelessWidget {
  const HealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final _isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  if (Navigator.canPop(context))
                    GestureDetector(onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_rounded, size: 20)),
                  Expanded(
                    child: Text('Tableau de santé',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                            color: context.textPrimary, letterSpacing: -0.5)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: context.primaryLightColor, borderRadius: BorderRadius.circular(8)),
                    child: const Text('2025', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ]),
              ),
            ),

            // ── Résumé annuel ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF1B54F8), Color(0xFF4D7FFF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Résumé 2025', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 12),
                    const Row(children: [
                      _MiniStat(value: '12', label: 'Consultations'),
                      _MiniStat(value: '4', label: 'Médecins'),
                      _MiniStat(value: '3', label: 'Ordonnances'),
                      _MiniStat(value: '8', label: 'Examens'),
                    ]),
                    const SizedBox(height: 16),
                    Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
                    const SizedBox(height: 14),
                    Row(children: [
                      const Icon(Icons.trending_up_rounded, color: AppColors.accent, size: 16),
                      const SizedBox(width: 8),
                      Text('+2 consultations vs 2024', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                    ]),
                  ]),
                ),
              ),
            ),

            // ── Graphique consultations ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Consultations par mois',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                  const SizedBox(height: 14),
                  Container(
                    height: 160,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.borderColor, width: 1),
                    ),
                    child: _ConsultBarChart(),
                  ),
                ]),
              ),
            ),

            // ── Dépenses médicales ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Dépenses médicales',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.borderColor, width: 1),
                    ),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Total 2025', style: TextStyle(fontSize: 13, color: context.textMuted)),
                        Text('127 500 FCFA',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: context.textPrimary)),
                      ]),
                      const SizedBox(height: 14),
                      ...[
                        _ExpenseRow(label: 'Cardiologie', amount: '45 000 FCFA', percent: 0.35, color: AppColors.cardio),
                        _ExpenseRow(label: 'Analyses & examens', amount: '32 000 FCFA', percent: 0.25, color: const Color(0xFF845EF7)),
                        _ExpenseRow(label: 'Ophtalmologie', amount: '20 000 FCFA', percent: 0.16, color: AppColors.ophtalmo),
                        _ExpenseRow(label: 'Médicaments', amount: '18 500 FCFA', percent: 0.14, color: AppColors.warning),
                        _ExpenseRow(label: 'Autres', amount: '12 000 FCFA', percent: 0.10, color: context.textMuted),
                      ].map((w) => Padding(padding: const EdgeInsets.only(bottom: 10), child: w)),
                    ]),
                  ),
                ]),
              ),
            ),

            // ── Médecins les plus consultés ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Médecins les plus consultés',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                  const SizedBox(height: 14),
                  ...[
                    _DoctorStatRow(initials: 'AT', name: 'Dr. Amine Toure', specialty: 'Cardiologie',
                        visits: 5, color: AppColors.cardio),
                    _DoctorStatRow(initials: 'CF', name: 'Dr. Cécile Fon', specialty: 'Ophtalmologie',
                        visits: 3, color: AppColors.ophtalmo),
                    _DoctorStatRow(initials: 'NB', name: 'Dr. Nathalie Bello', specialty: 'Pédiatrie',
                        visits: 2, color: AppColors.pediatrie),
                  ].map((w) => Padding(padding: const EdgeInsets.only(bottom: 10), child: w)),
                ]),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w400)),
    ]),
  );
}

class _ConsultBarChart extends StatelessWidget {
  final _data = const [1, 2, 0, 1, 3, 2, 1, 0, 2, 1, 3, 2];
  final _months = const ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

  const _ConsultBarChart();

  @override
  Widget build(BuildContext context) {
    final max = _data.reduce((a, b) => a > b ? a : b).toDouble();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_data.length, (i) {
        final h = max > 0 ? (_data[i] / max) : 0.0;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_data[i] > 0)
              Text('${_data[i]}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: context.textMuted)),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: Duration(milliseconds: 300 + i * 50),
              width: 16,
              height: math.max(4, 90 * h),
              decoration: BoxDecoration(
                color: i == DateTime.now().month - 1 ? AppColors.primary : context.primaryLightColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Text(_months[i], style: TextStyle(fontSize: 9, color: context.textMuted)),
          ],
        );
      }),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final String label, amount;
  final double percent;
  final Color color;
  const _ExpenseRow({required this.label, required this.amount, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) => Column(children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.textSecondary)),
      Text(amount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.textPrimary)),
    ]),
    const SizedBox(height: 5),
    ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: percent,
        backgroundColor: color.withValues(alpha: 0.12),
        valueColor: AlwaysStoppedAnimation(color),
        minHeight: 5,
      ),
    ),
  ]);
}

class _DoctorStatRow extends StatelessWidget {
  final String initials, name, specialty;
  final int visits;
  final Color color;
  const _DoctorStatRow({required this.initials, required this.name, required this.specialty, required this.visits, required this.color});

  @override
  Widget build(BuildContext context) {
    // final _isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Row(children: [
        Container(width: 44, height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(initials, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary)),
          Text(specialty, style: TextStyle(fontSize: 11, color: context.textMuted)),
        ])),
        Text('$visits visite${visits > 1 ? 's' : ''}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// FAMILY SCREEN
// ════════════════════════════════════════════════════════════════

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _members = [
    _FamilyMember('Sarah Dupont', 'Épouse', '32 ans', 'A+', AppColors.gyneco, 'SD', '3 RDV cette année'),
    _FamilyMember('Lucas Dupont', 'Fils', '8 ans', 'O+', AppColors.pediatrie, 'LD', '5 RDV cette année'),
    _FamilyMember('Marie Dupont', 'Mère', '62 ans', 'B+', AppColors.danger, 'MD', '7 RDV cette année'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(children: [
              if (Navigator.canPop(context))
                GestureDetector(onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_rounded, size: 20)),
              Expanded(
                child: Text('Ma famille',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                        color: context.textPrimary, letterSpacing: -0.5)),
              ),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Moi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF1B54F8), Color(0xFF4D7FFF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    Container(width: 52, height: 52,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                        child: const Center(child: Text('JD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)))),
                    const SizedBox(width: 14),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Jean Dupont', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      SizedBox(height: 2),
                      Text('Titulaire du compte · 35 ans · O+', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                      child: const Text('Moi', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ),

                const SizedBox(height: 20),
                Text('Membres de la famille',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                const SizedBox(height: 14),

                ..._members.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FamilyMemberCard(member: m),
                )),

                // Ajouter un membre
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showAddMember(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3), width: 2,
                      ),
                      color: context.primaryLightColor,
                    ),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.person_add_rounded, color: AppColors.primary, size: 22),
                      SizedBox(width: 10),
                      Text('Ajouter un proche',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ]),
                  ),
                ),

                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.successBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.success, size: 16),
                    SizedBox(width: 10),
                    Expanded(child: Text(
                      'Vous pouvez gérer les rendez-vous de tous vos proches depuis ce compte. Jusqu\'à 5 membres.',
                      style: TextStyle(fontSize: 12, color: context.successTextColor, height: 1.45),
                    )),
                  ]),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void _showAddMember(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMemberSheet(),
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  final _FamilyMember member;
  const _FamilyMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    // final _isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Column(children: [
        Row(children: [
          Container(width: 52, height: 52,
              decoration: BoxDecoration(color: member.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: member.color.withValues(alpha: 0.25), width: 1.5)),
              child: Center(child: Text(member.initials, style: TextStyle(color: member.color, fontWeight: FontWeight.w800, fontSize: 16)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(member.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 2),
            Text('${member.relation} · ${member.age} · Groupe ${member.bloodGroup}',
                style: TextStyle(fontSize: 11, color: context.textMuted)),
          ])),
          Text(member.stats, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.textMuted)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_month_outlined, size: 14),
            label: const Text('RDV', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.folder_shared_outlined, size: 14),
            label: const Text('Dossier', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )),
        ]),
      ]),
    );
  }
}

class _AddMemberSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final _isDark = context.isDark;
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Ajouter un proche', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary)),
          const SizedBox(height: 20),
          const _SimpleField(label: 'Prénom et nom', hint: 'Sarah Dupont'),
          const SizedBox(height: 14),
          const _SimpleField(label: 'Lien de parenté', hint: 'Épouse, enfant, parent…'),
          const SizedBox(height: 14),
          const _SimpleField(label: 'Date de naissance', hint: 'JJ / MM / AAAA'),
          const SizedBox(height: 28),
          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('Ajouter', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}

class _SimpleField extends StatelessWidget {
  final String label, hint;
  const _SimpleField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.textSecondary)),
    const SizedBox(height: 6),
    TextFormField(decoration: InputDecoration(hintText: hint)),
  ]);
}

class _FamilyMember {
  final String name, relation, age, bloodGroup, initials, stats;
  final Color color;
  const _FamilyMember(this.name, this.relation, this.age, this.bloodGroup, this.color, this.initials, this.stats);
}

// ════════════════════════════════════════════════════════════════
// QR CARD SCREEN
// ════════════════════════════════════════════════════════════════

class QRCardScreen extends StatelessWidget {
  const QRCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
            child: Row(children: [
              IconButton(onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20)),
              const Text('Carte patient', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.ios_share_rounded, color: Colors.white, size: 18),
                ),
              ),
            ]),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Présentez cette carte à l\'accueil',
                      style: TextStyle(color: Colors.white60, fontSize: 13)),
                  const SizedBox(height: 32),
                  // Carte physique
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(0, 16))],
                    ),
                    child: Column(children: [
                      Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF4D7FFF)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('DoctoPing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
                          Text('Carte Patient', style: TextStyle(fontSize: 11, color: context.textMuted)),
                        ]),
                      ]),
                      const SizedBox(height: 24),
                      // QR Code
                      Container(
                        width: 160, height: 160,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.textPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomPaint(painter: _BigQRPainter()),
                      ),
                      const SizedBox(height: 20),
                      Text('Jean Dupont',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.textPrimary)),
                      const SizedBox(height: 6),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _CardBadge(label: 'O+', color: AppColors.danger),
                        const SizedBox(width: 8),
                        _CardBadge(label: 'Allergie: Pénicilline', color: AppColors.warning),
                      ]),
                      const SizedBox(height: 14),
                      Text('ID: DTP-2025-00147',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                              color: context.textMuted, letterSpacing: 1.5)),
                    ]),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Text('Valide jusqu\'au 31/12/2025',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _CardBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CardBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1)),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
  );
}

class _BigQRPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    final rng = math.Random(7);
    final cell = size.width / 12;
    // Finder patterns coins
    for (final offset in [Offset(0, 0), Offset(size.width - 7 * cell, 0), Offset(0, size.height - 7 * cell)]) {
      _drawFinder(canvas, p, offset, cell);
    }
    // Data cells
    for (int r = 0; r < 12; r++) {
      for (int c = 0; c < 12; c++) {
        if (_isInFinder(r, c)) continue;
        if (rng.nextBool()) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(c * cell + 1, r * cell + 1, cell - 2, cell - 2), const Radius.circular(2)),
            p,
          );
        }
      }
    }
  }

  void _drawFinder(Canvas canvas, Paint p, Offset o, double c) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx, o.dy, 7*c, 7*c), const Radius.circular(3)), p);
    final bg = Paint()..color = const Color(0xFF0A1128);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx+c, o.dy+c, 5*c, 5*c), const Radius.circular(2)), bg);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx+2*c, o.dy+2*c, 3*c, 3*c), const Radius.circular(1)), p);
  }

  bool _isInFinder(int r, int c) {
    if (r < 8 && c < 8) return true;
    if (r < 8 && c > 3) return true;
    if (r > 3 && c < 8) return true;
    return false;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
