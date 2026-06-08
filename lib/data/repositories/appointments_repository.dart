import '../models/appointment/appointment_create_request.dart';
import '../models/appointment/appointment_list_response.dart';
import '../models/appointment/appointment_model.dart';
import '../models/appointment/appointment_update_request.dart';
import '../models/appointment/availability_check_request.dart';
import '../models/appointment/availability_check_response.dart';
import '../remote/appointments_api_service.dart';
import 'base_repository.dart';

class AppointmentsRepository extends BaseRepository {
  AppointmentsRepository({required AppointmentsApiService apiService})
    : _apiService = apiService;

  final AppointmentsApiService _apiService;

  Future<AppointmentModel> createAppointment(AppointmentCreateRequest request) {
    return run(() => _apiService.createAppointment(request));
  }

  Future<AppointmentListResponse> getMyAppointments({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) {
    return run(
      () => _apiService.getMyAppointments(
        status: status,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  Future<List<AppointmentModel>> getUpcomingAppointments({int limit = 10}) {
    return run(() => _apiService.getUpcomingAppointments(limit: limit));
  }

  Future<AvailabilityCheckResponse> checkAvailability(
    AvailabilityCheckRequest request,
  ) {
    return run(() => _apiService.checkAvailability(request));
  }

  Future<AppointmentModel> getAppointmentById(int appointmentId) {
    return run(() => _apiService.getAppointmentById(appointmentId));
  }

  Future<AppointmentModel> updateAppointment(
    int appointmentId,
    AppointmentUpdateRequest request,
  ) {
    return run(() => _apiService.updateAppointment(appointmentId, request));
  }

  Future<AppointmentModel> cancelAppointment({
    required int appointmentId,
    required String cancellationReason,
  }) {
    return run(
      () => _apiService.cancelAppointment(
        appointmentId: appointmentId,
        cancellationReason: cancellationReason,
      ),
    );
  }
}
