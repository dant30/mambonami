Map<String, dynamic> normalizeMap(dynamic payload) {
  if (payload is Map<String, dynamic>) return payload;
  if (payload is Map) {
    return payload.map((key, value) => MapEntry(key.toString(), value));
  }
  return const <String, dynamic>{};
}

List<T> normalizeList<T>(dynamic payload) {
  if (payload is List) return payload.whereType<T>().toList();

  final map = normalizeMap(payload);
  for (final key in const ['results', 'data', 'items', 'orders', 'products', 'notifications']) {
    final value = map[key];
    if (value is List) return value.whereType<T>().toList();
    if (value is Map) {
      final nested = normalizeList<T>(value);
      if (nested.isNotEmpty) return nested;
    }
  }

  return const [];
}

String stringValue(dynamic value, {String fallback = ''}) {
  if (value is String) return value;
  if (value == null) return fallback;
  final text = value.toString();
  return text.isEmpty ? fallback : text;
}

int intValue(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double doubleValue(dynamic value, {double fallback = 0.0}) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime? dateTimeValue(dynamic value) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return null;
}

bool boolValue(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase();
    if (normalized.isEmpty) return fallback;
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return fallback;
}