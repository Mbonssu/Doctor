import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../models/review/review_list_response.dart';
import '../models/review/review_model.dart';

class ReviewsApiService {
  const ReviewsApiService(this._dio);

  final Dio _dio;

  /// Récupérer les avis d'un médecin
  Future<ReviewListResponse> getDoctorReviews({
    required int doctorId,
    int page = 1,
    int pageSize = ApiConfig.defaultPageSize,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConfig.reviewsEndpoint}/doctor/$doctorId',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );

    final body = response.data ?? <String, dynamic>{};
    return ReviewListResponse.fromJson(body);
  }

  /// Créer un nouvel avis
  Future<ReviewModel> createReview({
    required int doctorId,
    required int patientId,
    required int rating,
    required String comment,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConfig.reviewsEndpoint,
      data: {
        'doctor_id': doctorId,
        'patient_id': patientId,
        'rating': rating,
        'comment': comment,
      },
    );

    final body = response.data ?? <String, dynamic>{};
    return ReviewModel.fromJson(body);
  }

  /// Obtenir un avis par ID
  Future<ReviewModel> getReviewById(int reviewId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConfig.reviewsEndpoint}/$reviewId',
    );

    final body = response.data ?? <String, dynamic>{};
    return ReviewModel.fromJson(body);
  }

  /// Mettre à jour un avis
  Future<ReviewModel> updateReview({
    required int reviewId,
    int? rating,
    String? comment,
  }) async {
    final data = <String, dynamic>{};
    if (rating != null) data['rating'] = rating;
    if (comment != null) data['comment'] = comment;

    final response = await _dio.put<Map<String, dynamic>>(
      '${ApiConfig.reviewsEndpoint}/$reviewId',
      data: data,
    );

    final body = response.data ?? <String, dynamic>{};
    return ReviewModel.fromJson(body);
  }

  /// Supprimer un avis
  Future<void> deleteReview(int reviewId) async {
    await _dio.delete('${ApiConfig.reviewsEndpoint}/$reviewId');
  }
}
