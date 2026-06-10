import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../models/appointment/appointment_list_response.dart';
import '../models/appointment/appointment_model.dart';
import '../models/appointment/appointment_update_request.dart';
import '../models/doctor/doctor_model.dart';
import '../models/doctor_schedule/doctor_schedule_model.dart';

/// Service pour les endpoints réservés au rôle médecin
class DoctorApiService {
  const DoctorApiService(this._dio);

  final Dio _dio;

  // ─── Profil médecin ────────────────────────────────────────────────────────

  Future<DoctorModel> getMyProfile() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConfig.doctorsEndpoint}/me',
    );
    return DoctorModel.fromJson(response.data ?? {});
  }

  Future<DoctorModel> updateMyProfile(Map<String, dynamic> updates) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '${ApiConfig.doctorsEndpoint}/me',
      data: updates,
    );
    return DoctorModel.fromJson(response.data ?? {});
  }

  // ─── Stats ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getMyStats() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConfig.doctorsEndpoint}/me/stats',
    );
    return response.data ?? {};
  }

  // ─── Schedule ──────────────────────────────────────────────────────────────

  Future<WeekScheduleResponse> getMySchedule() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConfig.doctorsEndpoint}/me/schedule',
    );
    return WeekScheduleResponse.fromJson(response.data ?? {});
  }

  Future<WeekScheduleResponse> getScheduleForDoctor(int doctorId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConfig.doctorsEndpoint}/$doctorId/schedule',
    );
    return WeekScheduleResponse.fromJson(response.data ?? {});
  }

  Future<WeekScheduleResponse> updateMySchedule({
    required int dayOfWeek,
    required bool isWorkingDay,
    required int consultDurationMin,
    required int breakDurationMin,
    required int maxPatients,
    required List<String> slots,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '${ApiConfig.doctorsEndpoint}/me/schedule',
      data: {
        'day_of_week': dayOfWeek,
        'is_working_day': isWorkingDay,
        'consult_duration_min': consultDurationMin,
        'break_duration_min': breakDurationMin,
        'max_patients': maxPatients,
        'slots': slots,
      },
    );
    return WeekScheduleResponse.fromJson(response.data ?? {});
  }

  // ─── RDV du médecin ────────────────────────────────────────────────────────

  Future<AppointmentListResponse> getMyAppointments({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConfig.doctorsEndpoint}/me/appointments',
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'page_size': pageSize,
      },
    );
    return AppointmentListResponse.fromJson(response.data ?? {});
  }

  Future<AppointmentModel> confirmAppointment(int appointmentId) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiConfig.appointmentByIdEndpoint(appointmentId),
      data: {'status': 'confirmed'},
    );
    return AppointmentModel.fromJson(response.data ?? {});
  }

  Future<AppointmentModel> completeAppointment(int appointmentId) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiConfig.appointmentByIdEndpoint(appointmentId),
      data: {'status': 'completed'},
    );
    return AppointmentModel.fromJson(response.data ?? {});
  }

  Future<AppointmentModel> refuseAppointment({
    required int appointmentId,
    required String reason,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConfig.cancelAppointmentEndpoint(appointmentId),
      data: {'cancellation_reason': reason},
    );
    return AppointmentModel.fromJson(response.data ?? {});
  }

  Future<AppointmentModel> addDoctorNotes({
    required int appointmentId,
    required String notes,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiConfig.appointmentByIdEndpoint(appointmentId),
      data: {'doctor_notes': notes},
    );
    return AppointmentModel.fromJson(response.data ?? {});
  }
}
