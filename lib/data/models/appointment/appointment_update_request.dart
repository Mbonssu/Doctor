class AppointmentUpdateRequest {
  const AppointmentUpdateRequest({
    this.appointmentDate,
    this.durationMinutes,
    this.appointmentType,
    this.status,
    this.reason,
    this.notes,
    this.doctorNotes,
  });

  final DateTime? appointmentDate;
  final int? durationMinutes;
  final String? appointmentType;
  final String? status;
  final String? reason;
  final String? notes;
  final String? doctorNotes;

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{};
    if (appointmentDate != null) {
      payload['appointment_date'] = appointmentDate!.toIso8601String();
    }
    if (durationMinutes != null) {
      payload['duration_minutes'] = durationMinutes;
    }
    if (appointmentType != null) {
      payload['appointment_type'] = appointmentType;
    }
    if (status != null) {
      payload['status'] = status;
    }
    if (reason != null) {
      payload['reason'] = reason;
    }
    if (notes != null) {
      payload['notes'] = notes;
    }
    if (doctorNotes != null) {
      payload['doctor_notes'] = doctorNotes;
    }
    return payload;
  }
}
