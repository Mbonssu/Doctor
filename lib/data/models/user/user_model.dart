import '../model_parsers.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isActive,
    required this.isVerified,
    this.phone,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String role;
  final bool isActive;
  final bool isVerified;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: parseInt(json['id']),
      email: (json['email'] ?? '') as String,
      firstName: (json['first_name'] ?? '') as String,
      lastName: (json['last_name'] ?? '') as String,
      phone: json['phone'] as String?,
      role: (json['role'] ?? 'patient') as String,
      isActive: parseBool(json['is_active']),
      isVerified: parseBool(json['is_verified']),
      avatarUrl: json['avatar_url'] as String?,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'role': role,
      'is_active': isActive,
      'is_verified': isVerified,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
