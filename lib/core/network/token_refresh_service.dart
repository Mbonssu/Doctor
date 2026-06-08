import 'package:flutter/foundation.dart';

import '../providers/auth_session_manager.dart';
import '../../data/models/auth/auth_tokens.dart';

class TokenRefreshService {
  TokenRefreshService({required AuthSessionManager sessionManager})
    : _sessionManager = sessionManager;

  final AuthSessionManager _sessionManager;
  bool _isRefreshing = false;

  bool get isRefreshing => _isRefreshing;

  Future<AuthTokens?> refreshTokens() async {
    if (_isRefreshing) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _sessionManager.tokens;
    }

    _isRefreshing = true;

    if (kDebugMode) {
      print('[TokenRefreshService] Token expired, clearing session');
    }

    await _sessionManager.clearSession();
    _isRefreshing = false;

    return null;
  }

  bool isTokenExpired(String token) {
    return false;
  }
}
