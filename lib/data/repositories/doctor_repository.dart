import '../models/appointment/appointment_list_response.dart';
import '../models/appointment/appointment_model.dart';
import '../models/doctor/doctor_model.dart';
import '../models/doctor_schedule/doctor_schedule_model.dart';
import '../remote/doctor_api_service.dart';
import 'base_repository.dart';

class DoctorRepository extends BaseRepository {
  DoctorRepository({required DoctorApiService apiService})
      : _apiService = apiService;

  final DoctorApiService _apiService;

  Future<DoctorModel> getMyProfile() =>
      run(() => _apiService.getMyProfile());

  Future<DoctorModel> updateMyProfile(Map<String, dynamic> updates) =>
      run(() => _apiService.updateMyProfile(updates));

  Future<Map<String, dynamic>> getMyStats() =>
      run(() => _apiService.getMyStats());

  Future<WeekScheduleResponse> getMySchedule() =>
      run(() => _apiService.getMySchedule());

  Future<WeekScheduleResponse> updateMySchedule({
    required int dayOfWeek,
    required bool isWorkingDay,
    required int consultDurationMin,
    required int breakDurationMin,
    required int maxPatients,
    required List<String> slots,
  }) =>
      run(() => _apiService.updateMySchedule(
            dayOfWeek: dayOfWeek,
            isWorkingDay: isWorkingDay,
            consultDurationMin: consultDurationMin,
            breakDurationMin: breakDurationMin,
            maxPatients: maxPatients,
            slots: slots,
          ));

  Future<AppointmentListResponse> getMyAppointments({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) =>
      run(() => _apiService.getMyAppointments(
            status: status,
            page: page,
            pageSize: pageSize,
          ));

  Future<AppointmentModel> confirmAppointment(int id) =>
      run(() => _apiService.confirmAppointment(id));

  Future<AppointmentModel> completeAppointment(int id) =>
      run(() => _apiService.completeAppointment(id));

  Future<AppointmentModel> refuseAppointment({
    required int appointmentId,
    required String reason,
  }) =>
      run(() => _apiService.refuseAppointment(
            appointmentId: appointmentId,
            reason: reason,
          ));

  Future<AppointmentModel> addDoctorNotes({
    required int appointmentId,
    required String notes,
  }) =>
      run(() => _apiService.addDoctorNotes(
            appointmentId: appointmentId,
            notes: notes,
          ));
}
