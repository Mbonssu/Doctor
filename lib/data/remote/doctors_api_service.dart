import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../models/doctor/doctor_list_response.dart';
import '../models/doctor/doctor_model.dart';

class DoctorsApiService {
  const DoctorsApiService(this._dio);

  final Dio _dio;

  Future<DoctorListResponse> searchDoctors({
    String? query,
    String? specialty,
    String? city,
    bool isAvailable = true,
    int page = 1,
    int pageSize = ApiConfig.defaultPageSize,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConfig.doctorsEndpoint,
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
        if (specialty != null && specialty.trim().isNotEmpty)
          'specialty': specialty.trim(),
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
        'is_available': isAvailable,
        'page': page,
        'page_size': pageSize,
      },
    );

    final body = response.data ?? <String, dynamic>{};
    return DoctorListResponse.fromJson(body);
  }

  Future<List<DoctorModel>> getTopRatedDoctors({int limit = 10}) async {
    final response = await _dio.get<List<dynamic>>(
      ApiConfig.topRatedDoctorsEndpoint,
      queryParameters: {'limit': limit},
    );

    final items = response.data ?? <dynamic>[];
    return items
        .whereType<Map<String, dynamic>>()
        .map(DoctorModel.fromJson)
        .toList();
  }

  Future<DoctorModel> getDoctorById(int doctorId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConfig.doctorByIdEndpoint(doctorId),
    );
    final body = response.data ?? <String, dynamic>{};
    return DoctorModel.fromJson(body);
  }

  Future<DoctorListResponse> getDoctorsBySpecialty(
    String specialty, {
    int page = 1,
    int pageSize = ApiConfig.defaultPageSize,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConfig.doctorsBySpecialtyEndpoint(specialty),
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    final body = response.data ?? <String, dynamic>{};
    return DoctorListResponse.fromJson(body);
  }
}
