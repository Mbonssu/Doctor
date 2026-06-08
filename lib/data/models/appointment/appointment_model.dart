import '../doctor/doctor_model.dart';
import '../model_parsers.dart';

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.durationMinutes,
    required this.appointmentType,
    required this.status,
    required this.consultationFee,
    required this.isPaid,
    this.reason,
    this.notes,
    this.paymentMethod,
    this.doctorNotes,
    this.cancelledBy,
    this.cancellationReason,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
    this.doctor,
  });

  final int id;
  final int patientId;
  final int doctorId;
  final DateTime appointmentDate;
  final int durationMinutes;
  final String appointmentType;
  final String status;
  final double consultationFee;
  final bool isPaid;
  final String? reason;
  final String? notes;
  final String? paymentMethod;
  final String? doctorNotes;
  final String? cancelledBy;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DoctorModel? doctor;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final doctorJson = json['doctor'];
    return AppointmentModel(
      id: parseInt(json['id']),
      patientId: parseInt(json['patient_id']),
      doctorId: parseInt(json['doctor_id']),
      appointmentDate:
          parseDateTime(json['appointment_date']) ?? DateTime.now(),
      durationMinutes: parseInt(json['duration_minutes'], fallback: 30),
      appointmentType: (json['appointment_type'] ?? 'consultation') as String,
      status: (json['status'] ?? 'pending') as String,
      consultationFee: parseDouble(json['consultation_fee']),
      isPaid: parseBool(json['is_paid']),
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      paymentMethod: json['payment_method'] as String?,
      doctorNotes: json['doctor_notes'] as String?,
      cancelledBy: json['cancelled_by'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledAt: parseDateTime(json['cancelled_at']),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      doctor: doctorJson is Map<String, dynamic>
          ? DoctorModel.fromJson(doctorJson)
          : null,
    );
  }
}
