import 'review_model.dart';

class ReviewListResponse {
  const ReviewListResponse({
    required this.reviews,
    required this.total,
    required this.averageRating,
    required this.page,
    required this.pageSize,
  });

  final List<ReviewModel> reviews;
  final int total;
  final double averageRating;
  final int page;
  final int pageSize;

  int get totalPages => (total / pageSize).ceil();
  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;

  factory ReviewListResponse.fromJson(Map<String, dynamic> json) {
    final reviewsList = (json['reviews'] as List<dynamic>?)
        ?.whereType<Map<String, dynamic>>()
        .map(ReviewModel.fromJson)
        .toList() ??
        <ReviewModel>[];

    return ReviewListResponse(
      reviews: reviewsList,
      total: (json['total'] as num?)?.toInt() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
    );
  }

  Map<String, dynamic> toJson() => {
    'reviews': reviews.map((r) => r.toJson()).toList(),
    'total': total,
    'average_rating': averageRating,
    'page': page,
    'page_size': pageSize,
  };
}
