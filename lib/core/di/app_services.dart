import '../network/api_client.dart';
import '../providers/auth_session_manager.dart';
import '../../data/local/token_storage.dart';
import '../../data/remote/appointments_api_service.dart';
import '../../data/remote/auth_api_service.dart';
import '../../data/remote/doctor_api_service.dart';
import '../../data/remote/doctors_api_service.dart';
import '../../data/remote/reviews_api_service.dart';
import '../../data/remote/users_api_service.dart';
import '../../data/repositories/appointments_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/doctor_repository.dart';
import '../../data/repositories/doctors_repository.dart';
import '../../data/repositories/reviews_repository.dart';
import '../../data/repositories/users_repository.dart';

class AppServices {
  AppServices._();

  static bool _initialized = false;

  static late final TokenStorage tokenStorage;
  static late final AuthSessionManager authSessionManager;
  static late final ApiClient apiClient;

  static late final AuthApiService authApiService;
  static late final UsersApiService usersApiService;
  static late final DoctorApiService doctorApiService;
  static late final DoctorsApiService doctorsApiService;
  static late final AppointmentsApiService appointmentsApiService;
  static late final ReviewsApiService reviewsApiService;

  static late final AuthRepository authRepository;
  static late final UsersRepository usersRepository;
  static late final DoctorRepository doctorRepository;
  static late final DoctorsRepository doctorsRepository;
  static late final AppointmentsRepository appointmentsRepository;
  static late final ReviewsRepository reviewsRepository;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tokenStorage = TokenStorage();
    authSessionManager = AuthSessionManager(tokenStorage: tokenStorage);
    await authSessionManager.initialize();

    apiClient = ApiClient(sessionManager: authSessionManager);

    authApiService = AuthApiService(apiClient.dio);
    usersApiService = UsersApiService(apiClient.dio);
    doctorApiService = DoctorApiService(apiClient.dio);
    doctorsApiService = DoctorsApiService(apiClient.dio);
    appointmentsApiService = AppointmentsApiService(apiClient.dio);
    reviewsApiService = ReviewsApiService(apiClient.dio);

    authRepository = AuthRepository(
      apiService: authApiService,
      sessionManager: authSessionManager,
    );
    usersRepository = UsersRepository(
      apiService: usersApiService,
      sessionManager: authSessionManager,
    );
    doctorRepository = DoctorRepository(apiService: doctorApiService);
    doctorsRepository = DoctorsRepository(apiService: doctorsApiService);
    appointmentsRepository = AppointmentsRepository(
      apiService: appointmentsApiService,
    );
    reviewsRepository = ReviewsRepository(apiService: reviewsApiService);

    _initialized = true;
  }
}
