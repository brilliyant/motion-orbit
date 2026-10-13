import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileStore {
  ProfileStore({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepositoryImpl();

  final ProfileRepository _repository;

  LocalProfile? profile;
  LocalProfile draft = LocalProfile();

  Future<void> load() async {
    final result = await _repository.loadProfile();
    if (result == null) return;
    draft = result.draft;
    profile = result.profile;
  }

  Future<void> saveDraft() => _repository.saveDraft(draft, profile);

  Future<void> complete() async {
    profile = await _repository.completeProfile(draft);
  }

  Future<void> recover() async {
    await _repository.recover();
    profile = null;
    draft = LocalProfile();
  }
}

