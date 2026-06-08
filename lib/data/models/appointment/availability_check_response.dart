class AvailabilityCheckResponse {
  const AvailabilityCheckResponse({
    required this.isAvailable,
    required this.message,
  });

  final bool isAvailable;
  final String message;

  factory AvailabilityCheckResponse.fromJson(Map<String, dynamic> json) {
    return AvailabilityCheckResponse(
      isAvailable: (json['is_available'] ?? false) as bool,
      message: (json['message'] ?? '') as String,
    );
  }
}
