import 'package:flutter/material.dart';
import '../../../core/di/app_services.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../data/models/review/review_model.dart';

class DoctorReviewsScreen extends StatefulWidget {
  final int doctorId;
  final String doctorName;

  const DoctorReviewsScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<DoctorReviewsScreen> createState() => _DoctorReviewsScreenState();
}

class _DoctorReviewsScreenState extends State<DoctorReviewsScreen> {
  String _selectedFilter = 'Tous';
  bool _isLoading = true;
  String? _errorMessage;
  List<ReviewModel> _reviews = [];
  double _averageRating = 0;
  int _totalReviews = 0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AppServices.reviewsRepository.getDoctorReviews(
        doctorId: widget.doctorId,
        page: 1,
        pageSize: 100,
      );

      if (!mounted) return;
      setState(() {
        _reviews = response.reviews;
        _averageRating = response.averageRating;
        _totalReviews = response.total;
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
        _errorMessage = 'Impossible de charger les avis.';
      });
    }
  }

  List<ReviewModel> get _filteredReviews {
    if (_selectedFilter == 'Tous') {
      return _reviews;
    }
    final rating = int.tryParse(_selectedFilter[0]) ?? 0;
    return _reviews.where((r) => r.rating == rating).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.bgColor,
        appBar: AppBar(
          title: const Text('Avis patients'),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: context.bgColor,
        appBar: AppBar(
          title: const Text('Avis patients'),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadReviews,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text('Avis patients'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
      ),
      body: Column(
        children: [
          // Résumé des notes
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              border: Border(
                bottom: BorderSide(
                  color: context.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Note globale
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.warning,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < _averageRating.round()
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 12,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_totalReviews avis',
                            style: TextStyle(
                              fontSize: 10,
                              color: context.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Répartition des notes
                    Expanded(
                      child: Column(
                        children: List.generate(5, (i) {
                          final rating = 5 - i;
                          final count = _reviews
                              .where((r) => r.rating == rating)
                              .length;
                          return _RatingBar(
                            stars: rating,
                            count: count,
                            total: _totalReviews,
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filtres
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'Tous',
                  isSelected: _selectedFilter == 'Tous',
                  onTap: () => setState(() => _selectedFilter = 'Tous'),
                ),
                _FilterChip(
                  label: '5 étoiles',
                  isSelected: _selectedFilter == '5 étoiles',
                  onTap: () => setState(() => _selectedFilter = '5 étoiles'),
                ),
                _FilterChip(
                  label: '4 étoiles',
                  isSelected: _selectedFilter == '4 étoiles',
                  onTap: () => setState(() => _selectedFilter = '4 étoiles'),
                ),
                _FilterChip(
                  label: '3 étoiles',
                  isSelected: _selectedFilter == '3 étoiles',
                  onTap: () => setState(() => _selectedFilter = '3 étoiles'),
                ),
              ],
            ),
          ),

          // Liste des avis
          if (_filteredReviews.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'Aucun avis pour ce critère',
                  style: TextStyle(color: context.textMuted),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _filteredReviews.length,
                itemBuilder: (context, index) {
                  final review = _filteredReviews[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ReviewCard(review: review),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final int stars;
  final int count;
  final int total;

  const _RatingBar({
    required this.stars,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '$stars',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded, size: 12, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.warning),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : context.surfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : context.borderColor,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : context.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date inconnue';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else {
      return 'Il y a ${(difference.inDays / 365).floor()} ans';
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientName = review.patient?.fullName ?? 'Patient #${review.patientId}';
    final firstLetter = patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.thumb_up_outlined, size: 14),
                label: const Text('Utile'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.flag_outlined, size: 14),
                label: const Text('Signaler'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
