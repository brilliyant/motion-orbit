import 'dart:convert';

enum AssessmentMetric { repetitions, seconds, meters }

class AssessmentRecord {
  const AssessmentRecord({
    required this.id,
    required this.test,
    required this.metric,
    required this.value,
    required this.date,
    this.note = '',
  });

  final String id;
  final String test;
  final AssessmentMetric metric;
  final double value;
  final DateTime date;
  final String note;

  Map<String, Object?> toJson() => {
        'id': id,
        'test': test,
        'metric': metric.name,
        'value': value,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory AssessmentRecord.fromJson(Map<String, Object?> json) =>
      AssessmentRecord(
        id: json['id']! as String,
        test: json['test']! as String,
        metric: AssessmentMetric.values.byName(json['metric']! as String),
        value: (json['value']! as num).toDouble(),
        date: DateTime.parse(json['date']! as String),
        note: json['note'] as String? ?? '',
      );
}

class MeasurementRecord {
  const MeasurementRecord({
    required this.id,
    required this.date,
    this.weightKg,
    this.waistCm,
    this.chestCm,
    this.hipsCm,
    this.leftArmCm,
    this.rightArmCm,
    this.leftThighCm,
    this.rightThighCm,
    this.note = '',
  });

  final String id;
  final DateTime date;
  final double? weightKg;
  final double? waistCm;
  final double? chestCm;
  final double? hipsCm;
  final double? leftArmCm;
  final double? rightArmCm;
  final double? leftThighCm;
  final double? rightThighCm;
  final String note;

  Map<String, Object?> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'weightKg': weightKg,
        'waistCm': waistCm,
        'chestCm': chestCm,
        'hipsCm': hipsCm,
        'leftArmCm': leftArmCm,
        'rightArmCm': rightArmCm,
        'leftThighCm': leftThighCm,
        'rightThighCm': rightThighCm,
        'note': note,
      };

  factory MeasurementRecord.fromJson(Map<String, Object?> json) =>
      MeasurementRecord(
        id: json['id']! as String,
        date: DateTime.parse(json['date']! as String),
        weightKg: (json['weightKg'] as num?)?.toDouble(),
        waistCm: (json['waistCm'] as num?)?.toDouble(),
        chestCm: (json['chestCm'] as num?)?.toDouble(),
        hipsCm: (json['hipsCm'] as num?)?.toDouble(),
        leftArmCm: (json['leftArmCm'] as num?)?.toDouble(),
        rightArmCm: (json['rightArmCm'] as num?)?.toDouble(),
        leftThighCm: (json['leftThighCm'] as num?)?.toDouble(),
        rightThighCm: (json['rightThighCm'] as num?)?.toDouble(),
        note: json['note'] as String? ?? '',
      );
}

enum GoalMetric { assessment, weight, waist }

class FitnessGoal {
  const FitnessGoal({
    required this.id,
    required this.title,
    required this.metric,
    required this.target,
    required this.startingValue,
    required this.targetDate,
    this.assessmentTest,
    this.isPrimary = false,
    this.isComplete = false,
  });

  final String id;
  final String title;
  final GoalMetric metric;
  final double target;
  final double? startingValue;
  final DateTime targetDate;
  final String? assessmentTest;
  final bool isPrimary;
  final bool isComplete;

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'metric': metric.name,
        'target': target,
        'startingValue': startingValue,
        'targetDate': targetDate.toIso8601String(),
        'assessmentTest': assessmentTest,
        'isPrimary': isPrimary,
        'isComplete': isComplete,
      };

  factory FitnessGoal.fromJson(Map<String, Object?> json) => FitnessGoal(
        id: json['id']! as String,
        title: json['title']! as String,
        metric: GoalMetric.values.byName(json['metric']! as String),
        target: (json['target']! as num).toDouble(),
        startingValue: (json['startingValue'] as num?)?.toDouble(),
        targetDate: DateTime.parse(json['targetDate']! as String),
        assessmentTest: json['assessmentTest'] as String?,
        isPrimary: json['isPrimary'] as bool? ?? false,
        isComplete: json['isComplete'] as bool? ?? false,
      );
}

String encodeRecords<T>(Iterable<T> records, Map<String, Object?> Function(T) toJson) =>
    jsonEncode(records.map(toJson).toList());
