/// API Configuration for DoctoPing backend
library;

import 'package:flutter/foundation.dart';

enum Environment {
  development,
  staging,
  production,
}

class ApiConfig {
  ApiConfig._();

  static Environment _currentEnvironment = Environment.development;

  static Environment get currentEnvironment => _currentEnvironment;

  static void setEnvironment(Environment environment) {
    _currentEnvironment = environment;
  }

  static const String _developmentBaseUrl = 'http://localhost:8000';
  static const String _stagingBaseUrl = 'https://staging-api.doctoping.com';
  static const String _productionBaseUrl = 'https://api.doctoping.com';
  
  static String? _customDevelopmentUrl;

  static void setCustomDevelopmentUrl(String url) {
    _customDevelopmentUrl = url;
  }

  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return _customDevelopmentUrl ?? _developmentBaseUrl;
      case Environment.staging:
        return _stagingBaseUrl;
      case Environment.production:
        return _productionBaseUrl;
    }
  }

  static const String apiVersion = '/api/v1';

  static String get apiBaseUrl => '$baseUrl$apiVersion';

  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration readTimeout = Duration(seconds: 30);
  static const Duration writeTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String verifyEmailEndpoint = '/auth/verify-email';
  static const String sendVerificationCodeEndpoint = '/auth/send-verification-code';
  static const String refreshEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';

  // User endpoints
  static const String userProfileEndpoint = '/users/me';
  static const String userStatsEndpoint = '/users/me/stats';
  static const String healthSummaryEndpoint = '/users/me/health-summary';

  // Doctor endpoints
  static const String doctorsEndpoint = '/doctors';
  static const String recommendedDoctorsEndpoint = '/doctors/recommended';
  static const String topRatedDoctorsEndpoint = '/doctors/top-rated';
  static String doctorByIdEndpoint(int doctorId) => '/doctors/$doctorId';
  static String doctorsBySpecialtyEndpoint(String specialty) => '/doctors/specialty/$specialty';

  // Appointment endpoints
  static const String appointmentsEndpoint = '/appointments';
  static const String myAppointmentsEndpoint = '/appointments/my-appointments';
  static const String upcomingAppointmentsEndpoint = '/appointments/upcoming';
  static const String nextAppointmentEndpoint = '/appointments/next';
  static const String checkAvailabilityEndpoint = '/appointments/check-availability';
  static String appointmentByIdEndpoint(int appointmentId) => '/appointments/$appointmentId';
  static String cancelAppointmentEndpoint(int appointmentId) => '/appointments/$appointmentId/cancel';

  // Review endpoints
  static const String reviewsEndpoint = '/reviews';
  static String doctorReviewsEndpoint(int doctorId) => '/reviews/doctor/$doctorId';

  // Favorite endpoints
  static const String favoritesEndpoint = '/favorite-doctors';

  // Notification endpoints
  static const String unreadNotificationsCountEndpoint = '/notifications/unread/count';

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const int defaultPageSize = 20;
  static const int defaultPage = 1;
  static const int maxRetries = 3;
  static const Duration initialRetryDelay = Duration(seconds: 1);
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);
  static const Duration doctorsCacheExpiration = Duration(minutes: 5);
  static const Duration userProfileCacheExpiration = Duration(minutes: 10);
  static const Duration appointmentsCacheExpiration = Duration(minutes: 2);

  static bool get isDevelopment => _currentEnvironment == Environment.development;
  static bool get isStaging => _currentEnvironment == Environment.staging;
  static bool get isProduction => _currentEnvironment == Environment.production;
  static bool get enableLogging => isDevelopment;

  static String get environmentName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  static void printConfig() {
    if (!enableLogging) return;
    debugPrint('=== API Configuration ===');
    debugPrint('Environment: $environmentName');
    debugPrint('Base URL: $baseUrl');
    debugPrint('API Base URL: $apiBaseUrl');
    debugPrint('========================');
  }
}
