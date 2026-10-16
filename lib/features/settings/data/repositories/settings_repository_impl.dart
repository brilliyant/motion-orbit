import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({required this.dataSource});

  final SettingsLocalDataSource dataSource;

  @override
  Future<AppSettings> loadSettings() => dataSource.readSettings();

  @override
  Future<void> saveThemeMode(AppThemeMode mode) =>
      dataSource.writeThemeMode(mode);

  @override
  Future<void> saveUnits(MeasurementUnits units) =>
      dataSource.writeUnits(units);

  @override
  Stream<LocalDataSummary> watchLocalData() => dataSource.watchLocalData();

  @override
  String exportJsonBackup() => dataSource.exportJsonBackup();

  @override
  String exportCsvBackup() => dataSource.exportCsvBackup();

  @override
  Future<void> restoreJsonBackup(String backup) =>
      dataSource.restoreJsonBackup(backup);

  @override
  Future<void> resetLocalProfileData() => dataSource.resetLocalProfileData();
}
