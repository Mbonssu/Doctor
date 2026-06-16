import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/di/app_services.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../data/models/doctor/doctor_model.dart';
import '../doctors/doctor_detail_screen.dart';
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

  List<DoctorModel> _results = [];
  String? _errorMessage;
  Timer? _debounce;

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _showResults = false; _results = []; _errorMessage = null; });
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      setState(() { _isLoading = true; _showResults = false; _errorMessage = null; });
      try {
        final resp = await AppServices.doctorsRepository.searchDoctors(
          query: query.trim(),
          specialty: _selectedSpecialty,
          isAvailable: _availableToday,
        );
        if (!mounted) return;
        setState(() { _results = resp.doctors; _isLoading = false; _showResults = true; });
      } on ApiException catch (e) {
        if (!mounted) return;
        setState(() { _errorMessage = e.displayMessage; _isLoading = false; _showResults = true; });
      } catch (_) {
        if (!mounted) return;
        setState(() { _errorMessage = 'Erreur de connexion'; _isLoading = false; _showResults = true; });
      }
    });
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
                      ? _ResultsList(results: _results, error: _errorMessage)
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Historique
          if (history.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recherches récentes',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: onClearHistory,
                  child: Text(
                    'Effacer',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: history.map((item) {
                return GestureDetector(
                  onTap: () => onTap(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: context.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 14,
                          color: context.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Suggestions par spécialité
          Text(
            'Suggestions par spécialité',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: specialties.map((spec) {
              return GestureDetector(
                onTap: () => onTap(spec),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.accent.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.medical_services_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        spec,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  final String? specialty;
  final bool availableToday;
  final double maxPrice;
  final String gender;
  final String location;
  final List<String> specialties;
  final String sortBy;
  final void Function(String?, bool, double, String, String, String) onApply;

  const _FiltersSheet({
    required this.specialty,
    required this.availableToday,
    required this.maxPrice,
    required this.gender,
    required this.location,
    required this.specialties,
    required this.sortBy,
    required this.onApply,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late String? _selectedSpecialty;
  late bool _availableToday;
  late double _maxPrice;
  late String _gender;
  late String _location;
  late String _sortBy;

  final _genders = ['Tous', 'Homme', 'Femme'];
  final _locations = ['Toutes les villes', 'Yaoundé', 'Douala', 'Garoua', 'Bafoussam', 'Bamenda'];
  final _sortOptions = ['Pertinence', 'Note', 'Expérience', 'Prix croissant', 'Prix décroissant'];

  @override
  void initState() {
    super.initState();
    _selectedSpecialty = widget.specialty;
    _availableToday = widget.availableToday;
    _maxPrice = widget.maxPrice;
    _gender = widget.gender;
    _location = widget.location;
    _sortBy = widget.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtres',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSpecialty = null;
                      _availableToday = false;
                      _maxPrice = 30000;
                      _gender = 'Tous';
                      _location = 'Toutes les villes';
                      _sortBy = 'Pertinence';
                    });
                  },
                  child: Text(
                    'Tout réinitialiser',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spécialité
                  _FilterSection(
                    title: 'Spécialité',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: widget.specialties.map((spec) {
                        final isSelected = _selectedSpecialty == spec;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedSpecialty = isSelected ? null : spec;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : context.surfaceColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : context.borderColor,
                                width: isSelected ? 0 : 1,
                              ),
                            ),
                            child: Text(
                              spec,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : context.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Disponibilité
                  _FilterSection(
                    title: 'Disponibilité',
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(
                            () => _availableToday = !_availableToday,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _availableToday
                                  ? AppColors.primary
                                  : context.surfaceColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _availableToday
                                    ? AppColors.primary
                                    : context.borderColor,
                                width: _availableToday ? 0 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.today_rounded,
                                  size: 18,
                                  color: _availableToday
                                      ? Colors.white
                                      : context.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Disponible aujourd\'hui',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _availableToday
                                        ? Colors.white
                                        : context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Prix max
                  _FilterSection(
                    title: 'Prix maximum : ${_maxPrice.toInt()} FCFA',
                    child: Slider(
                      value: _maxPrice,
                      min: 5000,
                      max: 30000,
                      divisions: 10,
                      activeColor: AppColors.primary,
                      label: '${_maxPrice.toInt()} FCFA',
                      onChanged: (v) => setState(() => _maxPrice = v),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Genre
                  _FilterSection(
                    title: 'Genre du médecin',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _genders.map((g) {
                        final isSelected = _gender == g;
                        return GestureDetector(
                          onTap: () => setState(() => _gender = g),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : context.surfaceColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : context.borderColor,
                                width: isSelected ? 0 : 1,
                              ),
                            ),
                            child: Text(
                              g,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : context.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Localisation
                  _FilterSection(
                    title: 'Localisation',
                    child: DropdownButtonFormField<String>(
                      value: _location,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: context.surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                      ),
                      items: _locations.map((loc) {
                        return DropdownMenuItem(
                          value: loc,
                          child: Text(loc),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _location = v!),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Trier par
                  _FilterSection(
                    title: 'Trier par',
                    child: DropdownButtonFormField<String>(
                      value: _sortBy,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: context.surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                      ),
                      items: _sortOptions.map((opt) {
                        return DropdownMenuItem(
                          value: opt,
                          child: Text(opt),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _sortBy = v!),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bouton Appliquer
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              border: Border(
                top: BorderSide(color: context.borderColor, width: 1),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(
                    _selectedSpecialty,
                    _availableToday,
                    _maxPrice,
                    _gender,
                    _location,
                    _sortBy,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Appliquer les filtres',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
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
  final List<DoctorModel> results;
  final String? error;
  const _ResultsList({required this.results, this.error});

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: context.textMuted),
          const SizedBox(height: 12),
          Text(error!, textAlign: TextAlign.center,
              style: TextStyle(color: context.textMuted, fontSize: 14)),
        ]),
      ));
    }
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
      itemBuilder: (_, i) => _DoctorResultCard(doctor: results[i]),
    );
  }
}

class _DoctorResultCard extends StatelessWidget {
  final DoctorModel doctor;
  const _DoctorResultCard({required this.doctor});

  String _initials() {
    final f = (doctor.user?.firstName ?? '').trim();
    final l = (doctor.user?.lastName ?? '').trim();
    final s = '${f.isNotEmpty ? f[0] : ''}${l.isNotEmpty ? l[0] : ''}';
    return s.isNotEmpty ? s.toUpperCase() : 'DR';
  }

  Color _color() {
    final s = doctor.specialty.toLowerCase();
    if (s.contains('cardio')) return AppColors.cardio;
    if (s.contains('neuro')) return AppColors.neuro;
    if (s.contains('pédia') || s.contains('pedia')) return AppColors.pediatrie;
    if (s.contains('opht')) return AppColors.ophtalmo;
    if (s.contains('derm')) return AppColors.dermato;
    if (s.contains('gyn')) return AppColors.gyneco;
    if (s.contains('ortho')) return AppColors.ortho;
    return AppColors.primary;
  }

  String _price() {
    final raw = doctor.consultationFee.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      buf.write(raw[i]);
      final right = raw.length - i - 1;
      if (right > 0 && right % 3 == 0) buf.write(' ');
    }
    return '${buf.toString()} FCFA';
  }

  String _location() {
    final h = doctor.hospitalName?.trim();
    final c = doctor.city?.trim();
    if (h != null && h.isNotEmpty && c != null && c.isNotEmpty) return '$h, $c';
    if (h != null && h.isNotEmpty) return h;
    if (c != null && c.isNotEmpty) return c;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final fullName = doctor.user?.fullName.trim();
    final name = (fullName != null && fullName.isNotEmpty) ? 'Dr. $fullName' : 'Dr. #${doctor.id}';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => DoctorDetailScreen(
          id: doctor.id,
          name: name,
          specialty: doctor.specialty,
          initials: _initials(),
          color: color,
          price: _price(),
          rating: doctor.rating,
          reviews: doctor.totalReviews,
          experience: '${doctor.yearsOfExperience} ans d\'exp.',
          available: doctor.isAvailable,
        ),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor, width: 1),
        ),
        child: Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Center(child: Text(_initials(),
                style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 3),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                child: Text(doctor.specialty,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
              ),
              const SizedBox(width: 6),
              Flexible(child: Text(_location(),
                  style: TextStyle(fontSize: 10, color: context.textMuted), overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.warning, size: 12),
              const SizedBox(width: 3),
              Text('${doctor.rating}', style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: context.textPrimary)),
              Text(' (${doctor.totalReviews})', style: TextStyle(fontSize: 10, color: context.textMuted)),
              const Spacer(),
              Text(_price(), style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ]),
          ])),
          const SizedBox(width: 10),
          Column(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: doctor.isAvailable ? AppColors.success : AppColors.danger,
            )),
            const SizedBox(height: 4),
            Text(doctor.isAvailable ? 'Dispo' : 'Complet',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                    color: doctor.isAvailable ? AppColors.success : AppColors.danger)),
          ]),
        ]),
      ),
    );
  }

  
}
