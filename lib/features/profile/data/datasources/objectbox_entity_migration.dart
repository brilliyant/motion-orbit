import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/data/persistence_json.dart';
import '../../../../objectbox.g.dart';
import '../../../body_measurements/data/models/body_measurement_entity.dart';
import '../../../fitness_assessment/data/models/fitness_assessment_entity.dart';
import '../../../goals/data/models/fitness_goal_entity.dart';
import '../../../training_plan/data/datasources/training_plan_local_data_source.dart';
import '../../../training_plan/data/models/training_plan_entity.dart';
import '../models/profile_box_entity.dart';
import '../models/profile_entity.dart';
import 'profile_local_data_source.dart';
import 'profile_records_data_source.dart';

class ObjectBoxMigrationException implements Exception {
  const ObjectBoxMigrationException(this.reason);
  final String reason;

  @override
  String toString() => 'Local data migration could not finish. Existing data '
      'has been kept. Retry after resolving this issue: $reason';
}

/// First upgrade: validate everything, migrate and read back in one write
/// transaction, then mark completion. Subsequent launches skip legacy data.
/// Failed upgrades roll back all typed writes and can safely be retried.
/// Legacy ObjectBox rows and SharedPreferences are retained for rollback;
/// neither is consulted by repositories after a successful upgrade.
class ObjectBoxEntityMigration {
  ObjectBoxEntityMigration(this.store);

  static const markerKey = 'storage/entity_migration_version';
  static const version = '1';
  static const legacyPreferenceKey = 'motion_orbit/local_profile/snapshot';
  final Store store;

  Future<void> run() async {
    try {
      await _migrate();
    } catch (error) {
      throw ObjectBoxMigrationException(error.toString());
    }
  }

  Future<void> _migrate() async {
    final legacyBox = store.box<ProfileBoxEntity>();
    final legacy = {for (final row in legacyBox.getAll()) row.key: row};
    final marker = legacy[markerKey];
    if (marker != null) {
      if (marker.value != version) {
        throw StateError('Unsupported entity migration version: ${marker.value}');
      }
      return;
    }

    const knownKeys = {
      'profile/snapshot', 'profile/measurements', 'profile/assessments',
      'profile/goals', 'training/plans', 'settings/measurement_units',
      'settings/theme_mode', 'profile/unreadable_snapshot',
      'profile/legacy_unreadable_snapshot',
      TrainingPlanLocalDataSource.initializedKey,
    };
    final unknown = legacy.keys.where((key) => !knownKeys.contains(key) &&
        !key.startsWith('profile/recovery/')).toList();
    if (unknown.isNotEmpty) {
      throw FormatException('Unmapped legacy storage keys: ${unknown.join(', ')}');
    }

    final preferences = await SharedPreferences.getInstance();
    final rawSnapshot = legacy['profile/snapshot']?.value ??
        preferences.getString(legacyPreferenceKey);
    final snapshotJson = rawSnapshot == null ? null :
        PersistenceJson.decodeObject(rawSnapshot, 'profile/snapshot');
    final snapshot = snapshotJson == null ? null :
        ProfileSnapshot.fromJson(snapshotJson);

    List<Map<String, dynamic>> rows(String key) {
      final value = legacy[key]?.value;
      if (value == null) return [];
      final result = PersistenceJson.records(jsonDecode(value), key);
      PersistenceJson.uniqueIds(result, key);
      return result;
    }

    // All decoding, validation and child mapping precede the first write.
    final measurementJson = rows('profile/measurements');
    final measurements = measurementJson.map(BodyMeasurementEntity.fromJson).toList();
    final assessmentJson = rows('profile/assessments');
    final assessments = assessmentJson.map(FitnessAssessmentEntity.fromJson).toList();
    final goalJson = rows('profile/goals');
    final goals = goalJson.map(FitnessGoalEntity.fromJson).toList();
    final planJson = rows('training/plans');
    final plans = [for (var i = 0; i < planJson.length; i++)
      TrainingPlanRecord.fromJson(planJson[i], i)];

    final profileSource = ProfileLocalDataSourceImpl(store: store);
    final records = ProfileRecordsDataSource(store: store);
    final planSource = TrainingPlanLocalDataSource(store: store);

    store.runInTransaction(TxMode.write, () {
      // An incomplete/older attempt must never overwrite conflicting typed data.
      final existingProfile = profileSource.readSnapshot();
      if (snapshotJson != null && existingProfile != null) {
        PersistenceJson.confirm(snapshotJson, existingProfile, 'profile/snapshot conflict');
      }
      _checkExisting(measurementJson, records.measurementRows(), 'measurements');
      _checkExisting(assessmentJson, records.assessmentRows(), 'assessments');
      _checkExisting(goalJson, records.goalRows(), 'goals');
      for (final json in planJson) {
        final existing = planSource.readPlan(json['id'] as String);
        if (existing != null) {
          PersistenceJson.confirm(json, existing, 'plan ${json['id']} conflict');
        }
      }

      if (snapshot != null) profileSource.putSnapshot(snapshot);
      for (final entity in measurements) {
        records.putMeasurement(entity);
      }
      for (final entity in assessments) {
        records.putAssessment(entity);
      }
      for (final entity in goals) {
        records.putGoal(entity);
      }
      for (final record in plans) {
        planSource.putPlan(record);
      }
      // An explicitly empty legacy collection is intentional, not a seed cue.
      // Existing users without plans also must not get samples on upgrade.
      final existingUser = rawSnapshot != null || legacy.keys.any((key) =>
          key.startsWith('profile/') || key == 'training/plans');
      if (existingUser || store.box<TrainingPlanEntity>().count() > 0) {
        planSource.markInitialized();
      }

      if (snapshotJson != null) {
        PersistenceJson.confirm(snapshotJson, profileSource.readSnapshot(), 'profile/snapshot');
      }
      _confirmRows(measurementJson, records.measurementRows(), 'measurements');
      _confirmRows(assessmentJson, records.assessmentRows(), 'assessments');
      _confirmRows(goalJson, records.goalRows(), 'goals');
      for (final json in planJson) {
        PersistenceJson.confirm(json, planSource.readPlan(json['id'] as String),
            'plan ${json['id']}');
      }
      // Last write: any failure above rolls back this entire migration.
      legacyBox.put(ProfileBoxEntity(key: markerKey, value: version));
    });
  }

  void _checkExisting(List<Map<String, dynamic>> incoming,
      List<Map<String, dynamic>> existing, String path) {
    final byId = {for (final row in existing) row['id']: row};
    for (final row in incoming) {
      final saved = byId[row['id']];
      if (saved == null) continue;
      PersistenceJson.confirm(row, saved, '$path/${row['id']} conflict');
    }
  }

  void _confirmRows(List<Map<String, dynamic>> expected,
      List<Map<String, dynamic>> actual, String path) {
    final byId = {for (final row in actual) row['id']: row};
    for (final row in expected) {
      PersistenceJson.confirm(row, byId[row['id']], '$path/${row['id']}');
    }
  }
}
