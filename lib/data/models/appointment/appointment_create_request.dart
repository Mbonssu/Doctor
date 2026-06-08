class AppointmentCreateRequest {
  const AppointmentCreateRequest({
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    this.durationMinutes = 30,
    this.appointmentType = 'consultation',
    this.reason,
    this.notes,
  });

  final int patientId;
  final int doctorId;
  final DateTime appointmentDate;
  final int durationMinutes;
  final String appointmentType;
  final String? reason;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'doctor_id': doctorId,
      'appointment_date': appointmentDate.toIso8601String(),
      'duration_minutes': durationMinutes,
      'appointment_type': appointmentType,
      'reason': reason,
      'notes': notes,
    };
  }
}
