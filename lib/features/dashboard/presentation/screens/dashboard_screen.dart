import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import '../../../profile/data/models/profile_model.dart';
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

  Future<void> _edit() async {
    if (widget.store.draft.id != p.id) {
      widget.store.draft = LocalProfile.fromJson(p.toJson());
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OnboardingScreen(store: widget.store, editing: true),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text(
          ['Home', 'Workout', 'Progress', 'Profile'][_tab],
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
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name.trim().isEmpty ? 'Your Profile' : p.name.trim(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Goal: ${p.goal ?? "Not set"}',
                          style:
                              const TextStyle(color: AppColors.textSecondary),
                        ),
                        Text(
                          'Level: ${p.level ?? "Not set"}',
                          style:
                              const TextStyle(color: AppColors.textSecondary),
                        ),
                        if (p.height.isNotEmpty)
                          Text(
                            'Height: ${p.height} cm',
                            style: const TextStyle(
                                color: AppColors.textSecondary),
                          ),
                        if (p.weight.isNotEmpty)
                          Text(
                            'Weight: ${p.weight} kg',
                            style: const TextStyle(
                                color: AppColors.textSecondary),
                          ),
                        if (p.age != null)
                          Text(
                            'Age bracket: ${p.age}',
                            style: const TextStyle(
                                color: AppColors.textSecondary),
                          ),
                        if (p.location != null)
                          Text(
                            'Location: ${p.location}',
                            style: const TextStyle(
                                color: AppColors.textSecondary),
                          ),
                        if (p.equipment.isNotEmpty)
                          Text(
                            'Equipment: ${p.equipment.join(", ")}',
                            style: const TextStyle(
                                color: AppColors.textSecondary),
                          ),
                        if (p.days.isNotEmpty)
                          Text(
                            'Days: ${p.days.join(", ")}',
                            style: const TextStyle(
                                color: AppColors.textSecondary),
                          ),
                        if (p.duration != null)
                          Text(
                            'Duration: ${p.duration}',
                            style: const TextStyle(
                                color: AppColors.textSecondary),
                          ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Edit Onboarding Profile',
                          onPressed: _edit,
                        ),
                      ],
                    ),
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
            label: 'Workout',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights, color: Colors.white),
            label: 'Progress',
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

