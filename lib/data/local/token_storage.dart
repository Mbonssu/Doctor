import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth/auth_tokens.dart';
import '../models/user/user_model.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kTokenType = 'token_type';
  static const _kUser = 'current_user';

  Future<void> saveTokens(AuthTokens tokens) async {
    await _secureStorage.write(key: _kAccessToken, value: tokens.accessToken);
    await _secureStorage.write(key: _kRefreshToken, value: tokens.refreshToken);
    await _secureStorage.write(key: _kTokenType, value: tokens.tokenType);
  }

  Future<AuthTokens?> readTokens() async {
    final accessToken = await _secureStorage.read(key: _kAccessToken);
    final refreshToken = await _secureStorage.read(key: _kRefreshToken);
    final tokenType = await _secureStorage.read(key: _kTokenType);

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType ?? 'bearer',
    );
  }

  Future<void> saveUser(UserModel user) async {
    await _secureStorage.write(key: _kUser, value: jsonEncode(user.toJson()));
  }

  Future<UserModel?> readUser() async {
    final raw = await _secureStorage.read(key: _kUser);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return UserModel.fromJson(decoded);
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: _kAccessToken);
    await _secureStorage.delete(key: _kRefreshToken);
    await _secureStorage.delete(key: _kTokenType);
    await _secureStorage.delete(key: _kUser);
  }
}
