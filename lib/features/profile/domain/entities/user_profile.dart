import 'dart:math';

import '../../../../core/constants/profile_constants.dart';

/// Domain Entity representing a user's fitness profile.
class UserProfile {
  UserProfile({
    String? id,
    this.name = '',
    this.height = '',
    this.weight = '',
    this.age,
    this.goal,
    this.level,
    this.location,
    this.duration,
    Set<String>? equipment,
    Set<String>? days,
    this.step = 0,
  })  : id = id ?? generateId(),
        equipment = equipment ?? {},
        days = days ?? {};

  final String id;
  String name;
  String height;
  String weight;
  String? age;
  String? goal;
  String? level;
  String? location;
  String? duration;
  final Set<String> equipment;
  final Set<String> days;
  int step;

  static String generateId() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  static String? numericError(
    String text,
    double min,
    double max,
    String unit,
  ) {
    if (text.trim().isEmpty) return null;
    final number = double.tryParse(text.trim().replaceAll(',', '.'));
    if (number == null || !number.isFinite || number < min || number > max) {
      return 'Enter a number from ${min.toInt()} to ${max.toInt()} $unit.';
    }
    return null;
  }

  bool get valid =>
      ProfileConstants.goals.contains(goal) &&
      ProfileConstants.levels.contains(level) &&
      numericError(height, 80, 250, 'cm') == null &&
      numericError(weight, 30, 300, 'kg') == null;
}

