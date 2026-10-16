import 'dart:convert';

import '../../../../objectbox.g.dart';
import 'objectbox_data_source.dart';
import '../models/profile_box_entity.dart';
import '../models/profile_records.dart';

class ProfileRecordsDataSource {
  ProfileRecordsDataSource({Store? store})
    : _store = store ?? MotionOrbitObjectBox.store;

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
    final prior = _box
        .query(ProfileBoxEntity_.key.equals(key))
        .build()
        .findFirst();
    _box.put(
      ProfileBoxEntity(id: prior?.id ?? 0, key: key, value: jsonEncode(data)),
    );
  }

  List<AssessmentRecord> assessments() =>
      _read('profile/assessments').map(AssessmentRecord.fromJson).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  void saveAssessment(AssessmentRecord record) {
    final rows = _read('profile/assessments')
      ..removeWhere((item) => item['id'] == record.id)
      ..add(record.toJson());
    _write('profile/assessments', rows);
  }

  List<MeasurementRecord> measurements() =>
      _read('profile/measurements').map(MeasurementRecord.fromJson).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  void saveMeasurement(MeasurementRecord record) {
    final rows = _read('profile/measurements')
      ..removeWhere((item) => item['id'] == record.id)
      ..add(record.toJson());
    _write('profile/measurements', rows);
  }

  /// Adds a single local example so the measurement screens have useful
  /// history to show on a fresh install. Existing user records are preserved.
  void seedSampleMeasurementIfEmpty() {
    if (measurements().isNotEmpty) return;
    final date = DateTime.now().subtract(const Duration(days: 7));
    saveMeasurement(
      MeasurementRecord(
        id: 'sample-body-measurement',
        date: DateTime(date.year, date.month, date.day),
        weightKg: 76,
        waistCm: 98,
        hipsCm: 104,
        chestCm: 99,
        leftArmCm: 32,
        rightArmCm: 32,
        leftThighCm: 57,
        rightThighCm: 57,
        bodyFatPercent: 27,
        muscleMassKg: 52,
        bodyFatSource: 'Sample Data',
        note: 'Example measurement history',
      ),
    );
  }

  List<FitnessGoal> goals() =>
      _read('profile/goals').map(FitnessGoal.fromJson).toList()
        ..sort((a, b) => (b.isPrimary ? 1 : 0).compareTo(a.isPrimary ? 1 : 0));

  void saveGoal(FitnessGoal goal) {
    final rows = _read('profile/goals')
      ..removeWhere((item) => item['id'] == goal.id)
      ..add(goal.toJson());
    _write('profile/goals', rows);
  }
}
