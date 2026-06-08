import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';

class FavoriteDoctorsScreen extends StatefulWidget {
  const FavoriteDoctorsScreen({super.key});

  @override
  State<FavoriteDoctorsScreen> createState() => _FavoriteDoctorsScreenState();
}

class _FavoriteDoctorsScreenState extends State<FavoriteDoctorsScreen> {
  final List<FavoriteDoctor> _favorites = [
    FavoriteDoctor(
      id: '1',
      name: 'Dr. Kouassi Jean',
      specialty: 'Cardiologue',
      hospital: 'CHU de Cocody',
      rating: 4.8,
      reviewCount: 245,
      experience: '15 ans',
      nextAvailable: DateTime.now().add(const Duration(days: 2)),
      imageUrl: '',
    ),
    FavoriteDoctor(
      id: '2',
      name: 'Dr. Yao Marie',
      specialty: 'Pédiatre',
      hospital: 'Polyclinique Sainte Anne-Marie',
      rating: 4.9,
      reviewCount: 312,
      experience: '12 ans',
      nextAvailable: DateTime.now().add(const Duration(days: 1)),
      imageUrl: '',
    ),
    FavoriteDoctor(
      id: '3',
      name: 'Dr. Traoré Ibrahim',
      specialty: 'Dentiste',
      hospital: 'Cabinet Dentaire Plateau',
      rating: 4.7,
      reviewCount: 189,
      experience: '10 ans',
      nextAvailable: DateTime.now().add(const Duration(hours: 5)),
      imageUrl: '',
    ),
  ];

  void _removeFavorite(String id) {
    setState(() {
      _favorites.removeWhere((doc) => doc.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Retiré des favoris'),
        backgroundColor: AppColors.textMuted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text('Médecins favoris'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 80,
                    color: context.textMutedColor,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Aucun favori',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez vos médecins préférés\npour un accès rapide',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textMutedColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Trouver un médecin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                return _FavoriteDoctorCard(
                  doctor: _favorites[index],
                  onRemove: () => _removeFavorite(_favorites[index].id),
                );
              },
            ),
    );
  }
}

class _FavoriteDoctorCard extends StatelessWidget {
  final FavoriteDoctor doctor;
  final VoidCallback onRemove;

  const _FavoriteDoctorCard({
    required this.doctor,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      doctor.name.substring(4, 5).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              doctor.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: onRemove,
                            icon: const Icon(
                              Icons.favorite_rounded,
                              color: AppColors.danger,
                              size: 22,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialty,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: context.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              doctor.hospital,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${doctor.rating}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                          ),
                          Text(
                            ' (${doctor.reviewCount} avis)',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.primaryLightColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              doctor.experience,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Disponibilité
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  'Disponible ${_formatAvailability(doctor.nextAvailable)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Prendre RDV',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAvailability(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.inHours < 24) {
      return 'aujourd\'hui';
    } else if (diff.inDays == 1) {
      return 'demain';
    } else if (diff.inDays < 7) {
      return 'dans ${diff.inDays} jours';
    } else {
      return 'le ${date.day}/${date.month}';
    }
  }
}

class FavoriteDoctor {
  final String id;
  final String name;
  final String specialty;
  final String hospital;
  final double rating;
  final int reviewCount;
  final String experience;
  final DateTime nextAvailable;
  final String imageUrl;

  FavoriteDoctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.rating,
    required this.reviewCount,
    required this.experience,
    required this.nextAvailable,
    required this.imageUrl,
  });
}
