import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../core/di/app_services.dart';
import '../../../data/models/doctor/doctor_model.dart';
import '../booking/booking_flow_screen.dart';

class FavoriteDoctorsScreen extends StatefulWidget {
  const FavoriteDoctorsScreen({super.key});
  @override
  State<FavoriteDoctorsScreen> createState() => _FavoriteDoctorsScreenState();
}

class _FavoriteDoctorsScreenState extends State<FavoriteDoctorsScreen> {
  List<DoctorModel> _favorites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final list = await AppServices.doctorsRepository.getFavoriteDoctors();
      if (mounted) setState(() { _favorites = list; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _remove(DoctorModel doctor) async {
    final name = _doctorName(doctor);
    // Retirer localement immédiatement (optimistic update)
    setState(() => _favorites.removeWhere((d) => d.id == doctor.id));
    try {
      await AppServices.doctorsRepository.removeFavorite(doctor.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$name retiré des favoris'),
          backgroundColor: context.isDark ? Colors.grey[800] : Colors.grey[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'Annuler', textColor: Colors.white,
            onPressed: () async {
              await AppServices.doctorsRepository.addFavorite(doctor.id);
              _load();
            },
          ),
        ));
      }
    } catch (e) {
      // Remettre en cas d'erreur
      if (mounted) setState(() => _favorites.insert(0, doctor));
    }
  }

  String _doctorName(DoctorModel d) {
    if (d.user == null) return 'Dr. #${d.id}';
    return 'Dr. ${d.user!.firstName} ${d.user!.lastName}';
  }

  String _initials(DoctorModel d) {
    final fn = d.user?.firstName ?? '';
    final ln = d.user?.lastName ?? '';
    return '${fn.isNotEmpty ? fn[0] : ''}${ln.isNotEmpty ? ln[0] : ''}'.toUpperCase();
  }

  static const _colors = [AppColors.cardio, AppColors.neuro, AppColors.pediatrie,
    AppColors.primary, const Color(0xFF845EF7), AppColors.accent];
  Color _color(DoctorModel d) => _colors[d.id % _colors.length];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(child: Column(children: [
        // Header
        Padding(padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Mes favoris', style: TextStyle(fontSize: 22,
                  fontWeight: FontWeight.w800, color: context.textPrimary, letterSpacing: -0.5)),
              if (!_isLoading && _favorites.isNotEmpty)
                Text('${_favorites.length} médecin${_favorites.length > 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 13, color: context.textMuted)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: context.surfaceColor, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.borderColor)),
              child: Row(children: const [
                Icon(Icons.sort_rounded, size: 16, color: AppColors.primary),
                SizedBox(width: 6),
                Text('Trier', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ]),
            ),
          ]),
        ),

        // Body
        Expanded(child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorState(onRetry: _load)
                : _favorites.isEmpty
                    ? _EmptyState()
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          itemCount: _favorites.length,
                          itemBuilder: (_, i) => _FavoriteCard(
                            doctor: _favorites[i],
                            name: _doctorName(_favorites[i]),
                            initials: _initials(_favorites[i]),
                            color: _color(_favorites[i]),
                            onRemove: () => _remove(_favorites[i]),
                            onBook: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => BookingFlowScreen(
                                doctorId: _favorites[i].id,
                                doctorName: _doctorName(_favorites[i]),
                                specialty: _favorites[i].specialty,
                                initials: _initials(_favorites[i]),
                                color: _color(_favorites[i]),
                                price: '${_favorites[i].consultationFee.toInt()} FCFA',
                              ))),
                          ),
                        ),
                      ),
        ),
      ])),
    );
  }
}

// ── FAVORITE CARD ─────────────────────────────────────────────

class _FavoriteCard extends StatelessWidget {
  final DoctorModel doctor;
  final String name, initials;
  final Color color;
  final VoidCallback onRemove, onBook;

  const _FavoriteCard({required this.doctor, required this.name,
    required this.initials, required this.color,
    required this.onRemove, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: context.surfaceColor, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          // Avatar
          Container(width: 58, height: 58,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5)),
            child: Center(child: Text(initials,
                style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)))),
          const SizedBox(width: 14),
          // Info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 3),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                child: Text(doctor.specialty, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color))),
              const SizedBox(width: 6),
              if (doctor.city != null)
                Flexible(child: Text(doctor.city!, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: context.textMuted))),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.warning, size: 13),
              const SizedBox(width: 3),
              Text('${doctor.rating}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.textPrimary)),
              Text(' · ${doctor.totalReviews} avis',
                  style: TextStyle(fontSize: 11, color: context.textMuted)),
              const Spacer(),
              Text('${doctor.consultationFee.toInt()} FCFA',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ]),
          ])),
          // Retirer des favoris
          GestureDetector(
            onTap: onRemove,
            child: Container(width: 36, height: 36, margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.2))),
              child: const Icon(Icons.favorite_rounded, color: AppColors.danger, size: 18)),
          ),
        ])),

        // Disponibilité + bouton
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: context.bgColor, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(width: 8, height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: doctor.isAvailable ? AppColors.success : AppColors.danger)),
            const SizedBox(width: 8),
            Text(doctor.isAvailable ? 'Disponible maintenant' : 'Complet pour le moment',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: doctor.isAvailable ? AppColors.success : AppColors.danger)),
            const Spacer(),
            GestureDetector(
              onTap: doctor.isAvailable ? onBook : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: doctor.isAvailable ? AppColors.primary : context.borderColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Prendre RDV',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: doctor.isAvailable ? Colors.white : context.textMuted)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── STATES ────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 80, height: 80,
        decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.08), shape: BoxShape.circle),
        child: const Icon(Icons.favorite_border_rounded, size: 36, color: AppColors.danger)),
    const SizedBox(height: 16),
    Text('Aucun favori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
    const SizedBox(height: 6),
    Text('Ajoutez des médecins à vos favoris\npour les retrouver ici rapidement.',
        textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: context.textMuted, height: 1.5)),
  ]));
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.wifi_off_rounded, size: 56, color: context.textMuted),
    const SizedBox(height: 12),
    Text('Impossible de charger', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.textPrimary)),
    const SizedBox(height: 20),
    ElevatedButton.icon(onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded), label: const Text('Réessayer'),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
  ]));
}
