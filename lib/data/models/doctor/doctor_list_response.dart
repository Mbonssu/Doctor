import '../model_parsers.dart';
import 'doctor_model.dart';

class DoctorListResponse {
  const DoctorListResponse({
    required this.doctors,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<DoctorModel> doctors;
  final int total;
  final int page;
  final int pageSize;

  factory DoctorListResponse.fromJson(Map<String, dynamic> json) {
    final doctorsRaw = (json['doctors'] ?? <dynamic>[]) as List<dynamic>;
    return DoctorListResponse(
      doctors: doctorsRaw
          .whereType<Map<String, dynamic>>()
          .map(DoctorModel.fromJson)
          .toList(),
      total: parseInt(json['total']),
      page: parseInt(json['page'], fallback: 1),
      pageSize: parseInt(json['page_size'], fallback: 20),
    );
  }
}
