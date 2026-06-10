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
    if (s.contains('derm')) return AppColors.derma;
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
