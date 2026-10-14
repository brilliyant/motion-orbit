import 'package:objectbox/objectbox.dart';

@Entity()
class ProfileBoxEntity {
  @Id()
  int id;

  @Unique()
  String key;

  String value;

  DateTime updatedAt;

  ProfileBoxEntity({
    this.id = 0,
    required this.key,
    required this.value,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();
}

