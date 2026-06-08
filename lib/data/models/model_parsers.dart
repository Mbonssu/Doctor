bool parseBool(dynamic value) {
  if (value is bool) {
    return value;
  }

  if (value is String) {
    final normalized = value.toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  if (value is num) {
    return value != 0;
  }

  return false;
}

DateTime? parseDateTime(dynamic value) {
  if (value is DateTime) {
    return value;
  }

  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value);
  }

  return null;
}

double parseDouble(dynamic value, {double fallback = 0}) {
  if (value is double) {
    return value;
  }

  if (value is int) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value) ?? fallback;
  }

  return fallback;
}

int parseInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }

  if (value is double) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }

  return fallback;
}
