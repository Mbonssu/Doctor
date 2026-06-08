import 'package:flutter/foundation.dart';

import '../../data/local/token_storage.dart';
import '../../data/models/auth/auth_response_model.dart';
import '../../data/models/auth/auth_tokens.dart';
import '../../data/models/user/user_model.dart';

class AuthSessionManager extends ChangeNotifier {
  AuthSessionManager({required TokenStorage tokenStorage})
    : _tokenStorage = tokenStorage;

  final TokenStorage _tokenStorage;

  AuthTokens? _tokens;
  UserModel? _currentUser;
  bool _isInitialized = false;

  AuthTokens? get tokens => _tokens;

  /// Nom historique utilisé par plusieurs écrans.
  UserModel? get user => _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _tokens != null;
  String? get accessToken => _tokens?.accessToken;
  String? get refreshToken => _tokens?.refreshToken;

  Future<void> initialize() async {
    _tokens = await _tokenStorage.readTokens();
    _currentUser = await _tokenStorage.readUser();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> saveAuthSession(AuthResponseModel session) async {
    _tokens = session.tokens;
    _currentUser = session.user;
    await _tokenStorage.saveTokens(session.tokens);
    await _tokenStorage.saveUser(session.user);
    notifyListeners();
  }

  Future<void> updateTokens(AuthTokens tokens) async {
    _tokens = tokens;
    await _tokenStorage.saveTokens(tokens);
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    _currentUser = user;
    await _tokenStorage.saveUser(user);
    notifyListeners();
  }

  Future<void> clearSession() async {
    _tokens = null;
    _currentUser = null;
    await _tokenStorage.clearSession();
    notifyListeners();
  }

  /// Alias historique pour compatibilité.
  Future<void> logout() => clearSession();
}
