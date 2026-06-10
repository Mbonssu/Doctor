import '../model_parsers.dart';

class DoctorScheduleModel {
  const DoctorScheduleModel({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.isWorkingDay,
    required this.consultDurationMin,
    required this.breakDurationMin,
    required this.maxPatients,
  });

  final int id;
  final int doctorId;
  final int dayOfWeek;
  final bool isWorkingDay;
  final int consultDurationMin;
  final int breakDurationMin;
  final int maxPatients;

  factory DoctorScheduleModel.fromJson(Map<String, dynamic> json) {
    return DoctorScheduleModel(
      id: parseInt(json['id']),
      doctorId: parseInt(json['doctor_id']),
      dayOfWeek: parseInt(json['day_of_week']),
      isWorkingDay: parseBool(json['is_working_day']),
      consultDurationMin: parseInt(json['consult_duration_min'], fallback: 30),
      breakDurationMin: parseInt(json['break_duration_min'], fallback: 10),
      maxPatients: parseInt(json['max_patients'], fallback: 20),
    );
  }
}

class DoctorTimeSlotModel {
  const DoctorTimeSlotModel({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.time,
    required this.isActive,
  });

  final int id;
  final int doctorId;
  final int dayOfWeek;
  final String time;
  final bool isActive;

  factory DoctorTimeSlotModel.fromJson(Map<String, dynamic> json) {
    return DoctorTimeSlotModel(
      id: parseInt(json['id']),
      doctorId: parseInt(json['doctor_id']),
      dayOfWeek: parseInt(json['day_of_week']),
      time: (json['time'] ?? '') as String,
      isActive: parseBool(json['is_active']),
    );
  }
}

class WeekScheduleResponse {
  const WeekScheduleResponse({
    required this.schedules,
    required this.slots,
  });

  final List<DoctorScheduleModel> schedules;
  final List<DoctorTimeSlotModel> slots;

  factory WeekScheduleResponse.fromJson(Map<String, dynamic> json) {
    final schedulesJson = (json['schedules'] as List? ?? []);
    final slotsJson = (json['slots'] as List? ?? []);
    return WeekScheduleResponse(
      schedules: schedulesJson
          .whereType<Map<String, dynamic>>()
          .map(DoctorScheduleModel.fromJson)
          .toList(),
      slots: slotsJson
          .whereType<Map<String, dynamic>>()
          .map(DoctorTimeSlotModel.fromJson)
          .toList(),
    );
  }
}
