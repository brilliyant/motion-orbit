import 'package:objectbox/objectbox.dart';

import '../../../../core/data/persistence_json.dart';
import '../../../profile/data/models/profile_records.dart';

@Entity()
class FitnessAssessmentEntity {
  @Id()
  int id;
  @Unique()
  String businessId;
  List<String> fields;
  String test;
  String metric;
  double value;
  @Index()
  String dateIso;
  String? note;

  FitnessAssessmentEntity({this.id = 0, required this.businessId,
    required this.fields, required this.test, required this.metric,
    required this.value, required this.dateIso, this.note});

  factory FitnessAssessmentEntity.fromJson(Map<String, dynamic> json) {
    PersistenceJson.keys(json,
        const {'id', 'test', 'metric', 'value', 'date', 'note'}, 'profile/assessments');
    AssessmentRecord.fromJson(json);
    final metric = PersistenceJson.text(json, 'metric');
    if (!AssessmentMetric.values.any((item) => item.name == metric)) {
      throw const FormatException('Invalid assessment metric.');
    }
    return FitnessAssessmentEntity(
      businessId: PersistenceJson.businessId(json),
      fields: json.keys.toList(),
      test: PersistenceJson.text(json, 'test'),
      metric: metric,
      value: PersistenceJson.number(json, 'value', required: true)!,
      dateIso: PersistenceJson.date(json, 'date', required: true)!,
      note: PersistenceJson.optionalText(json, 'note'),
    );
  }

  Map<String, dynamic> toJson() => PersistenceJson.select(fields, {
    'id': businessId, 'test': test, 'metric': metric, 'value': value,
    'date': dateIso, 'note': note,
  });
}
