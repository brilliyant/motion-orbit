import 'dart:convert';

import '../../../../core/data/persistence_json.dart';
import '../../../../objectbox.g.dart';
import 'objectbox_data_source.dart';
import '../models/profile_box_entity.dart';
import '../models/profile_entity.dart';

abstract class ProfileLocalDataSource {
  Future<String?> read();
  Future<void> write(String snapshot);
  Future<void> recover();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  ProfileLocalDataSourceImpl({Store? store})
    : _store = store ?? MotionOrbitObjectBox.store;

  final Store _store;

  ProfileEntity? _findSlot(String slot) {
    final query = _store.box<ProfileEntity>()
        .query(ProfileEntity_.slot.equals(slot)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

  Map<String, dynamic>? readSnapshot() {
    final state = _store.box<ProfileStateEntity>().get(1);
    if (state == null) {
      if (_store.box<ProfileEntity>().count() != 0) {
        throw const FormatException('Profile state is missing.');
      }
      return null;
    }
    final draft = _findSlot('draft');
    if (draft == null) throw const FormatException('Saved draft is missing.');
    final snapshot = ProfileSnapshot(state, draft, _findSlot('profile')).toJson();
    ProfileSnapshot.fromJson(snapshot);
    return snapshot;
  }

  void putSnapshot(ProfileSnapshot snapshot) {
    final box = _store.box<ProfileEntity>();
    snapshot.draft.id = _findSlot('draft')?.id ?? 0;
    box.put(snapshot.draft);
    final oldProfile = _findSlot('profile');
    final profile = snapshot.profile;
    if (profile != null) {
      profile.id = oldProfile?.id ?? 0;
      box.put(profile);
    } else if (oldProfile != null) {
      box.remove(oldProfile.id);
    }
    _store.box<ProfileStateEntity>().put(snapshot.state);
  }

  @override
  Future<String?> read() async {
    final snapshot = readSnapshot();
    return snapshot == null ? null : jsonEncode(snapshot);
  }

  @override
  Future<void> write(String snapshot) async {
    final json = PersistenceJson.decodeObject(snapshot, 'profile/snapshot');
    final mapped = ProfileSnapshot.fromJson(json);
    _store.runInTransaction(TxMode.write, () {
      putSnapshot(mapped);
      PersistenceJson.confirm(json, readSnapshot(), 'profile/snapshot');
    });
  }

  @override
  Future<void> recover() async {
    // This is an explicit user recovery action, never an upgrade fallback.
    _store.runInTransaction(TxMode.write, () {
      final state = _store.box<ProfileStateEntity>().get(1);
      final profiles = _store.box<ProfileEntity>().getAll();
      final raw = jsonEncode({
        'version': state?.version,
        'completed': state?.completed,
        'profiles': [for (final profile in profiles) {
          'slot': profile.slot, 'value': profile.toJson(),
        }],
      });
      _store.box<ProfileBoxEntity>().put(ProfileBoxEntity(
        key: 'profile/recovery/${DateTime.now().microsecondsSinceEpoch}', value: raw,
      ));
      _store.box<ProfileEntity>().removeAll();
      _store.box<ProfileStateEntity>().removeAll();
    });
  }
}
