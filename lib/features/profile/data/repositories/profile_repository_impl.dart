import 'dart:convert';

import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../datasources/profile_local_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({ProfileLocalDataSource? dataSource})
    : _dataSource = dataSource ?? ProfileLocalDataSourceImpl();

  final ProfileLocalDataSource _dataSource;
  Future<void> _writes = Future<void>.value();

  @override
  Future<({UserProfile? profile, UserProfile draft})?> loadProfile() async {
    final raw = await _dataSource.read();
    if (raw == null) return null;
    final value = jsonDecode(raw);
    if (value is! Map<String, dynamic> ||
        value['version'] != 1 ||
        value['completed'] is! bool) {
      throw const FormatException('Invalid saved setup');
    }
    final savedDraft = ProfileModel.fromJson(value['draft']);
    UserProfile? savedProfile;
    if (value['profile'] != null) {
      savedProfile = ProfileModel.fromJson(value['profile']);
    }
    if (value['completed'] == true &&
        (savedProfile == null || !savedProfile.valid)) {
      throw const FormatException('Incomplete saved profile');
    }
    if (value['completed'] == false && savedProfile != null) {
      throw const FormatException('Inconsistent saved setup');
    }
    return (profile: savedProfile, draft: savedDraft);
  }

  Future<void> _write(String snapshot) {
    final operation = _writes.then((_) async {
      await _dataSource.write(snapshot);
    });
    _writes = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  String _snapshot(UserProfile? savedProfile, UserProfile savedDraft) =>
      jsonEncode({
        'version': 1,
        'completed': savedProfile != null,
        'profile': savedProfile == null
            ? null
            : ProfileModel.fromEntity(savedProfile).toJson(),
        'draft': ProfileModel.fromEntity(savedDraft).toJson(),
      });

  @override
  Future<void> saveDraft(UserProfile draft, UserProfile? profile) =>
      _write(_snapshot(profile, draft));

  @override
  Future<UserProfile> completeProfile(UserProfile draft) async {
    if (!draft.valid) {
      throw const FormatException('Complete the required profile choices');
    }
    final saved = ProfileModel.fromEntity(draft);
    await _write(_snapshot(saved, saved));
    return saved;
  }

  @override
  Future<void> recover() => _dataSource.recover();
}
