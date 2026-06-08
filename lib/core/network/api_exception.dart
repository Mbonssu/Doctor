import 'package:dio/dio.dart';

/// Exception code constants
class ApiErrorCode {
  // Authentication
  static const String authError = 'AUTH_ERROR';
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String invalidToken = 'INVALID_TOKEN';
  static const String tokenExpired = 'TOKEN_EXPIRED';

  // User
  static const String userNotFound = 'USER_NOT_FOUND';
  static const String emailExists = 'EMAIL_EXISTS';
  static const String phoneExists = 'PHONE_EXISTS';
  static const String userInactive = 'USER_INACTIVE';

  // Validation
  static const String validationError = 'VALIDATION_ERROR';
  static const String invalidPassword = 'INVALID_PASSWORD';

  // Rate Limit
  static const String rateLimitExceeded = 'RATE_LIMIT_EXCEEDED';

  // Connection
  static const String connectionTimeout = 'CONNECTION_TIMEOUT';
  static const String connectionError = 'CONNECTION_ERROR';
  static const String noInternet = 'NO_INTERNET';

  // General
  static const String internalError = 'INTERNAL_ERROR';
}

/// API Exception with detailed error information
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.details,
    this.userMessage,
  });

  /// User-facing error message
  final String message;

  /// HTTP status code
  final int? statusCode;

  /// Error code (for specific handling)
  final String? code;

  /// Additional error details
  final dynamic details;

  /// User-friendly message (if different from message)
  final String? userMessage;

  /// Get user-friendly message
  String get displayMessage => userMessage ?? message;

  /// Create from DioException
  factory ApiException.fromDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    final parsedMessage = _extractMessage(data);
    final parsedCode = _extractCode(data);

    // Connection timeout
    if (error.type == DioExceptionType.connectionTimeout) {
      return ApiException(
        message: 'Request timeout. Please check your connection.',
        statusCode: statusCode,
        code: ApiErrorCode.connectionTimeout,
        details: data,
        userMessage: 'Connection timeout. Please try again.',
      );
    }

    // Send timeout
    if (error.type == DioExceptionType.sendTimeout) {
      return ApiException(
        message: 'Request timeout while sending data.',
        statusCode: statusCode,
        code: ApiErrorCode.connectionTimeout,
        details: data,
        userMessage: 'Upload timeout. Please try again.',
      );
    }

    // Receive timeout
    if (error.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: 'Request timeout while receiving data.',
        statusCode: statusCode,
        code: ApiErrorCode.connectionTimeout,
        details: data,
        userMessage: 'Download timeout. Please try again.',
      );
    }

    // Connection error
    if (error.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'No internet connection.',
        statusCode: statusCode,
        code: ApiErrorCode.noInternet,
        details: data,
        userMessage: 'Check your internet connection.',
      );
    }

    // Cancelled
    if (error.type == DioExceptionType.cancel) {
      return ApiException(
        message: 'Request cancelled.',
        statusCode: statusCode,
        details: data,
      );
    }

    // HTTP error responses
    if (statusCode == 401) {
      return ApiException(
        message: parsedMessage ?? 'Unauthorized',
        statusCode: statusCode,
        code: parsedCode ?? ApiErrorCode.authError,
        details: data,
        userMessage: 'Invalid email or password. Please try again.',
      );
    }

    if (statusCode == 403) {
      return ApiException(
        message: parsedMessage ?? 'Access denied',
        statusCode: statusCode,
        code: parsedCode,
        details: data,
        userMessage: 'You do not have permission to access this resource.',
      );
    }

    if (statusCode == 404) {
      return ApiException(
        message: parsedMessage ?? 'Not found',
        statusCode: statusCode,
        details: data,
        userMessage: 'The requested resource was not found.',
      );
    }

    if (statusCode == 422) {
      return ApiException(
        message: parsedMessage ?? 'Validation error',
        statusCode: statusCode,
        code: ApiErrorCode.validationError,
        details: data,
        userMessage: 'Please check your input and try again.',
      );
    }

    if (statusCode == 429) {
      return ApiException(
        message: 'Too many requests',
        statusCode: statusCode,
        code: ApiErrorCode.rateLimitExceeded,
        details: data,
        userMessage: 'Too many requests. Please try again later.',
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return ApiException(
        message: parsedMessage ?? 'Server error',
        statusCode: statusCode,
        details: data,
        userMessage: 'Server error. Please try again later.',
      );
    }

    return ApiException(
      message: parsedMessage ?? 'Unexpected API error.',
      statusCode: statusCode,
      code: parsedCode,
      details: data,
      userMessage: 'An unexpected error occurred. Please try again.',
    );
  }

  /// Extract error message from response data
  static String? _extractMessage(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      // Try to get nested message
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      // Try to get detail field
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }

      // If detail is a map, try to get message from it
      if (detail is Map<String, dynamic>) {
        final nestedMessage = detail['message'];
        if (nestedMessage is String && nestedMessage.trim().isNotEmpty) {
          return nestedMessage;
        }
      }
    }

    return null;
  }

  /// Extract error code from response data
  static String? _extractCode(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return null;
    }

    final code = data['code'];
    if (code is String && code.isNotEmpty) {
      return code;
    }

    final detail = data['detail'];
    if (detail is Map<String, dynamic>) {
      final detailCode = detail['code'];
      if (detailCode is String && detailCode.isNotEmpty) {
        return detailCode;
      }
    }

    return null;
  }

  /// Check if error is authentication related
  bool get isAuthError =>
      code == ApiErrorCode.authError ||
      code == ApiErrorCode.invalidCredentials ||
      code == ApiErrorCode.invalidToken ||
      statusCode == 401 ||
      statusCode == 403;

  /// Check if error is network related
  bool get isNetworkError =>
      code == ApiErrorCode.noInternet ||
      code == ApiErrorCode.connectionError ||
      code == ApiErrorCode.connectionTimeout;

  /// Check if error is validation related
  bool get isValidationError =>
      code == ApiErrorCode.validationError ||
      code == ApiErrorCode.invalidPassword ||
      statusCode == 422;

  /// Check if error is rate limit
  bool get isRateLimit =>
      code == ApiErrorCode.rateLimitExceeded ||
      statusCode == 429;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, code: $code, message: $message)';
}
