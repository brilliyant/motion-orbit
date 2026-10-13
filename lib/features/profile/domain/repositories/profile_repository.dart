import '../../data/models/profile_model.dart';

abstract class ProfileRepository {
  Future<({LocalProfile? profile, LocalProfile draft})?> loadProfile();
  Future<void> saveDraft(LocalProfile draft, LocalProfile? profile);
  Future<LocalProfile> completeProfile(LocalProfile draft);
  Future<void> recover();
}

