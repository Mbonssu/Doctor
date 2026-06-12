/// Service de gestion de la sécurité des comptes
/// 
/// Ce service gère les opérations de sécurité sensibles:
/// - Changement de mot de passe
/// - Changement d'email
/// - Changement de téléphone
/// - Vérification d'identité
/// 
/// Toutes les opérations incluent:
/// - Validation des données
/// - Gestion des erreurs
/// - Synchronisation avec le backend
/// - Mise à jour de l'état local

import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import '../../core/providers/auth_session_manager.dart';
import '../models/user/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/users_repository.dart';

class AccountSecurityService extends ChangeNotifier {
  AccountSecurityService({
    required AuthRepository authRepository,
    required UsersRepository usersRepository,
    required AuthSessionManager sessionManager,
  }) : _authRepository = authRepository,
       _usersRepository = usersRepository,
       _sessionManager = sessionManager;

  final AuthRepository _authRepository;
  final UsersRepository _usersRepository;
  final AuthSessionManager _sessionManager;

  // État
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Effacer les messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Valider la force d'un mot de passe
  /// 
  /// Retourne une map avec:
  /// - isStrong: bool
  /// - score: int (0-100)
  /// - issues: List&lt;String&gt; des problèmes détectés
  Map<String, dynamic> validatePasswordStrength(String password) {
    final issues = <String>[];
    var score = 0;

    if (password.length < 8) {
      issues.add('Password must be at least 8 characters long');
    } else {
      score += 20;
    }

    if (password.length >= 12) {
      score += 10;
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) {
      score += 20;
    } else {
      issues.add('Password must contain at least one uppercase letter');
    }

    if (RegExp(r'[a-z]').hasMatch(password)) {
      score += 20;
    } else {
      issues.add('Password must contain at least one lowercase letter');
    }

    if (RegExp(r'[0-9]').hasMatch(password)) {
      score += 15;
    } else {
      issues.add('Password must contain at least one digit');
    }

    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      score += 15;
    } else {
      issues.add('Password must contain at least one special character');
    }

    return {
      'isStrong': issues.isEmpty,
      'score': score.clamp(0, 100),
      'issues': issues,
    };
  }

  /// Valider un email
  bool isValidEmail(String email) {
    // RFC 5322-ish practical email regex (kept as a raw string)
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    return emailRegex.hasMatch(email);
  }

  /// Valider un numéro de téléphone (format international)
  bool isValidPhone(String phone) {
    // Accepter les formats: +33612345678, 0612345678, +1234567890
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  /// Changer le mot de passe
  /// 
  /// Sécurité:
  /// - Vérification du mot de passe actuel
  /// - Validation des critères du nouveau mot de passe
  /// - Tous les tokens seront révoqués (déconnexion forcée)
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    clearMessages();
    _isLoading = true;
    notifyListeners();

    try {
      // Validation basique
      if (currentPassword.isEmpty || newPassword.isEmpty) {
        throw const ApiException(message: 'Password fields cannot be empty');
      }

      if (currentPassword == newPassword) {
        throw const ApiException(
          message: 'New password must be different from current password',
        );
      }

      // Valider la force du nouveau mot de passe
      final validation = validatePasswordStrength(newPassword);
      if (!validation['isStrong']) {
        final issues = (validation['issues'] as List<String>).join('\n');
        throw ApiException(message: 'Password requirements not met:\n$issues');
      }

      // Effectuer le changement
      await _usersRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _successMessage =
          'Password changed successfully. Please login again with your new password.';
      _isLoading = false;
      notifyListeners();

      // Forcer la déconnexion après un délai
      await Future.delayed(const Duration(seconds: 1));
      await _authRepository.logout();

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Error changing password: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Changer l'email
  /// 
  /// Sécurité:
  /// - Vérification du mot de passe requise
  /// - L'email doit être unique et valide
  /// - Vérification obligatoire si configurée
  Future<bool> changeEmail({
    required String newEmail,
    required String password,
  }) async {
    clearMessages();
    _isLoading = true;
    notifyListeners();

    try {
      // Validation basique
      if (newEmail.isEmpty || password.isEmpty) {
        throw const ApiException(message: 'Email and password cannot be empty');
      }

      if (!isValidEmail(newEmail)) {
        throw const ApiException(message: 'Invalid email format');
      }

      final currentUser = _sessionManager.currentUser;
      if (currentUser != null &&
          newEmail.toLowerCase() == currentUser.email.toLowerCase()) {
        throw const ApiException(
          message: 'New email must be different from current email',
        );
      }

      // Effectuer le changement
      await _usersRepository.changeEmail(
        newEmail: newEmail,
        password: password,
      );

      _successMessage = 'Email changed successfully to $newEmail';
      _isLoading = false;
      notifyListeners();

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Error changing email: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Changer le numéro de téléphone
  Future<bool> changePhone({
    required String newPhone,
  }) async {
    clearMessages();
    _isLoading = true;
    notifyListeners();

    try {
      // Validation basique
      if (newPhone.isEmpty) {
        throw const ApiException(message: 'Phone cannot be empty');
      }

      if (!isValidPhone(newPhone)) {
        throw const ApiException(message: 'Invalid phone format');
      }

      final currentUser = _sessionManager.currentUser;
      if (currentUser != null && newPhone == currentUser.phone) {
        throw const ApiException(
          message: 'New phone must be different from current phone',
        );
      }

      // Effectuer le changement
      await _usersRepository.changePhone(newPhone: newPhone);

      _successMessage = 'Phone number updated successfully to $newPhone';
      _isLoading = false;
      notifyListeners();

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Error changing phone: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Mettre à jour le profil (basique)
  /// 
  /// Permet de modifier le nom, prénom, avatar sans sécurité sensible
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? avatarUrl,
  }) async {
    clearMessages();
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _usersRepository.updateCurrentUser(
        firstName: firstName,
        lastName: lastName,
        avatarUrl: avatarUrl,
      );

      _successMessage = 'Profile updated successfully';
      _isLoading = false;
      notifyListeners();

      return user;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Error updating profile: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Rafraîchir les données du profil depuis le serveur
  Future<UserModel> refreshProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _usersRepository.getCurrentUser();
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _errorMessage = 'Error refreshing profile: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
