import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/data/datasources/profile_records_data_source.dart';
import '../../../profile/presentation/screens/body_measurement_screens.dart';
import '../../../profile/presentation/screens/fitness_assessment_screens.dart';
import '../../../profile/presentation/screens/personal_information_screen.dart';
import '../../../profile/presentation/screens/progress_goals_settings_screens.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../profile/presentation/state/profile_store.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.store});
  final ProfileStore store;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;
  LocalProfile get p => widget.store.profile!;
  final ProfileRecordsDataSource _records = ProfileRecordsDataSource();

  Future<void> _edit() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PersonalInformationScreen(
          store: widget.store,
          onSaved: () { if (mounted) setState(() {}); },
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  void _openDestination(String destination) {
    final Widget screen = switch (destination) {
      'Personal Information' => PersonalInformationScreen(store: widget.store, onSaved: () { if (mounted) setState(() {}); }),
      'Fitness Assessment' => FitnessAssessmentScreen(records: _records),
      'Body Measurements' => BodyMeasurementsScreen(records: _records, profile: p),
      'Progress' => ProgressOverviewScreen(records: _records),
      'Goals' => GoalsOverviewScreen(records: _records),
      _ => const ProfileSettingsScreen(),
    };
    Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (_) => screen))
        .then((_) { if (mounted) setState(() {}); });
  }

  @override
  Widget build(BuildContext context) {
    final measurements = _records.measurements();
    if (_tab == 3) {
      return ProfileScreen(
        profile: p,
        selectedTab: _tab,
        onEditProfile: _edit,
        onTabSelected: (index) => setState(() => _tab = index),
        onOpenDestination: _openDestination,
        latestMeasurement: measurements.isEmpty ? null : measurements.first.weightKg,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text(
          ['Home', 'Training', 'Explore', 'Profile'][_tab],
          style: const TextStyle(fontWeight: FontWeight.w700),
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Starting Goal: ${p.goal ?? "Not set"}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Experience Level: ${p.level ?? "Not set"}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.secondary,
                          ),
                        ),
                        if (p.weight.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Current Weight: ${p.weight} kg',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No workouts yet.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Workout planning will be available here as the app grows.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ] else if (_tab == 1) ...[
                  const Icon(
                    Icons.fitness_center,
                    size: 56,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Workout planning is not implemented yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Optional AI form tracking will be available inside Workout.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ] else if (_tab == 2) ...[
                  const Icon(
                    Icons.insights,
                    size: 56,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Progress tracking will appear here after workout sessions are completed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: AppColors.surfaceContainerLow,
        indicatorColor: AppColors.primary,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center, color: Colors.white),
            label: 'Training',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: Colors.white),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.white),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
