import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../providers/auth_session_manager.dart';
import 'interceptors/auth_interceptor.dart';
import 'token_refresh_service.dart';

class ApiClient {
  ApiClient({required AuthSessionManager sessionManager})
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.apiBaseUrl,
          connectTimeout: ApiConfig.connectionTimeout,
          receiveTimeout: ApiConfig.readTimeout,
          sendTimeout: ApiConfig.writeTimeout,
          headers: Map<String, String>.from(ApiConfig.defaultHeaders),
        ),
      ) {
    final refreshService = TokenRefreshService(sessionManager: sessionManager);

    _dio.interceptors.add(
      AuthInterceptor(
        dio: _dio,
        sessionManager: sessionManager,
        tokenRefreshService: refreshService,
      ),
    );

    if (ApiConfig.enableLogging && kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }
  }

  final Dio _dio;

  Dio get dio => _dio;
}
