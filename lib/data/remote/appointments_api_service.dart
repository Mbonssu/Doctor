import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../models/appointment/appointment_create_request.dart';
import '../models/appointment/appointment_list_response.dart';
import '../models/appointment/appointment_model.dart';
import '../models/appointment/appointment_update_request.dart';
import '../models/appointment/availability_check_request.dart';
import '../models/appointment/availability_check_response.dart';

class AppointmentsApiService {
  const AppointmentsApiService(this._dio);

  final Dio _dio;

  Future<AppointmentModel> createAppointment(
    AppointmentCreateRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConfig.appointmentsEndpoint,
      data: request.toJson(),
    );
    final body = response.data ?? <String, dynamic>{};
    return AppointmentModel.fromJson(body);
  }

  Future<AppointmentListResponse> getMyAppointments({
    String? status,
    int page = ApiConfig.defaultPage,
    int pageSize = ApiConfig.defaultPageSize,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConfig.myAppointmentsEndpoint,
      queryParameters: {
        if (status != null && status.trim().isNotEmpty) 'status': status,
        'page': page,
        'page_size': pageSize,
      },
    );
    final body = response.data ?? <String, dynamic>{};
    return AppointmentListResponse.fromJson(body);
  }

  Future<List<AppointmentModel>> getUpcomingAppointments({
    int limit = 10,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      ApiConfig.upcomingAppointmentsEndpoint,
      queryParameters: {'limit': limit},
    );
    final items = response.data ?? <dynamic>[];
    return items
        .whereType<Map<String, dynamic>>()
        .map(AppointmentModel.fromJson)
        .toList();
  }

  Future<AvailabilityCheckResponse> checkAvailability(
    AvailabilityCheckRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConfig.checkAvailabilityEndpoint,
      data: request.toJson(),
    );
    final body = response.data ?? <String, dynamic>{};
    return AvailabilityCheckResponse.fromJson(body);
  }

  Future<AppointmentModel> getAppointmentById(int appointmentId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConfig.appointmentByIdEndpoint(appointmentId),
    );
    final body = response.data ?? <String, dynamic>{};
    return AppointmentModel.fromJson(body);
  }

  Future<AppointmentModel> updateAppointment(
    int appointmentId,
    AppointmentUpdateRequest request,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiConfig.appointmentByIdEndpoint(appointmentId),
      data: request.toJson(),
    );
    final body = response.data ?? <String, dynamic>{};
    return AppointmentModel.fromJson(body);
  }

  Future<AppointmentModel> cancelAppointment({
    required int appointmentId,
    required String cancellationReason,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConfig.cancelAppointmentEndpoint(appointmentId),
      data: {'cancellation_reason': cancellationReason},
    );
    final body = response.data ?? <String, dynamic>{};
    return AppointmentModel.fromJson(body);
  }
}
