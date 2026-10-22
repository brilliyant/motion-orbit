import 'package:objectbox/objectbox.dart';

import '../../../../core/data/persistence_json.dart';
import 'profile_model.dart';

@Entity()
class ProfileStateEntity {
  @Id(assignable: true)
  int id;
  int version;
  bool completed;

  ProfileStateEntity({this.id = 1, required this.version, required this.completed});
}

/// Draft and completed profile are distinct snapshots, often sharing a business
/// ID. The unique slot, rather than that shared ID, identifies each snapshot.
@Entity()
class ProfileEntity {
  @Id()
  int id;
  @Unique()
  String slot;
  @Index()
  String businessId;
  List<String> fields;
  String name;
  String height;
  String weight;
  String? age;
  String? goal;
  String? level;
  String? location;
  String? duration;
  String? dateOfBirth;
  String? biologicalSex;
  String? primaryEnvironment;
  String? limitations;
  List<String> equipment;
  List<String> availableEquipment;
  List<String> days;
  int step;

  ProfileEntity({
    this.id = 0,
    required this.slot,
    required this.businessId,
    required this.fields,
    required this.name,
    required this.height,
    required this.weight,
    this.age,
    this.goal,
    this.level,
    this.location,
    this.duration,
    this.dateOfBirth,
    this.biologicalSex,
    this.primaryEnvironment,
    this.limitations,
    required this.equipment,
    required this.availableEquipment,
    required this.days,
    required this.step,
  });

  factory ProfileEntity.fromJson(String slot, Map<String, dynamic> json) {
    PersistenceJson.keys(json, const {
      'id', 'name', 'height', 'weight', 'age', 'goal', 'level', 'location',
      'duration', 'dateOfBirth', 'biologicalSex', 'primaryEnvironment',
      'limitations', 'equipment', 'availableEquipment', 'days', 'step',
    }, 'profile/$slot');
    // Validate against the existing repository's profile schema, but persist
    // original values instead of its normalizing/defaulting conversion.
    ProfileModel.fromJson(json);
    return ProfileEntity(
      slot: slot,
      businessId: PersistenceJson.businessId(json),
      fields: json.keys.toList(),
      name: PersistenceJson.text(json, 'name'),
      height: PersistenceJson.text(json, 'height'),
      weight: PersistenceJson.text(json, 'weight'),
      age: PersistenceJson.optionalText(json, 'age'),
      goal: PersistenceJson.optionalText(json, 'goal'),
      level: PersistenceJson.optionalText(json, 'level'),
      location: PersistenceJson.optionalText(json, 'location'),
      duration: PersistenceJson.optionalText(json, 'duration'),
      dateOfBirth: PersistenceJson.optionalText(json, 'dateOfBirth'),
      biologicalSex: PersistenceJson.optionalText(json, 'biologicalSex'),
      primaryEnvironment: PersistenceJson.optionalText(json, 'primaryEnvironment'),
      limitations: PersistenceJson.optionalText(json, 'limitations'),
      equipment: PersistenceJson.strings(json, 'equipment'),
      availableEquipment: PersistenceJson.strings(json, 'availableEquipment'),
      days: PersistenceJson.strings(json, 'days'),
      step: PersistenceJson.integer(json, 'step'),
    );
  }

  Map<String, dynamic> toJson() => PersistenceJson.select(fields, {
    'id': businessId,
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
    'equipment': equipment,
    'availableEquipment': availableEquipment,
    'days': days,
    'step': step,
  });
}

class ProfileSnapshot {
  ProfileSnapshot(this.state, this.draft, this.profile);

  final ProfileStateEntity state;
  final ProfileEntity draft;
  final ProfileEntity? profile;

  factory ProfileSnapshot.fromJson(Map<String, dynamic> json) {
    PersistenceJson.keys(json,
        const {'version', 'completed', 'profile', 'draft'}, 'profile/snapshot');
    if (json['version'] != 1 || json['completed'] is! bool ||
        !json.containsKey('profile')) {
      throw const FormatException('Invalid saved setup.');
    }
    final completed = json['completed'] as bool;
    final draft = ProfileEntity.fromJson(
        'draft', PersistenceJson.object(json['draft'], 'profile/draft'));
    final profile = json['profile'] == null ? null : ProfileEntity.fromJson(
        'profile', PersistenceJson.object(json['profile'], 'profile/profile'));
    if (completed != (profile != null) ||
        (profile != null && !ProfileModel.fromJson(profile.toJson()).valid)) {
      throw const FormatException('Inconsistent or incomplete saved profile.');
    }
    return ProfileSnapshot(
        ProfileStateEntity(version: 1, completed: completed), draft, profile);
  }

  Map<String, dynamic> toJson() => {
    'version': state.version,
    'completed': state.completed,
    'draft': draft.toJson(),
    'profile': profile?.toJson(),
  };
}
