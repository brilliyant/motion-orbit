import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/settings_use_cases.dart';

class SettingsStore extends ChangeNotifier {
  SettingsStore({
    required this.loadSettings,
    required this.saveThemeMode,
    required this.saveUnits,
    required this.watchLocalData,
    required this.exportJsonBackup,
    required this.exportCsvBackup,
    required this.restoreJsonBackup,
    required this.resetLocalProfileData,
  });

  final LoadSettings loadSettings;
  final SaveThemeMode saveThemeMode;
  final SaveMeasurementUnits saveUnits;
  final WatchLocalData watchLocalData;
  final ExportJsonBackup exportJsonBackup;
  final ExportCsvBackup exportCsvBackup;
  final RestoreJsonBackup restoreJsonBackup;
  final ResetLocalProfileData resetLocalProfileData;
  StreamSubscription<LocalDataSummary>? _subscription;

  AppSettings settings = const AppSettings();
  LocalDataSummary? localData;
  bool loaded = false;
  bool saving = false;

  Future<void> load() async {
    settings = await loadSettings();
    loaded = true;
    notifyListeners();
    await _subscription?.cancel();
    _subscription = watchLocalData().listen((value) {
      localData = value;
      notifyListeners();
    });
  }

  Future<void> setTheme(AppThemeMode mode) async {
    if (saving) return;
    final previous = settings;
    settings = settings.copyWith(themeMode: mode);
    saving = true;
    notifyListeners();
    try {
      await saveThemeMode(mode);
    } catch (_) {
      settings = previous;
      rethrow;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> setUnits(MeasurementUnits units) async {
    if (saving) return;
    final previous = settings;
    settings = settings.copyWith(units: units);
    saving = true;
    notifyListeners();
    try {
      await saveUnits(units);
    } catch (_) {
      settings = previous;
      rethrow;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  String createJsonBackup() => exportJsonBackup();

  String createCsvBackup() => exportCsvBackup();

  Future<void> restoreBackup(String backup) async {
    await restoreJsonBackup(backup);
    await load();
  }

  Future<void> resetProfileData() async {
    await resetLocalProfileData();
    localData = const LocalDataSummary(
      profileSaved: false,
      assessments: 0,
      measurements: 0,
      goals: 0,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
