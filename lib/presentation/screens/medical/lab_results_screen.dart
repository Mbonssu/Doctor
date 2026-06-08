import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';

class LabResultsScreen extends StatefulWidget {
  const LabResultsScreen({super.key});

  @override
  State<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends State<LabResultsScreen> {
  String _selectedFilter = 'Tous';

  final List<String> _filters = ['Tous', 'Récents', 'Anciens', 'Anormaux'];

  final List<LabResult> _results = [
    LabResult(
      id: '1',
      title: 'Bilan sanguin complet',
      date: DateTime.now().subtract(const Duration(days: 2)),
      doctor: 'Dr. Kouassi Jean',
      status: 'Normal',
      tests: [
        TestItem(name: 'Hémoglobine', value: '14.5 g/dL', range: '12-16', isNormal: true),
        TestItem(name: 'Globules blancs', value: '7500 /mm³', range: '4000-10000', isNormal: true),
        TestItem(name: 'Plaquettes', value: '250000 /mm³', range: '150000-400000', isNormal: true),
      ],
    ),
    LabResult(
      id: '2',
      title: 'Glycémie à jeun',
      date: DateTime.now().subtract(const Duration(days: 15)),
      doctor: 'Dr. Yao Marie',
      status: 'Élevé',
      tests: [
        TestItem(name: 'Glucose', value: '1.25 g/L', range: '0.70-1.10', isNormal: false),
      ],
    ),
    LabResult(
      id: '3',
      title: 'Bilan lipidique',
      date: DateTime.now().subtract(const Duration(days: 30)),
      doctor: 'Dr. Kouassi Jean',
      status: 'Normal',
      tests: [
        TestItem(name: 'Cholestérol total', value: '1.80 g/L', range: '<2.00', isNormal: true),
        TestItem(name: 'HDL', value: '0.55 g/L', range: '>0.40', isNormal: true),
        TestItem(name: 'LDL', value: '1.10 g/L', range: '<1.60', isNormal: true),
        TestItem(name: 'Triglycérides', value: '0.90 g/L', range: '<1.50', isNormal: true),
      ],
    ),
    LabResult(
      id: '4',
      title: 'Fonction rénale',
      date: DateTime.now().subtract(const Duration(days: 45)),
      doctor: 'Dr. Yao Marie',
      status: 'Normal',
      tests: [
        TestItem(name: 'Créatinine', value: '9.5 mg/L', range: '7-13', isNormal: true),
        TestItem(name: 'Urée', value: '0.35 g/L', range: '0.15-0.45', isNormal: true),
      ],
    ),
  ];

  List<LabResult> get _filteredResults {
    if (_selectedFilter == 'Tous') return _results;
    if (_selectedFilter == 'Récents') {
      return _results
          .where((r) => r.date.isAfter(DateTime.now().subtract(const Duration(days: 30))))
          .toList();
    }
    if (_selectedFilter == 'Anciens') {
      return _results
          .where((r) => r.date.isBefore(DateTime.now().subtract(const Duration(days: 30))))
          .toList();
    }
    if (_selectedFilter == 'Anormaux') {
      return _results.where((r) => r.status != 'Normal').toList();
    }
    return _results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text('Résultats de laboratoire'),
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
          // Filtres
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedFilter = filter);
                    },
                    backgroundColor: context.surfaceColor,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : context.textSecondary,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : context.borderColor,
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Liste des résultats
          Expanded(
            child: _filteredResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.science_outlined,
                          size: 64,
                          color: context.textMutedColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun résultat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _filteredResults.length,
                    itemBuilder: (context, index) {
                      return _LabResultCard(result: _filteredResults[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LabResultCard extends StatelessWidget {
  final LabResult result;

  const _LabResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => _ResultDetailsSheet(result: result),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getStatusColor(result.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.science_rounded,
                        color: _getStatusColor(result.status),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(result.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(result.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        result.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _getStatusColor(result.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: context.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      result.doctor,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textMuted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${result.tests.length} test${result.tests.length > 1 ? "s" : ""}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: context.textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Normal':
        return AppColors.success;
      case 'Élevé':
      case 'Bas':
        return AppColors.warning;
      case 'Critique':
        return AppColors.danger;
      default:
        return AppColors.textMuted;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Aujourd\'hui';
    if (diff == 1) return 'Hier';
    if (diff < 7) return 'Il y a $diff jours';
    if (diff < 30) return 'Il y a ${(diff / 7).floor()} semaines';
    return 'Il y a ${(diff / 30).floor()} mois';
  }
}

class _ResultDetailsSheet extends StatelessWidget {
  final LabResult result;

  const _ResultDetailsSheet({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: context.bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: context.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${result.date.day}/${result.date.month}/${result.date.year}',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textMuted,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: context.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      result.doctor,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tests
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              itemCount: result.tests.length,
              itemBuilder: (context, index) {
                final test = result.tests[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: test.isNormal
                          ? context.borderColor
                          : AppColors.warning.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            test.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          Icon(
                            test.isNormal
                                ? Icons.check_circle_rounded
                                : Icons.warning_amber_rounded,
                            size: 20,
                            color: test.isNormal
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Valeur',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.textMuted,
                                ),
                              ),
                              Text(
                                test.value,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: test.isNormal
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Plage normale',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.textMuted,
                                ),
                              ),
                              Text(
                                test.range,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Actions
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Partager'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: context.borderColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Télécharger'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LabResult {
  final String id;
  final String title;
  final DateTime date;
  final String doctor;
  final String status;
  final List<TestItem> tests;

  LabResult({
    required this.id,
    required this.title,
    required this.date,
    required this.doctor,
    required this.status,
    required this.tests,
  });
}

class TestItem {
  final String name;
  final String value;
  final String range;
  final bool isNormal;

  TestItem({
    required this.name,
    required this.value,
    required this.range,
    required this.isNormal,
  });
}
