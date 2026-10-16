import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class LoadSettings {
  const LoadSettings(this.repository);
  final SettingsRepository repository;
  Future<AppSettings> call() => repository.loadSettings();
}

class SaveThemeMode {
  const SaveThemeMode(this.repository);
  final SettingsRepository repository;
  Future<void> call(AppThemeMode mode) => repository.saveThemeMode(mode);
}

class SaveMeasurementUnits {
  const SaveMeasurementUnits(this.repository);
  final SettingsRepository repository;
  Future<void> call(MeasurementUnits units) => repository.saveUnits(units);
}

class WatchLocalData {
  const WatchLocalData(this.repository);
  final SettingsRepository repository;
  Stream<LocalDataSummary> call() => repository.watchLocalData();
}

class ExportJsonBackup {
  const ExportJsonBackup(this.repository);
  final SettingsRepository repository;
  String call() => repository.exportJsonBackup();
}

class ExportCsvBackup {
  const ExportCsvBackup(this.repository);
  final SettingsRepository repository;
  String call() => repository.exportCsvBackup();
}

class RestoreJsonBackup {
  const RestoreJsonBackup(this.repository);
  final SettingsRepository repository;
  Future<void> call(String backup) => repository.restoreJsonBackup(backup);
}

class ResetLocalProfileData {
  const ResetLocalProfileData(this.repository);
  final SettingsRepository repository;
  Future<void> call() => repository.resetLocalProfileData();
}
