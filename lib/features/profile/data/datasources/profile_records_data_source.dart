import '../../../../objectbox.g.dart';
import '../../../body_measurements/data/models/body_measurement_entity.dart';
import '../../../fitness_assessment/data/models/fitness_assessment_entity.dart';
import '../../../goals/data/models/fitness_goal_entity.dart';
import 'objectbox_data_source.dart';
import '../models/profile_records.dart';

/// Compatibility facade for existing consumers. Each record now belongs to
/// its feature-specific box; individual saves never rewrite a collection.
class ProfileRecordsDataSource {
  ProfileRecordsDataSource({Store? store})
    : _store = store ?? MotionOrbitObjectBox.store;

  final Store _store;

  List<Map<String, dynamic>> assessmentRows() => _store
      .box<FitnessAssessmentEntity>().getAll().map((row) => row.toJson()).toList();

  List<Map<String, dynamic>> measurementRows() => _store
      .box<BodyMeasurementEntity>().getAll().map((row) => row.toJson()).toList();

  List<Map<String, dynamic>> goalRows() => _store
      .box<FitnessGoalEntity>().getAll().map((row) => row.toJson()).toList();

  List<AssessmentRecord> assessments() =>
      assessmentRows().map(AssessmentRecord.fromJson).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  void putAssessment(FitnessAssessmentEntity entity) {
    final box = _store.box<FitnessAssessmentEntity>();
    final query = box.query(
        FitnessAssessmentEntity_.businessId.equals(entity.businessId)).build();
    try {
      entity.id = query.findFirst()?.id ?? 0;
      box.put(entity);
    } finally {
      query.close();
    }
  }

  void saveAssessment(AssessmentRecord record) =>
      _store.runInTransaction(TxMode.write, () =>
          putAssessment(FitnessAssessmentEntity.fromJson(record.toJson())));

  List<MeasurementRecord> measurements() =>
      measurementRows().map(MeasurementRecord.fromJson).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  void putMeasurement(BodyMeasurementEntity entity) {
    final box = _store.box<BodyMeasurementEntity>();
    final query = box.query(
        BodyMeasurementEntity_.businessId.equals(entity.businessId)).build();
    try {
      entity.id = query.findFirst()?.id ?? 0;
      box.put(entity);
    } finally {
      query.close();
    }
  }

  void saveMeasurement(MeasurementRecord record) =>
      _store.runInTransaction(TxMode.write, () =>
          putMeasurement(BodyMeasurementEntity.fromJson(record.toJson())));

  List<FitnessGoal> goals() => goalRows().map(FitnessGoal.fromJson).toList()
    ..sort((a, b) => (b.isPrimary ? 1 : 0).compareTo(a.isPrimary ? 1 : 0));

  void putGoal(FitnessGoalEntity entity) {
    final box = _store.box<FitnessGoalEntity>();
    final query = box.query(
        FitnessGoalEntity_.businessId.equals(entity.businessId)).build();
    try {
      entity.id = query.findFirst()?.id ?? 0;
      box.put(entity);
    } finally {
      query.close();
    }
  }

  void saveGoal(FitnessGoal goal) =>
      _store.runInTransaction(TxMode.write, () =>
          putGoal(FitnessGoalEntity.fromJson(goal.toJson())));
}
