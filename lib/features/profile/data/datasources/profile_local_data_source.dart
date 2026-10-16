import 'package:shared_preferences/shared_preferences.dart';

import '../../../../objectbox.g.dart';
import 'objectbox_data_source.dart';
import '../models/profile_box_entity.dart';

abstract class ProfileLocalDataSource {
  Future<String?> read();
  Future<void> write(String snapshot);
  Future<void> recover();
}

/// Stores the profile snapshot in ObjectBox and migrates older preference data
/// the first time it is read.
class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  ProfileLocalDataSourceImpl({Store? store})
    : _store = store ?? MotionOrbitObjectBox.store;

  static const _snapshotKey = 'profile/snapshot';
  static const _recoveredSnapshotKey = 'profile/unreadable_snapshot';
  static const _legacyRecoveredSnapshotKey =
      'profile/legacy_unreadable_snapshot';
  static const _legacySnapshotKey = 'motion_orbit/local_profile/snapshot';
  static const _legacyRecoveredKey =
      'motion_orbit/local_profile/unreadable_snapshot';

  final Store _store;

  Box<ProfileBoxEntity> get _box => _store.box<ProfileBoxEntity>();

  ProfileBoxEntity? _find(String key) =>
      _box.query(ProfileBoxEntity_.key.equals(key)).build().findFirst();

  void _put(String key, String value) {
    final existing = _find(key);
    _box.put(ProfileBoxEntity(id: existing?.id ?? 0, key: key, value: value));
  }

  @override
  Future<String?> read() async {
    final saved = _find(_snapshotKey);
    if (saved != null) return saved.value;

    // Existing installations stored this snapshot in SharedPreferences.
    final preferences = await SharedPreferences.getInstance();
    final legacy = preferences.getString(_legacySnapshotKey);
    if (legacy == null) return null;

    _put(_snapshotKey, legacy);
    await preferences.remove(_legacySnapshotKey);
    return legacy;
  }

  @override
  Future<void> write(String snapshot) async {
    _put(_snapshotKey, snapshot);
  }

  @override
  Future<void> recover() async {
    final saved = _find(_snapshotKey);
    if (saved != null) {
      _put(_recoveredSnapshotKey, saved.value);
      _box.remove(saved.id);
    }

    final preferences = await SharedPreferences.getInstance();
    final legacy = preferences.getString(_legacySnapshotKey);
    if (legacy != null) {
      if (saved == null) _put(_recoveredSnapshotKey, legacy);
      await preferences.remove(_legacySnapshotKey);
    }

    // Preserve backups created by the previous SharedPreferences version.
    final legacyBackup = preferences.getString(_legacyRecoveredKey);
    if (legacyBackup != null) {
      _put(_legacyRecoveredSnapshotKey, legacyBackup);
      await preferences.remove(_legacyRecoveredKey);
    }
  }
}
