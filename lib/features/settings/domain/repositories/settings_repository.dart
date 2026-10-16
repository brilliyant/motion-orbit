import '../entities/app_settings.dart';

abstract interface class SettingsRepository {
  Future<AppSettings> loadSettings();
  Future<void> saveThemeMode(AppThemeMode mode);
  Future<void> saveUnits(MeasurementUnits units);
  Stream<LocalDataSummary> watchLocalData();
  String exportJsonBackup();
  String exportCsvBackup();
  Future<void> restoreJsonBackup(String backup);
  Future<void> resetLocalProfileData();
}
