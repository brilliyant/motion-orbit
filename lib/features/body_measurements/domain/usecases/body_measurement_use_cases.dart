import '../entities/body_measurement.dart';
import '../repositories/body_measurement_repository.dart';

class GetBodyMeasurements {
  const GetBodyMeasurements(this.repository);
  final BodyMeasurementRepository repository;
  List<BodyMeasurement> call() => repository.getMeasurements();
}

class SaveBodyMeasurement {
  const SaveBodyMeasurement(this.repository);
  final BodyMeasurementRepository repository;
  void call(BodyMeasurement measurement) =>
      repository.saveMeasurement(measurement);
}
