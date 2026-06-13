import '../models/doctor/doctor_list_response.dart';
import '../models/doctor/doctor_model.dart';
import '../remote/doctors_api_service.dart';
import 'base_repository.dart';

class DoctorsRepository extends BaseRepository {
  DoctorsRepository({required DoctorsApiService apiService})
    : _apiService = apiService;

  final DoctorsApiService _apiService;

  Future<DoctorListResponse> searchDoctors({
    String? query,
    String? specialty,
    String? city,
    bool isAvailable = true,
    int page = 1,
    int pageSize = 20,
  }) {
    return run(
      () => _apiService.searchDoctors(
        query: query,
        specialty: specialty,
        city: city,
        isAvailable: isAvailable,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  Future<List<DoctorModel>> getTopRatedDoctors({int limit = 10}) {
    return run(() => _apiService.getTopRatedDoctors(limit: limit));
  }

  Future<DoctorModel> getDoctorById(int doctorId) {
    return run(() => _apiService.getDoctorById(doctorId));
  }

  Future<DoctorListResponse> getDoctorsBySpecialty(
    String specialty, {
    int page = 1,
    int pageSize = 20,
  }) {
    return run(
      () => _apiService.getDoctorsBySpecialty(
        specialty,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  Future<List<DoctorModel>> getFavoriteDoctors() =>
      run(() => _apiService.getFavoriteDoctors());

  Future<void> addFavorite(int doctorId) =>
      run(() => _apiService.addFavorite(doctorId));

  Future<void> removeFavorite(int doctorId) =>
      run(() => _apiService.removeFavorite(doctorId));
}
