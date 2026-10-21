import 'package:flutter/material.dart';

class TrainingPlan {
  const TrainingPlan({
    required this.id,
    this.isSample = false,
    required this.title,
    required this.type,
    required this.focus,
    required this.date,
    required this.duration,
    required this.volume,
    required this.effort,
    required this.icon,
    required this.accent,
    required this.rpe,
    required this.imageUrl,
    this.description = '',
    this.notes = '',
    this.targetEvent = '',
    this.eventDate,
    this.scheduledDate,
    this.warmUp = const [],
    this.exercises = const [],
    this.coolDown = const [],
  });

  final String id;
  final bool isSample;
  final String title;
  final String type;
  final String focus;
  final String date;
  final String duration;
  final String volume;
  final String effort;
  final IconData icon;
  final Color accent;
  final String rpe;
  final String imageUrl;
  final String description;
  final String notes;
  final String targetEvent;
  final DateTime? eventDate;
  final DateTime? scheduledDate;
  final List<TrainingPlanActivity> warmUp;
  final List<TrainingPlanActivity> exercises;
  final List<TrainingPlanActivity> coolDown;

  Map<String, dynamic> toJson() => {
    'id': id,
    'isSample': isSample,
    'title': title,
    'type': type,
    'focus': focus,
    'date': date,
    'duration': duration,
    'volume': volume,
    'effort': effort,
    'rpe': rpe,
    'imageUrl': imageUrl,
    'iconCodePoint': icon.codePoint,
    'accent': accent.value,
    'description': description,
    'notes': notes,
    'targetEvent': targetEvent,
    'eventDate': eventDate?.toIso8601String(),
    'scheduledDate': scheduledDate?.toIso8601String(),
    'warmUp': warmUp.map((item) => item.toJson()).toList(),
    'exercises': exercises.map((item) => item.toJson()).toList(),
    'coolDown': coolDown.map((item) => item.toJson()).toList(),
  };

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] ?? json['name'] ?? json['planName'] ?? '')
        .toString()
        .trim();
    if (title.isEmpty) {
      throw const FormatException('Every imported plan needs a name.');
    }
    final type = (json['type'] ?? 'Strength').toString();
    final rawRpe = (json['rpe'] ?? 6).toString();
    final effortValue = RegExp(r'\d+').firstMatch(rawRpe)?.group(0) ?? '6';
    final exerciseData =
        json['exercises'] ??
        json['mainExercises'] ??
        json['exerciseList'] ??
        json['sets'] ??
        json['activities'];
    final exercises = _readActivities(exerciseData);
    final exerciseCount = exercises.length;
    final duration = json['duration'] ?? 50;
    return TrainingPlan(
      id: (json['id'] ?? 'plan-${DateTime.now().microsecondsSinceEpoch}')
          .toString(),
      isSample: json['isSample'] == true,
      title: title,
      type: type,
      focus: (json['focus'] ?? json['notes'] ?? 'Imported plan').toString(),
      date: (json['date'] ?? currentTrainingPlanDateLabel()).toString(),
      duration: duration is num
          ? '${duration.round()} min'
          : duration.toString(),
      volume:
          (json['volume'] ??
                  (exerciseCount > 0
                      ? '$exerciseCount exercises'
                      : 'No exercises added'))
              .toString(),
      effort: (json['effort'] ?? 'Target RPE $effortValue').toString(),
      icon: type.toLowerCase() == 'running'
          ? Icons.directions_run
          : Icons.fitness_center,
      accent: type.toLowerCase() == 'running'
          ? const Color(0xFF34D399)
          : const Color(0xFF84CC16),
      rpe: 'RPE $effortValue',
      imageUrl: (json['imageUrl'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
      targetEvent: (json['targetEvent'] ?? '').toString(),
      eventDate: DateTime.tryParse((json['eventDate'] ?? '').toString()),
      scheduledDate: DateTime.tryParse(
        (json['scheduledDate'] ?? '').toString(),
      ),
      warmUp: _readActivities(json['warmUp']),
      exercises: exercises,
      coolDown: _readActivities(json['coolDown']),
    );
  }

  TrainingPlan copyWith({String? id, String? title}) => TrainingPlan(
    id: id ?? this.id,
    isSample: isSample,
    title: title ?? this.title,
    type: type,
    focus: focus,
    date: date,
    duration: duration,
    volume: volume,
    effort: effort,
    icon: icon,
    accent: accent,
    rpe: rpe,
    imageUrl: imageUrl,
    description: description,
    notes: notes,
    targetEvent: targetEvent,
    eventDate: eventDate,
    scheduledDate: scheduledDate,
    warmUp: warmUp,
    exercises: exercises,
    coolDown: coolDown,
  );
}

List<TrainingPlanActivity> _readActivities(dynamic value) {
  if (value is Map) {
    final isActivity =
        value.containsKey('name') ||
        value.containsKey('exercise') ||
        value.containsKey('title');
    if (isActivity) {
      return [
        TrainingPlanActivity.fromJson(Map<String, dynamic>.from(value)),
      ];
    }
    for (final key in const ['items', 'activities', 'exercises', 'sets']) {
      final nested = value[key];
      if (nested is List || nested is Map) return _readActivities(nested);
    }
    return value.values.expand(_readActivities).toList();
  }

  if (value is! List) return const [];
  return value.expand((item) {
    if (item is Map) {
      return _readActivities(item);
    }
    if (item is String && item.trim().isNotEmpty) {
      return [TrainingPlanActivity(name: item.trim())];
    }
    return const <TrainingPlanActivity>[];
  }).toList();
}

class TrainingPlanActivity {
  const TrainingPlanActivity({
    required this.name,
    this.muscles = '',
    this.sets = '3',
    this.reps = '8-12',
    this.weight = '',
    this.rest = '90s',
    this.duration = '',
    this.notes = '',
  });

  final String name;
  final String muscles;
  final String sets;
  final String reps;
  final String weight;
  final String rest;
  final String duration;
  final String notes;

  String get summary => duration.isNotEmpty
      ? duration
      : sets.isEmpty && reps.isEmpty
      ? 'Duration not set'
      : '$sets × $reps${weight.isEmpty ? '' : ' • $weight'} • ${rest.isEmpty ? 'No rest set' : rest}';

  Map<String, dynamic> toJson() => {
    'name': name,
    'muscles': muscles,
    'sets': sets,
    'reps': reps,
    'weight': weight,
    'rest': rest,
    'duration': duration,
    'notes': notes,
  };

  factory TrainingPlanActivity.fromJson(Map<String, dynamic> json) => TrainingPlanActivity(
    name: (json['name'] ?? json['exercise'] ?? json['title'] ?? 'Activity')
        .toString(),
    muscles: (json['muscles'] ?? json['muscle'] ?? '').toString(),
    sets: (json['sets'] ?? '3').toString(),
    reps: (json['reps'] ?? '').toString(),
    weight: (json['weight'] ?? json['targetWeight'] ?? '').toString(),
    rest: (json['rest'] ?? '90s').toString(),
    duration: (json['duration'] ?? '').toString(),
    notes: (json['notes'] ?? '').toString(),
  );
}

String currentTrainingPlanDateLabel() {
  final date = DateTime.now();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}

String trainingPlanDateLabel(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

