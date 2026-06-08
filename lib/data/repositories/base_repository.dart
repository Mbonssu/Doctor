import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';

abstract class BaseRepository {
  /// Execute API call with error handling
  Future<T> run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException {
      rethrow;
    } on DioException catch (error) {
      final apiException = ApiException.fromDioError(error);
      if (kDebugMode) {
        print('API Error: $apiException');
      }
      throw apiException;
    } catch (error) {
      if (kDebugMode) {
        print('Unexpected Error: $error');
      }
      throw ApiException(
        message: error.toString(),
        userMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Execute API call with retry logic
  Future<T> runWithRetry<T>(
    Future<T> Function() action, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int retryCount = 0;

    while (true) {
      try {
        return await action();
      } on ApiException catch (error) {
        // Don't retry on authentication errors
        if (error.isAuthError) {
          rethrow;
        }

        // Retry on network errors
        if (!error.isNetworkError && retryCount < maxRetries) {
          retryCount++;
          await Future.delayed(delay * retryCount);
          continue;
        }

        rethrow;
      } on DioException catch (error) {
        // Convert to ApiException and retry if appropriate
        final apiException = ApiException.fromDioError(error);

        if (!apiException.isAuthError && retryCount < maxRetries) {
          retryCount++;
          await Future.delayed(delay * retryCount);
          continue;
        }

        throw apiException;
      }
    }
  }
}
