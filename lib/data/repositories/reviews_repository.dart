import '../models/review/review_list_response.dart';
import '../models/review/review_model.dart';
import '../remote/reviews_api_service.dart';
import 'base_repository.dart';

class ReviewsRepository extends BaseRepository {
  ReviewsRepository({required ReviewsApiService apiService})
    : _apiService = apiService;

  final ReviewsApiService _apiService;

  Future<ReviewListResponse> getDoctorReviews({
    required int doctorId,
    int page = 1,
    int pageSize = 20,
  }) {
    return run(
      () => _apiService.getDoctorReviews(
        doctorId: doctorId,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  Future<ReviewModel> createReview({
    required int doctorId,
    required int patientId,
    required int rating,
    required String comment,
  }) {
    return run(
      () => _apiService.createReview(
        doctorId: doctorId,
        patientId: patientId,
        rating: rating,
        comment: comment,
      ),
    );
  }

  Future<ReviewModel> getReviewById(int reviewId) {
    return run(() => _apiService.getReviewById(reviewId));
  }

  Future<ReviewModel> updateReview({
    required int reviewId,
    int? rating,
    String? comment,
  }) {
    return run(
      () => _apiService.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      ),
    );
  }

  Future<void> deleteReview(int reviewId) {
    return run(() => _apiService.deleteReview(reviewId));
  }
}
