import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  String _selectedCategory = 'Tous';

  final _locations = [
    _Location('Hôpital Central', 'Hôpital', 'Avenue de la République', 4.8, 245, AppColors.danger),
    _Location('Dr. Amine Toure', 'Cardiologue', 'Cabinet Médical Central', 4.9, 128, AppColors.cardio),
    _Location('Clinique du Soleil', 'Clinique', 'Rue des Palmiers', 4.7, 189, AppColors.accent),
    _Location('Dr. Nathalie Bello', 'Pédiatre', 'Centre Médical Enfants', 4.8, 96, AppColors.pediatrie),
    _Location('Pharmacie de la Paix', 'Pharmacie', 'Boulevard de la Liberté', 4.6, 78, AppColors.success),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredLocations = _selectedCategory == 'Tous'
        ? _locations
        : _locations.where((l) => l.type == _selectedCategory).toList();

    return Scaffold(
      body: Stack(
        children: [
          // Map placeholder
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.accent.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Carte interactive',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Intégration Google Maps à venir',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textMutedColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Search bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Rechercher un lieu...',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.textMutedColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Filters
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _CategoryChip(
                          label: 'Tous',
                          icon: Icons.apps_rounded,
                          isSelected: _selectedCategory == 'Tous',
                          onTap: () => setState(() => _selectedCategory = 'Tous'),
                        ),
                        _CategoryChip(
                          label: 'Hôpitaux',
                          icon: Icons.local_hospital_rounded,
                          isSelected: _selectedCategory == 'Hôpital',
                          onTap: () => setState(() => _selectedCategory = 'Hôpital'),
                        ),
                        _CategoryChip(
                          label: 'Médecins',
                          icon: Icons.medical_services_rounded,
                          isSelected: _selectedCategory == 'Cardiologue',
                          onTap: () => setState(() => _selectedCategory = 'Cardiologue'),
                        ),
                        _CategoryChip(
                          label: 'Pharmacies',
                          icon: Icons.medication_rounded,
                          isSelected: _selectedCategory == 'Pharmacie',
                          onTap: () => setState(() => _selectedCategory = 'Pharmacie'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.15,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filteredLocations.length} résultats',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: context.textPrimary,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.tune_rounded, size: 20),
                          ),
                        ],
                      ),
                    ),

                    // List
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        itemCount: filteredLocations.length,
                        itemBuilder: (context, index) {
                          final location = filteredLocations[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _LocationCard(location: location),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // My location button
          Positioned(
            right: 20,
            bottom: 300,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: context.surfaceColor,
              child: const Icon(
                Icons.my_location_rounded,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : context.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : context.textSecondaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : context.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final _Location location;

  const _LocationCard({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: location.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: location.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${location.type} · ${location.address}',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 12, color: AppColors.warning),
                    const SizedBox(width: 3),
                    Text(
                      '${location.rating}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      ' (${location.reviews})',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textMuted,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.directions_rounded,
                        size: 12, color: AppColors.primary),
                    const SizedBox(width: 3),
                    const Text(
                      '2.3 km',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: context.textMuted,
          ),
        ],
      ),
    );
  }
}

class _Location {
  final String name;
  final String type;
  final String address;
  final double rating;
  final int reviews;
  final Color color;

  _Location(this.name, this.type, this.address, this.rating, this.reviews, this.color);
}
