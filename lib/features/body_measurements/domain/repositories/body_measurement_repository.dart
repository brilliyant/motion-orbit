import '../entities/body_measurement.dart';

abstract interface class BodyMeasurementRepository {
  List<BodyMeasurement> getMeasurements();
  void saveMeasurement(BodyMeasurement measurement);
}
