import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<({UserProfile? profile, UserProfile draft})?> loadProfile();
  Future<void> saveDraft(UserProfile draft, UserProfile? profile);
  Future<UserProfile> completeProfile(UserProfile draft);
  Future<void> recover();
}
