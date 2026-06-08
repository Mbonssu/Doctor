import '../model_parsers.dart';
import '../user/user_model.dart';

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.updatedAt,
    this.patient,
  });

  final int id;
  final int doctorId;
  final int patientId;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserModel? patient;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final patientJson = json['patient'];
    return ReviewModel(
      id: parseInt(json['id']),
      doctorId: parseInt(json['doctor_id']),
      patientId: parseInt(json['patient_id']),
      rating: parseInt(json['rating']),
      comment: (json['comment'] ?? '') as String,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      patient: patientJson is Map<String, dynamic>
          ? UserModel.fromJson(patientJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'doctor_id': doctorId,
    'patient_id': patientId,
    'rating': rating,
    'comment': comment,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'patient': patient?.toJson(),
  };
}
