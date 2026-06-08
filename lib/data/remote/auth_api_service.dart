import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../models/auth/auth_response_model.dart';
import '../models/auth/auth_tokens.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';

class AuthApiService {
  const AuthApiService(this._dio);

  final Dio _dio;

  Future<AuthResponseModel> login(LoginRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConfig.loginEndpoint,
      data: request.toJson(),
    );
    final body = response.data ?? <String, dynamic>{};
    return AuthResponseModel.fromJson(body);
  }

  Future<AuthResponseModel> register(RegisterRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConfig.registerEndpoint,
      data: request.toJson(),
    );
    final body = response.data ?? <String, dynamic>{};
    return AuthResponseModel.fromJson(body);
  }

  Future<AuthTokens> refreshToken(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConfig.refreshEndpoint,
      data: {'refresh_token': refreshToken},
    );
    final body = response.data ?? <String, dynamic>{};
    return AuthTokens.fromJson(body);
  }

  Future<void> logout({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      ApiConfig.logoutEndpoint,
      data: {'access_token': accessToken, 'refresh_token': refreshToken},
    );
  }
}
