import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:motion_orbit/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:motion_orbit/features/profile/data/models/profile_model.dart';
import 'package:motion_orbit/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:motion_orbit/features/profile/domain/entities/user_profile.dart';
import 'package:motion_orbit/features/profile/presentation/state/profile_store.dart';

class FakeProfileLocalDataSource implements ProfileLocalDataSource {
  String? storage;

  @override
  Future<String?> read() async => storage;

  @override
  Future<void> write(String snapshot) async {
    storage = snapshot;
  }

  @override
  Future<void> recover() async {
    storage = null;
  }
}

void main() {
  group('UserProfile Entity Tests', () {
    test('numericError handles empty and valid ranges correctly', () {
      expect(UserProfile.numericError('', 80, 250, 'cm'), isNull);
      expect(UserProfile.numericError('175', 80, 250, 'cm'), isNull);
      expect(UserProfile.numericError('70', 80, 250, 'cm'), isNotNull);
      expect(UserProfile.numericError('abc', 80, 250, 'cm'), isNotNull);
    });

    test('valid returns true only when required fields and numbers are valid', () {
      final profile = UserProfile(id: 'test-1');
      expect(profile.valid, isFalse);

      profile.goal = 'Build Muscle';
      profile.level = 'Intermediate';
      expect(profile.valid, isTrue);

      profile.height = '180';
      profile.weight = '75';
      expect(profile.valid, isTrue);

      profile.height = '500'; // invalid
      expect(profile.valid, isFalse);
    });
  });

  group('ProfileModel & LocalProfile Tests', () {
    test('toJson and fromJson work correctly', () {
      final p = LocalProfile(id: '12345')
        ..name = 'Jordan'
        ..goal = 'Lose Fat'
        ..level = 'Beginner'
        ..equipment.addAll({'Dumbbells', 'Bodyweight'})
        ..days.addAll({'Monday', 'Wednesday'});

      final json = p.toJson();
      final restored = LocalProfile.fromJson(json);

      expect(restored.id, '12345');
      expect(restored.name, 'Jordan');
      expect(restored.goal, 'Lose Fat');
      expect(restored.level, 'Beginner');
      expect(restored.equipment, contains('Dumbbells'));
      expect(restored.days, contains('Monday'));
    });
  });

  group('Clean Architecture Repository & Store Tests', () {
    test('ProfileStore saves draft and completes profile', () async {
      final fakeDataSource = FakeProfileLocalDataSource();
      final repository = ProfileRepositoryImpl(dataSource: fakeDataSource);
      final store = ProfileStore(repository: repository);

      store.draft.name = 'Alex';
      store.draft.goal = 'Build Muscle';
      store.draft.level = 'Advanced';
      await store.saveDraft();

      expect(fakeDataSource.storage, isNotNull);
      final decoded = jsonDecode(fakeDataSource.storage!);
      expect(decoded['version'], 1);
      expect(decoded['completed'], isFalse);

      // Complete profile
      await store.complete();
      expect(store.profile, isNotNull);
      expect(store.profile!.goal, 'Build Muscle');

      final completedDecoded = jsonDecode(fakeDataSource.storage!);
      expect(completedDecoded['completed'], isTrue);

      // Recover
      await store.recover();
      expect(store.profile, isNull);
      expect(fakeDataSource.storage, isNull);
    });
  });
}

