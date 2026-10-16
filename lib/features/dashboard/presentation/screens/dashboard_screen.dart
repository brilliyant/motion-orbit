import 'package:flutter/material.dart';

import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../profile/data/datasources/profile_records_data_source.dart';
import '../../../body_measurements/presentation/screens/body_measurement_screens.dart';
import '../../../body_measurements/data/repositories/body_measurement_repository_impl.dart';
import '../../../body_measurements/domain/usecases/body_measurement_use_cases.dart';
import '../../../fitness_assessment/presentation/screens/fitness_assessment_screens.dart';
import '../../../personal_information/presentation/screens/personal_information_screen.dart';
import '../../../progress/presentation/screens/progress_overview_screen.dart';
import '../../../goals/presentation/screens/goals_screens.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../profile/presentation/state/profile_store.dart';
import '../../../settings/presentation/state/settings_store.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.store,
    required this.settingsStore,
  });
  final ProfileStore store;
  final SettingsStore settingsStore;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;
  UserProfile get p => widget.store.profile!;
  final ProfileRecordsDataSource _records = ProfileRecordsDataSource();
  late final BodyMeasurementRepositoryImpl _measurementRepository =
      BodyMeasurementRepositoryImpl(records: _records);
  late final GetBodyMeasurements _getMeasurements =
      GetBodyMeasurements(_measurementRepository);
  late final SaveBodyMeasurement _saveMeasurement =
      SaveBodyMeasurement(_measurementRepository);

  @override
  void initState() {
    super.initState();
    _records.seedSampleMeasurementIfEmpty();
  }

  double? get _latestWeight {
    final values = _records.measurements().where(
      (item) => item.weightKg != null,
    );
    return values.isEmpty ? null : values.first.weightKg;
  }

  Future<double?> _openBodyMeasurements() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BodyMeasurementsScreen(
          getMeasurements: _getMeasurements,
          saveMeasurement: _saveMeasurement,
          profile: p,
        ),
      ),
    );
    if (mounted) setState(() {});
    return _latestWeight;
  }

  Future<void> _reloadProfile() async {
    await widget.store.load();
    if (mounted) setState(() {});
  }

  void _resetToOnboarding() {
    widget.store.profile = null;
    widget.store.draft = UserProfile();
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (_) => OnboardingScreen(
          store: widget.store,
          settingsStore: widget.settingsStore,
        ),
      ),
      (_) => false,
    );
  }

  Future<void> _edit() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PersonalInformationScreen(
          store: widget.store,
          latestWeight: _latestWeight,
          onOpenMeasurements: _openBodyMeasurements,
          onSaved: () {
            if (mounted) setState(() {});
          },
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  void _openDestination(String destination) {
    final Widget screen = switch (destination) {
      'Personal Information' => PersonalInformationScreen(
        store: widget.store,
        latestWeight: _latestWeight,
        onOpenMeasurements: _openBodyMeasurements,
        onSaved: () {
          if (mounted) setState(() {});
        },
      ),
      'Fitness Assessment' => FitnessAssessmentScreen(records: _records),
      'Body Measurements' => BodyMeasurementsScreen(
        getMeasurements: _getMeasurements,
        saveMeasurement: _saveMeasurement,
        profile: p,
      ),
      'Progress' => ProgressOverviewScreen(records: _records),
      'Goals' => GoalsOverviewScreen(records: _records),
      'Settings' => ProfileSettingsScreen(
        settingsStore: widget.settingsStore,
        onProfileReset: _resetToOnboarding,
        onProfileRestored: _reloadProfile,
        onOpenAssessments: () => _openDestination('Fitness Assessment'),
      ),
      _ => ProfileSettingsScreen(
        settingsStore: widget.settingsStore,
        onProfileReset: _resetToOnboarding,
        onProfileRestored: _reloadProfile,
        onOpenAssessments: () => _openDestination('Fitness Assessment'),
      ),
    };
    Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (_) => screen))
        .then((_) {
          if (mounted) setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final measurements = _records.measurements();
    if (_tab == 3) {
      return ProfileScreen(
        profile: p,
        selectedTab: _tab,
        onEditProfile: _edit,
        onTabSelected: (index) => setState(() => _tab = index),
        onOpenDestination: _openDestination,
        latestMeasurement: measurements.isEmpty
            ? null
            : measurements.first.weightKg,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          ['Home', 'Training', 'Explore', 'Profile'][_tab],
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_tab == 0) ...[
                  Text(
                    p.name.trim().isEmpty
                        ? 'Welcome to Motion Orbit'
                        : 'Welcome, ${p.name.trim()}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Starting Goal: ${p.goal ?? "Not set"}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Experience Level: ${p.level ?? "Not set"}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.secondary,
                          ),
                        ),
                        if (p.weight.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Current Weight: ${p.weight} kg',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No workouts yet.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Workout planning will be available here as the app grows.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ] else if (_tab == 1) ...[
                  Icon(Icons.fitness_center, size: 56, color: colors.secondary),
                  const SizedBox(height: 16),
                  Text(
                    'Workout planning is not implemented yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Optional AI form tracking will be available inside Workout.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ] else if (_tab == 2) ...[
                  Icon(Icons.insights, size: 56, color: colors.secondary),
                  const SizedBox(height: 16),
                  Text(
                    'Progress tracking will appear here after workout sessions are completed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
      ),
    );
  }
}
