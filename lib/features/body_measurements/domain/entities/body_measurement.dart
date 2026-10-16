class BodyMeasurement {
  const BodyMeasurement({
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
    this.bodyFatPercent,
    this.muscleMassKg,
    this.bodyFatSource = 'Manual Entry',
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
  final double? bodyFatPercent;
  final double? muscleMassKg;
  final String bodyFatSource;
  final String note;
}
