import '../../core/providers/auth_session_manager.dart';
import '../models/user/user_model.dart';
import '../remote/users_api_service.dart';
import 'base_repository.dart';

class UsersRepository extends BaseRepository {
  UsersRepository({
    required UsersApiService apiService,
    required AuthSessionManager sessionManager,
  }) : _apiService = apiService,
       _sessionManager = sessionManager;

  final UsersApiService _apiService;
  final AuthSessionManager _sessionManager;

  Future<UserModel> getCurrentUser() {
    return run(() async {
      final user = await _apiService.getCurrentUser();
      await _sessionManager.updateUser(user);
      return user;
    });
  }

  Future<UserModel> updateCurrentUser({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
  }) {
    return run(() async {
      final user = await _apiService.updateCurrentUser(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      await _sessionManager.updateUser(user);
      return user;
    });
  }

  /// Changer le mot de passe
  /// 
  /// Important: Après le changement de mot de passe, l'utilisateur doit se reconnecter
  /// car tous les tokens existants seront révoqués par le backend
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return run(() async {
      final response = await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      // Vérifier si la réponse indique une déconnexion
      final requiresRelogin = response['requires_relogin'] as bool? ?? false;
      
      if (requiresRelogin) {
        // Nettoyer la session (mais pas complètement, pour afficher un message)
        await _sessionManager.clearSession();
      }
      
      return true;
    });
  }

  /// Changer l'email
  /// 
  /// Important: L'email doit être différent de l'email actuel
  Future<bool> changeEmail({
    required String newEmail,
    required String password,
  }) {
    return run(() async {
      final response = await _apiService.changeEmail(
        newEmail: newEmail,
        password: password,
      );
      
      // Vérification requise?
      final verificationRequired = response['verification_required'] as bool? ?? false;
      
      if (!verificationRequired && _sessionManager.currentUser != null) {
        // Mettre à jour l'email local
        final updatedUser = _sessionManager.currentUser!;
        await _sessionManager.updateUser(
          UserModel(
            id: updatedUser.id,
            email: newEmail,
            firstName: updatedUser.firstName,
            lastName: updatedUser.lastName,
            phone: updatedUser.phone,
            role: updatedUser.role,
            isActive: updatedUser.isActive,
            isVerified: updatedUser.isVerified,
            avatarUrl: updatedUser.avatarUrl,
            createdAt: updatedUser.createdAt,
            updatedAt: updatedUser.updatedAt,
          ),
        );
      }
      
      return true;
    });
  }

  /// Changer le numéro de téléphone
  Future<bool> changePhone({
    required String newPhone,
  }) {
    return run(() async {
      await _apiService.changePhone(newPhone: newPhone);
      
      if (_sessionManager.currentUser != null) {
        // Mettre à jour le téléphone local
        final updatedUser = _sessionManager.currentUser!;
        await _sessionManager.updateUser(
          UserModel(
            id: updatedUser.id,
            email: updatedUser.email,
            firstName: updatedUser.firstName,
            lastName: updatedUser.lastName,
            phone: newPhone,
            role: updatedUser.role,
            isActive: updatedUser.isActive,
            isVerified: updatedUser.isVerified,
            avatarUrl: updatedUser.avatarUrl,
            createdAt: updatedUser.createdAt,
            updatedAt: updatedUser.updatedAt,
          ),
        );
      }
      
      return true;
    });
  }
}
