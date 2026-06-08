import '../model_parsers.dart';
import '../user/user_model.dart';

class DoctorModel {
  const DoctorModel({
    required this.id,
    required this.userId,
    required this.specialty,
    required this.licenseNumber,
    required this.yearsOfExperience,
    required this.consultationFee,
    required this.isAvailable,
    required this.rating,
    required this.totalReviews,
    required this.totalPatients,
    this.bio,
    this.education,
    this.languages,
    this.hospitalName,
    this.officeAddress,
    this.city,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  final int id;
  final int userId;
  final String specialty;
  final String licenseNumber;
  final int yearsOfExperience;
  final String? bio;
  final String? education;
  final String? languages;
  final String? hospitalName;
  final String? officeAddress;
  final String? city;
  final double consultationFee;
  final bool isAvailable;
  final double rating;
  final int totalReviews;
  final int totalPatients;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserModel? user;

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return DoctorModel(
      id: parseInt(json['id']),
      userId: parseInt(json['user_id']),
      specialty: (json['specialty'] ?? '') as String,
      licenseNumber: (json['license_number'] ?? '') as String,
      yearsOfExperience: parseInt(json['years_of_experience']),
      bio: json['bio'] as String?,
      education: json['education'] as String?,
      languages: json['languages'] as String?,
      hospitalName: json['hospital_name'] as String?,
      officeAddress: json['office_address'] as String?,
      city: json['city'] as String?,
      consultationFee: parseDouble(json['consultation_fee']),
      isAvailable: parseBool(json['is_available']),
      rating: parseDouble(json['rating']),
      totalReviews: parseInt(json['total_reviews']),
      totalPatients: parseInt(json['total_patients']),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      user: userJson is Map<String, dynamic>
          ? UserModel.fromJson(userJson)
          : null,
    );
  }
}
