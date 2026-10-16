import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class LoadProfile {
  const LoadProfile(this._repository);
  final ProfileRepository _repository;

  Future<({UserProfile? profile, UserProfile draft})?> call() =>
      _repository.loadProfile();
}

class SaveProfileDraft {
  const SaveProfileDraft(this._repository);
  final ProfileRepository _repository;

  Future<void> call(UserProfile draft, UserProfile? profile) =>
      _repository.saveDraft(draft, profile);
}

class CompleteProfile {
  const CompleteProfile(this._repository);
  final ProfileRepository _repository;

  Future<UserProfile> call(UserProfile draft) =>
      _repository.completeProfile(draft);
}

class RecoverProfile {
  const RecoverProfile(this._repository);
  final ProfileRepository _repository;

  Future<void> call() => _repository.recover();
}
