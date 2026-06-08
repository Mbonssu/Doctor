library;

import 'package:flutter/foundation.dart';
import 'api_config.dart';

class EnvironmentConfig {
  EnvironmentConfig._();

  static void initialize({Environment? environment}) {
    if (environment != null) {
      ApiConfig.setEnvironment(environment);
    } else {
      _autoDetectEnvironment();
    }

    if (kDebugMode) {
      ApiConfig.printConfig();
    }
  }

  static void _autoDetectEnvironment() {
    if (kDebugMode) {
      ApiConfig.setEnvironment(Environment.development);
    } else if (kProfileMode) {
      ApiConfig.setEnvironment(Environment.staging);
    } else if (kReleaseMode) {
      ApiConfig.setEnvironment(Environment.production);
    } else {
      ApiConfig.setEnvironment(Environment.development);
    }
  }

  static void loadFromString(String envString) {
    switch (envString.toLowerCase()) {
      case 'development':
      case 'dev':
        ApiConfig.setEnvironment(Environment.development);
        break;
      case 'staging':
      case 'stage':
        ApiConfig.setEnvironment(Environment.staging);
        break;
      case 'production':
      case 'prod':
        ApiConfig.setEnvironment(Environment.production);
        break;
      default:
        ApiConfig.setEnvironment(Environment.development);
    }
    
    if (kDebugMode) {
      ApiConfig.printConfig();
    }
  }

  static Map<String, dynamic> getEnvironmentInfo() {
    return {
      'environment': ApiConfig.environmentName,
      'baseUrl': ApiConfig.baseUrl,
      'apiBaseUrl': ApiConfig.apiBaseUrl,
      'isDevelopment': ApiConfig.isDevelopment,
      'isStaging': ApiConfig.isStaging,
      'isProduction': ApiConfig.isProduction,
      'loggingEnabled': ApiConfig.enableLogging,
      'buildMode': kDebugMode
          ? 'debug'
          : kProfileMode
              ? 'profile'
              : kReleaseMode
                  ? 'release'
                  : 'unknown',
    };
  }

  static bool get isDevelopment => ApiConfig.isDevelopment;
  static bool get isStaging => ApiConfig.isStaging;
  static bool get isProduction => ApiConfig.isProduction;
}
