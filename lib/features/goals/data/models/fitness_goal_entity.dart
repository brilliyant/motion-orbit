import 'package:objectbox/objectbox.dart';

import '../../../../core/data/persistence_json.dart';
import '../../../profile/data/models/profile_records.dart';

@Entity()
class FitnessGoalEntity {
  @Id()
  int id;
  @Unique()
  String businessId;
  List<String> fields;
  String title;
  String metric;
  double target;
  double? startingValue;
  String targetDateIso;
  String? assessmentTest;
  bool isPrimary;
  bool isComplete;

  FitnessGoalEntity({this.id = 0, required this.businessId,
    required this.fields, required this.title, required this.metric,
    required this.target, this.startingValue, required this.targetDateIso,
    this.assessmentTest, required this.isPrimary, required this.isComplete});

  factory FitnessGoalEntity.fromJson(Map<String, dynamic> json) {
    PersistenceJson.keys(json, const {
      'id', 'title', 'metric', 'target', 'startingValue', 'targetDate',
      'assessmentTest', 'isPrimary', 'isComplete',
    }, 'profile/goals');
    FitnessGoal.fromJson(json);
    final metric = PersistenceJson.text(json, 'metric');
    if (!GoalMetric.values.any((item) => item.name == metric)) {
      throw const FormatException('Invalid goal metric.');
    }
    return FitnessGoalEntity(
      businessId: PersistenceJson.businessId(json),
      fields: json.keys.toList(),
      title: PersistenceJson.text(json, 'title'),
      metric: metric,
      target: PersistenceJson.number(json, 'target', required: true)!,
      startingValue: PersistenceJson.number(json, 'startingValue'),
      targetDateIso: PersistenceJson.date(json, 'targetDate', required: true)!,
      assessmentTest: PersistenceJson.optionalText(json, 'assessmentTest'),
      isPrimary: PersistenceJson.boolean(json, 'isPrimary'),
      isComplete: PersistenceJson.boolean(json, 'isComplete'),
    );
  }

  Map<String, dynamic> toJson() => PersistenceJson.select(fields, {
    'id': businessId, 'title': title, 'metric': metric, 'target': target,
    'startingValue': startingValue, 'targetDate': targetDateIso,
    'assessmentTest': assessmentTest, 'isPrimary': isPrimary,
    'isComplete': isComplete,
  });
}
