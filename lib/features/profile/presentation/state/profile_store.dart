import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/profile_use_cases.dart';

class ProfileStore {
  ProfileStore({
    required this._loadProfile,
    required this._saveDraft,
    required this._completeProfile,
    required this._recoverProfile,
  });

  final LoadProfile _loadProfile;
  final SaveProfileDraft _saveDraft;
  final CompleteProfile _completeProfile;
  final RecoverProfile _recoverProfile;

  UserProfile? profile;
  UserProfile draft = UserProfile();

  Future<void> load() async {
    final result = await _loadProfile();
    if (result == null) {
      profile = null;
      draft = UserProfile();
      return;
    }
    draft = result.draft;
    profile = result.profile;
  }

  Future<void> saveDraft() => _saveDraft(draft, profile);

  Future<void> complete() async {
    profile = await _completeProfile(draft);
  }

  Future<void> recover() async {
    await _recoverProfile();
    profile = null;
    draft = UserProfile();
  }
}
