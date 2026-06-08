import '../../core/providers/auth_session_manager.dart';
import '../../core/network/api_exception.dart';
import '../models/auth/auth_response_model.dart';
import '../models/auth/auth_tokens.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';
import '../remote/auth_api_service.dart';
import 'base_repository.dart';

class AuthRepository extends BaseRepository {
  AuthRepository({
    required AuthApiService apiService,
    required AuthSessionManager sessionManager,
  }) : _apiService = apiService,
       _sessionManager = sessionManager;

  final AuthApiService _apiService;
  final AuthSessionManager _sessionManager;

  /// Login with email and password
  Future<AuthResponseModel> login(LoginRequest request) {
    return run(() async {
      if (request.email.trim().isEmpty) {
        throw ApiException(
          message: 'Email cannot be empty',
          code: ApiErrorCode.validationError,
          userMessage: 'Please enter your email',
        );
      }

      if (request.password.isEmpty) {
        throw ApiException(
          message: 'Password cannot be empty',
          code: ApiErrorCode.validationError,
          userMessage: 'Please enter your password',
        );
      }

      final response = await _apiService.login(request);
      await _sessionManager.saveAuthSession(response);
      return response;
    });
  }

  /// Register a new user
  Future<AuthResponseModel> register(RegisterRequest request) {
    return run(() async {
      // Validate input
      final validationError = _validateRegister(request);
      if (validationError != null) {
        throw validationError;
      }

      final response = await _apiService.register(request);
      await _sessionManager.saveAuthSession(response);
      return response;
    });
  }

  /// Refresh access token
  Future<AuthTokens> refreshToken() {
    return runWithRetry(() async {
      final currentRefreshToken = _sessionManager.refreshToken;
      if (currentRefreshToken == null || currentRefreshToken.trim().isEmpty) {
        throw ApiException(
          message: 'No refresh token available',
          code: ApiErrorCode.invalidToken,
          userMessage: 'Your session has expired. Please login again.',
        );
      }

      final tokens = await _apiService.refreshToken(currentRefreshToken);
      await _sessionManager.updateTokens(tokens);
      return tokens;
    });
  }

  /// Logout user
  Future<void> logout() {
    return run(() async {
      try {
        final accessToken = _sessionManager.accessToken;
        final refreshToken = _sessionManager.refreshToken;

        if (accessToken != null &&
            refreshToken != null &&
            accessToken.trim().isNotEmpty &&
            refreshToken.trim().isNotEmpty) {
          await _apiService.logout(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
      } catch (error) {
        // Continue logout even if API call fails
        if (error is! ApiException) {
          rethrow;
        }
      } finally {
        await _sessionManager.clearSession();
      }
    });
  }

  /// Validate register request
  ApiException? _validateRegister(RegisterRequest request) {
    if (request.email.trim().isEmpty) {
      return ApiException(
        message: 'Email is required',
        code: ApiErrorCode.validationError,
        userMessage: 'Please enter your email',
      );
    }

    if (request.firstName.trim().isEmpty) {
      return ApiException(
        message: 'First name is required',
        code: ApiErrorCode.validationError,
        userMessage: 'Please enter your first name',
      );
    }

    if (request.lastName.trim().isEmpty) {
      return ApiException(
        message: 'Last name is required',
        code: ApiErrorCode.validationError,
        userMessage: 'Please enter your last name',
      );
    }

    if (request.password.isEmpty) {
      return ApiException(
        message: 'Password is required',
        code: ApiErrorCode.validationError,
        userMessage: 'Please enter a password',
      );
    }

    if (request.password.length < 8) {
      return ApiException(
        message: 'Password must be at least 8 characters',
        code: ApiErrorCode.invalidPassword,
        userMessage: 'Password must be at least 8 characters long',
      );
    }

    return null;
  }
}
