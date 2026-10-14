import 'package:shared_preferences/shared_preferences.dart';

abstract class ProfileLocalDataSource {
  Future<String?> read();
  Future<void> write(String snapshot);
  Future<void> recover();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  const ProfileLocalDataSourceImpl();

  static const _snapshotKey = 'motion_orbit/local_profile/snapshot';
  static const _recoveredSnapshotKey =
      'motion_orbit/local_profile/unreadable_snapshot';

  @override
  Future<String?> read() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_snapshotKey);
  }

  @override
  Future<void> write(String snapshot) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_snapshotKey, snapshot);
    if (!saved) throw StateError('Could not save the profile locally');
  }

  @override
  Future<void> recover() async {
    final preferences = await SharedPreferences.getInstance();
    final unreadableSnapshot = preferences.getString(_snapshotKey);
    if (unreadableSnapshot != null) {
      final backedUp = await preferences.setString(
        _recoveredSnapshotKey,
        unreadableSnapshot,
      );
      if (!backedUp) {
        throw StateError('Could not preserve the unreadable profile data');
      }
    }
    await preferences.remove(_snapshotKey);
  }
}
