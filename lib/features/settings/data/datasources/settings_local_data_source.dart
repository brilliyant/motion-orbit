import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/data/persistence_json.dart';
import '../../../../objectbox.g.dart';
import '../../../body_measurements/data/models/body_measurement_entity.dart';
import '../../../fitness_assessment/data/models/fitness_assessment_entity.dart';
import '../../../goals/data/models/fitness_goal_entity.dart';
import '../../../profile/data/datasources/objectbox_data_source.dart';
import '../../../profile/data/datasources/objectbox_entity_migration.dart';
import '../../../profile/data/datasources/profile_local_data_source.dart';
import '../../../profile/data/datasources/profile_records_data_source.dart';
import '../../../profile/data/models/profile_box_entity.dart';
import '../../../profile/data/models/profile_entity.dart';
import '../../../training_plan/data/datasources/training_plan_local_data_source.dart';
import '../../../training_plan/data/models/training_plan_entity.dart';
import '../../domain/entities/app_settings.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource({Store? store}) : _providedStore = store;

  static const _themeKey = 'settings/theme_mode';
  static const _unitsKey = 'settings/measurement_units';
  static const _legacyUnitsKey = 'motion_orbit/profile_units';
  static const _profileKeys = {
    'profile/snapshot', 'profile/assessments', 'profile/measurements', 'profile/goals',
  };

  final Store? _providedStore;
  // Startup creates Settings before opening storage so migration failures can
  // be displayed with Retry instead of failing before runApp.
  Store get _store => _providedStore ?? MotionOrbitObjectBox.store;
  Box<ProfileBoxEntity> get _box => _store.box<ProfileBoxEntity>();

  ProfileBoxEntity? _find(String key) {
    final query = _box.query(ProfileBoxEntity_.key.equals(key)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

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
    _write(_unitsKey, units.name);
    await (await SharedPreferences.getInstance()).setString(_legacyUnitsKey, units.name);
  }

  Stream<LocalDataSummary> watchLocalData() async* {
    yield _summarize();
    const observed = {
      ProfileEntity, ProfileStateEntity, BodyMeasurementEntity,
      FitnessAssessmentEntity, FitnessGoalEntity,
    };
    yield* _store.entityChanges
        .where((types) => types.any(observed.contains))
        .map((_) => _summarize());
  }

  Map<String, Object?> _backupData() {
    final records = ProfileRecordsDataSource(store: _store);
    final snapshot = ProfileLocalDataSourceImpl(store: _store).readSnapshot();
    final plans = TrainingPlanLocalDataSource(store: _store).readPlans();
    final theme = _find(_themeKey)?.value;
    final units = _find(_unitsKey)?.value;
    return {
      if (snapshot != null) 'profile/snapshot': snapshot,
      'profile/assessments': records.assessmentRows(),
      'profile/measurements': records.measurementRows(),
      'profile/goals': records.goalRows(),
      if (plans != null) 'training/plans': plans,
      if (theme != null) _themeKey: theme,
      if (units != null) _unitsKey: units,
    };
  }

  String exportJsonBackup() => jsonEncode({
    'format': 'motion_orbit_backup',
    'version': 1,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'data': _store.runInTransaction(TxMode.read, _backupData),
  });

  String exportCsvBackup() {
    final data = _store.runInTransaction(TxMode.read, _backupData);
    final rows = <List<String>>[['collection', 'record']];
    for (final entry in data.entries) {
      final value = entry.value;
      if (value is List) {
        for (final record in value) {
          rows.add([entry.key, jsonEncode(record)]);
        }
        continue;
      }
      rows.add([entry.key, jsonEncode(value)]);
    }
    return rows.map((row) => row.map(_csvCell).join(',')).join('\r\n');
  }

  Future<void> restoreJsonBackup(String backup) async {
    final decoded = PersistenceJson.decodeObject(backup, 'backup');
    if (decoded['format'] != 'motion_orbit_backup' ||
        decoded['version'] != 1 || decoded['data'] is! Map) {
      throw const FormatException('This is not a supported Motion Orbit backup.');
    }
    final data = PersistenceJson.object(decoded['data'], 'backup/data');
    PersistenceJson.keys(data, {
      ..._profileKeys, 'training/plans', _themeKey, _unitsKey,
    }, 'backup/data');
    if (data.isEmpty) throw const FormatException('The backup is empty.');

    // Prepare and validate every record before clearing or replacing anything.
    final snapshotJson = data.containsKey('profile/snapshot')
        ? PersistenceJson.object(data['profile/snapshot'], 'profile/snapshot') : null;
    final snapshot = snapshotJson == null ? null : ProfileSnapshot.fromJson(snapshotJson);
    List<Map<String, dynamic>> rows(String key) {
      if (!data.containsKey(key)) return [];
      final result = PersistenceJson.records(data[key], key);
      PersistenceJson.uniqueIds(result, key);
      return result;
    }
    final measurementJson = rows('profile/measurements');
    final measurements = measurementJson.map(BodyMeasurementEntity.fromJson).toList();
    final assessmentJson = rows('profile/assessments');
    final assessments = assessmentJson.map(FitnessAssessmentEntity.fromJson).toList();
    final goalJson = rows('profile/goals');
    final goals = goalJson.map(FitnessGoalEntity.fromJson).toList();
    final planJson = rows('training/plans');
    final plans = [for (var i = 0; i < planJson.length; i++)
      TrainingPlanRecord.fromJson(planJson[i], i)];

    final theme = data[_themeKey];
    final units = data[_unitsKey];
    if (data.containsKey(_themeKey) && !{'system', 'light', 'dark'}.contains(theme)) {
      throw const FormatException('Invalid backup theme.');
    }
    if (data.containsKey(_unitsKey) && !{'metric', 'imperial'}.contains(units)) {
      throw const FormatException('Invalid backup units.');
    }
    final preferences = await SharedPreferences.getInstance();
    final records = ProfileRecordsDataSource(store: _store);
    final profileSource = ProfileLocalDataSourceImpl(store: _store);
    final planSource = TrainingPlanLocalDataSource(store: _store);
    _store.runInTransaction(TxMode.write, () {
      if (data.keys.any(_profileKeys.contains)) {
        _clearTypedProfile();
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
        PersistenceJson.confirm(snapshotJson, profileSource.readSnapshot(), 'restored profile');
        PersistenceJson.confirm(measurementJson, records.measurementRows(), 'restored measurements');
        PersistenceJson.confirm(assessmentJson, records.assessmentRows(), 'restored assessments');
        PersistenceJson.confirm(goalJson, records.goalRows(), 'restored goals');
      }
      if (data.containsKey('training/plans')) {
        _store.box<TrainingPlanActivityEntity>().removeAll();
        _store.box<TrainingPlanEntity>().removeAll();
        for (final record in plans) {
          planSource.putPlan(record);
        }
        planSource.markInitialized();
        PersistenceJson.confirm(planJson, planSource.readPlans(), 'restored plans');
      }
      if (theme != null) _write(_themeKey, theme as String);
      if (units != null) _write(_unitsKey, units as String);
    });
    if (units != null) await preferences.setString(_legacyUnitsKey, units as String);
  }

  void _clearTypedProfile() {
    _store.box<ProfileEntity>().removeAll();
    _store.box<ProfileStateEntity>().removeAll();
    _store.box<BodyMeasurementEntity>().removeAll();
    _store.box<FitnessAssessmentEntity>().removeAll();
    _store.box<FitnessGoalEntity>().removeAll();
  }

  Future<void> resetLocalProfileData() async {
    final preferences = await SharedPreferences.getInstance();
    // Only invoked by the existing explicit reset flow, never by migration.
    _store.runInTransaction(TxMode.write, () {
      _clearTypedProfile();
      for (final entity in _box.getAll()) {
        if (entity.key.startsWith('profile/')) _box.remove(entity.id);
      }
      // Retain the migration marker so rollback copies cannot be re-imported.
    });
    await preferences.remove(ObjectBoxEntityMigration.legacyPreferenceKey);
    await preferences.remove('motion_orbit/local_profile/unreadable_snapshot');
  }

  String _csvCell(String value) => '"${value.replaceAll('"', '""')}"';

  LocalDataSummary _summarize() => LocalDataSummary(
    profileSaved: _store.box<ProfileStateEntity>().get(1) != null,
    assessments: _store.box<FitnessAssessmentEntity>().count(),
    measurements: _store.box<BodyMeasurementEntity>().count(),
    goals: _store.box<FitnessGoalEntity>().count(),
  );
}
