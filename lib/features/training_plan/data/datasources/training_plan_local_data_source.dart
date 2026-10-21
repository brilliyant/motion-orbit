import 'dart:convert';

import 'package:objectbox/objectbox.dart';

import '../../../../objectbox.g.dart';
import '../../../profile/data/datasources/objectbox_data_source.dart';
import '../../../profile/data/models/profile_box_entity.dart';

class TrainingPlanLocalDataSource {
  TrainingPlanLocalDataSource({Store? store})
    : _store = store ?? MotionOrbitObjectBox.store;

  static const _storageKey = 'training/plans';

  final Store _store;

  Box<ProfileBoxEntity> get _box => _store.box<ProfileBoxEntity>();

  List<Map<String, dynamic>>? readPlans() {
    final entity = _box
        .query(ProfileBoxEntity_.key.equals(_storageKey))
        .build()
        .findFirst();
    if (entity == null) return null;

    final decoded = jsonDecode(entity.value);
    if (decoded is! List || decoded.any((item) => item is! Map)) {
      throw const FormatException('Saved training plans are invalid.');
    }
    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Map<String, int> readPlanTypeCounts() {
    final plans = readPlans() ?? const <Map<String, dynamic>>[];
    final counts = <String, int>{'All': plans.length};
    for (final plan in plans) {
      final type = (plan['type'] ?? 'Strength').toString();
      counts.update(type, (count) => count + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  void writePlans(List<Map<String, dynamic>> plans) {
    final existing = _box
        .query(ProfileBoxEntity_.key.equals(_storageKey))
        .build()
        .findFirst();
    _box.put(
      ProfileBoxEntity(
        id: existing?.id ?? 0,
        key: _storageKey,
        value: jsonEncode(plans),
      ),
    );
  }
}
