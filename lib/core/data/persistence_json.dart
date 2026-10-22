import 'dart:convert';

/// Strict validation shared by persistence mappers and the upgrade migration.
/// Unknown properties must be mapped explicitly before an upgrade can proceed.
class PersistenceJson {
  static Map<String, dynamic> object(Object? value, String path) {
    if (value is! Map || value.keys.any((key) => key is! String)) {
      throw FormatException('$path must be an object.');
    }
    return Map<String, dynamic>.from(value);
  }

  static List<Map<String, dynamic>> records(Object? value, String path) {
    if (value is! List) throw FormatException('$path must be a list.');
    return [
      for (var i = 0; i < value.length; i++) object(value[i], '$path[$i]'),
    ];
  }

  static void keys(Map<String, dynamic> value, Set<String> allowed, String path) {
    final unknown = value.keys.where((key) => !allowed.contains(key)).toList();
    if (unknown.isNotEmpty) {
      throw FormatException('Unmapped fields in $path: ${unknown.join(', ')}');
    }
  }

  static String text(Map<String, dynamic> value, String key,
      {String fallback = ''}) {
    if (!value.containsKey(key)) return fallback;
    final result = value[key];
    if (result is! String) throw FormatException('Invalid $key.');
    return result;
  }

  static String businessId(Map<String, dynamic> value) {
    final result = text(value, 'id');
    if (result.isEmpty) throw const FormatException('Missing stable record ID.');
    return result;
  }

  static String? optionalText(Map<String, dynamic> value, String key) {
    if (value[key] == null) return null;
    return text(value, key);
  }

  static bool boolean(Map<String, dynamic> value, String key,
      {bool fallback = false}) {
    if (!value.containsKey(key)) return fallback;
    final result = value[key];
    if (result is! bool) throw FormatException('Invalid $key.');
    return result;
  }

  static int integer(Map<String, dynamic> value, String key,
      {int fallback = 0}) {
    if (!value.containsKey(key)) return fallback;
    final result = value[key];
    if (result is! int) throw FormatException('Invalid $key.');
    return result;
  }

  static double? number(Map<String, dynamic> value, String key,
      {bool required = false}) {
    final result = value[key];
    if (result == null && !required) return null;
    if (result is! num || !result.isFinite || result.toDouble() != result) {
      throw FormatException('Invalid or lossy numeric value for $key.');
    }
    return result.toDouble();
  }

  static List<String> strings(Map<String, dynamic> value, String key) {
    if (!value.containsKey(key)) return [];
    final result = value[key];
    if (result is! List || result.any((item) => item is! String)) {
      throw FormatException('Invalid $key.');
    }
    return result.cast<String>().toList();
  }

  /// Keep the original ISO string, including local/UTC semantics and precision.
  static String? date(Map<String, dynamic> value, String key,
      {bool required = false}) {
    final result = optionalText(value, key);
    if (result == null && !required) return null;
    if (result == null || DateTime.tryParse(result) == null) {
      throw FormatException('Invalid $key date.');
    }
    return result;
  }

  static Map<String, dynamic> select(
    List<String> fields,
    Map<String, dynamic> values,
  ) => {for (final key in fields) key: values[key]};

  static void uniqueIds(List<Map<String, dynamic>> records, String path) {
    final ids = <String>{};
    for (final record in records) {
      if (!ids.add(businessId(record))) {
        throw FormatException('Duplicate ID in $path: ${record['id']}');
      }
    }
  }

  static bool equal(Object? a, Object? b) {
    if (a is Map && b is Map) {
      return a.length == b.length &&
          a.keys.every((key) => b.containsKey(key) && equal(a[key], b[key]));
    }
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!equal(a[i], b[i])) return false;
      }
      return true;
    }
    return a == b;
  }

  static void confirm(Object? expected, Object? actual, String path) {
    if (!equal(expected, actual)) {
      throw StateError('Persistence readback differs for $path.');
    }
  }

  static Map<String, dynamic> decodeObject(String raw, String path) =>
      object(jsonDecode(raw), path);
}
