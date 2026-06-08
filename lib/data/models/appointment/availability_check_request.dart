class AvailabilityCheckRequest {
  const AvailabilityCheckRequest({
    required this.doctorId,
    required this.appointmentDate,
    this.durationMinutes = 30,
  });

  final int doctorId;
  final DateTime appointmentDate;
  final int durationMinutes;

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'appointment_date': appointmentDate.toIso8601String(),
      'duration_minutes': durationMinutes,
    };
  }
}
