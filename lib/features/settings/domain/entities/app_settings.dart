class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.units = MeasurementUnits.metric,
  });

  final AppThemeMode themeMode;
  final MeasurementUnits units;

  AppSettings copyWith({AppThemeMode? themeMode, MeasurementUnits? units}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        units: units ?? this.units,
      );
}

enum AppThemeMode { system, light, dark }

enum MeasurementUnits { metric, imperial }

class LocalDataSummary {
  const LocalDataSummary({
    required this.profileSaved,
    required this.assessments,
    required this.measurements,
    required this.goals,
  });

  final bool profileSaved;
  final int assessments;
  final int measurements;
  final int goals;

  int get totalRecords => assessments + measurements + goals;
}
