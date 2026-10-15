import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../../objectbox.g.dart';
import '../models/profile_box_entity.dart';
import '../models/profile_records.dart';

class MotionOrbitObjectBox {
  MotionOrbitObjectBox._();

  static Store? _store;

  static Future<void> initialize() async {
    if (_store != null) return;

    final appSupportDirectory = await getApplicationSupportDirectory();
    final objectBoxDirectory = path.join(appSupportDirectory.path, 'objectbox');
    _store ??= openStore(directory: objectBoxDirectory);
  }

  static Store get store {
    final value = _store;
    if (value == null) {
      throw StateError('ObjectBox has not been initialized');
    }
    return value;
  }
}

class ProfileRecordsDataSource {
  ProfileRecordsDataSource({Store? store}) : _store = store ?? MotionOrbitObjectBox.store;

  final Store _store;

  Box<ProfileBoxEntity> get _box => _store.box<ProfileBoxEntity>();

  List<Map<String, Object?>> _read(String key) {
    final entity = _box
        .query(ProfileBoxEntity_.key.equals(key))
        .build()
        .findFirst();
    if (entity == null || entity.value.isEmpty) return [];
    final decoded = jsonDecode(entity.value);
    if (decoded is! List) throw const FormatException('Invalid local records');
    return decoded.map((item) {
      if (item is! Map) throw const FormatException('Invalid local record');
      return item.map((key, value) => MapEntry(key as String, value));
    }).toList();
  }

  void _write(String key, List<Map<String, Object?>> data) {
    final prior = _box.query(ProfileBoxEntity_.key.equals(key)).build().findFirst();
    _box.put(ProfileBoxEntity(
      id: prior?.id ?? 0,
      key: key,
      value: jsonEncode(data),
    ));
  }

  List<AssessmentRecord> assessments() => _read('profile/assessments')
      .map(AssessmentRecord.fromJson)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  void saveAssessment(AssessmentRecord record) {
    final rows = _read('profile/assessments')
      ..removeWhere((item) => item['id'] == record.id)
      ..add(record.toJson());
    _write('profile/assessments', rows);
  }

  List<MeasurementRecord> measurements() => _read('profile/measurements')
      .map(MeasurementRecord.fromJson)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  void saveMeasurement(MeasurementRecord record) {
    final rows = _read('profile/measurements')
      ..removeWhere((item) => item['id'] == record.id)
      ..add(record.toJson());
    _write('profile/measurements', rows);
  }

  List<FitnessGoal> goals() => _read('profile/goals')
      .map(FitnessGoal.fromJson)
      .toList()
    ..sort((a, b) => (b.isPrimary ? 1 : 0).compareTo(a.isPrimary ? 1 : 0));

  void saveGoal(FitnessGoal goal) {
    final rows = _read('profile/goals')
      ..removeWhere((item) => item['id'] == goal.id)
      ..add(goal.toJson());
    _write('profile/goals', rows);
  }
}
