import 'dart:async';

import 'package:dio/dio.dart';

import '../../providers/auth_session_manager.dart';
import '../token_refresh_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required AuthSessionManager sessionManager,
    required TokenRefreshService tokenRefreshService,
  }) : _dio = dio,
       _sessionManager = sessionManager,
       _tokenRefreshService = tokenRefreshService;

  final Dio _dio;
  final AuthSessionManager _sessionManager;
  final TokenRefreshService _tokenRefreshService;

  Completer<void>? _refreshCompleter;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _sessionManager.accessToken;
    if (token != null &&
        token.trim().isNotEmpty &&
        !_hasAuthorizationHeader(options)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldHandleUnauthorized(err)) {
      handler.next(err);
      return;
    }

    if (_refreshCompleter != null) {
      await _refreshCompleter!.future;
      final retried = await _retryWithLatestToken(err.requestOptions);
      if (retried != null) {
        handler.resolve(retried);
        return;
      }
      handler.next(err);
      return;
    }

    _refreshCompleter = Completer<void>();

    try {
      final newTokens = await _tokenRefreshService.refreshTokens();
      _refreshCompleter!.complete();
      _refreshCompleter = null;

      if (newTokens == null) {
        handler.next(err);
        return;
      }

      final retried = await _retryRequest(
        err.requestOptions,
        newTokens.accessToken,
      );
      handler.resolve(retried);
    } catch (_) {
      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete();
      }
      _refreshCompleter = null;
      handler.next(err);
    }
  }

  bool _hasAuthorizationHeader(RequestOptions options) {
    return options.headers.keys.any(
      (key) => key.toLowerCase() == 'authorization',
    );
  }

  bool _shouldHandleUnauthorized(DioException err) {
    if (err.response?.statusCode != 401) {
      return false;
    }

    final path = err.requestOptions.path;
    return !path.contains('/auth/login') &&
        !path.contains('/auth/register') &&
        !path.contains('/auth/refresh');
  }

  Future<Response<dynamic>?> _retryWithLatestToken(
    RequestOptions requestOptions,
  ) async {
    final token = _sessionManager.accessToken;
    if (token == null || token.trim().isEmpty) {
      return null;
    }

    return _retryRequest(requestOptions, token);
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String accessToken,
  ) {
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    headers['Authorization'] = 'Bearer $accessToken';

    final retryOptions = Options(
      method: requestOptions.method,
      headers: headers,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      followRedirects: requestOptions.followRedirects,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      extra: requestOptions.extra,
      listFormat: requestOptions.listFormat,
      receiveTimeout: requestOptions.receiveTimeout,
      sendTimeout: requestOptions.sendTimeout,
      validateStatus: requestOptions.validateStatus,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: retryOptions,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
    );
  }
}
