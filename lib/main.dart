import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/profile/data/datasources/objectbox_data_source.dart';
import 'features/profile/data/datasources/profile_local_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/usecases/profile_use_cases.dart';
import 'features/profile/presentation/state/profile_store.dart';
import 'features/settings/data/datasources/settings_local_data_source.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/domain/usecases/settings_use_cases.dart';
import 'features/settings/presentation/state/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MotionOrbitObjectBox.initialize();
  final settingsRepository = SettingsRepositoryImpl(
    dataSource: SettingsLocalDataSource(),
  );
  final settingsStore = SettingsStore(
    loadSettings: LoadSettings(settingsRepository),
    saveThemeMode: SaveThemeMode(settingsRepository),
    saveUnits: SaveMeasurementUnits(settingsRepository),
    watchLocalData: WatchLocalData(settingsRepository),
    exportJsonBackup: ExportJsonBackup(settingsRepository),
    exportCsvBackup: ExportCsvBackup(settingsRepository),
    restoreJsonBackup: RestoreJsonBackup(settingsRepository),
    resetLocalProfileData: ResetLocalProfileData(settingsRepository),
  );
  await settingsStore.load();
  runApp(MainApp(settingsStore: settingsStore));
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    required this.settingsStore,
  });
  final SettingsStore settingsStore;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsStore,
      builder: (context, _) => MaterialApp(
        title: 'Motion Orbit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: switch (settingsStore.settings.themeMode) {
          AppThemeMode.system => ThemeMode.system,
          AppThemeMode.light => ThemeMode.light,
          AppThemeMode.dark => ThemeMode.dark,
        },
        home: StartupScreen(settingsStore: settingsStore),
      ),
    );
  }
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({
    super.key,
    required this.settingsStore,
  });
  final SettingsStore settingsStore;
  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  late final ProfileStore store;
  String? error;
  bool corrupt = false;
  @override
  void initState() {
    super.initState();
    final repository = ProfileRepositoryImpl(
      dataSource: ProfileLocalDataSourceImpl(),
    );
    store = ProfileStore(
      loadProfile: LoadProfile(repository),
      saveDraft: SaveProfileDraft(repository),
      completeProfile: CompleteProfile(repository),
      recoverProfile: RecoverProfile(repository),
    );
    _load();
  }

  Future<void> _load({bool recover = false}) async {
    setState(() {
      error = null;
      corrupt = false;
    });
    try {
      if (recover) await store.recover();
      await store.load();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => store.profile != null
              ? DashboardScreen(
                  store: store,
                  settingsStore: widget.settingsStore,
                )
              : OnboardingScreen(
                  store: store,
                  settingsStore: widget.settingsStore,
                ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        corrupt = e is FormatException;
        error = corrupt
            ? 'Your saved setup could not be read. Retry, or start a new setup. The unreadable data will be kept on this device.'
            : 'Local storage is unavailable. Please retry. Setup needs working local storage to save your profile.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: error == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(error!, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => _load(),
                      child: const Text('Retry'),
                    ),
                    if (corrupt)
                      TextButton(
                        onPressed: () => _load(recover: true),
                        child: const Text(
                          'Keep unreadable data and start new setup',
                        ),
                      ),
                  ],
                ),
        ),
      ),
    ),
  );
}
