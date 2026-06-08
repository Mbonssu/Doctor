import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../widgets/shared_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  bool _isLoading = false;
  bool _showResults = false;
  final List<String> _history = ['Cardiologue', 'Dr. Toure', 'Pédiatre Yaoundé'];

  // Filtres
  String? _selectedSpecialty;
  bool _availableToday = false;
  String _sortBy = 'Pertinence';
  double _maxPrice = 30000;
  String _gender = 'Tous';
  String _location = 'Toutes les villes';

  final _specialties = [
    'Cardiologie', 'Neurologie', 'Pédiatrie', 'Ophtalmologie',
    'Dermatologie', 'Gynécologie', 'Orthopédie', 'Généraliste',
    'Pneumologie', 'Gastroentérologie', 'Endocrinologie', 'Rhumatologie',
  ];

  final _results = [
    _SearchResult('Dr. Amine Toure', 'Cardiologie', 4.9, 128, '15 000 FCFA', true, 'AT', AppColors.cardio, 'Hôpital Central'),
    _SearchResult('Dr. Alice Kamga', 'Cardiologie', 4.7, 54, '12 000 FCFA', true, 'AK', AppColors.cardio, 'Clinique Élite'),
    _SearchResult('Dr. Nathalie Bello', 'Pédiatrie', 4.8, 96, '10 000 FCFA', true, 'NB', AppColors.pediatrie, 'Clinique La Paix'),
    _SearchResult('Dr. Paul Mbarga', 'Neurologie', 4.7, 74, '18 000 FCFA', false, 'PM', AppColors.neuro, 'CHU Yaoundé'),
    _SearchResult('Dr. Cécile Fon', 'Ophtalmologie', 4.9, 112, '10 000 FCFA', true, 'CF', AppColors.ophtalmo, 'Clinique Élite'),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _showResults = false);
      return;
    }
    setState(() { _isLoading = true; _showResults = false; });
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() { _isLoading = false; _showResults = true; });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                    ),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: context.borderColor,
                            width: 1.5),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        autofocus: true,
                        onChanged: _search,
                        onSubmitted: (q) {
                          if (q.isNotEmpty) {
                            setState(() => _history.insert(0, q));
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Médecin, spécialité, symptôme…',
                          prefixIcon: Icon(Icons.search_rounded,
                              color: context.textMuted, size: 20),
                          suffixIcon: _ctrl.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close_rounded,
                                      size: 18, color: context.textMuted),
                                  onPressed: () {
                                    _ctrl.clear();
                                    setState(() => _showResults = false);
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Bouton filtres
                  GestureDetector(
                    onTap: () => _showFilters(context),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _hasFilters ? AppColors.primary : (context.surfaceColor),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: _hasFilters ? AppColors.primary : (context.borderColor),
                            width: 1.5),
                      ),
                      child: Icon(Icons.tune_rounded,
                          size: 20,
                          color: _hasFilters ? Colors.white : context.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            // ── Filtres actifs ──
            if (_hasFilters)
              SizedBox(
                height: 38,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (_selectedSpecialty != null)
                      _ActiveFilter(
                          label: _selectedSpecialty!,
                          onRemove: () => setState(() => _selectedSpecialty = null)),
                    if (_availableToday)
                      _ActiveFilter(
                          label: 'Dispo aujourd\'hui',
                          onRemove: () => setState(() => _availableToday = false)),
                    if (_maxPrice < 30000)
                      _ActiveFilter(
                          label: '≤ ${_maxPrice.toInt()} FCFA',
                          onRemove: () => setState(() => _maxPrice = 30000)),
                    if (_gender != 'Tous')
                      _ActiveFilter(
                          label: _gender,
                          onRemove: () => setState(() => _gender = 'Tous')),
                    if (_location != 'Toutes les villes')
                      _ActiveFilter(
                          label: _location,
                          onRemove: () => setState(() => _location = 'Toutes les villes')),
                  ],
                ),
              ),

            // ── Contenu ──
            Expanded(
              child: _isLoading
                  ? _LoadingList()
                  : _showResults
                      ? _ResultsList(results: _results)
                      : _HistoryAndSuggestions(
                          history: _history,
                          specialties: _specialties,
                          onTap: (q) {
                            _ctrl.text = q;
                            _search(q);
                          },
                          onClearHistory: () => setState(() => _history.clear()),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasFilters =>
      _selectedSpecialty != null ||
      _availableToday ||
      _maxPrice < 30000 ||
      _gender != 'Tous' ||
      _location != 'Toutes les villes';

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FiltersSheet(
        specialty: _selectedSpecialty,
        availableToday: _availableToday,
        maxPrice: _maxPrice,
        gender: _gender,
        location: _location,
        specialties: _specialties,
        sortBy: _sortBy,
        onApply: (spec, avail, price, gen, loc, sort) {
          setState(() {
            _selectedSpecialty = spec;
            _availableToday = avail;
            _maxPrice = price;
            _gender = gen;
            _location = loc;
            _sortBy = sort;
          });
          Navigator.pop(context);
          if (_ctrl.text.isNotEmpty) _search(_ctrl.text);
        },
      ),
    );
  }
}

// ── Widgets internes ───────────────────────────────────────────

class _ActiveFilter extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilter({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.primaryLightColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.primary100Color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: const [
        SkeletonDoctorCard(),
        SkeletonDoctorCard(),
        SkeletonDoctorCard(),
      ],
    );
  }
}

class _ResultsList extends StatelessWidget {
  final List<_SearchResult> results;

  const _ResultsList({required this.results});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.person_search_rounded,
        title: 'Aucun résultat',
        subtitle: 'Essayez un autre terme\nou modifiez vos filtres.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final r = results[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: context.borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: r.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: r.color.withValues(alpha: 0.25), width: 1.5),
                ),
                child: Center(
                    child: Text(r.initials,
                        style: TextStyle(color: r.color, fontWeight: FontWeight.w800, fontSize: 16))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
                    const SizedBox(height: 3),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: r.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(r.specialty,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: r.color)),
                      ),
                      const SizedBox(width: 6),
                      Text(r.location,
                          style: TextStyle(fontSize: 10, color: context.textMuted)),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 12),
                      const SizedBox(width: 3),
                      Text('${r.rating}',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700, color: context.textPrimary)),
                      Text(' (${r.reviews})',
                          style: TextStyle(fontSize: 10, color: context.textMuted)),
                      const Spacer(),
                      Text(r.price,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: r.available ? AppColors.success : AppColors.danger,
                  ),
                ),
                const SizedBox(height: 4),
                Text(r.available ? 'Dispo' : 'Complet',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: r.available ? AppColors.success : AppColors.danger)),
              ]),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryAndSuggestions extends StatelessWidget {
  final List<String> history;
  final List<String> specialties;
  final void Function(String) onTap;
  final VoidCallback onClearHistory;

  const _HistoryAndSuggestions({
    required this.history,
    required this.specialties,
    required this.onTap,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Historique
        if (history.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recherches récentes',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
              GestureDetector(
                onTap: onClearHistory,
                child: const Text('Effacer',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...history.map((h) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.history_rounded, color: context.textMuted, size: 20),
                title: Text(h, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: Icon(Icons.north_west_rounded, size: 14, color: context.textMuted),
                onTap: () => onTap(h),
              )),
          const SizedBox(height: 20),
        ],

        // Spécialités populaires
        Text('Spécialités populaires',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: specialties.map((s) => GestureDetector(
            onTap: () => onTap(s),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Text(s,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500, color: context.textSecondary)),
            ),
          )).toList(),
        ),

        const SizedBox(height: 24),
        // Symptômes fréquents
        Text('Symptômes fréquents',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
        const SizedBox(height: 12),
        ...['Maux de tête', 'Douleur thoracique', 'Fièvre persistante',
            'Problèmes de vision', 'Douleur articulaire', 'Grossesse']
            .map((s) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.primaryLightColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.medical_information_outlined,
                        size: 16, color: AppColors.primary),
                  ),
                  title: Text(s,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: context.textMuted),
                  onTap: () => onTap(s),
                )),
      ],
    );
  }
}

// ── Filters Bottom Sheet ───────────────────────────────────────

class _FiltersSheet extends StatefulWidget {
  final String? specialty;
  final bool availableToday;
  final double maxPrice;
  final String gender;
  final String location;
  final String sortBy;
  final List<String> specialties;
  final void Function(String?, bool, double, String, String, String) onApply;

  const _FiltersSheet({
    required this.specialty,
    required this.availableToday,
    required this.maxPrice,
    required this.gender,
    required this.location,
    required this.sortBy,
    required this.specialties,
    required this.onApply,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late String? _specialty;
  late bool _available;
  late double _price;
  late String _gender;
  late String _location;
  late String _sort;

  final _cities = ['Toutes les villes', 'Yaoundé', 'Douala', 'Bafoussam', 'Garoua', 'Maroua'];
  final _sorts = ['Pertinence', 'Mieux notés', 'Prix croissant', 'Disponibles d\'abord'];

  @override
  void initState() {
    super.initState();
    _specialty = widget.specialty;
    _available = widget.availableToday;
    _price = widget.maxPrice;
    _gender = widget.gender;
    _location = widget.location;
    _sort = widget.sortBy;
  }

  @override
  Widget build(BuildContext context) {

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle + header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filtres avancés',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary)),
                      TextButton(
                        onPressed: () => setState(() {
                          _specialty = null; _available = false;
                          _price = 30000; _gender = 'Tous';
                          _location = 'Toutes les villes'; _sort = 'Pertinence';
                        }),
                        child: const Text('Réinitialiser',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.all(24),
                children: [
                  // Tri
                  _FilterSection(title: 'Trier par'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _sorts.map((s) => _Chip(
                      label: s,
                      selected: _sort == s,
                      onTap: () => setState(() => _sort = s),
                    )).toList(),
                  ),
                  const SizedBox(height: 22),

                  // Dispo aujourd'hui
                  _FilterSection(title: 'Disponibilité'),
                  const SizedBox(height: 12),
                  _ToggleRow(
                    label: 'Disponible aujourd\'hui',
                    value: _available,
                    onChanged: (v) => setState(() => _available = v),
                  ),
                  const SizedBox(height: 22),

                  // Ville
                  _FilterSection(title: 'Ville'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _cities.map((c) => _Chip(
                      label: c,
                      selected: _location == c,
                      onTap: () => setState(() => _location = c),
                    )).toList(),
                  ),
                  const SizedBox(height: 22),

                  // Tarif max
                  _FilterSection(title: 'Tarif maximum : ${_price.toInt()} FCFA'),
                  Slider(
                    value: _price,
                    min: 5000, max: 30000, divisions: 25,
                    onChanged: (v) => setState(() => _price = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('5 000 FCFA', style: TextStyle(fontSize: 11, color: context.textMuted)),
                      Text('30 000 FCFA', style: TextStyle(fontSize: 11, color: context.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Genre médecin
                  _FilterSection(title: 'Genre du médecin'),
                  const SizedBox(height: 12),
                  Row(
                    children: ['Tous', 'Homme', 'Femme'].map((g) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _Chip(label: g, selected: _gender == g, onTap: () => setState(() => _gender = g)),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 22),

                  // Spécialité
                  _FilterSection(title: 'Spécialité'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      _Chip(label: 'Toutes', selected: _specialty == null, onTap: () => setState(() => _specialty = null)),
                      ...widget.specialties.map((s) => _Chip(
                        label: s,
                        selected: _specialty == s,
                        onTap: () => setState(() => _specialty = s),
                      )),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Bouton appliquer
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => widget.onApply(_specialty, _available, _price, _gender, _location, _sort),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Appliquer les filtres',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  const _FilterSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary));
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: 1.5),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : context.textSecondary)),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.textPrimary)),
        const Spacer(),
        Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
      ],
    );
  }
}

class _SearchResult {
  final String name, specialty, price, initials, location;
  final double rating;
  final int reviews;
  final bool available;
  final Color color;

  const _SearchResult(this.name, this.specialty, this.rating, this.reviews,
      this.price, this.available, this.initials, this.color, this.location);
}
