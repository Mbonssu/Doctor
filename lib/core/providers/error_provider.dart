import 'package:flutter/foundation.dart';

/// Modèle pour représenter une erreur
class ErrorModel {
  final String message;
  final String? code;
  final dynamic details;
  final DateTime timestamp;

  ErrorModel({
    required this.message,
    this.code,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// User-friendly message
  String get displayMessage {
    // Traduire les codes d'erreur en messages utilisateur
    switch (code) {
      case 'AUTH_ERROR':
      case 'INVALID_CREDENTIALS':
        return 'Invalid email or password. Please try again.';
      case 'EMAIL_EXISTS':
        return 'This email is already registered.';
      case 'PHONE_EXISTS':
        return 'This phone number is already registered.';
      case 'INVALID_PASSWORD':
        return 'Password does not meet requirements.';
      case 'USER_INACTIVE':
        return 'Your account has been deactivated.';
      case 'INVALID_TOKEN':
        return 'Session expired. Please login again.';
      case 'RATE_LIMIT_EXCEEDED':
        return 'Too many attempts. Please try again later.';
      case 'NO_INTERNET':
        return 'No internet connection. Please check your connection.';
      case 'CONNECTION_TIMEOUT':
        return 'Connection timeout. Please try again.';
      default:
        return message;
    }
  }

  @override
  String toString() => 'Error($code): $message';
}

/// Provider pour gérer les erreurs globalement
class ErrorProvider extends ChangeNotifier {
  ErrorModel? _lastError;
  final List<ErrorModel> _errorHistory = [];

  ErrorModel? get lastError => _lastError;
  List<ErrorModel> get errorHistory => List.unmodifiable(_errorHistory);

  /// Ajouter une erreur
  void addError(ErrorModel error) {
    _lastError = error;
    _errorHistory.add(error);
    notifyListeners();
  }

  /// Ajouter une erreur à partir d'un message
  void addErrorMessage({
    required String message,
    String? code,
    dynamic details,
  }) {
    final error = ErrorModel(
      message: message,
      code: code,
      details: details,
    );
    addError(error);
  }

  /// Effacer la dernière erreur
  void clearLastError() {
    _lastError = null;
    notifyListeners();
  }

  /// Effacer tout l'historique
  void clearHistory() {
    _lastError = null;
    _errorHistory.clear();
    notifyListeners();
  }

  /// Vérifier si c'est une erreur d'authentification
  bool get isAuthError => _lastError?.code?.contains('AUTH') ?? false;

  /// Vérifier si c'est une erreur réseau
  bool get isNetworkError => _lastError?.code?.contains('CONNECTION') ?? false;
}
