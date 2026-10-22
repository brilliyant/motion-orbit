import 'dart:convert';

import 'package:objectbox/objectbox.dart';

import '../../../../core/data/persistence_json.dart';

@Entity()
class TrainingPlanEntity {
  @Id()
  int id;
  @Unique()
  String businessId;
  List<String> fields;
  int position;
  bool isSample;
  String title;
  @Index()
  String type;
  String focus;
  String date;
  String duration;
  String volume;
  String effort;
  String rpe;
  String imageUrl;
  int iconCodePoint;
  int accent;
  String description;
  String notes;
  String targetEvent;
  String? eventDateIso;
  String? scheduledDateIso;

  TrainingPlanEntity({this.id = 0, required this.businessId,
    required this.fields, required this.position, required this.isSample,
    required this.title, required this.type, required this.focus,
    required this.date, required this.duration, required this.volume,
    required this.effort, required this.rpe, required this.imageUrl,
    required this.iconCodePoint, required this.accent,
    required this.description, required this.notes, required this.targetEvent,
    this.eventDateIso, this.scheduledDateIso});

  factory TrainingPlanEntity.fromJson(Map<String, dynamic> json, int position) {
    PersistenceJson.keys(json, const {
      'id', 'isSample', 'title', 'type', 'focus', 'date', 'duration', 'volume',
      'effort', 'rpe', 'imageUrl', 'iconCodePoint', 'accent', 'description',
      'notes', 'targetEvent', 'eventDate', 'scheduledDate', 'warmUp',
      'exercises', 'coolDown',
    }, 'training/plans');
    final title = PersistenceJson.text(json, 'title');
    if (title.trim().isEmpty) throw const FormatException('Missing plan title.');
    return TrainingPlanEntity(
      businessId: PersistenceJson.businessId(json), fields: json.keys.toList(),
      position: position, isSample: PersistenceJson.boolean(json, 'isSample'),
      title: title, type: PersistenceJson.text(json, 'type', fallback: 'Strength'),
      focus: PersistenceJson.text(json, 'focus'),
      date: PersistenceJson.text(json, 'date'),
      duration: PersistenceJson.text(json, 'duration'),
      volume: PersistenceJson.text(json, 'volume'),
      effort: PersistenceJson.text(json, 'effort'),
      rpe: PersistenceJson.text(json, 'rpe'),
      imageUrl: PersistenceJson.text(json, 'imageUrl'),
      iconCodePoint: PersistenceJson.integer(json, 'iconCodePoint'),
      accent: PersistenceJson.integer(json, 'accent'),
      description: PersistenceJson.text(json, 'description'),
      notes: PersistenceJson.text(json, 'notes'),
      targetEvent: PersistenceJson.text(json, 'targetEvent'),
      eventDateIso: PersistenceJson.date(json, 'eventDate'),
      scheduledDateIso: PersistenceJson.date(json, 'scheduledDate'),
    );
  }

  Map<String, dynamic> toJson(List<TrainingPlanActivityEntity> activities) =>
      PersistenceJson.select(fields, {
    'id': businessId, 'isSample': isSample, 'title': title, 'type': type,
    'focus': focus, 'date': date, 'duration': duration, 'volume': volume,
    'effort': effort, 'rpe': rpe, 'imageUrl': imageUrl,
    'iconCodePoint': iconCodePoint, 'accent': accent,
    'description': description, 'notes': notes, 'targetEvent': targetEvent,
    'eventDate': eventDateIso, 'scheduledDate': scheduledDateIso,
    for (final section in TrainingPlanActivityEntity.sections)
      section: (activities.where((item) => item.section == section).toList()
            ..sort((a, b) => a.position.compareTo(b.position)))
          .map((item) => item.toJson()).toList(),
  });
}

@Entity()
class TrainingPlanActivityEntity {
  static const sections = ['warmUp', 'exercises', 'coolDown'];

  @Id()
  int id;
  // Legacy activities have no business ID. Their plan, section and ordinal
  // form a deterministic key that is safe to use again on a migration retry.
  @Unique()
  String recordKey;
  final plan = ToOne<TrainingPlanEntity>();
  String section;
  int position;
  List<String> fields;
  String name;
  String muscles;
  String sets;
  String reps;
  String weight;
  String rest;
  String duration;
  String notes;

  TrainingPlanActivityEntity({this.id = 0, required this.recordKey,
    required this.section, required this.position, required this.fields,
    required this.name, required this.muscles, required this.sets,
    required this.reps, required this.weight, required this.rest,
    required this.duration, required this.notes});

  factory TrainingPlanActivityEntity.fromJson(Map<String, dynamic> json,
      String recordKey, String section, int position) {
    PersistenceJson.keys(json, const {
      'name', 'muscles', 'sets', 'reps', 'weight', 'rest', 'duration', 'notes',
    }, 'training/plans/$recordKey');
    return TrainingPlanActivityEntity(
      recordKey: recordKey, section: section, position: position,
      fields: json.keys.toList(), name: PersistenceJson.text(json, 'name'),
      muscles: PersistenceJson.text(json, 'muscles'),
      sets: PersistenceJson.text(json, 'sets'),
      reps: PersistenceJson.text(json, 'reps'),
      weight: PersistenceJson.text(json, 'weight'),
      rest: PersistenceJson.text(json, 'rest'),
      duration: PersistenceJson.text(json, 'duration'),
      notes: PersistenceJson.text(json, 'notes'),
    );
  }
  Map<String, dynamic> toJson() => PersistenceJson.select(fields, {
    'name': name, 'muscles': muscles, 'sets': sets, 'reps': reps,
    'weight': weight, 'rest': rest, 'duration': duration, 'notes': notes,
  });
}

class TrainingPlanRecord {
  TrainingPlanRecord(this.plan, this.activities);

  final TrainingPlanEntity plan;
  final List<TrainingPlanActivityEntity> activities;

  factory TrainingPlanRecord.fromJson(Map<String, dynamic> json, int position) {
    final plan = TrainingPlanEntity.fromJson(json, position);
    final activities = <TrainingPlanActivityEntity>[];
    for (final section in TrainingPlanActivityEntity.sections) {
      if (!json.containsKey(section)) continue;
      final rows = PersistenceJson.records(json[section], 'plan/${plan.businessId}/$section');
      for (var i = 0; i < rows.length; i++) {
        activities.add(TrainingPlanActivityEntity.fromJson(rows[i],
            jsonEncode([plan.businessId, section, i]), section, i));
      }
    }
    return TrainingPlanRecord(plan, activities);
  }
}
