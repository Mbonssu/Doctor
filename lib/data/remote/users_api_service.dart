import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../models/user/user_model.dart';

class UsersApiService {
  const UsersApiService(this._dio);

  final Dio _dio;

  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConfig.userProfileEndpoint,
    );
    final body = response.data ?? <String, dynamic>{};
    return UserModel.fromJson(body);
  }

  Future<UserModel> updateCurrentUser({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
  }) async {
    final payload = <String, dynamic>{};
    if (firstName != null) payload['first_name'] = firstName.trim();
    if (lastName != null) payload['last_name'] = lastName.trim();
    if (phone != null) payload['phone'] = phone.trim();
    if (avatarUrl != null) payload['avatar_url'] = avatarUrl.trim();

    final response = await _dio.put<Map<String, dynamic>>(
      ApiConfig.userProfileEndpoint,
      data: payload,
    );
    final body = response.data ?? <String, dynamic>{};
    return UserModel.fromJson(body);
  }

  /// Changer le mot de passe
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${ApiConfig.userProfileEndpoint}/change-password',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
    final body = response.data ?? <String, dynamic>{};
    return body;
  }

  /// Changer l'email
  Future<Map<String, dynamic>> changeEmail({
    required String newEmail,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${ApiConfig.userProfileEndpoint}/change-email',
      data: {
        'new_email': newEmail,
        'password': password,
      },
    );
    final body = response.data ?? <String, dynamic>{};
    return body;
  }

  /// Changer le téléphone
  Future<Map<String, dynamic>> changePhone({
    required String newPhone,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${ApiConfig.userProfileEndpoint}/change-phone',
      data: {
        'new_phone': newPhone,
      },
    );
    final body = response.data ?? <String, dynamic>{};
    return body;
  }
}
