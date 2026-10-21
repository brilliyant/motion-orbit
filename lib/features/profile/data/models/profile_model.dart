import '../../../../core/constants/profile_constants.dart';
import '../../domain/entities/user_profile.dart';

/// Data Model for serialization and persistence of [UserProfile].
class ProfileModel extends UserProfile {
  ProfileModel({
    super.id,
    super.name,
    super.height,
    super.weight,
    super.age,
    super.goal,
    super.level,
    super.location,
    super.duration,
    super.dateOfBirth,
    super.biologicalSex,
    super.primaryEnvironment,
    super.limitations,
    super.equipment,
    super.availableEquipment,
    super.days,
    super.step,
  });

  static const ages = ProfileConstants.ages;
  static const goals = ProfileConstants.goals;
  static const levels = ProfileConstants.levels;
  static const locations = ProfileConstants.locations;
  static const equipmentOptions = ProfileConstants.equipmentOptions;
  static const dayOptions = ProfileConstants.dayOptions;
  static const durations = ProfileConstants.durations;
  static const biologicalSexOptions = ProfileConstants.biologicalSexOptions;
  static const environmentOptions = ProfileConstants.environmentOptions;
  static const availableEquipmentOptions =
      ProfileConstants.availableEquipmentOptions;

  static String? numericError(
    String text,
    double min,
    double max,
    String unit,
  ) => UserProfile.numericError(text, min, max, unit);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'height': height,
    'weight': weight,
    'age': age,
    'goal': goal,
    'level': level,
    'location': location,
    'duration': duration,
    'dateOfBirth': dateOfBirth,
    'biologicalSex': biologicalSex,
    'primaryEnvironment': primaryEnvironment,
    'limitations': limitations,
    'equipment': equipment.toList(),
    'availableEquipment': availableEquipment.toList(),
    'days': days.toList(),
    'step': step,
  };

  factory ProfileModel.fromEntity(UserProfile profile) => ProfileModel(
    id: profile.id,
    name: profile.name,
    height: profile.height,
    weight: profile.weight,
    age: profile.age,
    goal: profile.goal,
    level: profile.level,
    location: profile.location,
    duration: profile.duration,
    dateOfBirth: profile.dateOfBirth,
    biologicalSex: profile.biologicalSex,
    primaryEnvironment: profile.primaryEnvironment,
    limitations: profile.limitations,
    equipment: {...profile.equipment},
    availableEquipment: {...profile.availableEquipment},
    days: {...profile.days},
    step: profile.step,
  );

  factory ProfileModel.fromJson(dynamic value) {
    if (value is! Map<String, dynamic> ||
        value['id'] is! String ||
        (value['id'] as String).isEmpty) {
      throw const FormatException('Invalid profile');
    }
    final p = ProfileModel(id: value['id'] as String);

    String text(String key) {
      final v = value[key];
      if (v is! String) throw FormatException('Invalid $key');
      return v;
    }

    String? choice(String key, List<String> options) {
      final v = value[key];
      if (v == null) return null;
      if (v is! String || !options.contains(v)) {
        throw FormatException('Invalid $key');
      }
      return v;
    }

    String? optionalText(String key) {
      final v = value[key];
      if (v == null) return null;
      if (v is! String) throw FormatException('Invalid $key');
      return v;
    }

    void choices(String key, List<String> options, Set<String> target) {
      final v = value[key];
      if (v is! List ||
          v.any((item) => item is! String || !options.contains(item))) {
        throw FormatException('Invalid $key');
      }
      target.addAll(v.cast<String>());
    }

    void choicesOptional(String key, List<String> options, Set<String> target) {
      final v = value[key];
      if (v == null) return;
      if (v is! List ||
          v.any((item) => item is! String || !options.contains(item))) {
        throw FormatException('Invalid $key');
      }
      target.addAll(v.cast<String>());
    }

    p.name = text('name');
    p.height = text('height');
    p.weight = text('weight');
    p.age = choice('age', ProfileConstants.ages);
    p.goal = choice('goal', ProfileConstants.goals);
    p.level = choice('level', ProfileConstants.levels);
    p.location = choice('location', ProfileConstants.locations);
    p.duration = choice('duration', ProfileConstants.durations);
    p.dateOfBirth = optionalText('dateOfBirth');
    p.biologicalSex = choice('biologicalSex', biologicalSexOptions);
    p.primaryEnvironment = choice('primaryEnvironment', environmentOptions);
    p.limitations = optionalText('limitations') ?? '';
    choices('equipment', ProfileConstants.equipmentOptions, p.equipment);
    choicesOptional(
      'availableEquipment',
      availableEquipmentOptions,
      p.availableEquipment,
    );
    choices('days', ProfileConstants.dayOptions, p.days);

    final step = value['step'];
    if (step is! int || step < 0 || step > 4) {
      throw const FormatException('Invalid step');
    }
    p.step = step;

    if (p.step > 1 &&
        (UserProfile.numericError(p.height, 80, 250, 'cm') != null ||
            UserProfile.numericError(p.weight, 30, 300, 'kg') != null)) {
      p.step = 1;
    }
    if (p.step > 2 &&
        (!ProfileConstants.goals.contains(p.goal) ||
            !ProfileConstants.levels.contains(p.level))) {
      p.step = 2;
    }

    return p;
  }

  @override
  ProfileModel copy() => ProfileModel.fromJson(toJson());
}

/// Backward compatibility alias
class LocalProfile extends ProfileModel {
  LocalProfile({super.id});

  static const ages = ProfileConstants.ages;
  static const goals = ProfileConstants.goals;
  static const levels = ProfileConstants.levels;
  static const locations = ProfileConstants.locations;
  static const equipmentOptions = ProfileConstants.equipmentOptions;
  static const dayOptions = ProfileConstants.dayOptions;
  static const durations = ProfileConstants.durations;
  static const biologicalSexOptions = ProfileModel.biologicalSexOptions;
  static const environmentOptions = ProfileModel.environmentOptions;
  static const availableEquipmentOptions =
      ProfileModel.availableEquipmentOptions;

  static String? numericError(
    String text,
    double min,
    double max,
    String unit,
  ) => UserProfile.numericError(text, min, max, unit);

  factory LocalProfile.fromJson(dynamic value) {
    final model = ProfileModel.fromJson(value);
    final p = LocalProfile(id: model.id);
    p.name = model.name;
    p.height = model.height;
    p.weight = model.weight;
    p.age = model.age;
    p.goal = model.goal;
    p.level = model.level;
    p.location = model.location;
    p.duration = model.duration;
    p.dateOfBirth = model.dateOfBirth;
    p.biologicalSex = model.biologicalSex;
    p.primaryEnvironment = model.primaryEnvironment;
    p.limitations = model.limitations;
    p.equipment.addAll(model.equipment);
    p.availableEquipment.addAll(model.availableEquipment);
    p.days.addAll(model.days);
    p.step = model.step;
    return p;
  }
}
