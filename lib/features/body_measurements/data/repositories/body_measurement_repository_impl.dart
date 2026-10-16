import '../../../profile/data/datasources/profile_records_data_source.dart';
import '../../../profile/data/models/profile_records.dart';
import '../../domain/entities/body_measurement.dart';
import '../../domain/repositories/body_measurement_repository.dart';

class BodyMeasurementRepositoryImpl implements BodyMeasurementRepository {
  BodyMeasurementRepositoryImpl({required this.records});
  final ProfileRecordsDataSource records;

  @override
  List<BodyMeasurement> getMeasurements() => records.measurements().map((item) => BodyMeasurement(
    id: item.id, date: item.date, weightKg: item.weightKg, waistCm: item.waistCm,
    chestCm: item.chestCm, hipsCm: item.hipsCm, leftArmCm: item.leftArmCm,
    rightArmCm: item.rightArmCm, leftThighCm: item.leftThighCm,
    rightThighCm: item.rightThighCm, bodyFatPercent: item.bodyFatPercent,
    muscleMassKg: item.muscleMassKg, bodyFatSource: item.bodyFatSource, note: item.note,
  )).toList();

  @override
  void saveMeasurement(BodyMeasurement measurement) => records.saveMeasurement(MeasurementRecord(
    id: measurement.id, date: measurement.date, weightKg: measurement.weightKg,
    waistCm: measurement.waistCm, chestCm: measurement.chestCm, hipsCm: measurement.hipsCm,
    leftArmCm: measurement.leftArmCm, rightArmCm: measurement.rightArmCm,
    leftThighCm: measurement.leftThighCm, rightThighCm: measurement.rightThighCm,
    bodyFatPercent: measurement.bodyFatPercent, muscleMassKg: measurement.muscleMassKg,
    bodyFatSource: measurement.bodyFatSource, note: measurement.note,
  ));
}
