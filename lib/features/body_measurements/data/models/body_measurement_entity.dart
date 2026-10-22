import 'package:objectbox/objectbox.dart';

import '../../../../core/data/persistence_json.dart';

@Entity()
class BodyMeasurementEntity {
  @Id()
  int id;
  @Unique()
  String businessId;
  List<String> fields;
  @Index()
  String dateIso;
  double? weightKg;
  double? waistCm;
  double? chestCm;
  double? hipsCm;
  double? leftArmCm;
  double? rightArmCm;
  double? leftThighCm;
  double? rightThighCm;
  double? bodyFatPercent;
  double? muscleMassKg;
  String? bodyFatSource;
  String? note;

  BodyMeasurementEntity({
    this.id = 0,
    required this.businessId,
    required this.fields,
    required this.dateIso,
    this.weightKg,
    this.waistCm,
    this.chestCm,
    this.hipsCm,
    this.leftArmCm,
    this.rightArmCm,
    this.leftThighCm,
    this.rightThighCm,
    this.bodyFatPercent,
    this.muscleMassKg,
    this.bodyFatSource,
    this.note,
  });

  factory BodyMeasurementEntity.fromJson(Map<String, dynamic> json) {
    PersistenceJson.keys(json, const {
      'id', 'date', 'weightKg', 'waistCm', 'chestCm', 'hipsCm', 'leftArmCm',
      'rightArmCm', 'leftThighCm', 'rightThighCm', 'bodyFatPercent',
      'muscleMassKg', 'bodyFatSource', 'note',
    }, 'profile/measurements');
    return BodyMeasurementEntity(
      businessId: PersistenceJson.businessId(json),
      fields: json.keys.toList(),
      dateIso: PersistenceJson.date(json, 'date', required: true)!,
      weightKg: PersistenceJson.number(json, 'weightKg'),
      waistCm: PersistenceJson.number(json, 'waistCm'),
      chestCm: PersistenceJson.number(json, 'chestCm'),
      hipsCm: PersistenceJson.number(json, 'hipsCm'),
      leftArmCm: PersistenceJson.number(json, 'leftArmCm'),
      rightArmCm: PersistenceJson.number(json, 'rightArmCm'),
      leftThighCm: PersistenceJson.number(json, 'leftThighCm'),
      rightThighCm: PersistenceJson.number(json, 'rightThighCm'),
      bodyFatPercent: PersistenceJson.number(json, 'bodyFatPercent'),
      muscleMassKg: PersistenceJson.number(json, 'muscleMassKg'),
      bodyFatSource: PersistenceJson.optionalText(json, 'bodyFatSource'),
      note: PersistenceJson.optionalText(json, 'note'),
    );
  }

  Map<String, dynamic> toJson() => PersistenceJson.select(fields, {
    'id': businessId,
    'date': dateIso,
    'weightKg': weightKg,
    'waistCm': waistCm,
    'chestCm': chestCm,
    'hipsCm': hipsCm,
    'leftArmCm': leftArmCm,
    'rightArmCm': rightArmCm,
    'leftThighCm': leftThighCm,
    'rightThighCm': rightThighCm,
    'bodyFatPercent': bodyFatPercent,
    'muscleMassKg': muscleMassKg,
    'bodyFatSource': bodyFatSource,
    'note': note,
  });
}
