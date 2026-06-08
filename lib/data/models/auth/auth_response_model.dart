import '../user/user_model.dart';
import 'auth_tokens.dart';

class AuthResponseModel {
  const AuthResponseModel({required this.tokens, required this.user});

  final AuthTokens tokens;
  final UserModel user;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final userJson =
        (json['user'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    return AuthResponseModel(
      tokens: AuthTokens.fromJson(json),
      user: UserModel.fromJson(userJson),
    );
  }
}
