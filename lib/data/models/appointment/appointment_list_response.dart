import '../model_parsers.dart';
import 'appointment_model.dart';

class AppointmentListResponse {
  const AppointmentListResponse({
    required this.appointments,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<AppointmentModel> appointments;
  final int total;
  final int page;
  final int pageSize;

  factory AppointmentListResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['appointments'] ?? <dynamic>[]) as List<dynamic>;
    return AppointmentListResponse(
      appointments: items
          .whereType<Map<String, dynamic>>()
          .map(AppointmentModel.fromJson)
          .toList(),
      total: parseInt(json['total']),
      page: parseInt(json['page'], fallback: 1),
      pageSize: parseInt(json['page_size'], fallback: 20),
    );
  }
}
