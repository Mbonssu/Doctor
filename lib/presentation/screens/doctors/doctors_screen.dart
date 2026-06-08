import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/di/app_services.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../core/utils/modal_utils.dart';
import '../../../data/models/doctor/doctor_model.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  int _selectedSpecialty = 0;
  int _sortBy = 0;
  final _searchCtrl = TextEditingController();
  Timer? _searchDebounce;
  bool _isLoading = true;
  String? _errorMessage;

  final _specialties = [
    'Tous',
    'Cardiologie',
    'Neurologie',
    'Pédiatrie',
    'Ophtalmologie',
    'Dermatologie',
    'Gynécologie',
    'Orthopédie',
    'Généraliste',
  ];

  List<_DoctorData> _doctors = const [];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_DoctorData> get _filteredDoctors {
    var list = List<_DoctorData>.from(_doctors);
    if (_sortBy == 1) list.sort((a, b) => b.rating.compareTo(a.rating));
    if (_sortBy == 2) list = list.where((d) => d.available).toList();
    return list;
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final specialty = _selectedSpecialty == 0
          ? null
          : _specialties[_selectedSpecialty];
      final response = await AppServices.doctorsRepository.searchDoctors(
        query: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
        specialty: specialty,
        page: 1,
        pageSize: 100,
      );

      if (!mounted) return;
      setState(() {
        _doctors = response.doctors.map(_mapDoctor).toList();
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger les médecins.';
      });
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), _fetchDoctors);
  }

  _DoctorData _mapDoctor(DoctorModel doctor) {
    final fullName = doctor.user?.fullName.trim();
    final name = (fullName != null && fullName.isNotEmpty)
        ? 'Dr. $fullName'
        : 'Dr. #${doctor.id}';
    final specialty = doctor.specialty;
    final initials = _initialsFromName(
      doctor.user?.firstName,
      doctor.user?.lastName,
    );

    return _DoctorData(
      id: doctor.id,
      name: name,
      specialty: specialty,
      rating: doctor.rating,
      reviews: doctor.totalReviews,
      price: _formatPrice(doctor.consultationFee),
      available: doctor.isAvailable,
      initials: initials,
      color: _colorForSpecialty(specialty),
      experience: '${doctor.yearsOfExperience} ans d\'exp.',
      location: _locationForDoctor(doctor),
    );
  }

  String _locationForDoctor(DoctorModel doctor) {
    final hospital = doctor.hospitalName?.trim();
    final city = doctor.city?.trim();
    if (hospital != null &&
        hospital.isNotEmpty &&
        city != null &&
        city.isNotEmpty) {
      return '$hospital, $city';
    }
    if (hospital != null && hospital.isNotEmpty) {
      return hospital;
    }
    if (city != null && city.isNotEmpty) {
      return city;
    }
    return 'Localisation non renseignée';
  }

  String _formatPrice(double fee) {
    final rounded = fee.round();
    final raw = rounded.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      buffer.write(raw[i]);
      final rightCount = raw.length - i - 1;
      if (rightCount > 0 && rightCount % 3 == 0) {
        buffer.write(' ');
      }
    }
    return '${buffer.toString()} FCFA';
  }

  String _initialsFromName(String? firstName, String? lastName) {
    final first = (firstName ?? '').trim();
    final last = (lastName ?? '').trim();
    final initials =
        '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}';
    return initials.isNotEmpty ? initials.toUpperCase() : 'DR';
  }

  Color _colorForSpecialty(String specialty) {
    final normalized = specialty.toLowerCase();
    if (normalized.contains('cardio')) {
      return AppColors.cardio;
    }
    if (normalized.contains('neuro')) {
      return AppColors.neuro;
    }
    if (normalized.contains('pédia') || normalized.contains('pedia')) {
      return AppColors.pediatrie;
    }
    if (normalized.contains('opht')) {
      return AppColors.ophtalmo;
    }
    if (normalized.contains('derma')) {
      return AppColors.dermato;
    }
    if (normalized.contains('gyn')) {
      return AppColors.gyneco;
    }
    if (normalized.contains('ortho')) {
      return AppColors.ortho;
    }
    if (normalized.contains('génér') || normalized.contains('gener')) {
      return AppColors.generale;
    }
    return AppColors.primary;
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
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              color: context.bgColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Trouver un médecin',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      // Tri
                      GestureDetector(
                        onTap: () => _showSortModal(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: context.borderColor,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.sort_rounded,
                            size: 20,
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Recherche
                  Container(
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: context.borderColor,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Nom, spécialité…',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: context.textMuted,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filtres spécialités
            SizedBox(
              height: 44,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                scrollDirection: Axis.horizontal,
                itemCount: _specialties.length,
                itemBuilder: (context, i) {
                  final isSelected = i == _selectedSpecialty;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedSpecialty = i);
                      _fetchDoctors();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (context.surfaceColor),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (context.borderColor),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _specialties[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : context.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Compte résultats
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
              child: Row(
                children: [
                  Text(
                    '${_filteredDoctors.length} médecin${_filteredDoctors.length > 1 ? 's' : ''} trouvé${_filteredDoctors.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.textMuted,
                    ),
                  ),
                  const Spacer(),
                  if (_sortBy > 0)
                    GestureDetector(
                      onTap: () => setState(() => _sortBy = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.primaryLightColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _sortBy == 1 ? 'Mieux notés' : 'Disponibles',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Liste médecins
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? _DoctorsErrorState(
                      message: _errorMessage!,
                      onRetry: _fetchDoctors,
                    )
                  : _filteredDoctors.isEmpty
                  ? _EmptyState(
                      message: _searchCtrl.text.trim().isEmpty
                          ? 'Aucun médecin disponible pour le moment'
                          : 'Aucun médecin trouvé pour cette recherche',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      itemCount: _filteredDoctors.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _DoctorTile(doctor: _filteredDoctors[i]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortModal() {
    ModalUtils.showBlurredBottomSheet(
      context: context,
      builder: (_) => _SortModal(
        selected: _sortBy,
        onSelect: (v) {
          setState(() => _sortBy = v);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _DoctorData {
  final int id;
  final String name, specialty, price, initials, experience, location;
  final double rating;
  final int reviews;
  final bool available;
  final Color color;

  const _DoctorData({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.available,
    required this.initials,
    required this.color,
    required this.experience,
    required this.location,
  });
}

class _DoctorTile extends StatelessWidget {
  final _DoctorData doctor;

  const _DoctorTile({required this.doctor});

  @override
  Widget build(BuildContext context) {
    // final _isDark = context.isDark;

    return GestureDetector(
      onTap: () => _showDoctorDetail(context, doctor),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.borderColor, width: 1),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: doctor.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: doctor.color.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      doctor.initials,
                      style: TextStyle(
                        color: doctor.color,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: doctor.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              doctor.specialty,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: doctor.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            doctor.experience,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: context.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Dispo
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: doctor.available
                        ? AppColors.success
                        : AppColors.danger,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (doctor.available
                                    ? AppColors.success
                                    : AppColors.danger)
                                .withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Ligne séparatrice
            Container(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color: context.textMuted,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    doctor.location,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: context.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.warning,
                  size: 14,
                ),
                const SizedBox(width: 3),
                Text(
                  '${doctor.rating}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                Text(
                  ' (${doctor.reviews})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: context.textMuted,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  doctor.price,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDoctorDetail(BuildContext context, _DoctorData doc) {
    ModalUtils.showBlurredBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DoctorDetailSheet(doctor: doc),
    );
  }
}

class _DoctorDetailSheet extends StatefulWidget {
  final _DoctorData doctor;
  const _DoctorDetailSheet({required this.doctor});

  @override
  State<_DoctorDetailSheet> createState() => _DoctorDetailSheetState();
}

class _DoctorDetailSheetState extends State<_DoctorDetailSheet> {
  int _selectedDay = 0;
  int _selectedSlot = -1;

  final _days = ['Lun 19', 'Mar 20', 'Mer 21', 'Jeu 22', 'Ven 23'];
  final _slots = [
    '08h00',
    '08h30',
    '09h00',
    '09h30',
    '10h00',
    '10h30',
    '14h00',
    '14h30',
    '15h00',
    '15h30',
  ];

  @override
  Widget build(BuildContext context) {
    // final _isDark = context.isDark;
    final doc = widget.doctor;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          controller: scrollCtrl,
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Entête médecin
                    Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: doc.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: doc.color.withValues(alpha: 0.25),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              doc.initials,
                              style: TextStyle(
                                color: doc.color,
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: context.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doc.specialty,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: doc.color,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.warning,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${doc.rating} · ${doc.reviews} avis',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Bouton favori
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.dangerLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.favorite_border_rounded,
                              color: AppColors.danger,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Infos stats
                    Row(
                      children: [
                        _InfoPill(
                          icon: Icons.work_history_rounded,
                          label: doc.experience,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        _InfoPill(
                          icon: Icons.location_on_outlined,
                          label: doc.location,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 10),
                        _InfoPill(
                          icon: Icons.payments_outlined,
                          label: doc.price,
                          color: const Color(0xFF845EF7),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Bio
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'À propos',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${doc.name} est spécialiste en ${doc.specialty} avec ${doc.experience}. Diplômé de la Faculté de Médecine de Yaoundé, il/elle exerce actuellement à ${doc.location} et prend en charge des patients de tous âges dans le cadre de consultations régulières et de suivis spécialisés.',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Sélection du jour
                    Text(
                      'Choisir un jour',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 62,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _days.length,
                        itemBuilder: (_, i) {
                          final sel = i == _selectedDay;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedDay = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.primary
                                    : (context.cardColor),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: sel
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _days[i].split(' ')[0],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: sel
                                          ? Colors.white70
                                          : context.textMuted,
                                    ),
                                  ),
                                  Text(
                                    _days[i].split(' ')[1],
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: sel
                                          ? Colors.white
                                          : context.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Créneaux horaires
                    Text(
                      'Créneaux disponibles',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(_slots.length, (i) {
                        final sel = i == _selectedSlot;
                        final unavail = i == 3 || i == 7;
                        return GestureDetector(
                          onTap: unavail
                              ? null
                              : () => setState(() => _selectedSlot = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: unavail
                                  ? (context.cardColor)
                                  : sel
                                  ? AppColors.primary
                                  : (context.cardColor),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: unavail
                                    ? Colors.transparent
                                    : sel
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              _slots[i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: unavail
                                    ? context.textMuted
                                    : sel
                                    ? Colors.white
                                    : context.textPrimary,
                                decoration: unavail
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 32),

                    // Bouton réservation
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedSlot >= 0
                            ? () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'RDV confirmé avec ${doc.name} le ${_days[_selectedDay]} à ${_slots[_selectedSlot]}',
                                    ),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _selectedSlot >= 0
                              ? 'Confirmer le RDV · ${_slots[_selectedSlot]}'
                              : 'Sélectionnez un créneau',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortModal extends StatelessWidget {
  final int selected;
  final void Function(int) onSelect;

  const _SortModal({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    // final _isDark = context.isDark;
    final options = [
      {'label': 'Par défaut', 'icon': Icons.sort_rounded},
      {'label': 'Mieux notés en premier', 'icon': Icons.star_rounded},
      {
        'label': 'Disponibles uniquement',
        'icon': Icons.check_circle_outline_rounded,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Trier par',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(options.length, (i) {
            final isSelected = i == selected;
            return GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.primaryLightColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      options[i]['icon'] as IconData,
                      size: 20,
                      color: isSelected
                          ? AppColors.primary
                          : context.textSecondary,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      options[i]['label'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : context.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.primaryLightColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun médecin trouvé',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.textMuted),
          ),
        ],
      ),
    );
  }
}

class _DoctorsErrorState extends StatelessWidget {
  const _DoctorsErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 42,
              color: AppColors.danger,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: context.textSecondary),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
