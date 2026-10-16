import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../objectbox.g.dart';
import '../../../profile/data/datasources/objectbox_data_source.dart';
import '../../../profile/data/models/profile_box_entity.dart';
import '../../domain/entities/app_settings.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource({Store? store})
    : _store = store ?? MotionOrbitObjectBox.store;

  static const _themeKey = 'settings/theme_mode';
  static const _unitsKey = 'settings/measurement_units';
  static const _legacyUnitsKey = 'motion_orbit/profile_units';
  static const _profileKeys = {
    'profile/snapshot',
    'profile/assessments',
    'profile/measurements',
    'profile/goals',
  };

  final Store _store;
  Box<ProfileBoxEntity> get _box => _store.box<ProfileBoxEntity>();

  ProfileBoxEntity? _find(String key) =>
      _box.query(ProfileBoxEntity_.key.equals(key)).build().findFirst();

  void _write(String key, String value) {
    final previous = _find(key);
    _box.put(ProfileBoxEntity(id: previous?.id ?? 0, key: key, value: value));
  }

  Future<AppSettings> readSettings() async {
    final savedTheme = _find(_themeKey)?.value;
    final themeMode = switch (savedTheme) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      _ => AppThemeMode.system,
    };
    final savedUnits = _find(_unitsKey)?.value;
    final String units = savedUnits == 'metric' || savedUnits == 'imperial'
        ? savedUnits!
        : (await SharedPreferences.getInstance()).getString(_legacyUnitsKey) ??
              'metric';
    if (savedUnits == null) _write(_unitsKey, units);
    return AppSettings(
      themeMode: themeMode,
      units: units == 'imperial'
          ? MeasurementUnits.imperial
          : MeasurementUnits.metric,
    );
  }

  Future<void> writeThemeMode(AppThemeMode mode) async =>
      _write(_themeKey, mode.name);

  Future<void> writeUnits(MeasurementUnits units) async {
    final value = units.name;
    _write(_unitsKey, value);
    // Keep older measurement entry points in sync while they migrate to this store.
    await (await SharedPreferences.getInstance()).setString(
      _legacyUnitsKey,
      value,
    );
  }

  Stream<LocalDataSummary> watchLocalData() => _box
      .query()
      .watch(triggerImmediately: true)
      .map((query) => _summarize(query.find()));

  String exportJsonBackup() {
    final data = <String, Object?>{};
    for (final entity in _box.getAll()) {
      if (!_isBackupKey(entity.key)) continue;
      final raw = entity.value;
      try {
        data[entity.key] = jsonDecode(raw);
      } on FormatException {
        data[entity.key] = raw;
      }
    }
    return jsonEncode({
      'format': 'motion_orbit_backup',
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'data': data,
    });
  }

  String exportCsvBackup() {
    final rows = <List<String>>[
      ['collection', 'record'],
    ];
    for (final entity in _box.getAll()) {
      if (!_isBackupKey(entity.key)) continue;
      Object? value;
      try {
        value = jsonDecode(entity.value);
      } on FormatException {
        value = entity.value;
      }
      if (value is List) {
        for (final record in value) {
          rows.add([entity.key, jsonEncode(record)]);
        }
      } else {
        rows.add([entity.key, jsonEncode(value)]);
      }
    }
    return rows.map((row) => row.map(_csvCell).join(',')).join('\r\n');
  }

  Future<void> restoreJsonBackup(String backup) async {
    final decoded = jsonDecode(backup);
    if (decoded is! Map ||
        decoded['format'] != 'motion_orbit_backup' ||
        decoded['version'] != 1 ||
        decoded['data'] is! Map) {
      throw const FormatException(
        'This is not a supported Motion Orbit backup.',
      );
    }

    final data = decoded['data'] as Map;
    final restored = <String, String>{};
    for (final entry in data.entries) {
      if (entry.key is! String || !_isBackupKey(entry.key as String)) continue;
      final key = entry.key as String;
      final value = entry.value;
      if (key == _themeKey &&
          value is String &&
          {'system', 'light', 'dark'}.contains(value)) {
        restored[key] = value;
      } else if (key == _unitsKey &&
          value is String &&
          {'metric', 'imperial'}.contains(value)) {
        restored[key] = value;
      } else if (key == 'profile/snapshot' &&
          value is Map &&
          value['version'] == 1 &&
          value['completed'] is bool &&
          value['draft'] is Map &&
          (value['completed'] == true
              ? value['profile'] is Map
              : value['profile'] == null)) {
        restored[key] = jsonEncode(value);
      } else if (_profileKeys.contains(key) &&
          key != 'profile/snapshot' &&
          value is List &&
          value.every((record) => record is Map)) {
        restored[key] = jsonEncode(value);
      }
    }
    if (restored.isEmpty) {
      throw const FormatException(
        'The backup contains no restorable profile data.',
      );
    }

    for (final entity in _box.getAll()) {
      if (entity.key.startsWith('profile/')) _box.remove(entity.id);
    }
    for (final entry in restored.entries) {
      _write(entry.key, entry.value);
    }
    final units = restored[_unitsKey];
    if (units != null) {
      await (await SharedPreferences.getInstance()).setString(
        _legacyUnitsKey,
        units,
      );
    }
  }

  Future<void> resetLocalProfileData() async {
    for (final entity in _box.getAll()) {
      if (entity.key.startsWith('profile/')) _box.remove(entity.id);
    }
  }

  bool _isBackupKey(String key) =>
      _profileKeys.contains(key) || key == _themeKey || key == _unitsKey;

  String _csvCell(String value) => '"${value.replaceAll('"', '""')}"';

  LocalDataSummary _summarize(List<ProfileBoxEntity> entities) {
    final values = {for (final entity in entities) entity.key: entity.value};
    int count(String key) {
      final value = values[key];
      if (value == null || value.isEmpty) return 0;
      try {
        final decoded = jsonDecode(value);
        return decoded is List ? decoded.length : 0;
      } on FormatException {
        return 0;
      }
    }

    return LocalDataSummary(
      profileSaved: values.containsKey('profile/snapshot'),
      assessments: count('profile/assessments'),
      measurements: count('profile/measurements'),
      goals: count('profile/goals'),
    );
  }
}
